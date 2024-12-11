function covidData = getCovidData(fNameCovidAge, fNameCovidSex)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ DATA FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Import Covid deaths data
opts = detectImportOptions(fNameCovidAge);
opts = setvartype(opts, {'death_weekday', 'age_elderly'}, 'categorical');
covidAgeRaw = readtable(fNameCovidAge, opts);

opts = detectImportOptions(fNameCovidSex);
opts = setvartype(opts, {'death_weekday', 'sex'}, 'categorical');
covidSexRaw = readtable(fNameCovidSex, opts);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE-PROCESS COVID DEATHS DATA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Process Covid deaths data
covidAgeRaw = renamevars(covidAgeRaw, 'age_elderly', 'ageClass');
covidAgeRaw.ageClass = reordercats(covidAgeRaw.ageClass, ["<60", "60-69", "70-79", "80+"]); 
covidAgeRaw.Year = year(covidAgeRaw.death_date);
covidAgeRaw.month = month(covidAgeRaw.death_date);
 
covidSexRaw.sex = renamecats(covidSexRaw.sex, lower(categories(covidSexRaw.sex)));  % Make category names lower case
covidSexRaw.Year = year(covidSexRaw.death_date);
covidSexRaw.month = month(covidSexRaw.death_date);

covidData.yearly = groupsummary(covidAgeRaw, "Year", "sum", "deaths");
covidData.yearly = renamevars(covidData.yearly, 'sum_deaths', 'deaths');
covidData.monthly = groupsummary(covidAgeRaw, ["Year", "month"], "sum", "deaths");
covidData.monthly = renamevars(covidData.monthly, 'sum_deaths', 'deaths');
covidData.byAge = groupsummary(covidAgeRaw, ["Year", "ageClass"], "sum", "deaths");
covidData.byAge = renamevars(covidData.byAge, 'sum_deaths', 'deaths');
covidData.bySex = groupsummary(covidSexRaw, ["Year", "sex"], "sum", "deaths");
covidData.bySex = renamevars(covidData.bySex, 'sum_deaths', 'deaths');

