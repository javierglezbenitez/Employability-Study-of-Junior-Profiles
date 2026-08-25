# ============================================================
# Análisis: ¿Qué factores marcan la diferencia entre estar
# empleado o no como junior en tecnología?
#
# Dataset: Stack Overflow Developer Survey (73,462 registros)
# Autor: Javier González Benítez
# ============================================================

library(dplyr)
library(readr)
library(stringr)
library(ggplot2)

# ------------------------------------------------------------
# 1. Carga de datos
# ------------------------------------------------------------
df <- read_csv("stackoverflow_full.csv", show_col_types = FALSE)

cat("Filas:", nrow(df), " | Columnas:", ncol(df), "\n")
cat("Tasa de empleo global:", round(mean(df$Employed) * 100, 1), "%\n\n")

# ------------------------------------------------------------
# 2. Definimos "junior" como <= 2 años de experiencia profesional
# ------------------------------------------------------------
juniors <- df %>% filter(YearsCodePro <= 2)
cat("Nº de juniors (<=2 años exp. profesional):", nrow(juniors), "\n\n")

# ------------------------------------------------------------
# 3. Hallazgo 1 — Tasa de empleo según experiencia profesional
# ------------------------------------------------------------
df <- df %>%
  mutate(exp_bucket = case_when(
    YearsCodePro == 0             ~ "0 años",
    YearsCodePro <= 2             ~ "1-2 años",
    YearsCodePro <= 4             ~ "3-4 años",
    YearsCodePro <= 6             ~ "5-6 años",
    YearsCodePro <= 10            ~ "7-10 años",
    TRUE                          ~ "10+ años"
  ))

orden_exp <- c("0 años", "1-2 años", "3-4 años", "5-6 años", "7-10 años", "10+ años")
df$exp_bucket <- factor(df$exp_bucket, levels = orden_exp)

empleo_por_exp <- df %>%
  group_by(exp_bucket) %>%
  summarise(tasa_empleo = round(mean(Employed) * 100, 1), n = n())

cat("== Hallazgo 1: Tasa de empleo por experiencia profesional ==\n")
print(empleo_por_exp)
cat("\n")

# ------------------------------------------------------------
# 4. Hallazgo 2 — Nº de tecnologías dominadas (ComputerSkills)
#    comparado entre juniors empleados y no empleados
# ------------------------------------------------------------
skills_por_empleo <- juniors %>%
  group_by(Employed) %>%
  summarise(skills_media = round(mean(ComputerSkills), 1), n = n())

cat("== Hallazgo 2: Nº medio de tecnologías dominadas (juniors) ==\n")
print(skills_por_empleo)
cat("\n")

# ------------------------------------------------------------
# 5. Hallazgo 3 — Combo Cloud (AWS/Azure/GCP) + Contenedores
#    (Docker/Kubernetes)
# ------------------------------------------------------------
cloud_kw     <- c("AWS", "Azure", "Google Cloud")
container_kw <- c("Docker", "Kubernetes")

tiene_alguna <- function(texto, palabras) {
  any(str_detect(as.character(texto), fixed(palabras)))
}

juniors <- juniors %>%
  rowwise() %>%
  mutate(
    has_cloud     = tiene_alguna(HaveWorkedWith, cloud_kw),
    has_container = tiene_alguna(HaveWorkedWith, container_kw),
    combo = as.integer(has_cloud) + as.integer(has_container)
  ) %>%
  ungroup()

combo_labels <- c("0" = "Ninguna de las dos",
                   "1" = "Solo una (cloud o contenedores)",
                   "2" = "Ambas (cloud + contenedores)")

empleo_por_combo <- juniors %>%
  group_by(combo) %>%
  summarise(tasa_empleo = round(mean(Employed) * 100, 1), n = n()) %>%
  mutate(combo_label = combo_labels[as.character(combo)])

cat("== Hallazgo 3: Tasa de empleo según cloud + contenedores ==\n")
print(empleo_por_combo)
cat("\n")

# ------------------------------------------------------------
# 6. Hallazgo 4 — Nivel educativo (juniors)
# ------------------------------------------------------------
empleo_por_edlevel <- juniors %>%
  group_by(EdLevel) %>%
  summarise(tasa_empleo = round(mean(Employed) * 100, 1), n = n()) %>%
  arrange(desc(tasa_empleo))

cat("== Hallazgo 4: Tasa de empleo junior por nivel educativo ==\n")
print(empleo_por_edlevel)
cat("\n")

# ------------------------------------------------------------
# 7. Hallazgo 5 — España vs otros países (top 10 por volumen)
# ------------------------------------------------------------
top_paises <- juniors %>%
  count(Country, sort = TRUE) %>%
  slice_head(n = 10) %>%
  pull(Country)

empleo_por_pais <- juniors %>%
  filter(Country %in% top_paises) %>%
  group_by(Country) %>%
  summarise(tasa_empleo = round(mean(Employed) * 100, 1), n = n()) %>%
  arrange(desc(tasa_empleo))

cat("== Hallazgo 5: Tasa de empleo junior por país (top 10 por volumen) ==\n")
print(empleo_por_pais)
cat("\n")

# ------------------------------------------------------------
# 8. Gráficos (se guardan como PNG en el directorio de trabajo)
# ------------------------------------------------------------
theme_set(theme_minimal(base_size = 12))

p1 <- ggplot(empleo_por_exp, aes(x = exp_bucket, y = tasa_empleo)) +
  geom_col(fill = "#2a78d6") +
  labs(title = "Tasa de empleo según experiencia profesional",
       x = "Años de experiencia profesional", y = "Tasa de empleo (%)") +
  coord_cartesian(ylim = c(40, 60))

p2 <- ggplot(empleo_por_combo, aes(x = combo_label, y = tasa_empleo)) +
  geom_col(fill = "#1baf7a") +
  labs(title = "Tasa de empleo junior: cloud + contenedores",
       x = "", y = "Tasa de empleo (%)") +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))

p3 <- ggplot(empleo_por_pais, aes(x = reorder(Country, tasa_empleo), y = tasa_empleo)) +
  geom_col(fill = "#898781") +
  geom_col(data = filter(empleo_por_pais, Country == "Spain"), fill = "#1baf7a") +
  coord_flip(ylim = c(40, 60)) +
  labs(title = "Tasa de empleo junior por país", x = "", y = "Tasa de empleo (%)")

ggsave("grafico_experiencia.png", p1, width = 7, height = 4.5, dpi = 150)
ggsave("grafico_cloud_contenedores.png", p2, width = 7, height = 4.5, dpi = 150)
ggsave("grafico_paises.png", p3, width = 7, height = 5, dpi = 150)

cat("Gráficos guardados: grafico_experiencia.png, grafico_cloud_contenedores.png, grafico_paises.png\n")
