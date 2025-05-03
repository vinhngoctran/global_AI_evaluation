function Quantiles = flood_frequency_analysis(flood_data)
P = flood_data(:,2);
[paramEsts, paramCI] = gevfit(P);

k = paramEsts(1); % shape
sigma = paramEsts(2); % scale
mu = paramEsts(3); % location

% Confidence intervals
k_CI = paramCI(:,1);
sigma_CI = paramCI(:,2);
mu_CI = paramCI(:,3);

% 3. Define Return Periods and Probabilities
ReturnPeriods = [5, 10, 20, 50, 100];
NonExceedProb = 1 - 1./ReturnPeriods; % e.g., 1-1/2 = 0.5

% 4. Calculate Quantiles
Quantiles = gevinv(NonExceedProb, k, sigma, mu); % Main quantile

% For lower and upper bounds, use lower and upper params
Quantiles_Low = gevinv(NonExceedProb, k_CI(1), sigma_CI(1), mu_CI(1));
Quantiles_Upp = gevinv(NonExceedProb, k_CI(2), sigma_CI(2), mu_CI(2));
end