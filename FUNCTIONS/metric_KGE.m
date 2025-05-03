function enKGE = metric_KGE(observed, simulated)
valid = all(~isnan([observed, simulated]), 2);
observed = observed(valid);
simulated = simulated(valid, :);
for i = 1:size(simulated, 2)
    try
        enKGE(i) = computeKGE(observed, simulated(:, i));
    catch
        enKGE(i) = NaN;
    end
end
end

function KGE = computeKGE(observed,simulated)
     % Ensure column vectors
    observed = observed(:);
    simulated = simulated(:);

    % Remove missing data marked as -999
    data = [observed, simulated];
    data(data == -999) = NaN;
    data = rmmissing(data);
    observed = data(:,1);
    simulated = data(:,2);

    % Statistics
    r = corr(observed, simulated);                  % Correlation
    meanObs = mean(observed);
    meanSim = mean(simulated);
    stdObs = std(observed);
    stdSim = std(simulated);

    beta = meanSim / meanObs;                       % Bias ratio
    gamma = (stdSim / meanSim) / (stdObs / meanObs); % Variability ratio

    % KGE calculation
    KGE = 1 - sqrt((r - 1)^2 + (beta - 1)^2 + (gamma - 1)^2);
end
