## Global file to call libraries used in the data cleaning and random rounding
## process.

library(tidyverse)
source("R/func_rr3.R") ## Load the random rounding function to the global env.

## The order of files below demonstrates the order of operations.
## Note, you will not be able to run most of these scripts due to the lack of raw unrounded
## data. We supply them for transparency.

source("R/clean_monthly_deaths_data.R") ## Not runnable; loads, cleans and rounds the raw data
source("R/effects_of_rr_protocols.R") ## Not runnable; explores the effects of rounding on aggregate annual counts, output data from script supplied
source("R/load_and_plot_rr_sims.R") ## Runnable, plots the distributions of the results from above script. Plots saved to "check_plots"
