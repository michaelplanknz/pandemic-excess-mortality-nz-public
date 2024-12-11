function popData = getPopData(fNamePop)

% Import population data
% Note cell range A4:GK139 to exclude metadata that is at the bottom of the Infoshare
% spreadsheet
opts = detectImportOptions(fNamePop, 'Range', 'A4:GK139');
popRaw = readtable(fNamePop, opts);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE-PROCESS POPULATION DATA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% stack pop table
% columns 2->97 are male, 98-193 are female, 194->289 are total both sexes
assert( size(popRaw, 2) == 193)
popData = stack(popRaw, 2:193, 'NewDataVariableName', 'popSize', 'IndexVariableName', 'stratum');
nRows = height(popData);

% Extract stratum information to match with strata in deaths table - age is the first part of the string, second part indicates sex (no suffix for male, "_1" for female, "_2" for total)
stratumString = string(popData.stratum);
ageString = extractBefore(stratumString, "Year");

popData.age = str2double(extractAfter(ageString, "x"));

popData.sex = repmat("NA", nRows, 1);
popData.sex(~contains(stratumString, "_1")) = "male";
popData.sex( contains(stratumString, "_1")) = "female";
popData.sex = categorical(popData.sex);

% Split the Year_Quarter field into separate variables
popData.Year = str2double(extractBefore(popData.Year_Quarter, "Q"));
popData.quarter = str2double(extractAfter(popData.Year_Quarter, "Q"));

% Replicate each row three times so there is one row for each month
popData = repelem(popData, 3, 1);
nRows = height(popData);
popData.month = 3*(popData.quarter-1) + repmat( (1:3)', nRows/3, 1);


