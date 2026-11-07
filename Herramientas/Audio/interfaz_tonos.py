"""Interfaz de escritorio para excitar una bocina desde Windows."""

import math
from pathlib import Path
import queue
import threading
import time
import tkinter as tk
from tkinter import ttk, messagebox
import winsound

from generar_tonos import write_tone


def parameters(frequency, duration, level):
    values = tuple(float(str(v).replace(",", ".")) for v in (frequency, duration, level))
    if not all(math.isfinite(v) for v in values):
        raise ValueError("Introduce valores finitos.")
    frequency, duration, level = values
    if not 1 <= frequency <= 20000:
        raise ValueError("La frecuencia debe estar entre 1 y 20000 Hz.")
    if not 0.2 <= duration <= 600:
        raise ValueError("La duración debe estar entre 0.2 y 600 segundos.")
    if not 0 < level <= 100:
        raise ValueError("La amplitud debe ser mayor que 0 y como máximo 100 %.")
    return frequency, duration, level / 100


class ToneApp:
    def __init__(self, root):
        self.root = root
        self.events = queue.Queue()
        self.token = 0
        self.timer = None
        self.started = 0
        self.duration = 0
        self.closed = False
        self.frequency = tk.StringVar(value="40")
        self.seconds = tk.StringVar(value="15")
        self.level = tk.StringVar(value="5")
        self.channel = tk.StringVar(value="Izquierdo")
        self.status = tk.StringVar(value="Listo. Pulsa Play para escuchar el tono.")
        root.title("Generador de tonos · EVM / PVM")
        root.minsize(520, 430)
        panel = ttk.Frame(root, padding=24)
        panel.pack(fill="both", expand=True)
        ttk.Label(panel, text="Excitación del parlante", font=("Segoe UI", 18, "bold")).pack(anchor="w")
        ttk.Label(panel, text="Tono senoidal · salida predeterminada de Windows").pack(anchor="w", pady=(4, 18))
        self.controls = []
        for label, variable in (("Frecuencia (Hz)", self.frequency),
                                ("Duración (segundos)", self.seconds),
                                ("Amplitud digital (%)", self.level)):
            row = ttk.Frame(panel)
            row.pack(fill="x", pady=5)
            ttk.Label(row, text=label, width=25).pack(side="left")
            entry = ttk.Entry(row, textvariable=variable, width=18)
            entry.pack(side="right")
            self.controls.append(entry)
        row = ttk.Frame(panel)
        row.pack(fill="x", pady=5)
        ttk.Label(row, text="Canal de audio").pack(side="left")
        self.channels = ttk.Combobox(row, textvariable=self.channel, state="readonly",
                                    values=["Izquierdo", "Derecho", "Ambos"], width=16)
        self.channels.pack(side="right")
        buttons = ttk.Frame(panel)
        buttons.pack(fill="x", pady=(22, 12))
        self.play_button = ttk.Button(buttons, text="▶ Play", command=self.play)
        self.play_button.pack(side="left", expand=True, fill="x", padx=(0, 8))
        self.stop_button = ttk.Button(buttons, text="■ Detener", command=self.stop, state="disabled")
        self.stop_button.pack(side="left", expand=True, fill="x")
        self.progress = ttk.Progressbar(panel, maximum=100)
        self.progress.pack(fill="x", pady=8)
        ttk.Label(panel, textvariable=self.status, wraplength=470).pack(anchor="w", pady=8)
        ttk.Label(panel, wraplength=470, text="Empieza con volumen bajo. La amplitud digital no equivale a watts.\n"
                  "Los cambios se aplican al siguiente Play. Esc detiene el audio.").pack(anchor="w", pady=8)
        root.bind("<Escape>", lambda event: self.stop())
        root.protocol("WM_DELETE_WINDOW", self.close)
        root.after(50, self.poll)

    def busy(self, active):
        self.play_button.configure(state="disabled" if active else "normal")
        self.stop_button.configure(state="normal" if active else "disabled")
        for control in self.controls:
            control.configure(state="disabled" if active else "normal")
        self.channels.configure(state="disabled" if active else "readonly")

    def play(self):
        try:
            frequency, duration, amplitude = parameters(self.frequency.get(), self.seconds.get(), self.level.get())
        except ValueError as error:
            messagebox.showerror("Revisa los parámetros", str(error))
            return
        self.token += 1
        token = self.token
        self.busy(True)
        self.status.set("Preparando el tono…")
        self.progress["value"] = 0
        channel = {"Izquierdo": "left", "Derecho": "right", "Ambos": "both"}[self.channel.get()]

        def generate():
            try:
                from datetime import datetime
                folder = Path(__file__).resolve().parents[2] / "Data" / "Audio" / "Interfaz"
                folder.mkdir(parents=True, exist_ok=True)
                path = folder / (datetime.now().strftime("%Y%m%d_%H%M%S_%f") + f"_{frequency:g}Hz.wav")
                write_tone(path, frequency, duration, amplitude, 48000, channel, 0.1)
                self.events.put((token, path, duration, frequency, None))
            except Exception as error:
                self.events.put((token, None, duration, frequency, str(error)))

        threading.Thread(target=generate, daemon=True).start()

    def poll(self):
        if self.closed:
            return
        try:
            while True:
                token, path, duration, frequency, error = self.events.get_nowait()
                if token != self.token:
                    continue
                if error:
                    self.stop()
                    messagebox.showerror("No se pudo generar el tono", error)
                    continue
                try:
                    winsound.PlaySound(str(path), winsound.SND_FILENAME | winsound.SND_ASYNC | winsound.SND_NODEFAULT)
                except RuntimeError as error:
                    self.stop()
                    messagebox.showerror("Error de audio", str(error))
                    continue
                self.duration = duration
                self.started = time.monotonic()
                self.status.set(f"Reproduciendo {frequency:g} Hz durante {duration:g} s")
                self.tick()
        except queue.Empty:
            pass
        self.root.after(50, self.poll)

    def tick(self):
        elapsed = time.monotonic() - self.started
        self.progress["value"] = min(100, elapsed / self.duration * 100)
        if elapsed >= self.duration:
            self.timer = None
            self.stop("Finalizado. Puedes pulsar Play para repetir.", finished=True)
        else:
            self.timer = self.root.after(50, self.tick)

    def stop(self, message="Detenido.", finished=False):
        self.token += 1  # Descarta generaciones pendientes: nunca reproducir tras Detener.
        if self.timer is not None:
            self.root.after_cancel(self.timer)
            self.timer = None
        winsound.PlaySound(None, 0)
        self.busy(False)
        self.progress["value"] = 100 if finished else 0
        self.status.set(message)

    def close(self):
        self.stop()
        self.closed = True
        self.root.destroy()


if __name__ == "__main__":
    window = tk.Tk()
    ToneApp(window)
    window.mainloop()
