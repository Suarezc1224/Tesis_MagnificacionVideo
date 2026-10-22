# Validación de la integración

Ejecutada el 22 de octubre de 2026 con MATLAB R2024a
(24.1.0.2537033), en Windows. Resultado: **PASS**, sin advertencias en la
ejecución final. El analizador `checkcode` pasó para las funciones nuevas de
producción y el script de demostración.

| Comprobación | Resultado |
| --- | --- |
| Reconstrucción espacial, imagen sintética en [0,1], región interior | RMSE 0.00209655 |
| Fotogramas negros y escena estática con ganancia no nula | Finitos y estables |
| Desplazamiento sinusoidal X, 2 Hz, alpha=3 | Ganancia medida 3.57690 |
| Desplazamiento sinusoidal Y, 2 Hz, alpha=3 | Ganancia medida 3.57711 |
| Ganancia ideal del filtro para esa frecuencia | 3.97429 |
| AVI RGB de dimensiones impares | 40 fotogramas, 49 x 67, 30 FPS |
| MPEG-4 de dimensiones pares | 12 fotogramas, 48 x 64, 30 FPS |
| Validación de banda, niveles, sobrescritura y archivo de entrada/salida idéntico | PASS |
| Selección de niveles como vector columna | PASS |
| Identidad SHA-256 de las cinco rutinas oficiales usadas | Coinciden con el ZIP |

La prueba de ganancia admite 15% de diferencia respecto a la ganancia ideal
temporal debido a las aproximaciones espaciales. Estos valores corresponden a
una secuencia sintética específica, no a una calibración para videos reales.
El método conserva el carácter aproximado de la reconstrucción y de la
transformada de Riesz original; `alpha=0` no proporciona identidad exacta.

Para reproducir las pruebas, desde la carpeta Riesz_Matlab:

```matlab
addpath('tests');
runRieszTests;
```

La ejecución genera `tests/output/test_results.json`, un archivo MAT y videos
de entrada/salida. El registro final se encuentra en `matlab_validation.log`.
