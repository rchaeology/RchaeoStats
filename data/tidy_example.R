# Create a small clean version of the dataset
library(readxl)
library(here)
library(dplyr)

sheep_data <- readr::read_csv(here("data/sheep-data_raw.csv"))
data <- read_xlsx(here("data/mortuary-data.xlsx"))

# minor modification of the sheep dataset to use in the example workflow
  # cleaned data are also available online: https://edu.nl/3hru6
sheep_data_clean <- sheep_data |>
  filter(Zone != "Cyprus") |>
  select(!c(Dl_GLl, Bd_Dl, `Photo#`, `Cat#`))

# clean mortuary dataset
select_data <- data |>
  rename(
    IndoPacific_bead = `Indo-Pacific_bead`,
    Height = Hight
  ) |>
  mutate(
    across(
    c(Glass_bead, IndoPacific_bead),
    \(x) case_match(x,
                    c("shatter", "cluster", "unsure number") ~ NA,
                    .default = x) |>
      as.numeric()
    ),
    across(c(Length, Width),
           \(x) stringr::str_remove(x, "\\+") |> as.numeric())
  ) |>
  ggplot2::remove_missing(vars = c("Height", "Length", "Phase")) |>
  select(ID, Layer, Length, Width, Height, Pit, Phase, Coffin, Gender, Age, contains(c("bead", "vessel")))
  
readr::write_csv(sheep_data_clean, here("data/sheep-data.csv"))
readr::write_csv(select_data, here("data/04_clean-example-data.csv"))
