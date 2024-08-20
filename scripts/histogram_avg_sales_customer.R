# Carga de paquetes necesarios
library(tidyverse)  # Paquete principal que incluye ggplot2, dplyr, etc.
library(readxl)     # Para leer archivos Excel
library(lubridate)  # Para manipulación de fechas
library(corrplot)   # Para generar gráficos de correlación

# Resolver conflicto de filter
conflicts_prefer(dplyr::filter)

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

# Une las tablas de ventas y tiendas utilizando la columna "store" como clave
sales_all <- sales %>%
  left_join(stores, by = c("store"))

# Muestra las últimas 10 filas del dataset unido
sales_all %>% tail(10)

# Agrupa los datos por país y calcula las ventas y clientes en millones
sales_all %>%
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
    year = as.numeric(format(as.Date(sales_all$date), "%Y")),  # Extrae el año
    month = as.numeric(format(as.Date(sales_all$date), "%m")), # Extrae el mes
    day = as.numeric(format(as.Date(sales_all$date), "%d"))    # Extrae el día
  )

# Crea una fecha auxiliar con el día establecido en 1 para análisis
sales_all <- sales_all %>%
  mutate(day = 1) %>%
  mutate(date_custom = ISOdate(year = year, month = month, day = day)) %>%
  mutate(yearmonth = as.numeric(format(as.Date(date), "%Y%m")))  # Crea una variable de año-mes

# Filtra los datos para excluir a Italia
sales_all <- sales_all %>% filter(country != "italy")

# Calcula las ventas promedio por cliente para cada país y año
avg_sales <- sales_all %>%
  group_by(country, year) %>%
  summarise(
    avg_sales_customes = sum(sales) / sum(customers)  # Calcula las ventas promedio por cliente
  )

# Calcula el promedio y la desviación estándar de las ventas promedio
mean_sales <- mean(avg_sales$avg_sales_customes)
std_dev_sales <- sd(avg_sales$avg_sales_customes)

# Crea el histograma con las líneas para la media y las desviaciones estándar
histograma <- ggplot(avg_sales, aes(x = avg_sales_customes)) +
  geom_histogram(color = "black", fill = "white") +
  # Agrega una línea en el promedio
  geom_vline(xintercept = mean_sales, linetype = "dashed", color = "blue") +
  # Agrega una línea en el promedio más 2 desviaciones estándar
  geom_vline(xintercept = mean_sales + 2 * std_dev_sales,
             linetype = "dashed", color = "red") +
  # Agrega una línea en el promedio menos 2 desviaciones estándar
  geom_vline(xintercept = mean_sales - 2 * std_dev_sales,
             linetype = "dashed", color = "red") +
  labs(title = "Histograma de Ventas y la Regla Empírica Débil")

# Mostrar el gráfico en la consola
print(histograma)

# Guarda el gráfico como una imagen PNG
ggsave(
  filename = "histogram_avg_sales_customer.png",  # Nombre del archivo
  plot = histograma,                              # Objeto del gráfico
  width = 8,                                      # Ancho del gráfico en pulgadas
  height = 6,                                     # Altura del gráfico en pulgadas
  dpi = 300                                       # Resolución de la imagen
)