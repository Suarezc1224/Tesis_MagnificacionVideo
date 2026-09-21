# Magnificación de Video para la Detección de Movimientos Sutiles

Este repositorio contiene la arquitectura de código, referencias bibliográficas, datasets de video y documentación en LaTeX correspondientes al trabajo de titulación enfocado en el **diseño y análisis comparativo de métodos de magnificación de video (Eulerianos y de Fase) para la detección de vibraciones y movimientos sutiles**.

---

## 📁 Estructura del Repositorio

A continuación se detalla la organización de archivos y directorios del proyecto:

```text
.
├── Algoritmos/               # Códigos fuente e implementaciones en MATLAB
│   ├── EVM_Matlab/           # Implementación del método Eulerian Video Magnification
│   │   └── matlabPyrTools/   # Herramientas de pirámides espaciales y filtros (MEX/Tutoriales)
│   └── vidmag-master/        # Pipeline avanzado de magnificación de video
│       ├── Filters/          # Filtros temporales (Paso banda, Butterworth, FIR)
│       ├── Linear/           # Magnificación lineal espacio-temporal
│       ├── PhaseBased/       # Magnificación basada en fase y pirámide de Riesz
│       ├── pyrToolsExt/      # Extensiones para descomposición de imágenes/video
│       └── Util/             # Funciones auxiliares y de soporte
├── Data/                     # Datasets de prueba y resultados (Excluido de Git remoto)
│   └── Source and Result Videos/
│       └── results/          # Secuencias procesadas y videos magnificados
├── Referencias/              # Clasificación de literatura científica (.pdf, bibliografía)
│   ├── Eulerian/             # Publicaciones sobre enfoque Euleriano
│   ├── Phase/                # Publicaciones sobre magnificación basada en fase
│   ├── Metodos/              # Metodologías y comparativas
│   ├── SN/                   # Signal to Noise / Análisis de ruido
│   └── Otros/                # Documentación complementaria
├── Reportes/                 # Informes de avances, borradores e entregables
│   ├── Borradores/           # Notas de trabajo y borradores preliminares
│   ├── Chunchi-Suarez_DenunciaUIC/
│   └── Chunchi-Suarez_Reporte25/
└── TT_Overleaft/             # Proyecto principal en LaTeX (Overleaf) para el documento final
    ├── logos/                # Recursos gráficos institucionales
    ├── sections/             # Capítulos individuales (Introducción, Estado del Arte, etc.)
    └── etc/                  # Configuraciones y plantillas del documento

```

---

## 🛠️ Requisitos del Sistema

* **MATLAB**: R2020b o superior.
* **Toolboxes de MATLAB requeridas**:
* Image Processing Toolbox.
* Signal Processing Toolbox.
* System Identification Toolbox (para compilación de rutinas MEX en `matlabPyrTools`).


* **Compilador C/C++** (Opcional, para recompilar binarios en `matlabPyrTools/MEX` mediante `mex -setup`).
* **Compilador LaTeX** (MikTeX / TeX Live o integración directa con Overleaf).

---

## ⚠️ Nota sobre Control de Versiones (Git)

Debido a las restricciones de tamaño de GitHub (límite de 100 MB por archivo), la carpeta **`Data/`** ha sido agregada al archivo `.gitignore` para evitar la subida de videos de alta resolución (`.avi`) y archivos comprimidos de gran tamaño (`.zip`).

Si requieres acceder a los datasets de video completos, contacta al autor o revisa el repositorio institucional de libre acceso correspondiente.

---

## 📜 Autor y Créditos

* **Desarrollador / Autor**: Edgar Joel Suarez Jaigua
* **Institución**: Trabajo de Titulación - Análisis comparativo de métodos de magnificación de video.

```

---

### Cómo crearlo rápidamente en tu terminal (PowerShell)

Para guardar este archivo directamente en la raíz de tu proyecto de tesis, ejecuta el siguiente comando en PowerShell:

```powershell
Set-Content -Path "README.md" -Value @"
# Tesis: Magnificación de Video para la Detección de Movimientos Sutiles

Este repositorio contiene la arquitectura de código, referencias bibliográficas, datasets de video y documentación en LaTeX correspondientes al trabajo de titulación enfocado en el **diseño y análisis comparativo de métodos de magnificación de video (Eulerianos y de Fase) para la detección de vibraciones y movimientos sutiles**.

---

## 📁 Estructura del Repositorio

A continuación se detalla la organización de archivos y directorios del proyecto:

```text
.
├── Algoritmos/               # Códigos fuente e implementaciones en MATLAB
│   ├── EVM_Matlab/           # Implementación del método Eulerian Video Magnification
│   │   └── matlabPyrTools/   # Herramientas de pirámides espaciales y filtros (MEX/Tutoriales)
│   └── vidmag-master/        # Pipeline avanzado de magnificación de video
│       ├── Filters/          # Filtros temporales (Paso banda, Butterworth, FIR)
│       ├── Linear/           # Magnificación lineal espacio-temporal
│       ├── PhaseBased/       # Magnificación basada en fase y pirámide de Riesz
│       ├── pyrToolsExt/      # Extensiones para descomposición de imágenes/video
│       └── Util/             # Funciones auxiliares y de soporte
├── Data/                     # Datasets de prueba y resultados (Excluido de Git remoto)
│   └── Source and Result Videos/
│       └── results/          # Secuencias procesadas y videos magnificados
├── Referencias/              # Clasificación de literatura científica (.pdf, bibliografía)
│   ├── Eulerian/             # Publicaciones sobre enfoque Euleriano
│   ├── Phase/                # Publicaciones sobre magnificación basada en fase
│   ├── Metodos/              # Metodologías y comparativas
│   ├── SN/                   # Signal to Noise / Análisis de ruido
│   └── Otros/                # Documentación complementaria
├── Reportes/                 # Informes de avances, borradores e entregables
│   ├── Borradores/           # Notas de trabajo y borradores preliminares
│   ├── Chunchi-Suarez_DenunciaUIC/
│   └── Chunchi-Suarez_Reporte25/
└── TT_Overleaft/             # Proyecto principal en LaTeX (Overleaf) para el documento final
    ├── logos/                # Recursos gráficos institucionales
    ├── sections/             # Capítulos individuales (Introducción, Estado del Arte, etc.)
    └── etc/                  # Configuraciones y plantillas del documento

```

---

## 🛠️ Requisitos del Sistema

* **MATLAB**: R2020b o superior.
* **Toolboxes de MATLAB requeridas**:
* Image Processing Toolbox.
* Signal Processing Toolbox.
* System Identification Toolbox (para compilación de rutinas MEX en `matlabPyrTools`).


* **Compilador C/C++** (Opcional, para recompilar binarios en `matlabPyrTools/MEX` mediante `mex -setup`).
* **Compilador LaTeX** (MikTeX / TeX Live o integración directa con Overleaf).

---

## ⚠️ Nota sobre Control de Versiones (Git)

Debido a las restricciones de tamaño de GitHub (límite de 100 MB por archivo), la carpeta **`Data/`** ha sido agregada al archivo `.gitignore` para evitar la subida de videos de alta resolución (`.avi`) y archivos comprimidos de gran tamaño (`.zip`).

Si requieres acceder a los datasets de video completos, contacta al autor o revisa el repositorio institucional de libre acceso correspondiente.

---
