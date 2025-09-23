# Estimating excess mortality during the Covid-19 pandemic in Aotearoa New Zealand

This repository contains data and code for estimating excess mortality in Aotearoa New Zealand during the Covid-19 pandemic and should be read in conjunction with the accompanying article [Estimating excess mortality during the Covid-19 pandemic in Aotearoa New Zealand](https://academic.oup.com/ije/article/54/4/dyaf093/8163015).

A preprint of the article is available [here](https://arxiv.org/abs/2412.08927). Results in the pre-print and the [final published article](https://academic.oup.com/ije/article/54/4/dyaf093/8163015) were generated using the version of this repository tagged v1.0, which is also archived as [Zenodo archive](https://dx.doi.org/10.5281/zenodo.15107131). 

## Abstract

**Background.** The excess mortality rate in Aotearoa New Zealand during the Covid-19 pandemic is frequently estimated to be among the lowest in the world. However, to facilitate international comparisons, many of the methods that have been used to estimate excess mortality do not use age-stratified data on deaths and population size, which may compromise their accuracy.

**Methods.** We used a quasi-Poisson regression model for monthly all-cause deaths among New Zealand residents, controlling for age, sex and seasonality. We fitted the model to deaths data for 2014-19. We estimated monthly excess mortality for 2020-23 as the difference between actual deaths and projected deaths according to the model. We conducted sensitivity analysis on the length of the pre-pandemic period used to fit the model. We benchmarked our results against a simple linear regression on the standardised annual mortality rate.

**Results.** We estimated cumulative excess mortality in New Zealand in 2020-23 was 1040 (95% confidence interval [-1134, 2927]), equivalent to 0.7% [-0.8%, 2.0%] of expected mortality. Excess mortality was negative in 2020-21. The magnitude, timing and age-distribution of the positive excess mortality in 2022-23 were closely matched with confirmed Covid-19 deaths.

**Conclusions.** Negative excess mortality in 2020-21 reflects very low levels of Covid-19 and major reductions in seasonal respiratory diseases during this period. In 2022-23, Covid-19 deaths were the main contributor to excess mortality and there was little or no net non-Covid-19 excess. Overall, New Zealand experienced one of the lowest rates of pandemic excess mortality in the world. 



## Structure of this repository

The folder `data` contains the [data](#data).

The folder `Matlab` contains all the Matlab code used in the anaysis.

The folder `results` contains outputs from the analysis, including the figures and table that appear in the article.

The folders `R`, `check_data` and `check_plots` contain scripts and associated outputs used for [random rounding](#random-rounding) of the raw data.




## How to use this repository

The main Matlab script is called `main.m` and this reads in data on all-cause mortality, Covid-19 attributed deaths and population size, fits the quasi-Poisson regression GLM and the standardised mortality rate linear regression model. 

The model is run for all seven baselines (from 4 years to 10 years in length) and by default, graphs are plotted for the 6-year baseline (2014-2019 includive). Results (figures and latex tables for the article) are saved in the /results/ folder.  

Note: if you do not have access to the raw, unrounded data (see [data](#data)), you will need to set the variable `useRawDeathsFlag` in `main.m` to equal 0.




## Data

The main data files used in the analysis are:
* `monthly_deaths_data_Jan2010_Dec2023_agg_rr.csv` - Stats NZ data on the monthly number of all-cause deaths from January 2010 to December 2023, stratified by sex and one-year age group and randomly rounded. For details of the rounding scheme and other information about the dataset, see file [monthly_deaths_metadata.txt](data/monthly_deaths_metadata.txt).
* `infoshare_ERP_quarterly.csv` - Stats NZ data on the estimated resident population as in each quarter from 1991-Q1 to 2023-Q4, stratified by sex and one-year age group. Downloaded from [Stats NZ Infoshare](https://infoshare.stats.govt.nz/) -> Population -> Population Estimates -> Estimated Resident Population by Age and Sex (1991+) (Qrtly-Mar/Jun/Sep/Dec).
* `covid19_deaths_data_by_age.csv` - Te Whatu Ora (Health New Zealand) data on the daily number of Covid-19 attributed deaths (Covid-19 as underlying and Covid-19 as contributory) from 29 March 2020 to 10 November 2024, stratified into coarse age bands (under 60 years, 60-69 years, 70-79 years, and 80+ years). Downloaded from [Te Whatu Ora Covid-19 Trends and Insights dashboard](https://tewhatuora.shinyapps.io/covid19/) -> Deaths -> Deaths by age.
* `covid19_deaths_data_by_sex.csv` - Te Whatu Ora (Health New Zealand) data on the daily number of Covid-19 attributed deaths (Covid-19 as underlying and Covid-19 as contributory) from 29 March 2020 to 10 November 2024, stratified by sex. Downloaded from [Te Whatu Ora Covid-19 Trends and Insights dashboard](https://tewhatuora.shinyapps.io/covid19/) -> Deaths -> Deaths by sex.




## Random rounding

The results shown in the article used raw, unrounded data on death counts. The raw data cannot be published due to privacy concerns relating to small counts. To preserve confidentiality, the dataset in this repository contains death counts that have been randomly rounded (see file [monthly_deaths_metadata.txt](data/monthly_deaths_metadata.txt)). Running the code on this dataset will produce results that are similar to those in the article, but not identical and with broader confidence intervals due to the added noise. 

For completeness and transparency, we have provided the code used in cleaning and rounding the data. These can be found in the folder labelled `R`. We have also demonstrated the effect of rounding on data at an annual aggregate level. The results of this demonstration are in the `check_data` folder, with the plots of the results in the `check_plots` folder. Notes regarding this process can be found in the scripts themselves. The ordering of scripts is described in [global.R](R/global.R).


