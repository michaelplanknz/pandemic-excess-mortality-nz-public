function plotGraphs(tbl, resultsYearly, resultsMonthly, results10, resultsClasses, resultsSex, covidData, FIT_TO_YEAR, baselineYears, ORIGIN_YEAR, covidAgeBreaks, resultsFolder)

year0 = FIT_TO_YEAR-baselineYears+1;

plotTitles = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)"];

colOrd =colororder;
lightBlue = [0.7 0.8 0.95];

% Total aggregate deaths
h = figure(1);
h.Position = [456   397   654   378];
[x, y] = getFillArgs(resultsMonthly.Year, resultsMonthly.dCI(:, 1), resultsMonthly.dCI(:, 2));
fill(x, y, lightBlue, 'LineStyle', 'none' )
hold on
plot( resultsMonthly.Year, resultsMonthly.dMean, 'b-')
plot(resultsMonthly.Year, resultsMonthly.deaths, 'b.')
ylabel('monthly deaths')
xline(FIT_TO_YEAR+1, 'k--');
xline(year0, 'k--');
grid on
saveas(gcf, resultsFolder+"Fig1.png");


% SMR plot
figure(2)
[x, y] = getFillArgs(resultsYearly.Year, resultsYearly.dStdCI(:, 1), resultsYearly.dStdCI(:, 2));
fill(x, 1000*y, lightBlue, 'LineStyle', 'none' )
hold on
plot(resultsYearly.Year, 1000*resultsYearly.dMeanStd, 'b-')
plot(resultsYearly.Year, 1000*resultsYearly.SMRmean, '-')
% plot(resultsYearly.Year, 1000*resultsYearly.SMRCI(:, 1), 'b--')
% plot(resultsYearly.Year, 1000*resultsYearly.SMRCI(:, 2), 'b--')
plot(resultsYearly.Year, 1000*resultsYearly.SMR, 'bo') 
xline(FIT_TO_YEAR+0.5, 'k--');
xline(year0-0.5, 'k--');
xlim([2010 2023])
ylabel('standardised yearly mortality rate per 1000')
grid on
legend(["","QPR","SMR-LR","data"])
saveas(gcf, resultsFolder+"Fig2.png");


% Excess over time
h = figure(3);
h.Position = [       107         459        1154         431];
tiledlayout(1, 2, "TileSpacing", "compact");
nexttile;
plot(covidData.yearly.Year, covidData.yearly.deaths, 'o-')
hold on
errorbar(resultsYearly.Year, resultsYearly.excess, resultsYearly.excess-resultsYearly.excessCI(:, 1), resultsYearly.excessCI(:, 2)-resultsYearly.excess, 'o-')
plot(resultsYearly.Year, resultsYearly.SMRexcess, 'o-')
xlim([2020 2023])
h = gca;
h.XTick = unique(round(h.XTick));
ylabel('yearly deaths')
yline(0, 'k-');
legend( 'Covid deaths','excess deaths (QPR)', 'excess deaths (SMR-LR)', 'location', 'southeast')
grid on
title('(a)')

nexttile;
tPlot = covidData.monthly.Year + (covidData.monthly.month-1)/12;
plot(tPlot, covidData.monthly.deaths, '.-')
hold on
errorbar(resultsMonthly.Year, resultsMonthly.excess, resultsMonthly.excess-resultsMonthly.excessCI(:, 1), resultsMonthly.excessCI(:, 2)-resultsMonthly.excess, 'o-')
ylabel('monthly deaths')
xlim([2020 2024-1/12])
h = gca;
h.XTick = unique(round(h.XTick));
yline(0, 'k-');
legend( 'Covid deaths','excess deaths (QPR)', 'location', 'southeast')
grid on
title('(b)')
saveas(gcf, resultsFolder+"Fig3.png");


% Aggregate results across Covid age bands for comparison with confirmed
% Covid deaths
yearsToPlot = [2022, 2023];
nYears = length(yearsToPlot);
nAges = length(covidAgeBreaks);
covidDeathsByAge = zeros(nAges, nYears);
totDeathsByAge = zeros(nAges, nYears);
predByAge = zeros(nAges, nYears);
predByAgeLo = zeros(nAges, nYears);
predByAgeHi = zeros(nAges, nYears);
excessByAge = zeros(nAges, nYears);
excessByAgeLo = zeros(nAges, nYears);
excessByAgeHi = zeros(nAges, nYears);

