classdef SimpleLogPearson3Fitter
    properties
        transformed_sample
        distribution_parameters
        sample_moments
        log_transform
        original_data
    end
    
    methods
        function obj = SimpleLogPearson3Fitter(data, log_transform)
            if nargin < 2
                log_transform = true;
            end
            
            obj.original_data = data;
            obj.log_transform = log_transform;
            
            if log_transform
                obj.transformed_sample = log(data);
            else
                obj.transformed_sample = data;
            end
            
            obj.distribution_parameters = pearson3_parameters_simple(obj.transformed_sample);
            [mean_val, std_val, skew_val] = sample_moments(obj.transformed_sample);
            obj.sample_moments = struct('mean', mean_val, 'std', std_val, 'skew', skew_val);
        end
        
        function type_name = get.type_name(obj)
            type_name = 'SimpleLogPearson3Fitter';
        end
        
        function exceedance_probs = exceedance_probabilities_from_flow_values(obj, flows)
            if any(flows <= 0)
                error('All flow values must be positive.');
            end
            
            transformed_flows = obj.transform_data(flows);
            cdf_values = pearson3_cdf(...
                obj.distribution_parameters.alpha, ...
                obj.distribution_parameters.beta, ...
                obj.distribution_parameters.tau, ...
                transformed_flows);
            
            exceedance_probs = 1 - cdf_values;
        end
        
        function flow_values = flow_values_from_exceedance_probabilities(obj, exceedance_probabilities)
            quantiles = 1 - exceedance_probabilities;
            transformed_flows = pearson3_invcdf(...
                obj.distribution_parameters.alpha, ...
                obj.distribution_parameters.beta, ...
                obj.distribution_parameters.tau, ...
                quantiles);
            
            flow_values = obj.untransform_data(transformed_flows);
        end
        
        function transformed = transform_data(obj, data)
            if obj.log_transform
                transformed = log(data);
            else
                transformed = data;
            end
        end
        
        function untransformed = untransform_data(obj, data)
            if obj.log_transform
                untransformed = exp(data);
            else
                untransformed = data;
            end
        end
    end
end

function [mean_val, std_val, skew_val] = sample_moments(data)
    MIN_DATA_POINTS = 7;
    
    n = length(data);
    if n < MIN_DATA_POINTS
        error('Not enough data points. Need at least %d, got %d.', MIN_DATA_POINTS, n);
    end
    
    mean_val = mean(data);
    std_val = sqrt(n/(n-1) * mean((data - mean_val).^2));
    skew_val = sqrt(n*(n-1))/(n-2) * mean(((data - mean_val)./std_val).^3);
end

function params = parameters_from_moments(mean_val, std_val, skew_val)
    MIN_ALLOWED_SKEW = 0.000016;
    
    if abs(skew_val) < MIN_ALLOWED_SKEW
        error('NumericalFittingError: Small Skew');
    end
    
    alpha = 4 / skew_val^2;
    beta = std_val * skew_val / 2;
    tau = mean_val - 2 * std_val / skew_val;
    
    params = struct('alpha', alpha, 'beta', beta, 'tau', tau);
end

function params = pearson3_parameters_simple(data)
    [mean_val, std_val, skew_val] = sample_moments(data);
    params = parameters_from_moments(mean_val, std_val, skew_val);
end

function inv_cdf_values = pearson3_invcdf(alpha, beta, tau, quantiles)
    if any(quantiles <= 0) || any(quantiles >= 1)
        error('Quantiles must be between 0 and 1 exclusive.');
    end
    
    if beta >= 0
        inverse_gamma = gammaincinv(alpha, quantiles);
    else
        inverse_gamma = gammaincinv(alpha, 1 - quantiles, 'upper');
    end
    
    inv_cdf_values = tau + beta * inverse_gamma;
end

function cdf_values = pearson3_cdf(alpha, beta, tau, values)
    if beta >= 0
        cdf_values = gammainc((values - tau) / beta, alpha);
    else
        cdf_values = gammainc((values - tau) / beta, alpha, 'upper');
    end
