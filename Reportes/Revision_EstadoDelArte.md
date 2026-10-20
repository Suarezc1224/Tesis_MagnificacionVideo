# Incorporación del estado del arte

Se incorporaron los apartados 1 a 8 del PDF proporcionado, incluida la tabla comparativa de dieciséis trabajos. Se excluyeron el apartado 9, «Síntesis del estado del arte», la portada sobre redes 4G y el cierre de plantilla ajeno a la tesis.

El capítulo se guarda en `TT_Overleaft/sections/03_EstadoDelArte.tex` y se incluye en `main.tex` inmediatamente después del marco teórico y antes de metodología. La numeración de capítulos se obtiene automáticamente, sin cambiar los nombres de los archivos existentes.

## Correspondencia de referencias

| Referencia del PDF | Clave única en la tesis |
|---|---|
| 1. Wu et al. (2012) | `wu2012eulerian` |
| 2. Wadhwa et al. (2013) | `wadhwa2013phase` |
| 3. Wadhwa et al. (2014) | `wadhwa2014riesz` |
| 4. Elgharib et al. (2015) | `elgharib2015video` |
| 5. Zhang et al. (2017) | `zhang2017acceleration` |
| 6. Wu et al. (2018) | `wu2018pca` |
| 7. Takeda et al. (2018) | `takeda2018jerk` |
| 8. Takeda et al. (2019) | `takeda2019wild` |
| 9. Yadav et al. (2020) | `yadav2020performance` |
| 10. Śmieja et al. (2021) | `smieja2021motion` |
| 11. Takeda et al. (2022) | `takeda2022bilateral` |
| 12. Yang et al. (2023) | `yang2023adaptive` |
| 13. Ahmed et al. (2023) | `ahmed2023overview` |
| 14. Mattioli et al. (2023) | `mattioli2023breathing` |
| 15. Yang y Jiang (2024) | `yang2024phase` |
| 16. Zang et al. (2026) | `zang2026phase` |

Se reutilizaron catorce entradas ya presentes y se añadieron únicamente las de Śmieja y Mattioli, con autores, año, publicación y DOI contrastados en fuentes primarias. Se corrigió el DOI erróneo que tenía la entrada de PCA: el correcto es `10.1007/s11760-018-1282-0`.

Fuentes de comprobación específicas de esta incorporación:

- [PCA: página del editor Springer](https://link.springer.com/article/10.1007/s11760-018-1282-0).
- [Śmieja et al.: artículo publicado](https://www.mdpi.com/1424-8220/21/19/6572).
- [Mattioli et al.: página del editor](https://www.sciencedirect.com/science/article/pii/S1746809423005815).
- [Zhang et al.: repositorio oficial CVF](https://openaccess.thecvf.com/content_cvpr_2017/html/Zhang_Video_Acceleration_Magnification_CVPR_2017_paper.html).

Las demás identidades bibliográficas se conservaron de la revisión previa, contrastando su correspondencia con la lista del PDF. La asociación de una cita con una obra no equivale a una verificación exhaustiva de cada afirmación experimental; las valoraciones y limitaciones se presentan dentro del alcance de los estudios citados.

## Ajustes de integración

Se normalizaron acentos extraídos del PDF, se eliminaron dos párrafos repetidos y se corrigieron expresiones que alteraban el sentido técnico, como «eliminación» por «selección» de movimientos sutiles y «reducción del rendimiento» por «reducción del costo computacional». Se precisó que la revisión de Ahmed incluye implementaciones y comparaciones experimentales, de acuerdo con el resumen publicado.

La tabla se incorporó como `longtable`, con encabezados de continuación y terminadores explícitos de fila. Se añadieron al glosario las siglas PCA, IIR, FA, BVMF, RGOMP, PSNR, SSIM y RMSE cuando no estaban definidas.

La metodología contenía un cierre prematuro `\end{document}`, una bibliografía manual de Atoll y texto de otra plantilla. Ese fragmento se conservó en `Reportes/Borradores/Fragmento_plantilla_metodologia.txt` y se retiró del capítulo compilado para permitir el acceso a resultados, conclusiones y bibliografía central. No se revisó el contenido científico de esos capítulos posteriores.

## Validación final

- XeLaTeX y BibTeX completados correctamente; referencias resueltas y numeración de capítulos actualizada.
- Revisadas visualmente la apertura del capítulo y las tres partes de la tabla comparativa.
- Verificadas las dieciséis citas del capítulo, las cincuenta y cuatro claves únicas de la biblioteca, los terminadores de tabla y las definiciones del glosario.
