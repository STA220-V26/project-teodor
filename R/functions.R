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