# Cargar los paquetes necesarios
library(tidyverse)  # Incluye funciones para manipulación de datos y visualización
library(readxl)     # Para leer archivos Excel
library(lubridate)  # Para trabajar con fechas

# Definir la ruta de los datos
datapath <- "C:\\Users\\fernando.hinojosa\\Downloads\\Programación R al elaborar reportes estadísticos\\Sprint 1\\Recursos externos"

# Establecer el directorio de trabajo a la ruta de datos
setwd(datapath)

# Especificar las rutas a los archivos de datos
sales_data <- ".\\data\\sales.csv"          # Archivo CSV con datos de ventas
stores_info <- ".\\data\\stores_info.xlsx"  # Archivo Excel con información adicional de tiendas

# Cargar los datos de ventas desde el archivo CSV
sales <- read_csv2(file = sales_data, col_names = TRUE)

# Cargar los datos de las tiendas desde la hoja "data" del archivo Excel
stores <- read_excel(path = stores_info, sheet = "data")

# Unir las tablas de ventas y tiendas
# Utilizamos left_join para combinar los datos de ventas con la información de tiendas
sales_all <- sales %>%
  left_join(stores, by = "store")

# Convertir la columna de fecha a tipo Date
# Aseguramos que la columna `date` sea de tipo Date para facilitar el manejo de fechas
sales_all <- sales_all %>%
  mutate(date = ymd(date))

# Obtener la última fecha disponible en los datos
# Encontramos la fecha más reciente en el conjunto de datos
last_date <- max(sales_all$date, na.rm = TRUE)

# Filtrar los datos para los últimos 3 meses desde la última fecha disponible
# Seleccionamos los datos de los últimos 3 meses para el análisis
three_months_ago <- last_date %m-% months(3)
recent_sales <- sales_all %>%
  filter(date >= three_months_ago & date <= last_date)

# Calcular los top 10 de ventas y top 10 de clientes por país
# Agrupamos por país y tienda, luego calculamos las métricas de ventas y clientes
top_stores <- recent_sales %>%
  group_by(country, store) %>%
  summarise(
    total_sales = sum(sales, na.rm = TRUE),      # Suma total de ventas
    total_customers = sum(customers, na.rm = TRUE),  # Suma total de clientes
    avg_sales = mean(sales, na.rm = TRUE),       # Promedio de ventas
    avg_customers = mean(customers, na.rm = TRUE), # Promedio de clientes
    .groups = 'drop'                             # No mantener las agrupaciones
  ) %>%
  arrange(country, desc(total_sales)) %>%
  mutate(
    rank_sales = row_number(desc(total_sales)),        # Rango por ventas
    rank_customers = row_number(desc(total_customers))  # Rango por clientes
  ) %>%
  filter(rank_sales <= 10 | rank_customers <= 10)  # Filtramos para los top 10 en ventas o clientes

# Crear la visualización
# Creamos un gráfico de barras para mostrar las ventas y clientes de las mejores tiendas
top_plot <- ggplot(top_stores, aes(x = reorder(store, -total_sales), y = total_sales, fill = country)) +
  geom_bar(stat = "identity", position = position_dodge()) +  # Barras para ventas
  geom_text(aes(label = round(avg_sales, 2)), vjust = -0.3, color = "blue", size = 3.5) +  # Etiquetas de promedio de ventas
  geom_text(aes(y = total_customers, label = round(avg_customers, 2)), vjust = 1.5, color = "red", size = 3.5) +  # Etiquetas de promedio de clientes
  facet_wrap(~ country, scales = "free_x") +  # Crear facetas por país
  labs(title = "Top 10 Tiendas por Desempeño en Ventas y Clientes",
       subtitle = "Promedio de ventas y clientes en los últimos 3 meses",
       x = "Tienda",
       y = "Total de Ventas (Valor Monetario)",
       fill = "País") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Mejorar la legibilidad del texto en el eje x

# Guardar la visualización como PNG
# Guardamos el gráfico generado en un archivo PNG
ggsave(filename = "top_10_performance_stores_by_country.png", plot = top_plot, width = 12, height = 8, dpi = 300)
