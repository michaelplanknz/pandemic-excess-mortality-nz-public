function [tbl, mdl] = fitModel(tbl, FIT_TO_YEAR, baselineYears, interactFlag, quadraticFlag, dispersionFlag, Alpha, nSamples, covidAgeBreaks, stdPopTot)


% Model specification with/without interaction terms
if quadraticFlag == 0
    modelSpec = "deaths ~ t";
else
    modelSpec = "deaths ~ t^2";
end
modelSpec = modelSpec + " + month + age + sex";
if interactFlag
    if quadraticFlag == 0
        modelSpec = modelSpec + "+ ageCoarse:t";
    else
        modelSpec = modelSpec + "+ ageCoarse:t^2";
    end
    modelSpec = modelSpec + " + ageCoarse:sex + ageCoarse:month";
end

 % offset for total deaths is (pop size)*(number of days in year)
tbl.offset = log(tbl.popSize) + log(tbl.nDays);          

% Flags for dows included in fitting period
inFlag = tbl.Year > FIT_TO_YEAR-baselineYears &  tbl.Year <= FIT_TO_YEAR;
mdl = fitglm(tbl(inFlag, :), modelSpec, 'Distribution', 'poisson', 'Offset', tbl.offset(inFlag), 'CategoricalVars', {'age', 'month'}, 'DispersionFlag', dispersionFlag);

% choose whether to calculate simultaneous or non simultaneous CIs (note these CIs are only used within individual strata, bootstrapped CIs are calculated separately and used for all other outputs)
simCIflag = false;     

% Generate model predictions for deaths and rates per person per day by evaluating model
% with/without offset
[tbl.dMean, tbl.dCI] = predict(mdl, tbl, 'Offset', tbl.offset, 'Alpha', Alpha, 'Simultaneous', simCIflag );
[tbl.rateMean, tbl.rateCI] = predict(mdl, tbl, 'Alpha', Alpha, 'Simultaneous', simCIflag);


% Get model outputs (deaths) under resampled regression coefficients
[dMeanSamp, designX] = sampleResponse(mdl, tbl, nSamples);
tbl.dMeanSamp = dMeanSamp;

% For each row in the table, store the corresponding row of the design
% matrix multiplied by the predicted response
tbl.yX = tbl.dMean .* designX;


% Calculate excess within each stratum
tbl.excess = tbl.deaths - tbl.dMean;
tbl.excessMeanSamp = tbl.deaths - tbl.dMeanSamp;


% Calculate standardised expected mortality rate for each stratum, as
% predicted by the QPR model
tbl.dMeanStd = tbl.dMean./tbl.popSizeYearlyMean  .* tbl.stdPop/stdPopTot;
tbl.dMeanSampStd = tbl.dMeanSamp./tbl.popSizeYearlyMean  .* tbl.stdPop/stdPopTot;

% Additional age band variables for different aggregation schemes
tbl.age10 = 10*floor(tbl.age/10);            
tbl.covidAgeClass = discretize(tbl.age, [covidAgeBreaks, inf]);




