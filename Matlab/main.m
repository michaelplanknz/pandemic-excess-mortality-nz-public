clear 
close all

% For reproducibility
rng(48922);

% Global settings
ORIGIN_YEAR = 2014;         % year corresponding to t=0
STD_YEAR = 2021;             % standard population year
FIT_TO_YEAR = 2019;           % last year to include in fit (2019 = last pre-pandemic year)

baselineYears = [4 5 6 7 8 9 10];         % number of years to include in pre-2020 baseline 
dispersionFlag = 1;         % dispersion flag for Poisson regression model
interactFlag = 1;           % flag on whether or not to include interaction variables 
quadraticFlag = 0;          % flag for whether or not to include quadratic terms in t
Alpha = 0.05;               % significance level for CIs
nSamples = 5000;                % number of samples of the model coefficient vector to take
coarseAgeBreaks = [0 30 70:5:95];       % age breaks for coarse age bands (as per ONS method)
plotFlag = [0 0 1 0 0 0 0 ];    % flag indicating ewhich of the scenarios (baseline length) to produce plots for
useRawDeathsFlag = 1;       % flag indicating whether to use raw (unrounded) or rounded deaths data

% Folder locations 
dataFolder = "../data/";
resultsFolder = "../results/";

% Data file names
fNamePop = dataFolder + "infoshare_ERP_quarterly_2018_base.csv";
fNameCovidAge = dataFolder + "covid19_deaths_data_by_age.csv";
fNameCovidSex = dataFolder + "covid19_deaths_data_by_sex.csv";

if useRawDeathsFlag
    fNameDeaths = "../raw_data_unrounded/monthly_deaths_data_Jan2010_Dec2023_agg_rounding_comp_w_raw.csv";
    colName = "raw_cnt";
else
    fNameDeaths = dataFolder + "monthly_deaths_data_Jan2010_Dec2023_agg_rr.csv";
    colName = "n_rnd";
end


% Age breaks for data on Covid deaths
covidAgeBreaks = [0 60 70 80 ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ IN AND PRE-PROCESS DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

deathsData = getDeathsData(fNameDeaths, colName);
popData = getPopData(fNamePop);
covidData = getCovidData(fNameCovidAge, fNameCovidSex);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JOIN DEATHS AND POPULATION DATA AND PREPARE FOR REGRESSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[tbl, stdPopTot] = makeRegressionTable(deathsData, popData, ORIGIN_YEAR, STD_YEAR, coarseAgeBreaks);


nScenarios = length(baselineYears);

for iScenario = 1:nScenarios
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MODEL FITTING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    [tbl, mdl] = fitModel(tbl, FIT_TO_YEAR, baselineYears(iScenario), interactFlag, quadraticFlag, dispersionFlag, Alpha, nSamples, covidAgeBreaks, stdPopTot);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AGGREGATE ACROSS STRATA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [resultsYearly, resultsMonthly, results10, resultsClasses, resultsSex] = aggregateResults(tbl, mdl.CoefficientCovariance, FIT_TO_YEAR, ORIGIN_YEAR, Alpha);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CALCULATE EXCESS FROM STANDARDISED MORTALITY RATE LINEAR REGRESSION  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [SMRmean, SMRCI, SMRexcess, SMRexcess_pc] = fitSMRModel(resultsYearly, FIT_TO_YEAR, baselineYears(iScenario), Alpha, stdPopTot);
    resultsYearly.SMRmean = SMRmean;
    resultsYearly.SMRCI = SMRCI;
    resultsYearly.SMRexcess = SMRexcess;  
    resultsYearly.SMRexcess_pc = SMRexcess_pc;  



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % GET SUMMARY OF RESULTS TO SAVE FOR THIS SCENARIO
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    [resultsSummary(iScenario, :), SMRSummary(iScenario, :)] = getResultsSummary(tbl, resultsYearly, Alpha, stdPopTot, iScenario);
    
    % Measure correlation between excess and covid deaths from start of 2022 to
    % last time period (currently Sep 2023)
    x1 = resultsMonthly.excess(resultsMonthly.Year >= 2022);
    x2 = covidData.monthly.deaths(covidData.monthly.Year >= 2022 & covidData.monthly.Year <= 2023);
    excessCovidCorr(iScenario) = corr(x1, x2);
    
    dev = mdl.Deviance;
    logLik = mdl.LogLikelihood;


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOTTING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if plotFlag(iScenario)
        plotGraphs(tbl, resultsYearly, resultsMonthly, results10, resultsClasses, resultsSex, covidData, FIT_TO_YEAR, baselineYears(iScenario), ORIGIN_YEAR, covidAgeBreaks, resultsFolder);

        % Save results10 and resultsYearly tables for reading back in and plotting comparison between ERP 2018 and 2023
        fileLbl = extractBefore(extractAfter(fNamePop, "quarterly_"), ".csv");
        fOut = resultsFolder + "results_ERP_" + fileLbl + ".mat";
        save(fOut, 'results10', 'resultsYearly');

    end
end

writeLatexTable(resultsSummary, SMRSummary, FIT_TO_YEAR, baselineYears, resultsFolder);

