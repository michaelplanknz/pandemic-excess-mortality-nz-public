function [SMRmean, SMRCI, SMRexcess, SMRexcess_pc] = fitSMRModel(resultsYearly, FIT_TO_YEAR, baselineYears, Alpha, stdPopTot)

% Years to include in regression
ind = resultsYearly.Year <= FIT_TO_YEAR & resultsYearly.Year >= FIT_TO_YEAR - baselineYears + 1;

% Fit linear regression
mdlASMR = fitglm(resultsYearly(ind, :), "SMR ~ Year");

% Evaluate linear regression to obtain baseline
[SMRmean, SMRCI] = predict(mdlASMR, resultsYearly, 'Alpha', Alpha);

% Estimate excess and percent excess
SMRexcess = (resultsYearly.SMR-SMRmean)*stdPopTot;  
SMRexcess_pc = SMRexcess./(SMRmean*stdPopTot);  


