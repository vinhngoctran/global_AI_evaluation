function [PE, T2P] = computeflooderror(Obs, Sim)
try
idx = find(Obs==max(Obs));
idy = find(Sim(idx(1)-10:idx(1)+10)==max(Sim(idx(1)-10:idx(1)+10)));  % Consider 21-day flood event with peak at day 11
PE = (max(Sim(idx(1)-10:idx(1)+10))-max(Obs))/max(Obs)*100; % Percentage
T2P = idy(1)-11; % day
if isnan(PE)
    T2P = NaN;
end
catch
PE = NaN;
T2P = NaN;
end
end