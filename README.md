# Análisis de Ventas y Desempeño de Tiendas

Este repositorio contiene un conjunto de scripts en R diseñados para analizar datos de ventas y evaluar el desempeño de tiendas. Los análisis cubren proporciones de ventas por país, cambios porcentuales en ventas, distribución de ventas por cliente, y el desempeño de tiendas. Los resultados se presentan en tablas y visualizaciones que pueden ser útiles para la toma de decisiones empresariales.

## Contenido del Repositorio

1. **Scripts en R:**
   - `prop_sales_by_country_by_year_month.R`: Calcula la proporción de ventas por país para cada mes entre 2013 y 2015. Genera un archivo CSV con los resultados.
   - `prop_changes_sales_by_country_by_year_month.R`: Calcula el cambio porcentual mensual en ventas por país. Genera un archivo CSV con los resultados.
   - `histogram_avg_sales_customer.R`: Crea un histograma de la variable `avg_sales_customer` para España y Francia. Genera una imagen PNG con el histograma.
   - `top_10_performance_stores_by_country.R`: Determina las tiendas en el top 10 de ventas y top 19 de clientes por país y crea una visualización de su desempeño. Genera una imagen PNG con la visualización.

2. **Resultados Generados:**
   - `prop_sales_by_country_by_year_month.csv`: Proporción de ventas por país y mes.
   - `prop_changes_sales_by_country_by_year_month.csv`: Cambio porcentual mensual en ventas por país.
   - `histogram_avg_sales_customer.png`: Histograma de promedio de ventas por cliente para España y Francia.
   - `top_10_performance_stores_by_country.png`: Visualización del desempeño de tiendas en ventas y clientes.

3. **Documento de Interpretación:**
   - `1_interpretation.pdf`: Un documento que proporciona una interpretación detallada de los gráficos y tablas generados, junto con los principales insights para el negocio.

## Pasos para Revisar y Ejecutar el Contenido

1. **Instalar Dependencias:**
   Asegúrate de tener R instalado en tu sistema. Además, instala los paquetes necesarios ejecutando el siguiente comando en R:
   ```r
   install.packages(c("tidyverse", "readxl", "lubridate"))

## Configurar el Entorno de Trabajo
- Descarga o clona el repositorio en tu máquina local.
- Asegúrate de que los archivos de datos estén en la ruta especificada en los scripts. Ajusta la ruta en el script según tu configuración local si es necesario.

## Ejecutar los Scripts
- Abre R o RStudio.
- Navega al directorio que contiene los scripts.
- Ejecuta los scripts en el siguiente orden
    source("prop_sales_by_country_by_year_month.R")
    source("prop_changes_sales_by_country_by_year_month.R")
    source("histogram_avg_sales_customer.R")
    source("top_10_performance_stores_by_country.R")

## Revisar los Resultados
- Los archivos CSV generados (prop_sales_by_country_by_year_month.csv y prop_changes_sales_by_country_by_year_month.csv) contendrán los datos calculados.
- Las imágenes PNG (histogram_avg_sales_customer.png y top_10_performance_stores_by_country.png) se guardarán en el directorio de trabajo actual y mostrarán las visualizaciones generadas.
- Lee el archivo 1_interpretation.pdf para obtener una interpretación de los resultados y los insights relevantes.
