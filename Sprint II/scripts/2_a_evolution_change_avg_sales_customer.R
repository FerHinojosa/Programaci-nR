# Carga los paquetes necesarios
library(tidyverse)
library(readxl)
library(lubridate)

# Prefiere la función lag de dplyr en caso de conflictos
conflicts_prefer(dplyr::lag)

# Define la ruta de los datos
datapath <- "C:/Users/fernando.hinojosa/Downloads/Programación_R_al_elaborar_reportes_estadísticos/Sprint_1/Recursos_externos"

# Establece el directorio de trabajo a la ruta de datos
setwd(datapath)

# Especifica las rutas a los archivos de datos
sales_data <- "./data/sales.csv"
stores_info_data <- "./data/stores_info.xlsx"

# Carga los datos
sales <- read.csv2(sales_data, sep = ";", header = TRUE)
stores <- read_excel(stores_info_data, sheet = "data")

# Une los datos de ventas con la información de las tiendas
sales_all <- sales %>%
  left_join(stores, by = "store")

# Convierte la columna de fecha a formato Date
sales_all <- sales_all %>%
  mutate(date = ymd(date))

# Extrae año y mes de la fecha de venta
sales_all <- sales_all %>%
  mutate(year = year(date),
         month = month(date))

# Calcula el promedio de ventas por cliente para cada tienda en cada mes
sales_all <- sales_all %>%
  group_by(store, year, month, country, store_type) %>%
  summarise(sales_per_customer = sum(sales) / sum(customers), .groups = 'drop')

# Calcula el cambio porcentual mes a mes de la cantidad promedio de ventas por cliente
sales_all <- sales_all %>%
  arrange(store, year, month) %>%
  group_by(store) %>%
  mutate(pct_change_sales_per_customer = (sales_per_customer / lag(sales_per_customer) - 1) * 100) %>%
  ungroup()

# Visualización general de la evolución mes a mes en términos porcentuales
plot_general <- sales_all %>%
  group_by(year, month) %>%
  summarise(avg_pct_change = mean(pct_change_sales_per_customer, na.rm = TRUE), .groups = 'drop') %>%
  ggplot(aes(x = make_date(year, month, 1), y = avg_pct_change)) +
  geom_line(color = "blue") +
  labs(title = "Evolución Mes a Mes del Cambio Porcentual en Ventas Promedio por Cliente",
       x = "Fecha",
       y = "Cambio Porcentual Promedio (%)") +
  theme_minimal()

# Guarda la visualización general
ggsave("2_c_evolution_change_avg_sales_customer_general.png", plot = plot_general, width = 10, height = 6)

# Visualización de la evolución mes a mes por país y tipo de tienda
plot_by_country_store_type <- sales_all %>%
  ggplot(aes(x = make_date(year, month, 1), y = pct_change_sales_per_customer, color = country)) +
  geom_line() +
  facet_wrap(~ store_type, scales = "free_y") +  # Ajusta las escalas en Y para cada faceta
  labs(title = "Evolución Mes a Mes del Cambio Porcentual en Ventas Promedio por Cliente por País y Tipo de Tienda",
       x = "Fecha",
       y = "Cambio Porcentual Promedio (%)",
       color = "País") +
  theme_minimal()

# Guarda la visualización por país y tipo de tienda
ggsave("2_a_evolution_change_avg_sales_customer_by_country_store_type.png", plot = plot_by_country_store_type, width = 10, height = 6)
