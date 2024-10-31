function export_figure_2_data_to_excel()
%%
% clear
   % Load all necessary data
    load('RESULTS2\R3_NearingNSE.mat', "NSEvalue", "NSEmark", "BasinInfo");
    load('RESULTS2/R4_2_NearingHydrological_final.mat', 'RP', 'checkdata', 'FloodFrequency', 'FloodFrequency_delta', 'PE', 'T2P', 'StartEndYear');
    load('RESULTS2\R3_Nearing_sim.mat', 'StartTime');
    load('RESULTS2\R6_CheckReliablePrediction.mat', "Raindata", "OBS_check", "SIM_check", 'TimeRain', 'idx_overlap', 'NameIDX');
    load('RESULTS2/R7_nophysic.mat', 'N_event');
    load('RESULTS\R2_Nearring_watershed.mat', 'BasinNearing');

    % Create tables for each dataset
    varNames = arrayfun(@(x) sprintf('FF_delta_%dyr', x), 1:size(FloodFrequency_delta,2), 'UniformOutput', false);
    T1 = array2table(FloodFrequency_delta, 'VariableNames', varNames);
    
    T2 = table(PE, T2P, 'VariableNames', {'PE', 'T2P'});
    T3 = table(checkdata, 'VariableNames', {'checkdata'});
    
    % Create time series for OBS_check and SIM_check
    DATETIME = (StartTime(1):days(1):StartTime(1)+days(size(OBS_check,1)-1))';
    T4 = table(DATETIME, OBS_check, SIM_check);
    
    % Create time series for Raindata
    T5 = table(TimeRain, Raindata);
    
    % Process N_event data
    PE_threshold = [-99 -95:5:-50];
    NonphysicEvent = zeros(numel(PE_threshold), 2);
    for j = 1:numel(PE_threshold)
        NonphysicEvent(j,:) = [sum(N_event{j,1}(:,2)) sum(N_event{j,1}(:,4))];
    end
    T6 = table(PE_threshold', NonphysicEvent(:,1), NonphysicEvent(:,2), 'VariableNames', {'PE_threshold', 'Missed_flood', 'False_flood'});
    
    % Process continent data
    for i = 1:size(BasinNearing,1)
        ContinentIn(i,1) = string(BasinNearing.Continent{i});
    end
    uniqContinent = unique(ContinentIn);
    Nonphysic_continent = zeros(numel(uniqContinent), 2, 11);
    for j = 1:numel(uniqContinent)
        idx = find(ContinentIn == uniqContinent{j});
        for i = 1:11
            Nonphysic_continent(j,:,i) = [sum(N_event{i,1}(idx,2))/sum(N_event{i,1}(idx,1)) sum(N_event{i,1}(idx,4))/sum(N_event{i,1}(idx,3))]*100;
        end
    end
    T7 = table(uniqContinent, squeeze(Nonphysic_continent(:,1,11)), squeeze(Nonphysic_continent(:,2,11)), 'VariableNames', {'Continent', 'Missed_flood_percent', 'False_flood_percent'});

    % Write all tables to separate sheets in an Excel file
    filename = 'FigureData/F2.xlsx';
    writetable(T1, filename, 'Sheet', 'FloodFrequency_delta');
    writetable(T2, filename, 'Sheet', 'PE_T2P');
    writetable(T3, filename, 'Sheet', 'checkdata');
    writetable(T4, filename, 'Sheet', 'OBS_SIM_check');
    writetable(T5, filename, 'Sheet', 'Raindata');
    writetable(T6, filename, 'Sheet', 'NonphysicEvent');
    writetable(T7, filename, 'Sheet', 'Nonphysic_continent');

    disp(['Data exported to ', filename]);
end