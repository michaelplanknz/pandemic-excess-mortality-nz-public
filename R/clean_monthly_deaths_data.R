## Clean up monthly deaths data and write new csv
## This script outlines the process undertaken to clean the raw data, 
## then apply random rounding to it in order to avoid disclosure

## Note, you will not be able to run this script due to the lack of raw unrounded
## data. We supply this script for transparency.

## Load the raw data

month_deaths_raw <-
  read_csv("data/monthly_deaths_2010_Dec2023_unr.csv") ## Note, this is an internal file and not published

## Basic cleaning and aggregation

month_deaths_clean_agg <-
  month_deaths_raw %>% 
  mutate(sex = ifelse(sex == 1, "male", "female")) %>% 
  mutate(age_num = ifelse(age == "105+", 105, age),
         age_num = as.integer(age_num),
         age = ifelse(age_num >= 95, 95, age_num),
         age_num = NULL)%>% 
  rename(raw_cnt = `_FREQ_`) %>% 
  arrange(year, month, age, sex) %>% 
  group_by(year, month, year_month, age, sex) %>% 
  summarise(raw_cnt = sum(raw_cnt)) %>% 
  filter(year != is.na(year)) %>% ## The data output process from source creates empty cells at the bottom of the data file. This removes them from the data frame 
  ungroup() %>% 
  mutate(age_lab = ifelse(age == 95, "95+", age)) %>% 
  select(year, month, year_month, age, age_lab, sex, raw_cnt)

month_deaths_clean_agg_rnd <-
  month_deaths_clean_agg %>% 
  mutate(n_rnd = ifelse(raw_cnt < 6, rrn(raw_cnt, n = 6), rrn(raw_cnt, n = 3))) ## Random rounding is applied using a user written random rounding function - see func_rr3 in the "R" folder

month_deaths_clean_agg_rnd %>% filter(n_rnd < 6 & n_rnd != 0) ## Checking for correct rounding, there should be no values below 6 that are not 0. Returns an empty dataframe

write_csv(month_deaths_clean_agg_rnd %>% mutate(raw_cnt = NULL), file = "out/monthly_deaths_data_Jan2010_Dec2023_agg_rr.csv") ## Write out the rounded data for publication. Note, the raw counts are explicitly removed here
