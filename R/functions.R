pivot_selected_measures <- function(data) {
  
  data |>
    filter(type == "numeric") |>
    mutate(
      measure_name = case_when(
        str_detect(description, "Body Height")         ~ "height",
        str_detect(description, "Body Weight")         ~ "weight",
        str_detect(description, fixed("BMI) [Ratio]")) ~ "bmi",
        .default = NA_character_
      )
    ) |>
    filter(!is.na(measure_name)) |>
    pivot_wider(
      id_cols     = c(patient, encounter, date),
      names_from  = measure_name,
      values_from = value,
      values_fn   = first
    ) |>
    filter(
      !is.na(bmi) | (!is.na(height) & !is.na(weight))
    )
}

fill_bmi <- function(data) {
  data |>
    mutate(across(c(height, weight, bmi), as.numeric)) |> 
    mutate(
      bmi = if_else(
        is.na(bmi),
        weight / (height / 100)^2,
        bmi
      )
    )
}

add_insurance_coverage <- function(data) {
  data |>
    mutate(
      insurance_percentage_coverage = (total_claim_cost - payer_coverage) / total_claim_cost
    )
}

# data frame
# y= proportion
# x=explaning variables (lägg in ny variabel)
#OBS y får inte vara exakt 0 eller 1 i beta-regression
data <- data.frame(
  insurance_coverage = c(0.2, 0.5, 0.7, 0.3, 0.9),
  bmi = c(1, 2, 3, 4, 5),
  income = c(5, 3, 6, 2, 7)
)
#Om vi får 0 och 1 i vår nya kolumn kör vi koden nedan
data$y <- (data$y*(nrow(data)-1)+0.5)/nrow(data)


#Dummy variabel för "Övervikt" som är BMI ≥ 25 enligt WHO
data$overweight <- ifelse(data$bmi >= 25, 1, 0)
#Ger nedan
#| värde | betydelse       |
#| ----- | --------------- |
#| 0     | inte överviktig |
#| 1     | överviktig      |
model <- betareg(y ~ overweight + income, data = data)
summary(model)

#Ger oss
#koefficienter
#standardfel
#p-värden
#pseudo-R²
# Leta efter signifkanta nivåer till exempel BMI_high   p = 0.0002
#Värt att nämna std.error 
#Pseudo R-squared: 0.32 ger oss variansen i modellen

#Valfritt att predicta
predict(model, type = "response")




#Age filtering
# Idea:(encounter:start - patients:birthdate) creates a variable
calculate_age <- function(encounter_file, patients_file) {
  
  # Load datasets
  encounter <- read.csv(encounter_file, stringsAsFactors = FALSE)
  patients  <- read.csv(patients_file, stringsAsFactors = FALSE)
  
  # Convert to Date format
  encounter$start <- as.Date(encounter$start)
  patients$birthdate <- as.Date(patients$birthdate)
  
  # Join datasets on patient ID
  merged_data <- encounter %>%
    inner_join(patients, by = c("patient" = "id"))
  
  # Calculate age at time of encounter
  merged_data <- merged_data %>%
    mutate(age = as.integer(interval(birthdate, start) / years(1)))
  
  # Keep relevant columns
  result <- merged_data %>%
    select(patient, start, birthdate, age)
  
  return(result)
}
