clear
close all

% Folder and file locations 
resultsFolder = "../results/";
fIn2018 = resultsFolder + "results_ERP_2018_base.mat";
fIn2023 = resultsFolder + "results_ERP_2023_base.mat";

% Read in results for ERP 2018 base and 2023 base
read2018 = load(fIn2018);
read2023 = load(fIn2023);

lightBlue = [0.7 0.7 1];
lightRed = [1 0.7 0.7];

% Plot expected and actual deaths in 10 year age bands
ages = 0:10:90;
nAges = length(ages);
tRange = [2014, 2023];
Alpha = 0.4;

h = figure(1);
h.Position = [95    89   904   879];
tiledlayout(4, 3, "TileSpacing", "compact");
for iAge = 1:nAges
    nexttile;
    ind2018 = read2018.results10.age10 == ages(iAge);
    ind2023 = read2023.results10.age10 == ages(iAge);
    [x, y] = getFillArgs(read2018.results10.Year(ind2018), read2018.results10.dCI(ind2018, 1), read2018.results10.dCI(ind2018, 2)); 
    fill(x, y, lightBlue, 'LineStyle', 'none', 'FaceAlpha', Alpha, 'HandleVisibility', 'off' )
    hold on
    [x, y] = getFillArgs(read2023.results10.Year(ind2023), read2023.results10.dCI(ind2023, 1), read2023.results10.dCI(ind2023, 2)); 
    fill(x, y, lightRed, 'LineStyle', 'none', 'FaceAlpha', Alpha, 'HandleVisibility', 'off' )
    plot(read2018.results10.Year(ind2018), read2018.results10.dMean(ind2018), 'b-' )
    plot(read2023.results10.Year(ind2023), read2023.results10.dMean(ind2023), 'r-' )
    plot(read2023.results10.Year(ind2023), read2023.results10.deaths(ind2023), 'k.' )
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
[x, y] = getFillArgs(read2018.resultsYearly.Year, read2018.resultsYearly.dCI(:, 1), read2018.resultsYearly.dCI(:, 2)); 
fill(x, y, lightBlue, 'LineStyle', 'none', 'FaceAlpha', Alpha, 'HandleVisibility', 'off' )
hold on
[x, y] = getFillArgs(read2023.resultsYearly.Year, read2023.resultsYearly.dCI(:, 1), read2023.resultsYearly.dCI(:, 2)); 
fill(x, y, lightRed, 'LineStyle', 'none', 'FaceAlpha', Alpha, 'HandleVisibility', 'off' )
plot(read2018.resultsYearly.Year, read2018.resultsYearly.dMean, 'b-' )
plot(read2023.resultsYearly.Year, read2023.resultsYearly.dMean, 'r-' )
plot(read2023.resultsYearly.Year, read2023.resultsYearly.deaths, 'k.' )
xline(2019.5, 'k--')
xlim(tRange)
grid on
ylabel('yearly deaths')
title('total all ages')
leg = legend('expected deaths (ERP 2018 base)', 'expected deaths (ERP 2023 base)', 'actual deaths');
leg.Layout.Tile = 12;


