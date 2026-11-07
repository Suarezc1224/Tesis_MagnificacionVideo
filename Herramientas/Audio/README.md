# Excitacion de bocina para EVM/PVM

## Si MATLAB muestra Out of memory

Para una prueba pequena, ejecutar `preparar_video_ligero` en MATLAB desde
esta carpeta y seleccionar el original. Genera una copia de ancho maximo
480 pixeles y hasta 500 fotogramas consecutivos, leyendo y escribiendo uno
por uno. Necesita Image Processing Toolbox (`imresize`). No modifica el original.
La salida se guarda en `Data/Audio/VideoLigero` y su ruta aparece en consola.
Para elegir otro tramo:

```matlab
salida = preparar_video_ligero('F:\PRIVATE\M4ROOT\CLIP\Par_400.MP4',480,500,201);
```

Usar esa copia en la interfaz. Para el experimento de captura 1000 fps y
excitacion 400 Hz: Fs=1000, f1=380, f2=420, alpha=5, sigma=3 y octave.
Conservar los FPS originales de captura al configurar Fs: la copia mantiene
los FPS de reproduccion del archivo. No reduce temporalmente el muestreo.
500 fotogramas representan 0.5 segundos fisicos a 1000 fps.
La copia Motion JPEG es con perdida y sirve para diagnostico; la reduccion
espacial puede ocultar movimientos y no garantiza que toda maquina tenga RAM
suficiente. No sustituye la validacion del video original.

## Interfaz grafica (Windows)

Hacer doble clic en `Abrir_generador.bat`. Busca primero el Python incluido
con Codex y, si no existe, utiliza `py -3`.
Elegir frecuencia, duracion, amplitud digital y canal; pulsar **Play**.
**Detener**, Escape o cerrar la ventana detienen la salida. La interfaz no
reproduce nada al abrirse. Empieza en 40 Hz, 15 s y 5 % de amplitud.
Los WAV se conservan en `Data/Audio/Interfaz`. La generacion ocurre en segundo
plano; puede tardar unos segundos para tonos largos. Los cambios se aplican
al siguiente Play. La salida utilizada es la predeterminada de Windows.
Para registros JSON y secuencias de repeticiones, usar el script de consola.

Desde esta misma carpeta tambien se puede ejecutar:

```powershell
py -3 .\interfaz_tonos.py
```

Requiere Python 3.9 o posterior. Usa solo la biblioteca estandar.
Ejecutar desde la raiz del proyecto en PowerShell:

```powershell
python Herramientas/Audio/generar_tonos.py
python Herramientas/Audio/generar_tonos.py --frecuencias 40 --duracion 15 --reproducir
python Herramientas/Audio/generar_tonos.py --frecuencias 20 40 80 --duracion 10 --repeticiones 5 --reproducir
```

Si Windows utiliza el lanzador `py`, sustituir `python` por `py -3`.
Sin `--reproducir` solo se crean WAV y un manifiesto JSON en Data/Audio.
Cada frecuencia se reproduce por separado, con rampas de 0.1 s y espera
de 5 s para preparar la camara. Ctrl+C detiene la reproduccion.
Un mismo WAV se reutiliza para las repeticiones. Las marcas de tiempo
registran solicitudes de software, no sincronizacion fisica con la camara.

## Conexion

Laptop (salida de auriculares o adaptador USB de audio) -> entrada de audio
del amplificador -> una bocina pasiva. La placa necesita fuente independiente.
Seleccionar esa salida como predeterminada en Windows antes de ejecutar.
El script utiliza el canal izquierdo; usar `--canal right` si se conecta la
bocina a la salida derecha. `--canal both` envia el tono a ambos canales,
pero NO autoriza a unir sus salidas electricas.

Verificar el chip, alimentacion, polaridad y serigrafia del HW-210 antes de
energizarlo. Si es una placa PAM8610 confirmada, seguir el esquema de esa
placa: conectar la bocina entre L+ y L- (o R+ y R-). No unir los negativos
de salida entre si ni a GND o a la laptop. La conexion de masa de la entrada
de audio es diferente de los terminales negativos de la bocina.
No conectar la salida amplificada al puerto de audio de la laptop.

Fuente del fabricante del chip (no identifica por si sola la placa):
https://www.diodes.com/datasheet/download/PAM8610.pdf

## Procedimiento experimental

1. Cablear con la alimentacion desconectada y bajar volumen de laptop y placa.
2. Empezar con 40 Hz y amplitud digital 0.05; subir volumen gradualmente.
3. La amplitud digital no especifica voltaje, potencia o desplazamiento.
   No compensar la ausencia de sonido a baja frecuencia subiendo mucho el nivel:
   una bocina pequena puede tener poca respuesta y excursion excesiva.
4. Desactivar mejoras de audio, ecualizacion, sonido espacial y notificaciones.
5. Fijar la bocina en una base independiente del tripode. Filmar el cono de
   forma oblicua para que su desplazamiento tenga una componente en la imagen.
   Un punto de textura ligero ayuda; no cargar el cono con objetos pesados.
6. Grabar referencia sin excitacion y luego una toma por tono/repeticion.
7. Analizar el tramo estable, excluyendo rampas y transitorios del montaje.
   La frecuencia programada no sustituye la medida de vibracion: pueden aparecer
   armonicos y resonancias. Para amplitud absoluta usar referencia independiente.
8. En HFR usar los fps de captura para el filtro temporal, no los fps de
   reproduccion del archivo. El script no activa ni sincroniza la Sony.
