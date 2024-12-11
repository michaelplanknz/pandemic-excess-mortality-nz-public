clear
close all

clear 
close all

% Data file names
dataFolder = "../data/";
resultsFolder = "../results/";
fNameDeaths = "monthly_deaths_data_Jan2010_Dec2023.csv";
fNamePop = "infoshare_ERP_annual_dec.csv";
fNameCovidAge = "covid19_deaths_data_by_age.csv";
fNameCovidSex = "covid19_deaths_data_by_sex.csv";

year0 = 2010;
FIT_FROM_YEAR = 2014;
FIT_TO_YEAR = 2019;           % last year to include in fit (2019 = last pre-pandemic year)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ IN AND PRE-PROCESS DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[deathsData, popData, covidData] = getData(dataFolder, fNameDeaths, fNamePop, fNameCovidAge, fNameCovidSex);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE QUANTITIES FOR PLOTTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Total pop size in U65 vs over 65
popData.U65flag = popData.age < 65;
pop = groupsummary(popData, ["Year", "U65flag"], "sum", "popSize" );
pop.popSizeRel(pop.U65flag) = pop.sum_popSize(pop.U65flag)/pop.sum_popSize(pop.U65flag & pop.Year == year0);
pop.popSizeRel(~pop.U65flag) = pop.sum_popSize(~pop.U65flag)/pop.sum_popSize(~pop.U65flag & pop.Year == year0);

% Deaths in U65 vs 65+
deathsData.U65flag = deathsData.age < 65;
deaths = groupsummary(deathsData, ["Year", "U65flag"], "sum", "deaths");
deaths.deathsRel(deaths.U65flag) = deaths.sum_deaths(deaths.U65flag)/deaths.sum_deaths(deaths.U65flag & deaths.Year == year0);
deaths.deathsRel(~deaths.U65flag) = deaths.sum_deaths(~deaths.U65flag)/deaths.sum_deaths(~deaths.U65flag & deaths.Year == year0);

% Fit simple linear regression on U65 and 65+ pop size in the pre-pandemic
% period
mdlSpec = "sum_popSize ~ Year";
inFlag = pop.U65flag & pop.Year >= FIT_FROM_YEAR & pop.Year <= FIT_TO_YEAR;
mdl1 = fitlm(pop(inFlag, :), mdlSpec);
inFlag = ~pop.U65flag & pop.Year >= FIT_FROM_YEAR & pop.Year <= FIT_TO_YEAR;
mdl2 = fitlm(pop(inFlag, :), mdlSpec);

% Evaluate regression model for plotting
nRows = height(pop);
pop.reg = nan(nRows, 1);
pop.reg(pop.U65flag) = predict(mdl1, pop(pop.U65flag, :))
pop.reg(~pop.U65flag) = predict(mdl2, pop(~pop.U65flag, :))

% Proportion of deaths that were in U65s each year
deaths_pU65 = deaths.sum_deaths(deaths.U65flag)./( deaths.sum_deaths(deaths.U65flag) + deaths.sum_deaths(~deaths.U65flag) );


h = figure(1);
h.Position = [368   533   818   352];
tiledlayout(1, 2, "TileSpacing", "compact")

nexttile;
plot(pop.Year(pop.U65flag), pop.sum_popSize(pop.U65flag)/1e6, 'o', pop.Year(pop.U65flag), pop.reg(pop.U65flag)/1e6, 'b--')
xlabel('year')
ylabel('population size (millions)')
xlim([year0, 2023])
grid on
xline(FIT_FROM_YEAR, 'k:')
xline(FIT_TO_YEAR, 'k:')
title('(a) under 65 years old')

nexttile;
plot(pop.Year(~pop.U65flag), pop.sum_popSize(~pop.U65flag)/1e6, 'o', pop.Year(~pop.U65flag), pop.reg(~pop.U65flag)/1e6, 'b--')
xlabel('year')
ylabel('population size (millions)')
xlim([year0, 2023])
grid on
xline(FIT_FROM_YEAR, 'k:')
xline(FIT_TO_YEAR, 'k:')
title('(b) over 65 years old')
saveas(gcf, resultsFolder+"SuppFig2.png")



