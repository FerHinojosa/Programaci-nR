# Carga paquetes de trabajo
library(tidyverse)
library(readxl)
library(lubridate)
library(GGally)

# Define la ruta de los datos
datapath <- "C:/Users/fernando.hinojosa/Downloads/Programación_R_al_elaborar_reportes_estadísticos/Sprint_1/Recursos_externos"

# Establece el directorio de trabajo a la ruta de datos
setwd(datapath)

# Especifica las rutas a los archivos de datos
sales_data <- "./data/sales.csv"          # Archivo CSV con datos de ventas
stores_info_data <- "./data/stores_info.xlsx"  # Archivo Excel con información adicional de tiendas

# Lee los datos de ventas desde el archivo CSV
sales <- read.csv2(
  sales_data,
  sep = ";",
  header = TRUE
)

# Lee la información de las tiendas desde el archivo Excel
stores <- read_excel(
  stores_info_data,
  sheet = "data" # nombre de la hoja del archivo Excel
)

# Une los datos de ventas con la información de las tiendas
sales_all <- sales %>%
  left_join(stores, by = "store")

# Convierte la columna de fecha a formato Date
sales_all <- sales_all %>%
  mutate(date = ymd(date))

# Extrae el año, mes y día de la fecha de venta
sales_all <- sales_all %>%
  mutate(
    year = year(date),
    month = month(date),
    day = day(date),
    date_custom = ISOdate(year, month, 1)
  )

# Genera la visualización general de la evolución de ventas en millones de dólares
sales_all %>%
  group_by(date_custom) %>%
  summarise(total_sales = sum(sales) / 1e6) %>%
  ggplot(aes(x = date_custom, y = total_sales)) +
  geom_line(color = "blue") +
  labs(
    title = "Evolución de las Ventas (en millones de dólares)",
    x = "Fecha",
    y = "Ventas (millones de dólares)"
  ) +
  theme_minimal() +
  ggsave("2_a_evolution_sales_general.png", width = 10, height = 6)

# Verificación: Observa los datos resumidos para asegurarte de que son correctos
summary_sales <- sales_all %>%
  group_by(date_custom, country) %>%
  summarise(total_sales = sum(sales) / 1e6)

# Genera la visualización de la evolución de ventas por país
plot_by_country <- ggplot(summary_sales, aes(x = date_custom, y = total_sales, color = country)) +
  geom_line() +
  labs(
    title = "Evolución de las Ventas por País (en millones de dólares)",
    x = "Fecha",
    y = "Ventas (millones de dólares)",
    color = "País"
  ) +
  theme_minimal()

# Muestra el gráfico para verificar que se creó correctamente
print(plot_by_country)

# Guarda el gráfico en un archivo
ggsave("2_a_evolution_sales_by_country.png", plot = plot_by_country, width = 10, height = 6)