sexes = ["male", "female"];
nSexes = 2;
covidDeathsBySex = zeros(nSexes, nYears);
totDeathsBySex = zeros(nSexes, nYears);
predBySex = zeros(nSexes, nYears);
predBySexLo = zeros(nSexes, nYears);
predBySexHi = zeros(nSexes, nYears);
excessBySex = zeros(nSexes, nYears);
excessBySexLo = zeros(nSexes, nYears);
excessBySexHi = zeros(nSexes, nYears);
for iYear = 1:nYears
    covidDeathsByAge(:, iYear) = covidData.byAge.deaths(covidData.byAge.Year == yearsToPlot(iYear));
    for iAge = 1:nAges
        totDeathsByAge(iAge, iYear) = resultsClasses.deaths(resultsClasses.Year == yearsToPlot(iYear) & resultsClasses.covidAgeClass == iAge);
        predByAge(iAge, iYear) = resultsClasses.dMean(resultsClasses.Year == yearsToPlot(iYear) & resultsClasses.covidAgeClass == iAge);
        y = resultsClasses.dCI(resultsClasses.Year == yearsToPlot(iYear) & resultsClasses.covidAgeClass == iAge, :);
        predByAgeLo(iAge, iYear) = y(1);
        predByAgeHi(iAge, iYear) = y(2);
        excessByAge(iAge, iYear) = resultsClasses.excess(resultsClasses.Year == yearsToPlot(iYear) & resultsClasses.covidAgeClass == iAge); 
        y = resultsClasses.excessCI(resultsClasses.Year == yearsToPlot(iYear) & resultsClasses.covidAgeClass == iAge, :);
        excessByAgeLo(iAge, iYear) = y(1);
        excessByAgeHi(iAge, iYear) = y(2);
    end

    for iSex = 1:2
        covidDeathsBySex(iSex, iYear) = covidData.bySex.deaths(covidData.bySex.Year == yearsToPlot(iYear) & covidData.bySex.sex == sexes(iSex));
        totDeathsBySex(iSex, iYear) = resultsSex.deaths(resultsSex.Year == yearsToPlot(iYear) & resultsSex.sex == sexes(iSex));
        predBySex(iSex, iYear) = resultsSex.dMean(resultsSex.Year == yearsToPlot(iYear) & resultsSex.sex == sexes(iSex));
        y = resultsSex.dCI(resultsSex.Year == yearsToPlot(iYear) & resultsSex.sex == sexes(iSex), :);
        predBySexLo(iSex, iYear) = y(1);
        predBySexHi(iSex, iYear) = y(2);
        excessBySex(iSex, iYear) = resultsSex.excess(resultsSex.Year == yearsToPlot(iYear) & resultsSex.sex == sexes(iSex)); 
        y = resultsSex.excessCI(resultsSex.Year == yearsToPlot(iYear) & resultsSex.sex == sexes(iSex), :);
        excessBySexLo(iSex, iYear) = y(1);
        excessBySexHi(iSex, iYear) = y(2);
    end
end
        
% Excess by age and sex compared to Covid deaths
h = figure(4);
h.Position = [   680   445   721   553];
tiledlayout(2, 2, "TileSpacing", "compact")
for iYear = 1:nYears
    % OLD PLOT WITH EXPECTED DEATHS OVERLAID ONTO NON COVID DEATHS AND
    % COVID DEATHS
    % nexttile;
    % negErr = predByAge(:, iYear)-predByAgeLo(:, iYear);
    % posErr = predByAgeHi(:, iYear)-predByAge(:, iYear);
    % bar([totDeathsByAge(:, iYear)-covidDeathsByAge(:, iYear), covidDeathsByAge(:, iYear) ], 'stacked')
    % hold on
    % errorbar(1:nAges, predByAge(:, iYear), negErr, posErr, 'go')
    % ylim([0 25000])
    % ylabel('yearly deaths')
    % legend('non-Covid', 'Covid', 'expected', 'Location', 'northwest'  )
    % h = gca;
    % h.XTickLabels = {'0-59', '60-69', '70-79', '80+'};
    % grid on
    % title(plotTitles(2*iYear-1))
    % xlabel('age (years)')

    nexttile;
    negErr = excessByAge(:, iYear)-excessByAgeLo(:, iYear);
    posErr = excessByAgeHi(:, iYear)-excessByAge(:, iYear);
    %set(gca, 'ColorOrderIndex', 2)
    b = bar(covidDeathsByAge(:, iYear));
    hold on
    errorbar(1:nAges, excessByAge(:, iYear), negErr, posErr, 'o')
    ylim([-300 2500])
    if iYear == 1
        legend('Covid deaths', 'excess deaths', 'Location', 'northwest'  )
    end
    ylabel('yearly deaths')
    h = gca;
    h.XTickLabels = {'0-59', '60-69', '70-79', '80+'};
    grid on
    xlabel('age (years)')
    title(plotTitles(iYear)+" "+string(yearsToPlot(iYear)) )
