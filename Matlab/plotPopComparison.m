clear 
close all

% Folder locations 
dataFolder = "../data/";


% Data file names
fNamePop2018 = dataFolder + "infoshare_ERP_quarterly_2018_base.csv";
fNamePop2023 = dataFolder + "infoshare_ERP_quarterly_2023_base.csv";

% Read population data (admin pop data needs a call to a different function
% as it is a different format)
popData2018 = getPopData(fNamePop2018);
popData2023 = getPopData(fNamePop2023);

% Aggregate into 10 year age bands
popData2018 = calcPopData10(popData2018);
popData2023 = calcPopData10(popData2023);

% Get pop totals
popTot2018 = groupsummary(popData2018, "t", "sum", "sum_popSize");
popTot2023 = groupsummary(popData2023, "t", "sum", "sum_popSize");



% Plot
ages = 0:10:90;
nAges = length(ages);

tRange = [datetime(2018, 1,1), datetime(2023,12, 31)];

h = figure(1);
h.Position = [95    89   904   879];
tiledlayout(4, 3, "TileSpacing", "compact");
for iAge = 1:nAges
    nexttile;
    ind = popData2018.age10 == ages(iAge);
    plot(popData2018.t(ind), popData2018.sum_popSize(ind), '.-')
    hold on
    ind = popData2023.age10 == ages(iAge);
    plot(popData2023.t(ind), popData2023.sum_popSize(ind), '.-')
    ylabel('population size')
    xlim(tRange)
    grid on
    if iAge < nAges
        title(sprintf('%i-%i years', ages(iAge), ages(iAge)+9 ))
    else
        title('90+ years')
    end
end
nexttile;
plot(popTot2018.t, popTot2018.sum_sum_popSize, '.-')
hold on
plot(popTot2023.t, popTot2023.sum_sum_popSize, '.-')
grid on
xlim(tRange)
ylabel('population size')
title('total all ages')
leg = legend('original (ERP 2018 base)', 'updated (ERP 2023 base)');
leg.Layout.Tile = 12;




h = figure(2);
h.Position = [95    89   904   879];
tiledlayout(4, 3, "TileSpacing", "compact");
for iAge = 1:nAges
    nexttile;
    ind = popData2018.age10 == ages(iAge);
    plot(popData2018.t(ind), 100*(popData2023.sum_popSize(ind)./popData2018.sum_popSize(ind) - 1), '.-')
    yline(0, 'k-')
    ylabel('change in pop estmiate (%)')
    xlim(tRange)
    ylim([-5 1])
    grid on
    if iAge < nAges
        title(sprintf('%i-%i years', ages(iAge), ages(iAge)+9 ))
    else
        title('90+ years')
    end
end
nexttile;
plot(popTot2018.t, 100*(popTot2023.sum_sum_popSize./popTot2018.sum_sum_popSize - 1), '.-')
yline(0, 'k-')
xlim(tRange)
ylim([-5 1])
grid on
ylabel('change in pop estmiate (%)')
title('total all ages')
