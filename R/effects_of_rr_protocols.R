## Analysis of noise due to random rounding

## This script looks at the distribution of values resulting from random rounding to base 3
## and using the "adaptive" random rounding on the deaths data.
## We do this by running the rounding exercise 100 times for each protocol, and plotting the 
## generated distribution, aggregated to annual counts by sex, comparing these with the true counts

## Note, you will not be able to run this script due to the lack of raw unrounded
## data. We supply this script for transparency.

## See "~/R/load_and_plot_rr_sims.R" for plotting scripts.

deaths_dist_checks_rr3 <-  ## Checking the noise levels by replicating 100 random rounding events for RR3
  month_deaths_clean_agg %>% 
  rowwise() %>% 
  mutate(n_rr3 = list(replicate(100, rrn(raw_cnt, n = 3), simplify = TRUE))) %>% 
  unnest_wider(n_rr3, names_sep = "_") %>% 
  pivot_longer(raw_cnt:n_rr3_100, values_to = "cnt", names_to = "rounding") %>% 
  group_by(year, sex, rounding) %>%
  summarise(cnt = sum(cnt)) %>% 
  ungroup() %>% 
  mutate(sim_lab = ifelse(rounding == "raw_cnt", "unrounded", "rounded"))

deaths_dist_checks_rrn <- ## Checking the noise levels by replicating 100 random rounding events for "adaptive rounding"
  month_deaths_clean_agg %>% 
  rowwise() %>% 
  mutate(n_rr3 = list(replicate(100, ifelse(raw_cnt < 6, rrn(raw_cnt, n = 6), rrn(raw_cnt, n = 3)), simplify = TRUE))) %>% 
  unnest_wider(n_rr3, names_sep = "_") %>% 
  pivot_longer(raw_cnt:n_rr3_100, values_to = "cnt", names_to = "rounding") %>% 
  group_by(year, sex, rounding) %>%
  summarise(cnt = sum(cnt)) %>% 
  ungroup() %>% 
  mutate(sim_lab = ifelse(rounding == "raw_cnt", "unrounded", "rounded"))

write_csv(deaths_dist_checks_rr3, file = "check_data/deaths_data_rr3_distribution_checks.csv")
write_csv(deaths_dist_checks_rrn, file = "check_data/deaths_data_rr3-6_distribution_checks.csv")