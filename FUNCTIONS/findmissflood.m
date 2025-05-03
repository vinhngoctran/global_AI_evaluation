function [idx YYYY] = findmissflood(Obs,Sim,StartTime,PE_threshold)
Obs(Obs==-999)=NaN;
DATETIME = [StartTime:days(1):StartTime+days(numel(Obs)-1)]';
startDate = DATETIME(1);
endDate = DATETIME(end);
years = year(startDate):year(endDate);
N_event = [0, 0, 0,0];
MaxX = 0;
MaxY = 0;
for y = years
 
    % Extract data for the current year
    yearData_obs = Obs(year(DATETIME) == y, :);
    yearData_sim = Sim(year(DATETIME) == y, :);

    if sum(isnan(yearData_obs))==0
        [PE, T2P] = computeflooderror(yearData_obs,yearData_sim);
        N_event(1) = N_event(1)+1;
        if PE<=PE_threshold              % Big observed flood but no simulated flood
            N_event(2)=N_event(2)+1;
            if max(yearData_obs)>MaxX
                MaxX = max(yearData_obs);
                idx(1) = find(yearData_obs==max(yearData_obs));
                YYYY(1) = y;
            end
        end

        [PE, T2P] = computeflooderror(yearData_sim,yearData_obs); % No observed flood but big simulated flood
        N_event(3) = N_event(3)+1;
        if PE<=PE_threshold              % Big observed flood but no simulated flood
            N_event(4)=N_event(4)+1;
            if max(yearData_sim)>MaxY
                MaxY = max(yearData_sim);
            idx(2) = find(yearData_sim==max(yearData_sim));
            YYYY(2) = y;
            end
        end
    end
end

end