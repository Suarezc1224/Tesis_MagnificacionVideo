@echo off
setlocal
cd /d "%~dp0"
set "TONE_PYTHON=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if exist "%TONE_PYTHON%" (
    "%TONE_PYTHON%" interfaz_tonos.py
    goto done
)
py -3 interfaz_tonos.py
:done
if errorlevel 1 (
    echo No se pudo abrir la interfaz. Se necesita Python 3 con tkinter.
    pause
)
endlocal
