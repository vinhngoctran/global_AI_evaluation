function export_figure_3_data_to_excel()
    load('RESULTS2\R8_Regional_GB_2.mat', 'Qobs', 'Qsim', "TimeDATE", "StationID", 'InforSelec', 'DataAll', 'OverlapInfo', 'AREA_all', 'overlapdata');
    T_GB = table();
    T_US = table();
    T_CNRFC = table();

    % Process GB data
    for i = 1:size(OverlapInfo, 1)
        NSEvalue_GB(i,1) = Nash(DataAll{i,1}(:,2), DataAll{i,1}(:,1));
        NSEvalue_GB(i,2) = Nash(DataAll{i,1}(:,4), DataAll{i,1}(:,3));
        
        [flood_events, event_peaks, event_dates] = find_flood_events(DataAll{i,1}(:,2));
        NSE_flood_GB = zeros(numel(flood_events), 2);
        for j = 1:numel(flood_events)
            NSE_flood_GB(j,1) = Nash(DataAll{i,1}(event_dates{j},2), DataAll{i,1}(event_dates{j},1));
            NSE_flood_GB(j,2) = Nash(DataAll{i,1}(event_dates{j},4), DataAll{i,1}(event_dates{j},3));
        end
        NSE_flood_mean_GB(i,1) = mean(NSE_flood_GB(:,1), 'omitnan');
        NSE_flood_mean_GB(i,2) = mean(NSE_flood_GB(:,2), 'omitnan');
    end
    
    T_GB.NSE_Global = NSEvalue_GB(:,1);
    T_GB.NSE_Regional = NSEvalue_GB(:,2);
    T_GB.NSE_Event_Global = NSE_flood_mean_GB(:,1);
    T_GB.NSE_Event_Regional = NSE_flood_mean_GB(:,2);
    T_GB.Latitude = OverlapInfo(:,3);
    T_GB.Longitude = OverlapInfo(:,4);

    % Process US data
    load('RESULTS2\R8_Regional_US_2.mat', 'all_qsim', 'all_qobs', 'InforSelec', 'Time', 'DataAll', 'OverlapInfo', 'AREA_all', 'overlapdata_US');
   
    for i = 1:size(OverlapInfo, 1)
        NSEvalue_US(i,1) = Nash(DataAll{i,1}(:,2), DataAll{i,1}(:,1));
        NSEvalue_US(i,2) = Nash(DataAll{i,1}(:,4), DataAll{i,1}(:,3));
        
        [flood_events, event_peaks, event_dates] = find_flood_events(DataAll{i,1}(:,2));
        NSE_flood_US = zeros(numel(flood_events), 2);
        for j = 1:numel(flood_events)
            NSE_flood_US(j,1) = Nash(DataAll{i,1}(event_dates{j},2), DataAll{i,1}(event_dates{j},1));
            NSE_flood_US(j,2) = Nash(DataAll{i,1}(event_dates{j},4), DataAll{i,1}(event_dates{j},3));
        end
        NSE_flood_mean_US(i,1) = mean(NSE_flood_US(:,1), 'omitnan');
        NSE_flood_mean_US(i,2) = mean(NSE_flood_US(:,2), 'omitnan');
    end
    
    T_US.NSE_Global = NSEvalue_US(:,1);
    T_US.NSE_Regional = NSEvalue_US(:,2);
    T_US.NSE_Event_Global = NSE_flood_mean_US(:,1);
    T_US.NSE_Event_Regional = NSE_flood_mean_US(:,2);
    T_US.Latitude = OverlapInfo(:,2);
    T_US.Longitude = OverlapInfo(:,3);

    % Process CNRFC data
     load('RESULTS2\R8_Regional_CNRFC_2.mat', 'Time', 'DataAll', 'OverlapInfo', 'overlapdata_CNRFC');

    for i = 1:size(OverlapInfo, 1)
        for LT = 1:4
            NSEvalue_CNRFC(i,1,LT) = Nash(DataAll{i,1}(:,9), DataAll{i,1}(:,LT+1));
            NSEvalue_CNRFC(i,2,LT) = Nash(DataAll{i,2}(:,9), DataAll{i,2}(:,LT+1));
            NSEvalue_CNRFC(i,3,LT) = Nash(DataAll{i,1}(1+LT:end,14), DataAll{i,1}(1:end-LT,9+LT));

            [flood_events, event_peaks, event_dates] = find_flood_events(DataAll{i,1}(:,9));
            NSE_flood_CNRFC = zeros(numel(flood_events), 3);
            for j = 1:numel(flood_events)
                NSE_flood_CNRFC(j,1,LT) = Nash(DataAll{i,1}(event_dates{j},9), DataAll{i,1}(event_dates{j},LT+1));
                NSE_flood_CNRFC(j,2,LT) = Nash(DataAll{i,2}(event_dates{j},9), DataAll{i,2}(event_dates{j},LT+1));
                NSE_flood_CNRFC(j,3,LT) = Nash(DataAll{i,1}(event_dates{j},14), DataAll{i,1}(event_dates{j}-LT,9+LT));
            end
            NSE_flood_mean_CNRFC(i,1,LT) = mean(NSE_flood_CNRFC(:,1,LT), 'omitnan');
            NSE_flood_mean_CNRFC(i,2,LT) = mean(NSE_flood_CNRFC(:,2,LT), 'omitnan');
            NSE_flood_mean_CNRFC(i,3,LT) = mean(NSE_flood_CNRFC(:,3,LT), 'omitnan');
        end
    end
    
    for LT = 1:4
        T_CNRFC.(['NSE_AI_LT', num2str(LT)]) = NSEvalue_CNRFC(:,2,LT);
        T_CNRFC.(['NSE_PBM_LT', num2str(LT)]) = NSEvalue_CNRFC(:,3,LT);
        T_CNRFC.(['NSE_Event_AI_LT', num2str(LT)]) = NSE_flood_mean_CNRFC(:,2,LT);
        T_CNRFC.(['NSE_Event_PBM_LT', num2str(LT)]) = NSE_flood_mean_CNRFC(:,3,LT);
    end
    T_CNRFC.Latitude = OverlapInfo(:,1);
    T_CNRFC.Longitude = OverlapInfo(:,2);

    % Write all tables to separate sheets in an Excel file
    filename = 'FigureData/figure_3_data.xlsx';
    writetable(T_GB, filename, 'Sheet', 'GB_Data');
    writetable(T_US, filename, 'Sheet', 'US_Data');
    writetable(T_CNRFC, filename, 'Sheet', 'CNRFC_Data');

    disp(['Data exported to ', filename]);
end