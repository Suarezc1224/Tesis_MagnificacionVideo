# Revisión de citas y bibliografía

- Entradas finales: 54.
- Obras citadas en archivos TeX (incluidos anexos): 34.
- Comandos de cita normalizados: 36.
- Entradas duplicadas por DOI o título: 0.
- Claves de cita activas sin entrada: 0.
- Validación real con BibTeX y el estilo IEEEtranEC: correcta, sin errores ni advertencias bibliográficas.
- Claves repetidas en un mismo comando: 0.

## Correcciones relevantes

- Se unificaron las variantes de clave entre los capítulos; citar una misma obra en varios párrafos mantiene una sola entrada bibliográfica.
- Jerk-Aware Video Acceleration Magnification es de 2018, mientras que Video Magnification in the Wild corresponde a 2019; se separaron las entradas y sus citas.
- Takeda2022 y TakedaBVMF identifican Bilateral Video Magnification Filter y comparten una entrada.
- Se corrigieron título, autores y DOI de la revisión de Ahmed de 2023; se completó el DOI de Zang de 2026 y se distinguió la publicación de Flotho de 2023 del preprint de 2022.
- No se identificó la referencia Nandana2020; el pasaje sobre estudios comparativos del capítulo 1 se vinculó al estudio existente y verificable de Yadav et al. (2020), sin crear una entrada ficticia ni tratar ambas claves como sinónimos.
- Se añadieron los trabajos citados de Zhang, Takeda, Yang y CASME II que faltaban, además de dos fuentes oficiales de hardware para el archivo de anexos.

## Límites y observaciones

- La auditoría estructural cubre todas las entradas del BibTeX y todos los archivos TeX. La comprobación externa de metadatos se centró en las referencias faltantes o inconsistentes; no equivale a una revisión de cada afirmación científica del texto.
- Apendices.tex no está incluido actualmente en main.tex. Su tabla rotulada ESP32-S3-WROOM-1 contiene características de otra familia (LX6 y Bluetooth 4.2); se resolvió su cita a la guía existente, pero queda pendiente revisar esa tabla técnica y la procedencia exacta de las imágenes.
- Se conservan las referencias no citadas como biblioteca de consulta; BibTeX solo incorpora las citadas al documento, salvo uso de nocite.

## Archivos con citas normalizadas

- `sections\01_Capitulo1_Generalidades.tex`
- `sections\02_Capitulo2_MarcoTeorico.tex`
- `sections\03_Capitulo3_Metodologia.tex`
- `sections\Apendices.tex`

## Entradas conservadas sin cita activa

- `bennett2016adaptive`
- `bennett2017adaptive`
- `bharadwaj2013computationally`
- `cai2022bayesian`
- `das2021detecting`
- `fahmy2017micro`
- `flotho2023lagrangian`
- `javaid2013video`
- `jimenez2023modelo`
- `kooij2016depth`
- `kumar2018small`
- `lauridsen2019extracting`
- `leng2019seeing`
- `liu2014enhanced`
- `sarode2014video`
- `verma2018edge`
- `wadhwa2017eulerian`
- `wu2014linear`
- `yu2017region`
- `zhang2022motion`
