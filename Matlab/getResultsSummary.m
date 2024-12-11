function [resultsSummary, SMRSummary] = getResultsSummary(tbl, resultsYearly, Alpha, stdPopTot, iScenario)

qt = [Alpha/2, 1-Alpha/2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUMMARY RESULTS TABLE FOR QUASI-POSSION MODREL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resultsSummary.iScenario = iScenario;

% Summary of excess each year
resultsSummary.excess2020 = resultsYearly.excess(resultsYearly.Year == 2020);
resultsSummary.excessCI2020 = resultsYearly.excessCI(resultsYearly.Year == 2020, :);
resultsSummary.excess2021 = resultsYearly.excess(resultsYearly.Year == 2021);
resultsSummary.excessCI2021 = resultsYearly.excessCI(resultsYearly.Year == 2021, :);
resultsSummary.excess2022 = resultsYearly.excess(resultsYearly.Year == 2022);
resultsSummary.excessCI2022 = resultsYearly.excessCI(resultsYearly.Year == 2022, :);
resultsSummary.excess2023 = resultsYearly.excess(resultsYearly.Year == 2023);
resultsSummary.excessCI2023 = resultsYearly.excessCI(resultsYearly.Year == 2023, :);

% Aggregate over years 2020-2022
resultsSummary.excess2020_22 = sum(tbl.excess(tbl.Year >= 2020 & tbl.Year <= 2022));
resultsSummary.excessCI2020_22 = quantile(sum(tbl.excessMeanSamp(tbl.Year >= 2020 & tbl.Year <= 2022, :)), qt, 2);

% Aggregate over years 2020-2023
resultsSummary.excessAll = sum(tbl.excess(tbl.Year >= 2020 & tbl.Year <= 2023));
resultsSummary.excessCIAll = quantile(sum(tbl.excessMeanSamp(tbl.Year >= 2020 & tbl.Year <= 2023, :)), qt, 2);

% Summary of percent excess each year
resultsSummary.excess_pc2020 = resultsYearly.excess_pc(resultsYearly.Year == 2020);
resultsSummary.excess_pcCI2020 = resultsYearly.excess_pcCI(resultsYearly.Year == 2020, :);
resultsSummary.excess_pc2021 = resultsYearly.excess_pc(resultsYearly.Year == 2021);
resultsSummary.excess_pcCI2021 = resultsYearly.excess_pcCI(resultsYearly.Year == 2021, :);
resultsSummary.excess_pc2022 = resultsYearly.excess_pc(resultsYearly.Year == 2022);
resultsSummary.excess_pcCI2022 = resultsYearly.excess_pcCI(resultsYearly.Year == 2022, :);
resultsSummary.excess_pc2023 = resultsYearly.excess_pc(resultsYearly.Year == 2023);
resultsSummary.excess_pcCI2023 = resultsYearly.excess_pcCI(resultsYearly.Year == 2023, :);

% Aggregate over years 2020-2022
resultsSummary.excess_pc2020_22 = resultsSummary.excess2020_22/sum(tbl.dMean(tbl.Year >= 2020 & tbl.Year <= 2022) );
resultsSummary.excess_pcCI2020_22 = resultsSummary.excessCI2020_22/sum(tbl.dMean(tbl.Year >= 2020 & tbl.Year <= 2022) );

% Aggregate over years 2020-2023
resultsSummary.excess_pcAll = resultsSummary.excessAll/sum(tbl.dMean(tbl.Year >= 2020 & tbl.Year <= 2023) );
resultsSummary.excess_pcCIAll = resultsSummary.excessCIAll/sum(tbl.dMean(tbl.Year >= 2020 & tbl.Year <= 2023) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUMMARY RESULTS TABLE FOR SMR LINEAR REGRESSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SMRSummary.iScenario= iScenario;
SMRSummary.excess2020 = resultsYearly.SMRexcess(resultsYearly.Year == 2020);
SMRSummary.excess2021 = resultsYearly.SMRexcess(resultsYearly.Year == 2021);
SMRSummary.excess2022 = resultsYearly.SMRexcess(resultsYearly.Year == 2022);
SMRSummary.excess2023 = resultsYearly.SMRexcess(resultsYearly.Year == 2023);
SMRSummary.excess2020_22 = sum(resultsYearly.SMRexcess(resultsYearly.Year >= 2020 & resultsYearly.Year <= 2022));
SMRSummary.excessAll = sum(resultsYearly.SMRexcess(resultsYearly.Year >= 2020 & resultsYearly.Year <= 2023));
SMRSummary.excess_pc2020 = resultsYearly.SMRexcess_pc(resultsYearly.Year == 2020);
SMRSummary.excess_pc2021 = resultsYearly.SMRexcess_pc(resultsYearly.Year == 2021);
SMRSummary.excess_pc2022 = resultsYearly.SMRexcess_pc(resultsYearly.Year == 2022);
SMRSummary.excess_pc2023 = resultsYearly.SMRexcess_pc(resultsYearly.Year == 2023);
SMRSummary.excess_pc2020_22 = SMRSummary.excess2020_22./sum(resultsYearly.SMRmean(resultsYearly.Year >= 2020 & resultsYearly.Year <= 2022)*stdPopTot);
SMRSummary.excess_pcAll = SMRSummary.excessAll./sum(resultsYearly.SMRmean(resultsYearly.Year >= 2020 & resultsYearly.Year <= 2023)*stdPopTot);


resultsSummary = struct2table(resultsSummary);
SMRSummary = struct2table(SMRSummary);

