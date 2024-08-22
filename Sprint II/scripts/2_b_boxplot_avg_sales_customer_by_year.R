# Carga los paquetes necesarios
library(tidyverse)
library(readxl)
library(lubridate)

# Define la ruta de los datos
datapath <- "C:/Users/fernando.hinojosa/Downloads/Programación_R_al_elaborar
_reportes_estadísticos/Sprint_1/Recursos_externos"

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

# Extrae el año de la fecha de venta y lo convierte en factor
sales_all <- sales_all %>%
  mutate(year = factor(year(date)))

# Verifica si hay valores faltantes en ventas o clientes
sum(is.na(sales_all$sales))
sum(is.na(sales_all$customers))

# Calcula el promedio de ventas por cliente para cada tienda en cada día
sales_all <- sales_all %>%
  mutate(sales_per_customer = sales / customers)

# Genera un diagrama de cajas para la cantidad promedio de ventas por cliente,
# segmentado por año
plot_boxplot <- ggplot(sales_all, aes(x = year, y = sales_per_customer))
+ geom_boxplot(fill = "lightblue") +
  labs(title =
         "Distribución de la Cantidad Promedio de Ventas por Cliente al Día",
       x = "Año",
       y = "Ventas Promedio por Cliente") +
  theme_minimal()

# Muestra el gráfico para ver si se generó correctamente
print(plot_boxplot)

# Guarda la visualización
ggsave("2_b_boxplot_avg_sales_customer_by_year.png", plot = plot_boxplot,
       width = 10, height = 6)