end

function pmf_values = pearson3_pmf(alpha, beta, tau, edges)
    cdf_values = pearson3_cdf(alpha, beta, tau, edges);
    pmf_values = diff(cdf_values);
end

%% Backtesting functions
function backtest_equivalence()
    % Test data
    rng(42); % For reproducibility
    test_data = exp(randn(100, 1) * 100 + 10; % Lognormal-like data
    
    % Test with log transform
    fprintf('Testing with log transform...\n');
    py_fitter = py.backend.return_period_calculator.naive_fitter.SimpleLogPearson3Fitter(...
        py.numpy.array(test_data), true);
    mat_fitter = SimpleLogPearson3Fitter(test_data, true);
    
    compare_fitters(py_fitter, mat_fitter, test_data);
    
    % Test without log transform
    fprintf('\nTesting without log transform...\n');
    py_fitter = py.backend.return_period_calculator.naive_fitter.SimpleLogPearson3Fitter(...
        py.numpy.array(test_data), false);
    mat_fitter = SimpleLogPearson3Fitter(test_data, false);
    
    compare_fitters(py_fitter, mat_fitter, test_data);
end

function compare_fitters(py_fitter, mat_fitter, test_data)
    % Compare moments
    py_moments = py_fitter._sample_moments;
    mat_moments = mat_fitter.sample_moments;
    
    fprintf('\nMoments comparison:\n');
    fprintf('Mean: Python=%f, MATLAB=%f, Diff=%g\n', ...
        py_moments{1}, mat_moments.mean, abs(py_moments{1} - mat_moments.mean));
    fprintf('Std: Python=%f, MATLAB=%f, Diff=%g\n', ...
        py_moments{2}, mat_moments.std, abs(py_moments{2} - mat_moments.std));
    fprintf('Skew: Python=%f, MATLAB=%f, Diff=%g\n', ...
        py_moments{3}, mat_moments.skew, abs(py_moments{3} - mat_moments.skew));
    
    % Compare parameters
    py_params = py_fitter._distribution_parameters;
    mat_params = mat_fitter.distribution_parameters;
    
    fprintf('\nParameters comparison:\n');
    fprintf('Alpha: Python=%f, MATLAB=%f, Diff=%g\n', ...
        py_params{'alpha'}, mat_params.alpha, abs(py_params{'alpha'} - mat_params.alpha));
    fprintf('Beta: Python=%f, MATLAB=%f, Diff=%g\n', ...
        py_params{'beta'}, mat_params.beta, abs(py_params{'beta'} - mat_params.beta));
    fprintf('Tau: Python=%f, MATLAB=%f, Diff=%g\n', ...
        py_params{'tau'}, mat_params.tau, abs(py_params{'tau'} - mat_params.tau));
    
    % Test flow to probability conversion
    test_flows = linspace(min(test_data), max(test_data), 10);
    py_probs = py_fitter.exceedance_probabilities_from_flow_values(py.numpy.array(test_flows));
    mat_probs = mat_fitter.exceedance_probabilities_from_flow_values(test_flows);
    
    fprintf('\nFlow to probability comparison:\n');
    for i = 1:length(test_flows)
        fprintf('Flow=%f: Python=%f, MATLAB=%f, Diff=%g\n', ...
            test_flows(i), py_probs{i}, mat_probs(i), abs(py_probs{i} - mat_probs(i)));
    end
    
    % Test probability to flow conversion
    test_probs = linspace(0.01, 0.99, 10);
    py_flows = py_fitter.flow_values_from_exceedance_probabilities(py.numpy.array(test_probs));
    mat_flows = mat_fitter.flow_values_from_exceedance_probabilities(test_probs);
    
    fprintf('\nProbability to flow comparison:\n');
    for i = 1:length(test_probs)
        fprintf('Prob=%f: Python=%f, MATLAB=%f, Diff=%g\n', ...
            test_probs(i), py_flows{i}, mat_flows(i), abs(py_flows{i} - mat_flows(i)));
    end
end