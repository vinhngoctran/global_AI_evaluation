function R2 = ComputeR2(Obs,Sim)
data = [Obs(:), Sim(:)];
    data(data == -999) = NaN;
    data = rmmissing(data);  % Remove rows with NaNs
    Obs = data(:,1);
    Sim = data(:,2);
    mdl = fitlm(Obs,Sim);
    R2=mdl.Rsquared.Ordinary;
end

