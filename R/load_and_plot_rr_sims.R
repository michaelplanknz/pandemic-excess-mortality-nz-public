## This script loads and plots the results of simulating the two random rounding
## protocols 100 times. The results are aggregated to annual counts, by sex.

## Load the data

deaths_dist_checks_rr3 <-
  read_csv(file = "check_data/deaths_data_rr3_distribution_checks.csv")

deaths_dist_checks_rrn <-
  read_csv(file = "check_data/deaths_data_rr3-6_distribution_checks.csv")

## Plot the results

death_dist_plot_rr3 <-
  deaths_dist_checks_rr3 %>% 
  ggplot() +
  geom_violin(data = deaths_dist_checks_rr3 %>% filter(sim_lab == "rounded"),
              aes(x = year, y = cnt, group = year)) +
  geom_boxplot(data = deaths_dist_checks_rr3 %>% filter(sim_lab == "unrounded"),
               aes(x = year, y = cnt, group = year), colour = "red") +
  facet_grid(cols = vars(sex)) +
  labs(x = "",
       y = "Counts of deaths (RR3)",
       fill = "")

death_dist_plot_rr3  

ggsave(filename = "check_plots/deaths_rr3_sim.pdf", plot = death_dist_plot_rr3, width = 297, height = 210, units = "mm")

death_dist_plot_rrn <-
  deaths_dist_checks_rrn %>% 
  ggplot() +
  geom_violin(data = deaths_dist_checks_rrn %>% filter(sim_lab == "rounded"),
              aes(x = year, y = cnt, group = year)) +
  geom_boxplot(data = deaths_dist_checks_rrn %>% filter(sim_lab == "unrounded"),
               aes(x = year, y = cnt, group = year), colour = "red") +
  facet_grid(cols = vars(sex)) +
  labs(x = "",
       y = "Counts of deaths (RR3/6)",
       fill = "")

death_dist_plot_rrn

ggsave(filename = "check_plots/deaths_rr3-6_sim.pdf", plot = death_dist_plot_rrn, width = 297, height = 210, units = "mm")

combined_death_dist <-
  deaths_dist_checks_rr3 %>% 
  rename(rr_3 = cnt) %>% 
  left_join(deaths_dist_checks_rrn %>% rename(rr_n = cnt), by = c("year", "sex", "rounding", "sim_lab")) %>% 
  select(year, sex, rounding, sim_lab, rr_3, rr_n) %>% 
  pivot_longer(rr_3:rr_n, names_to = "protocol", values_to = "cnt")

combined_death_dist_plot <-
  combined_death_dist %>% 
  ggplot() +
  geom_violin(data = combined_death_dist %>% 
                filter(sim_lab == "rounded",
                       protocol == "rr_n"),
              aes(x = year, y = cnt, group = year, fill = protocol)) +
  geom_violin(data = combined_death_dist %>% 
                filter(sim_lab == "rounded",
                       protocol == "rr_3"),
              aes(x = year, y = cnt, group = year, fill = protocol)) +
  geom_boxplot(data = combined_death_dist %>% filter(sim_lab == "unrounded"),
               aes(x = year, y = cnt, group = year), colour = "black") +
  scale_fill_manual(values=c("rr_n" = "coral1", "rr_3" = "cadetblue1"),
                    labels=c("rr_n" = "Adaptive random rounding", "rr_3" = "Random rounding to base 3")) +
  facet_grid(cols = vars(sex)) +
  labs(x = "",
       y = "Counts of deaths",
       fill = "") +
  theme(legend.position = "bottom")

combined_death_dist_plot

ggsave(filename = "check_plots/deaths_rr_sim_comp.pdf", plot = combined_death_dist_plot, width = 297, height = 210, units = "mm")