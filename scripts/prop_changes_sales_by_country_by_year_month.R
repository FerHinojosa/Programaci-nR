# Carga de paquetes necesarios
library(tidyverse)  # Paquete principal que incluye ggplot2, dplyr, etc.
library(readxl)     # Para leer archivos Excel
library(lubridate)  # Para manipulación de fechas
library(corrplot)   # Para generar gráficos de correlación

# Define la ruta de los datos
datapath <- "C:\\Users\\fernando.hinojosa\\Downloads\\Programación R al elaborar reportes estadísticos\\Sprint 1\\Recursos externos"

# Establece el directorio de trabajo a la ruta de datos
setwd(datapath)

# Especifica las rutas a los archivos de datos
sales_data <- ".\\data\\sales.csv"          # Archivo CSV con datos de ventas
stores_info <- ".\\data\\stores_info.xlsx"  # Archivo Excel con información adicional de tiendas

# Carga los datos de ventas desde el archivo CSV
sales <- read.csv2(
  file = sales_data,  # Ruta al archivo CSV
  sep = ";",          # Delimitador de campo
  header = TRUE       # Indica si la primera fila contiene nombres de columnas
)

# Muestra las últimas 6 filas del dataset sales para inspección
sales %>% tail()

# Carga los datos de las tiendas desde la hoja "data" del archivo Excel
stores <- read_excel(
  path = stores_info, # Ruta al archivo Excel
  sheet = "data"      # Nombre de la hoja a leer
)

# Visualiza el dataset de ventas
view(sales)

# Une las tablas de ventas y tiendas utilizando la columna "store" como clave
sales_all <- sales %>%
  left_join(stores, by = c("store"))

# Muestra las últimas 10 filas del dataset unido
sales_all %>% tail(10)

# Agrupa los datos por país y calcula las ventas y clientes en millones
sales_summary <- sales_all %>%
  group_by(country) %>%
  summarise(
    sales = sum(sales) / 1000000,        # Suma las ventas y las convierte a millones
    customers = sum(customers) / 1000000 # Suma los clientes y los convierte a millones
  )

# Convierte la columna "date" a formato de fecha
sales$date <- ymd(sales$date)

# Extrae el año, mes y día de la fecha de venta y agrega columnas correspondientes
sales_all <- sales_all %>%
  mutate(
    year = as.numeric(format(as.Date(date), "%Y")),   # Extrae el año
    month = as.numeric(format(as.Date(date), "%m")),  # Extrae el mes
    day = as.numeric(format(as.Date(date), "%d"))     # Extrae el día
  )

# Crea una fecha auxiliar con el día establecido en 1 para análisis
sales_all <- sales_all %>%
  mutate(day = 1) %>%
  mutate(date_custom = ISOdate(year = year, month = month, day = day)) %>%
  mutate(yearmonth = as.numeric(format(as.Date(date), "%Y%m")))  # Crea una variable de año-mes

# Calcula la proporción de cambios en las ventas por mes y país
prop_changes_sales_month <- sales_all %>%
  group_by(country, yearmonth) %>%
  summarise(
    sales = sum(sales)  # Suma las ventas por año-mes y país
  ) %>%
  ungroup() %>%
  group_by(yearmonth) %>%
  mutate(sales = sales / sum(sales) * 100)  # Calcula el porcentaje de ventas por país
%>%
  ungroup() %>%  # Desagrupar para obtener un dataframe sin grupos
  pivot_wider(
    names_from = yearmonth,  # Nombres de las columnas provenientes de la variable yearmonth
    values_from = sales      # Valores que provienen de la variable sales
  )

# Guarda los resultados en un archivo CSV
write.csv(
  x = prop_changes_sales_month,                       # Datos a guardar
  file = "prop_changes_sales_by_country_by_year_month.csv",  # Nombre del archivo
  row.names = TRUE                                    # Incluir nombres de fila
)
