function deathsData = getDeathsData(fNameDeaths, colName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ DATA FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Import all-cause deaths data
opts = detectImportOptions(fNameDeaths);
opts = setvartype(opts, 'sex', 'categorical');
opts.SelectedVariableNames = ["year", "month", "age", "sex", colName];
deathsRaw = readtable(fNameDeaths, opts);
deathsRaw = renamevars(deathsRaw, {'year', char(colName)}, {'Year', 'deaths'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE-PROCESS MONTHLY DEATHS DATA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

totDeathsCheck = sum(deathsRaw.deaths);
deathsData = deathsRaw;

% Fill missing year-month-age-sex combinations which are true ZEROs (not missing data) 
% Get unique values of all variables
yrs = unique(deathsData.Year);
mnths = unique(deathsData.month);
a = unique(deathsData.age);
sx = unique(deathsData.sex);

% Check values are as expected
assert(isequal(yrs, (2010:2023)' ));
assert(isequal(mnths, (1:12)' ));
assert(isequal(a, (0:95)' ));
assert(isequal(sx, categorical(["female", "male"])' ));

% Create extra rows for combinations of variables not present in the data 
extraRows.Year = [];
extraRows.month = [];
extraRows.age = [];
extraRows.sex = [];
for ii = 1:length(yrs)
    if ii < length(yrs)
        nMonths = 12;
    else
        nMonths = max(deathsData.month(deathsData.Year == yrs(ii)));
    end
    for jj = 1:nMonths
        for kk = 1:length(a)
            for ll = 1:length(sx)
                if sum( deathsData.Year == yrs(ii) & deathsData.month == mnths(jj) & deathsData.age == a(kk) & deathsData.sex == sx(ll)  ) == 0
                    extraRows.Year = [extraRows.Year; yrs(ii)];
                    extraRows.month = [extraRows.month; mnths(jj)];
                    extraRows.age = [extraRows.age; a(kk)];
                    extraRows.sex = [extraRows.sex; sx(ll)];
                end
            end
        end
    end
end
extraRows = struct2table(extraRows);
extraRows.deaths = zeros(height(extraRows), 1);
deathsData = [deathsData; extraRows];
deathsData = sortrows(deathsData, {'Year', 'month'});
assert(totDeathsCheck == sum(deathsData.deaths));          % check total deaths has been preserved

