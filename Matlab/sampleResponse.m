function [pred, designX] = sampleResponse(mdl, tbl, nSample)

% Calculate nSample sets of mean responses to a GLM in mdl by sampling the coefficients
% from a multivariate normal representing their approximate sampling distribution.
% tbl is the input table to the fitglm command 
% Function returns pred - a n x m matrix of predictions who ith row corresponds to the ith row of tbl and jth column is the jth sample
% and the design matrix (designX)

SMALL = 1e-8;

% Number of observations in data
nRows = height(tbl);

% Coefficient estimates in fitted model:
betaMean = mdl.Coefficients.Estimate;
nPars = length(betaMean);

% Coefficient covariance matrix:
betaCov = mdl.CoefficientCovariance;
[~, D] = eig(betaCov);
evMin = min(diag(D));
while evMin <= 0      % add small perturbation to ensure Sigma is positive definite
    betaCov = betaCov + (-evMin+SMALL)*eye(nPars);
    [~, D] = eig(betaCov);
    evMin = min(diag(D));
end


% String array of coefficient names
name = mdl.CoefficientNames;

% Construct model design matrix designX corresponding to the observations in tbl, with each row of designX corresponding to the same row of tbl, and each column of designX corresponding to one of the fitted coefficients
designX = nan(nRows, nPars);
for iPar = 1:nPars
    if string(name{iPar}) == "(Intercept)";
        designX(:, iPar) = ones(nRows, iPar);       % column of ones for the intercept temr
    else
        % split string at ":" to separate terms in an interaction variables
        intVars = split(string(name{iPar}), ":");
        nIntVars = length(intVars);
        % nIntVars is the number of interacting variables for this coefficient
        % if nIntVars=1, it is a non-interaction term and a single column will be calculated
        % if nIntVars>1, it is an interation term and one column wkll be calcuklated for each predictor variable in the interaction and the column of the design matrix will be set to the product of the interaction columns
        cols = nan(nRows, nIntVars);
        for iVar = 1:nIntVars
            if contains(intVars(iVar), "_")     % coefficient for a categorical predictor variable taking a specified category
                nameAndLevel = split(intVars(iVar), "_");
                assert(length(nameAndLevel) == 2);
                varName = nameAndLevel(1);
                varLevel = nameAndLevel(2);
                cols(:, iVar) = string(tbl{:, varName}) == varLevel;         % binary column indicating whether or not the predictor variable takes the specified level
            else                                % coefficient for a continuous predictor variable
                if contains(intVars(iVar), "^" )        % for polynomial terms of the form x_k^n with n>1 
                    varAndPower = split(intVars(iVar), "^");
                    pwr = double(varAndPower(2));
                    cols(:, iVar) = tbl{:, varAndPower(1) }.^pwr;
                else                                    % terms of the form x_k
                    cols(:, iVar) = tbl{:, intVars(iVar) };
                end
            end
        end
        designX(:, iPar) = prod(cols, 2);
    end
end

% Check that predictions computed from the constructed design matrix match 
predCheck1 = predict(mdl, tbl, 'Offset', tbl.offset);
predCheck2 =  mdl.Link.Inverse(tbl.offset + designX*betaMean );
maxErr = max(abs(predCheck1 - predCheck2));

if maxErr > 0
    fprintf('In sampleResponse: Max. abs. difference between output of predict and manual calculation of predictions via design matrix = %d\n', max(abs(predCheck1 - predCheck2)) );
end


% Bootstrap sample of coefficients from multivariate normal dist:
betaSample = mvnrnd(betaMean, betaCov, nSample)';

pred = mdl.Link.Inverse(tbl.offset + designX*betaSample );
