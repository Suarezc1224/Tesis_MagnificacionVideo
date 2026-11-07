# Magnificación de video con pirámides de Riesz (MATLAB)

Implementación local del procesamiento en línea descrito por Wadhwa, Rubinstein,
Durand y Freeman (ICCP 2014), usando la pirámide espacial y los filtros MATLAB
oficiales del MIT. El controlador de video y las funciones de fase son una
implementación de integración de este proyecto; no son código publicado por el MIT.
Este método magnifica fase dentro de una banda temporal, no aceleración.

## Inicio rápido

Requisitos: MATLAB R2020b o posterior, Image Processing Toolbox y Signal
Processing Toolbox. No requiere EVM, PVM, MEX ni descargas adicionales.

Desde MATLAB, abre esta carpeta y ejecuta:

```matlab
demoRieszVideo
```

El selector permite elegir un video. Edita `alpha`, `lowHz` y `highHz` en el script
antes de ejecutarlo para adecuarlos a tu experimento. Son ejemplos, no frecuencias
estimadas automáticamente. La salida se guarda junto al video como `_riesz.avi`.

También puedes llamar directamente:

```matlab
addpath('C:\Users\joels\OneDrive\Escritorio\Tesis_MagnificacionVideo\Algoritmos\Riesz_Matlab');
info = rieszMagnifyVideo('C:\videos\entrada.mp4', ...
    'C:\videos\salida_riesz.avi',10,0.8,1.2);
```

Los tres valores finales son `alpha`, frecuencia inferior y frecuencia superior
(Hz). Debe cumplirse `0 < lowHz < highHz < fps/2`. Los FPS se leen del archivo.
`alpha=0` produce la reconstrucción espacial de referencia; la ganancia total de
desplazamiento ideal en banda es aproximadamente `1+alpha`, con la respuesta y
el retardo del filtro causal. No es una ganancia física calibrada.

Opciones:

```matlab
info = rieszMagnifyVideo('entrada.mp4','salida.mp4',5,1,3, ...
    'Sigma',2,'Levels',[2 3],'Overwrite',false,'Verbose',true);
```

- `Sigma`: desviación del suavizado gaussiano, en píxeles de cada nivel (2).
- `Levels`: bandas a magnificar, de fina a gruesa. Vacío selecciona todas excepto
  el residual paso bajo. Cada fotograma determina la cantidad de niveles; la
  descomposición oficial se detiene cuando alguna dimensión es menor que 10.
- `Overwrite`: permite reemplazar una salida existente (por defecto `false`).
- `Verbose`: muestra progreso cada 100 fotogramas y al terminar.

No añadas `genpath` de todos los algoritmos: las funciones originales están en
`private/` para evitar conflictos con las herramientas de EVM/PVM.

## Archivos

- `rieszMagnifyVideo.m`: lectura, procesamiento progresivo y escritura de video.
- `rieszInitialize.m`, `rieszProcessFrame.m`: interfaz para integrar el método en
  otra aplicación. Reciben imágenes grises `single`/`double`, idealmente en [0,1].
  Inicializa con el primer fotograma y procesa desde el segundo conservando estado.
- `private/`: funciones de fase y copias de las cinco rutinas originales necesarias.
  `filterTaps.m` se llama `FilterTaps.m` en esta copia para coincidir con el nombre
  declarado por los autores. El contenido original se conserva.
- `official/RieszPyrSupplemental/`: paquete extraído sin modificar, con README,
  demostración espacial, filtros, documentación y videos de los autores.
- `official/RieszPyrSupplemental.zip`: archivo original descargado.
- `docs/`: artículo, informe cuaterniónico y pseudocódigo oficiales.
- `tests/runRieszTests.m`: validación numérica y procesamiento de video sintético.

## Correspondencia con el pseudocódigo

1. Pirámide oficial de cada fotograma y convoluciones Riesz aproximadas de tres
   coeficientes en X/Y (`rieszDecompose`).
2. Diferencia de fase cuaterniónica entre fotogramas consecutivos, suponiendo
   orientación local aproximadamente constante (`rieszPhaseDifference`).
3. Acumulación de fase y Butterworth pasabanda causal `butter(1,...)`. Este diseño
   pasabanda da tres coeficientes y dos registros, como el pseudocódigo.
4. Suavizado gaussiano ponderado por amplitud; no se omite.
5. Multiplicación por `alpha`, desplazamiento cuaterniónico y parte real.
6. Conservación del residual actual y reconstrucción con `reconNewPyr` oficial.

Decisiones numéricas de integración: `atan2` en lugar de `acos` para la fase;
límites explícitos para divisiones nulas; extensión simétrica en Riesz/suavizado;
gaussiana truncada a tres sigmas. Los bordes de análisis/reconstrucción se mantienen
como en el paquete oficial. El primer fotograma se escribe con su reconstrucción,
sin fase añadida, para preservar cantidad de fotogramas y duración.

En RGB se modifica luminancia YIQ y se conserva la crominancia. Se recorta a [0,1]
antes de codificar a 8 bits. AVI usa Motion JPEG (calidad 95); MP4/M4V usa MPEG-4
y requiere dimensiones pares. El video de salida no incluye audio. El video debe
tener muestreo temporal regular; no se corrigen fotogramas perdidos ni tiempos
irregulares. El filtro causal presenta transitorio inicial y retardo de fase.
La pirámide oficial tiene error de reconstrucción aproximado: `alpha=0` no implica
identidad exacta píxel a píxel. Amplificaciones altas pueden producir artefactos.

## Verificación

```matlab
addpath('tests');
results = runRieszTests;
```

Verifica reconstrucción, estabilidad en negro y escena estática, ganancia de
desplazamiento sintético en X/Y frente a la respuesta ideal del filtro (tolerancia
relativa de 15% por las aproximaciones espaciales), lectura/escritura
RGB con dimensiones impares, FPS, cantidad de fotogramas y validación de entradas.
Escribe videos y resultados en `tests/output/` (excluido de Git).

## Fuentes y atribución

Wadhwa, N., Rubinstein, M., Durand, F. y Freeman, W. T. (2014).
*Riesz Pyramids for Fast Phase-Based Video Magnification*. ICCP.
DOI: https://doi.org/10.1109/ICCPHOT.2014.6831820

- Proyecto: https://people.csail.mit.edu/nwadhwa/riesz-pyramid/
- Paquete: https://people.csail.mit.edu/nwadhwa/riesz-pyramid/RieszPyrSupplemental.zip
- Pseudocódigo: https://people.csail.mit.edu/nwadhwa/riesz-pyramid/pseudocode.pdf
- Informe: https://people.csail.mit.edu/nwadhwa/riesz-pyramid/quaternionMM.pdf

Se conservan los avisos de autoría de Neal Wadhwa y Eero Simoncelli en los archivos
originales. Este proyecto no concede una licencia adicional sobre el material
oficial ni representa una distribución oficial del MIT. Consulta los términos de
los autores para cualquier uso o redistribución.
