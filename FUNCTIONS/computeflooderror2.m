function [PE] = computeflooderror2(Obs, Sim)
try
PE = (max(Sim)-max(Obs))/max(Obs)*100; % Percentage
if isnan(PE)
end
catch
PE = NaN;
end
end