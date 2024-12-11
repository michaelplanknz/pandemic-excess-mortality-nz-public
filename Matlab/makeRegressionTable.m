function [tbl, stdPopTot] = makeRegressionTable(deathsData, popData, ORIGIN_YEAR, STD_YEAR, coarseAgeBreaks)

% Join monthly deaths and pop data 
%tbl = innerjoin(deathsData, popData, 'Keys', {'Year', 'age', 'sex'}, 'LeftVariables', {'Year', 'month', 'age', 'sex', 'deaths'}, 'RightVariables', 'popSize'); 
tbl = innerjoin(deathsData, popData, 'Keys', {'Year', 'month', 'age', 'sex'}, 'LeftVariables', {'Year', 'month', 'age', 'sex', 'deaths'}, 'RightVariables', 'popSize'); 
nRows = height(tbl);

% Create standard population size column for calculating standardised rates
% (use Q1 of the standard year)
tblStdYear = tbl( tbl.Year == STD_YEAR & tbl.month == 1, :); 
stdPopTot = sum(tblStdYear.popSize);
tbl.stdPop = nan(nRows, 1);
tbl.popSizeYearlyMean = nan(nRows, 1);
for iRow = 1:nRows
    % Look up the standard population for the current age-sex combination 
    tbl.stdPop(iRow) = tblStdYear.popSize(tblStdYear.age == tbl.age(iRow) & tblStdYear.sex == tbl.sex(iRow));
    % Also record a yearly mean population size by averageing all months
    % (equivalent to averaging quarters)
    tbl.popSizeYearlyMean(iRow) = mean(tbl.popSize(tbl.age == tbl.age(iRow) & tbl.sex == tbl.sex(iRow) & tbl.Year == tbl.Year(iRow) ));
end

% Since SMR is only calculated yearly, use the yearly mean pop size as denominator
tbl.SMR = tbl.deaths./tbl.popSizeYearlyMean .* tbl.stdPop/stdPopTot;


% Create new variables for regression:

% Time period variable in months with t=0 corresponding to start of 2014:
tbl.t = 12*(tbl.Year-ORIGIN_YEAR) + tbl.month ;

% Variable for coarse age bands as per ONS
tbl.ageCoarse = getCoarseAgeLabels(tbl.age, coarseAgeBreaks); 

tbl.nDays = getDaysInMonth(tbl.Year, tbl.month);
