# Carga de paquetes necesarios
library(readxl)     # Para leer archivos Excel
library(lubridate)  # Para manipular fechas
library(corrplot)   # Para crear gráficos de correlación
library(tidyverse)  # Incluye dplyr, ggplot2, tidyr, etc., para manipulación y visualización de datos
library(conflicted) # Para manejar conflictos de nombres de funciones entre paquetes

# Define la ruta a los datos
DATA_PATH <- "C:\\Users\\fernando.hinojosa\\Downloads\\Programación R al elaborar reportes estadísticos\\Sprint 1\\Recursos externos"

# Establece el directorio de trabajo a la ruta de datos
setwd(DATA_PATH)

# Especifica las rutas de los archivos de datos
sales_data <- ".\\data\\sales.csv"           # Archivo CSV de datos de ventas
stores_info <- ".\\data\\stores_info.xlsx"   # Archivo Excel con información adicional de tiendas

# Carga los datos de ventas desde el archivo CSV
sales <- read.csv2(
  file = sales_data,  # Ruta al archivo CSV
  sep = ";",          # Delimitador de campo
  header = TRUE       # Indica si la primera fila contiene nombres de columnas
)

# Muestra las últimas 6 filas del dataset sales para inspección
sales %>% tail()

# Carga los datos de tiendas desde la hoja "data" del archivo Excel
stores <- read_excel(
  path = stores_info, # Ruta al archivo Excel
  sheet = "data"      # Nombre de la hoja a leer
)

# Une las tablas de ventas y tiendas en una sola tabla, utilizando la columna "store" como clave
sales_all <- sales %>%
  left_join(stores, by = c("store"))

# Muestra las últimas 10 filas del dataset unido
sales_all %>% tail(10)

# Agrupa los datos por país y calcula las ventas y clientes en millones
sales_summary <- sales_all %>%
  group_by(country) %>%
  summarise(
    sales = sum(sales) / 1000000,         # Suma las ventas y las convierte a millones
    customers = sum(customers) / 1000000  # Suma los clientes y los convierte a millones
  )

# Convierte la columna "date" a formato de fecha
sales$date <- ymd(sales$date)

# Extrae el año, mes y día de la fecha de venta y agrega columnas correspondientes
sales_all <- sales_all %>%
  mutate(
    year = year(date),     # Extrae el año
    month = month(date),   # Extrae el mes
    day = day(date)        # Extrae el día
  )

# Establece un día fijo (1) para la creación de una fecha personalizada para el análisis
sales_all <- sales_all %>%
  mutate(day = 1) %>%
  mutate(date_custom = ISOdate(year = year, month = month, day = day)) %>%
  mutate(yearmonth = as.numeric(format(date, "%Y%m")))  # Crea una variable de año-mes para agrupación

# Calcula la proporción de ventas por país para cada año-mes
prop_sales_country <- sales_all %>%
  group_by(yearmonth, country) %>%
  summarise(sales = sum(sales)) %>%  # Suma las ventas por año-mes y país
  ungroup() %>%
  group_by(yearmonth) %>%
  mutate(percentage = sales / sum(sales) * 100)  # Calcula el porcentaje de ventas por país

# Visualiza la proporción de ventas por país utilizando un gráfico de dispersión
ggplot(data = prop_sales_country) +
  geom_point(mapping = aes(x = country, y = percentage))

# Guarda los resultados en un archivo CSV
write.csv(
  x = prop_sales_country,                       # Datos a guardar
  file = "prop_sales_by_country_by_year_month.csv",  # Nombre del archivo
  row.names = TRUE                              # Incluir nombres de fila
)