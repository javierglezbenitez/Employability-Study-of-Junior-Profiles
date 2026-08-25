# Análisis de empleabilidad junior en tecnología

¿Qué factores marcan la diferencia entre estar empleado o no como perfil junior en tecnología? Análisis exploratorio en R sobre la encuesta de desarrolladores de Stack Overflow (73.462 registros).

## Objetivo

Identificar patrones reales (no percepciones) sobre qué distingue a los juniors empleados de los que siguen en búsqueda, usando datos públicos en vez de opiniones.

## Dataset

Encuesta de Stack Overflow Developer Survey, con variables como edad, nivel educativo, años de experiencia, país, tecnologías dominadas, salario previo y situación laboral (`Employed`).

## Hallazgos principales

1. **Experiencia**: el salto más grande en probabilidad de empleo ocurre entre 0 y 2 años de experiencia profesional; después la curva se aplana.
2. **Amplitud de stack**: los juniors empleados dominan de media casi el doble de tecnologías (16.6 vs 8.5) que los que no están empleados.
3. **Cloud + contenedores**: quienes dominan tanto tecnologías cloud (AWS/Azure/GCP) como contenedores (Docker/Kubernetes) tienen casi el doble de probabilidad de estar empleados (62.8%) frente a quienes no dominan ninguna de las dos (34.8%).
4. **España vs otros países**: España presenta la tasa de empleo junior más alta entre los 10 países con más muestra en el dataset (55.9%), por encima de EEUU, Reino Unido o Alemania.

## Tecnologías

R, dplyr, ggplot2, readr, stringr

## Cómo ejecutarlo

```r
install.packages(c("dplyr", "readr", "stringr", "ggplot2"))
source("analisis_empleabilidad.R")
```

Genera 4 gráficos en PNG: `grafico_experiencia.png`, `grafico_cloud_contenedores.png`, `grafico_paises.png` , `grafico_skills.png`.

## Autor

Javier González Benítez — [LinkedIn](www.linkedin.com/in/javier-gonzalez-benitez-78052838b)
