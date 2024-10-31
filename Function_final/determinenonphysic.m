function [N_event, PE, T2P]= determinenonphysic(Obs,Sim,StartTime,PE_threshold)
Obs(Obs==-999)=NaN;
DATETIME = [StartTime:days(1):StartTime+days(numel(Obs)-1)]';
startDate = DATETIME(1);
endDate = DATETIME(end);
years = year(startDate):year(endDate);
N_event = [0, 0, 0,0];
PE = [0,0];
T2P = [0,0];
k = 0;
for y = years
 
    % Extract data for the current year
    yearData_obs = Obs(year(DATETIME) == y, :);
    yearData_sim = Sim(year(DATETIME) == y, :);

    if sum(isnan(yearData_obs))==0
        k=k+1;
        [PE(k,1), T2P(k,1)] = computeflooderror(yearData_obs,yearData_sim);
        N_event(1) = N_event(1)+1;
        if PE(k,1)<=PE_threshold              % Big observed flood but no simulated flood
            N_event(2)=N_event(2)+1;
        end

        [PE(k,2), T2P(k,2)] = computeflooderror(yearData_sim,yearData_obs); % No observed flood but big simulated flood
        N_event(3) = N_event(3)+1;
        if PE(k,2)<=PE_threshold              % Big observed flood but no simulated flood
            N_event(4)=N_event(4)+1;
        end
    end
end

end