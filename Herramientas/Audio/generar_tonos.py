"""Generador de excitacion senoidal para experimentos EVM/PVM. Python 3.9+."""

import argparse
from array import array
from datetime import datetime, timezone
import json
import math
from pathlib import Path
import sys
import time
import wave


def finite_float(value):
    number = float(value)
    if not math.isfinite(number):
        raise argparse.ArgumentTypeError("El valor debe ser finito.")
    return number


def write_tone(path, frequency, duration, amplitude, rate, channel, fade):
    """WAV PCM16 estereo; rampas cosenoidales evitan saltos en los extremos."""
    frames = round(duration * rate)
    ramp = min(round(fade * rate), frames // 2)
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(rate)
        for start in range(0, frames, 8192):
            block = array("h")
            for i in range(start, min(start + 8192, frames)):
                edge = min(i, frames - 1 - i)
                envelope = (0.5 - 0.5 * math.cos(math.pi * edge / ramp)
                            if ramp and edge < ramp else 1.0)
                sample = round(32767 * amplitude * envelope
                               * math.sin(2 * math.pi * frequency * i / rate))
                block.extend((sample if channel != "right" else 0,
                              sample if channel != "left" else 0))
            if sys.byteorder != "little":
                block.byteswap()
            wav.writeframesraw(block.tobytes())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--frecuencias", nargs="+", type=finite_float, default=[40.0],
                        help="Frecuencias en Hz, reproducidas por separado (default: 40).")
    parser.add_argument("--duracion", type=finite_float, default=10.0,
                        help="Segundos por tono (default: 10).")
    parser.add_argument("--amplitud", type=finite_float, default=0.05,
                        help="Amplitud digital de pico entre 0 y 1 (default: 0.05). No son watts.")
    parser.add_argument("--muestreo", type=int, choices=[44100, 48000], default=48000)
    parser.add_argument("--canal", choices=["left", "right", "both"], default="left")
    parser.add_argument("--rampa", type=finite_float, default=0.1,
                        help="Duracion de cada rampa en segundos (default: 0.1).")
    parser.add_argument("--repeticiones", type=int, default=1)
    parser.add_argument("--pausa", type=finite_float, default=3.0)
    parser.add_argument("--espera", type=finite_float, default=5.0,
                        help="Espera antes de cada reproduccion para preparar la camara.")
    parser.add_argument("--salida", type=Path,
                        default=Path(__file__).resolve().parents[2] / "Data" / "Audio")
    parser.add_argument("--reproducir", action="store_true",
                        help="Reproducir por la salida predeterminada de Windows.")
    args = parser.parse_args()
    if not 0 < args.amplitud <= 1:
        parser.error("--amplitud debe estar entre 0 (excluido) y 1.")
    if not 0 < args.duracion <= 600:
        parser.error("--duracion debe estar entre 0 (excluido) y 600 segundos.")
    if not 0 < args.rampa <= args.duracion / 2:
        parser.error("--rampa debe ser positiva y no superar la mitad de --duracion.")
    if args.repeticiones < 1 or min(args.pausa, args.espera) < 0:
        parser.error("Repeticiones >= 1 y pausas/espera >= 0.")
    if any(not 0 < f < args.muestreo / 2 for f in args.frecuencias):
        parser.error("Cada frecuencia debe ser positiva y menor que muestreo/2.")
    if args.reproducir and sys.platform != "win32":
        parser.error("La reproduccion integrada requiere Windows; puedes generar WAV sin ella.")
    session = args.salida / datetime.now().strftime("sesion_%Y%m%d_%H%M%S_%f")
    session.mkdir(parents=True, exist_ok=False)
    config = vars(args).copy()
    config["salida"] = str(args.salida)
    manifest = {"creado_utc": datetime.now(timezone.utc).isoformat(),
                "configuracion": config,
                "nota": "Frecuencia de excitacion nominal; no mide vibracion ni sincroniza camara.",
                "tomas": []}
    manifest_path = session / "sesion.json"

    def save():
        manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")

    save()
    try:
        for index, frequency in enumerate(args.frecuencias, 1):
            filename = f"tono_{index:02d}_{frequency:g}Hz.wav"
            path = session / filename
            write_tone(path, frequency, args.duracion, args.amplitud,
                       args.muestreo, args.canal, args.rampa)
            for repetition in range(1, args.repeticiones + 1):
                take = {"archivo": filename, "frecuencia_hz": frequency,
                        "repeticion": repetition, "estado": "generado"}
                manifest["tomas"].append(take)
                save()
                print(f"{frequency:g} Hz | toma {repetition} | {path}", flush=True)
                if args.reproducir:
                    import winsound
                    print(f"Preparar camara: espera {args.espera:g} s. Ctrl+C detiene.", flush=True)
                    time.sleep(args.espera)
                    take["estado"] = "reproduciendo"
                    take["solicitud_reproduccion_utc"] = datetime.now(timezone.utc).isoformat()
                    save()
                    winsound.PlaySound(str(path), winsound.SND_FILENAME | winsound.SND_ASYNC
                                       | winsound.SND_NODEFAULT)
                    time.sleep(round(args.duracion * args.muestreo) / args.muestreo)
                    winsound.PlaySound(None, 0)
                    take["estado"] = "reproduccion_finalizada_sin_verificacion_fisica"
                    save()
                    time.sleep(args.pausa)
    except KeyboardInterrupt:
        manifest["interrumpido"] = True
        print("\nSesion interrumpida.")
    finally:
        if args.reproducir:
            import winsound
            winsound.PlaySound(None, 0)
        save()
    print(f"Parametros: {manifest_path}")


if __name__ == "__main__":
    main()
