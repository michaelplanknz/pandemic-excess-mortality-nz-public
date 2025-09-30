function plotGraphs(tbl, resultsYearly, resultsMonthly, results10, resultsClasses, resultsSex, covidData, FIT_TO_YEAR, baselineYears, ORIGIN_YEAR, covidAgeBreaks, resultsFolder)

year0 = FIT_TO_YEAR-baselineYears+1;

plotTitles = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)"];

colOrd =colororder;
lightBlue = [0.7 0.8 0.95];
lightRed = [0.95 0.8 0.7];

% Total aggregate deaths
h = figure(1);
h.Position = [   374         124        1288         697];
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
h = figure(2);
h.Position = [    560         116        1118         832];
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
h.Position = [           333         378        1349         521];
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
h.Position = [    680   241   990   725];
tiledlayout(2, 2, "TileSpacing", "compact")
for iYear = 1:nYears
    nexttile;
    negErr = excessByAge(:, iYear)-excessByAgeLo(:, iYear);
    posErr = excessByAgeHi(:, iYear)-excessByAge(:, iYear);
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







h = figure(5);
h.Position = [         323         382        1246         461];
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



% Plot expected and actual deaths in 10 year age bands
ages = 0:10:90;
nAges = length(ages);
tRange = [2014, 2023];

h = figure(6);
h.Position = [95    89   904   879];
tiledlayout(4, 3, "TileSpacing", "compact");
for iAge = 1:nAges
    nexttile;
    ind = results10.age10 == ages(iAge);
    [x, y] = getFillArgs(results10.Year(ind), results10.dCI(ind, 1), results10.dCI(ind, 2)); 
    fill(x, y, lightBlue, 'LineStyle', 'none', 'FaceAlpha', 0.5, 'HandleVisibility', 'off' )
    hold on
    plot(results10.Year(ind), results10.dMean(ind), 'b-' )
    plot(results10.Year(ind), results10.deaths(ind), 'k.' )
    xline(2019.5, 'k--')
    xlim(tRange)
    grid on
    ylabel('yearly deaths')
    if iAge < nAges
        title(sprintf('%i-%i years', ages(iAge), ages(iAge)+9 ))
    else
        title('90+ years')
    end
end
nexttile;
[x, y] = getFillArgs(resultsYearly.Year, resultsYearly.dCI(:, 1), resultsYearly.dCI(:, 2)); 
fill(x, y, lightBlue, 'LineStyle', 'none', 'FaceAlpha', 0.5, 'HandleVisibility', 'off' )
hold on
plot(resultsYearly.Year, resultsYearly.dMean, 'b-' )
plot(resultsYearly.Year, resultsYearly.deaths, 'k.' )
xline(2019.5, 'k--')
xlim(tRange)
grid on
ylabel('yearly deaths')
title('total all ages')
leg = legend('expected deaths', 'actual deaths');
leg.Layout.Tile = 12;

drawnow

