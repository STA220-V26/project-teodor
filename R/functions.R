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

merge_bmi_insurance <- function(encounters_insurance_added, observations) {
  
  encounters_insurance_added %>%
    select(id, patient, insurance_percentage_coverage) %>%
    inner_join(
      observations %>% select(encounter, bmi),
      by = c("id" = "encounter")
    )
}

add_income <- function(bmi_insurance, patients_raw) {
  
  bmi_insurance %>%
    left_join(
      patients_raw %>% select(id, income),
      by = c("patient" = "id")
    )
}

transform_insurance <- function(Analysis_data) {
  Analysis_data %>%
    mutate(
      insurance_transformed = case_when(
        insurance_percentage_coverage == 0 ~ 0.005,
        insurance_percentage_coverage == 1 ~ 0.995,
        TRUE ~ insurance_percentage_coverage
      )
    )
}
fit_betareg <- function(Analysis_data_final) {
  betareg(insurance_transformed ~ bmi + income, data = Analysis_data_final)
}