end
for iYear = 1:nYears
    nexttile;
    negErr = excessBySex(:, iYear)-excessBySexLo(:, iYear);
    posErr = excessBySexHi(:, iYear)-excessBySex(:, iYear);
    %set(gca, 'ColorOrderIndex', 2)
    b = bar(covidDeathsBySex(:, iYear));
    hold on
    errorbar(1:nSexes, excessBySex(:, iYear), negErr, posErr, 'o')
    ylim([0 2000])
    ylabel('yearly deaths')
    h = gca;
    h.XTickLabels = {'male', 'female'};
    grid on
    title(plotTitles(iYear+2)+" "+string(yearsToPlot(iYear)) )
end
saveas(gcf, resultsFolder+"Fig4.png");



        
% Excess by age and sex compared to Covid deaths - plotted as percentage
h = figure(44);
h.Position = [   680   445   721   553];
tiledlayout(2, 2, "TileSpacing", "compact")
for iYear = 1:nYears
    nexttile;
    negErr = (excessByAge(:, iYear)-excessByAgeLo(:, iYear))./predByAge(:, iYear);
    posErr = (excessByAgeHi(:, iYear)-excessByAge(:, iYear))./predByAge(:, iYear);
    %set(gca, 'ColorOrderIndex', 2)
    b = bar(100*covidDeathsByAge(:, iYear)./predByAge(:, iYear));
    hold on
    errorbar(1:nAges, 100*excessByAge(:, iYear)./predByAge(:, iYear), 100*negErr, 100*posErr, 'o')
    ylim([-5 15])
    if iYear == 1
        legend('Covid deaths', 'excess deaths', 'Location', 'northwest'  )
    end
    ylabel('yearly deaths as % of expected deaths')
    h = gca;
    h.XTickLabels = {'0-59', '60-69', '70-79', '80+'};
    grid on
    xlabel('age (years)')
    title(plotTitles(iYear)+" "+string(yearsToPlot(iYear)) )
end
for iYear = 1:nYears
    nexttile;
    negErr = (excessBySex(:, iYear)-excessBySexLo(:, iYear))./predBySex(:, iYear);
    posErr = (excessBySexHi(:, iYear)-excessBySex(:, iYear))./predBySex(:, iYear);
    %set(gca, 'ColorOrderIndex', 2)
    b = bar(100*covidDeathsBySex(:, iYear)./predBySex(:, iYear));
    hold on
    errorbar(1:nSexes, 100*excessBySex(:, iYear)./predBySex(:, iYear), 100*negErr, 100*posErr, 'o')
    ylim([0 12])
    ylabel('yearly deaths as % of expected deaths')
    h = gca;
    h.XTickLabels = {'male', 'female'};
    grid on
    title(plotTitles(iYear+2)+" "+string(yearsToPlot(iYear)) )
end
saveas(gcf, resultsFolder+"SuppFig1b.png");








h = figure(5);
h.Position = [ 680         609        1087         389];
tiledlayout(1, 2, "TileSpacing", 'compact')
nexttile;
for iYear = 1:nYears
    inFlag = results10.Year == yearsToPlot(iYear);
    y = results10.excess(inFlag);
    posErr = results10.excessCI(inFlag, 2) - y;
    negErr = y - results10.excessCI(inFlag, 1);
    errorbar(results10.age10(inFlag)+5, y, negErr, posErr, 'o-')
    hold on
end
xlabel('age (years)')
ylabel('yearly excess deaths')
grid on
legend(string(yearsToPlot), 'Location', 'northwest')
title('(a)')
nexttile;
for iYear = 1:nYears
    inFlag = results10.Year == yearsToPlot(iYear);
    y = results10.excess(inFlag)./results10.dMean(inFlag);
    posErr = results10.excessCI(inFlag, 2)./results10.dMean(inFlag) - y;
    negErr = y - results10.excessCI(inFlag, 1)./results10.dMean(inFlag);
    errorbar(results10.age10(inFlag)+5, 100*y, 100*negErr, 100*posErr, 'o-')
    hold on
