function [resultsYearly, resultsMonthly, results10, resultsClasses, resultsSex] = aggregateResults(tbl, betaCov, FIT_TO_YEAR, ORIGIN_YEAR, Alpha)

% Aggregate monthly results
resultsMonthly = groupsummary(tbl, "t", "sum",  ["popSize", "deaths", "dMean", "dMeanSamp", "excess", "excessMeanSamp", "yX"]);
resultsMonthly = renamevars(resultsMonthly, {'sum_popSize', 'sum_deaths', 'sum_dMean', 'sum_dMeanSamp', 'sum_excess', 'sum_excessMeanSamp'}, {'popSize', 'deaths', 'dMean', 'dMeanSamp', 'excess', 'excessMeanSamp'});
% Create a new non-integer 'Year' variable that is year+(month-1)/12
resultsMonthly.Year = (resultsMonthly.t-1)/12 + ORIGIN_YEAR;
resultsMonthly.excess_pc = resultsMonthly.excess./resultsMonthly.dMean;

% Aggregate across all strata (age x sex x month) in each year:
resultsYearly = groupsummary(tbl, "Year", "sum", ["deaths", "dMean", "dMeanSamp", "dMeanStd", "dMeanSampStd", "excess", "excessMeanSamp", "SMR", "dMeanStd"]);
resultsYearly = renamevars(resultsYearly, {'sum_deaths', 'sum_dMean', 'sum_dMeanSamp', 'sum_dMeanStd', 'sum_dMeanSampStd', 'sum_excess', 'sum_excessMeanSamp', 'sum_SMR'}, {'deaths', 'dMean', 'dMeanSamp', 'dMeanStd', 'dMeanSampStd', 'excess', 'excessMeanSamp', 'SMR'});
% Copy pop size across from resultsMonthly (using the first month of each
% year)
resultsYearly.popSize = resultsMonthly.popSize(ismember(resultsMonthly.Year, resultsYearly.Year));
resultsYearly.excess_pc = resultsYearly.excess./resultsYearly.dMean;

% Aggregate in 10 year age bands (yearly, both sexes):
results10 = groupsummary(tbl, ["Year", "age10"], "sum", ["deaths", "dMean", "dMeanSamp", "excess", "excessMeanSamp"]);
results10 = renamevars(results10, {'sum_deaths', 'sum_dMean', 'sum_dMeanSamp', 'sum_excess', 'sum_excessMeanSamp'}, {'deaths', 'dMean', 'dMeanSamp', 'excess', 'excessMeanSamp'});

% Aggregate across Covid age classes (yearly, both sexes)
resultsClasses = groupsummary(tbl, ["Year", "covidAgeClass"], "sum", ["deaths", "dMean", "dMeanSamp", "excess", "excessMeanSamp"]);
resultsClasses = renamevars(resultsClasses, {'sum_deaths', 'sum_dMean', 'sum_dMeanSamp', 'sum_excess', 'sum_excessMeanSamp'}, {'deaths', 'dMean', 'dMeanSamp', 'excess', 'excessMeanSamp'});

% Aggregate for each sex (yearly, all ages)
resultsSex = groupsummary(tbl, ["Year", "sex"], "sum", ["deaths", "dMean", "dMeanSamp", "excess", "excessMeanSamp"]);
resultsSex = renamevars(resultsSex, {'sum_deaths', 'sum_dMean', 'sum_dMeanSamp', 'sum_excess', 'sum_excessMeanSamp'}, {'deaths', 'dMean', 'dMeanSamp', 'excess', 'excessMeanSamp'});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONFIDENCE INTERVALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate CIs for deaths by aggregating samples and taking quantiles
qt = [Alpha/2, 1-Alpha/2];
resultsMonthly.dCI = quantile(resultsMonthly.dMeanSamp, qt, 2); 
resultsYearly.dCI = quantile(resultsYearly.dMeanSamp, qt, 2); 
results10.dCI = quantile(results10.dMeanSamp, qt, 2); 
resultsClasses.dCI = quantile(resultsClasses.dMeanSamp, qt, 2); 
resultsSex.dCI = quantile(resultsSex.dMeanSamp, qt, 2);

% Calculate correpsonding CIs for excess 
resultsMonthly.excessCI = quantile(resultsMonthly.excessMeanSamp, qt, 2);
resultsYearly.excessCI = quantile(resultsYearly.excessMeanSamp, qt, 2);
results10.excessCI = quantile(results10.excessMeanSamp, qt, 2);
resultsClasses.excessCI = quantile(resultsClasses.excessMeanSamp, qt ,2);
resultsSex.excessCI = quantile(resultsSex.excessMeanSamp, qt ,2);

% Calculate correpsonding CIs for percent excess 
resultsMonthly.excess_pcCI = resultsMonthly.excessCI./resultsMonthly.dMean;
resultsYearly.excess_pcCI =  resultsYearly.excessCI./resultsYearly.dMean;

% Calculate CIs for monthly results using Delta method as a check
zVal = norminv(1-Alpha/2);
deltaSE = sqrt( sum( resultsMonthly.sum_yX .* (betaCov*resultsMonthly.sum_yX')', 2 ) );
resultsMonthly.dCI_delta = resultsMonthly.dMean + zVal * [-1 1] .* deltaSE;
resultsMonthly.excesCIs_delta = resultsMonthly.deaths - fliplr(resultsMonthly.dCI_delta);

% Calculate CIs for age-standardised deaths (still predicted by QPR model)
resultsYearly.dStdCI = quantile(resultsYearly.dMeanSampStd, qt, 2); 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUMULATIVE EXCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate cumulative excess from 2020 onwards by looking at cumulative excess relative to its nominal value at end of 2019
ind = find(resultsYearly.Year == FIT_TO_YEAR);       
E0 = sum(resultsYearly.excess(1:ind));
E0samp = sum(resultsYearly.excessMeanSamp(1:ind, :));
resultsYearly.cumExcess = cumsum(resultsYearly.excess)-E0;
resultsYearly.cumExcessCI = quantile( cumsum(resultsYearly.excessMeanSamp)-E0samp, qt, 2);

% Calculate cumulative excess on monthly model (+1 because want to look relative to end of Dec 2019, which is coded as resultsMonthly.Year = 2020.0
ind = find(resultsMonthly.Year == FIT_TO_YEAR+1);     
E0 = sum(resultsMonthly.excess(1:ind));
E0samp = sum(resultsMonthly.excessMeanSamp(1:ind, :) );
resultsMonthly.cumExcess = cumsum(resultsMonthly.excess)-E0;
resultsMonthly.cumExcessCI = quantile( cumsum(resultsMonthly.excessMeanSamp)-E0samp, qt, 2);

