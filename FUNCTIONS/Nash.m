function NSE = Nash(Qobs,Qsim)
try
    data = [Qobs(:), Qsim(:)];
    data(data == -999) = NaN;
    data = rmmissing(data);  % Remove rows with NaNs
    Qobs_clean = data(:,1);
    Qsim_clean = data(:,2);
    Qobs_mean = mean(Qobs_clean);
    numerator = sum((Qsim_clean - Qobs_clean).^2);
    denominator = sum((Qobs_clean - Qobs_mean).^2);
    NSE = 1 - (numerator / denominator);
catch
    NSE = NaN;
end