end
xlabel('age (years)')
ylabel('yearly excess death (%)')
grid on
title('(b)')
saveas(gcf, resultsFolder+"SuppFig1.png");



% Plot deaths in 10-year age age groups 
h = figure(6);
h.Position = [ 560         292        1010         656];
tiledlayout(3, 4, "TileSpacing", "compact");
age10 = 0:10:90;
nAges = length(age10);
for iAge = 1:nAges
    nexttile;
    inFlag = results10.age10 == age10(iAge);
    [x, y] = getFillArgs(results10.Year(inFlag), results10.dCI(inFlag, 1), results10.dCI(inFlag, 2) );
    fill(x, y, lightBlue, 'LineStyle', 'none' )
    hold on
    plot(results10.Year(inFlag), results10.dMean(inFlag), 'b-')
    plot(results10.Year(inFlag), results10.deaths(inFlag), 'b.')
    xline(FIT_TO_YEAR+0.5, 'k--');
    xline(year0-0.5, 'k--');
    xlim([2010 2023])
    if age10(iAge) < 90
        title(sprintf("age %i-%i years", age10(iAge), age10(iAge)+9))
    else
        title(sprintf("age 90+ years"))
    end
    grid on
end
% Plot total aggregate yearly deaths in last tile
nexttile;
[x, y] = getFillArgs(resultsYearly.Year, resultsYearly.dCI(:, 1), resultsYearly.dCI(:, 2) );
fill(x, y, lightBlue, 'LineStyle', 'none' )
hold on
plot(resultsYearly.Year, resultsYearly.dMean, 'b-')
plot(resultsYearly.Year, resultsYearly.deaths, 'b.')
ylabel('number of deaths')
xline(FIT_TO_YEAR+0.5, 'k--');
xline(year0-0.5, 'k--');
xlim([2010 2023])
title('all ages')
grid on
sgtitle('yearly deaths in 10-year age bands')
%saveas(gcf, resultsFolder+"Fig6.png");




% Cumulative excess 
figure(7)
tPlot = covidData.monthly.Year + (covidData.monthly.month-1)/12;
hold on
set(gca, 'ColorOrderIndex', 2)
% Note +1/12 in the x-axis so that results for excess up to the end of e.g. Jan 2020 are plotted
% at t=2020+1/12
errorbar(resultsMonthly.Year+1/12, resultsMonthly.cumExcess, resultsMonthly.cumExcess-resultsMonthly.cumExcessCI(:, 1), resultsMonthly.cumExcessCI(:, 2)-resultsMonthly.cumExcess, '.-')
% Note +1 in the x-axis so that results for excess up to the end of e.g. 2020 are plotted
% at t=2021
plot(resultsYearly.Year(resultsYearly.Year >= 2019)+1, [0; cumsum(resultsYearly.SMRexcess(resultsYearly.Year >= 2020))], 'o-' )
xlim([2020 2024])
ylabel('cumulative deaths')
yline(0, 'k-');
legend( 'excess (monthly)', 'excess (SMR-LR)', 'location', 'northwest')
grid on
%saveas(gcf, resultsFolder+"Fig7.png");





% Plot raw monthly deaths in some individual strata 
a = [0, 5, 80:5:95];
nAges = length(a);
figure(100);
tiledlayout(3, 4, "TileSpacing", "compact")
for iAge = 1:nAges
    nexttile;
    inFlag = tbl.age == a(iAge) & tbl.sex == "male";
    tPlot = ORIGIN_YEAR + tbl.t(inFlag)/12;
    plot(tPlot, tbl.deaths(inFlag), '.', tPlot, tbl.dMean(inFlag), 'b-' ,tPlot, tbl.dCI(inFlag, 1), 'b:',tPlot, tbl.dCI(inFlag, 2), 'b:')
    xline(FIT_TO_YEAR+1, 'k--');
    xlim([year0, inf])
    title(sprintf("age %i, M", a(iAge)))
    grid on
    nexttile;
    inFlag = tbl.age == a(iAge) & tbl.sex == "female";
    plot(tPlot, tbl.deaths(inFlag), '.', tPlot, tbl.dMean(inFlag), 'b-', tPlot, tbl.dCI(inFlag, 1), 'b:', tPlot, tbl.dCI(inFlag, 2), 'b:')
    xline(FIT_TO_YEAR+1, 'k--');
    xlim([year0, inf])
    title(sprintf("age %i, F", a(iAge)))
    grid on
end
sgtitle('raw monthly deaths in selected strata')




