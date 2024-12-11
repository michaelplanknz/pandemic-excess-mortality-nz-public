function writeLatexTable(resultsSummary, SMRSummary, FIT_TO_YEAR, baselineYears, resultsFolder)

nScenarios = height(resultsSummary);

fid = fopen(resultsFolder+"table.tex", 'w');

fprintf(fid, '\\begin{tabular}{lrrrr} \n');
fprintf(fid, '\\hline\n');
fprintf(fid, 'Baseline period & \\multicolumn{3}{l}{Excess (QPR)} & Excess (SMR-LR) \\\\ \n');
fprintf(fid, '\\hline\n');

for iScenario = 1:nScenarios
    fprintf(fid, '%i--%i    &    %.0f [ & %.0f, & %.0f]   &   %.0f \\\\ \n', FIT_TO_YEAR-baselineYears(iScenario)+1, FIT_TO_YEAR, resultsSummary.excessAll(iScenario), resultsSummary.excessCIAll(iScenario, 1), resultsSummary.excessCIAll(iScenario, 2), SMRSummary.excessAll(iScenario) );
end

fprintf(fid, '\\hline\n');
fprintf(fid, '\\end{tabular}\n');
fclose(fid);



fid = fopen(resultsFolder+"supp_table.tex", 'w');

fprintf(fid, '\\begin{tabular}{lrrrr} \n');
fprintf(fid, '\\hline\n');
fprintf(fid, 'Baseline period & \\multicolumn{3}{l}{Excess (QPR)} & Excess (SMR-LR) \\\\ \n');
fprintf(fid, '\\hline\n');

for iScenario = 1:nScenarios
    fprintf(fid, '%i--%i    &    %.0f [ & %.0f, & %.0f]   &   %.0f \\\\ \n', FIT_TO_YEAR-baselineYears(iScenario)+1, FIT_TO_YEAR, resultsSummary.excess2020_22(iScenario), resultsSummary.excessCI2020_22(iScenario, 1), resultsSummary.excessCI2020_22(iScenario, 2), SMRSummary.excess2020_22(iScenario) );
end

fprintf(fid, '\\hline\n');
fprintf(fid, '\\end{tabular}\n');
fclose(fid);
