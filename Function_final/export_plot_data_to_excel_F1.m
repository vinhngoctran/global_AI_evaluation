function export_plot_data_to_excel()
%%
    % Load the necessary data
    load('RESULTS2\R3_NearingNSE.mat', 'NSEvalue', 'NSEmark', 'BasinInfo');
    load('RESULTS\R2_Nearring_watershed.mat', 'MISSINGBasin', 'DamAttribute', 'Area_nearing', 'BasinNearing');

    % Calculate RatioVol
    for i = 1:size(BasinNearing, 1)
        RatioVol(i,1) = BasinInfo(i,1) / BasinNearing.calculated_drain_area(i);
        ContinentIn(i,1) = string(BasinNearing.Continent{i});
    end

    % Create a table with all the data
    T = table(NSEvalue(:,1), NSEvalue(:,2), NSEmark(:,1), NSEmark(:,2), ...
              BasinInfo(:,1), BasinNearing.latitude, BasinNearing.longitude, ...
              BasinNearing.calculated_drain_area, ContinentIn, RatioVol, ...
              'VariableNames', {'NSE_Natural', 'NSE_Dammed', 'NSEmark_Natural', ...
                                'NSEmark_Dammed', 'BasinInfo', 'Latitude', ...
                                'Longitude', 'Calculated_Drain_Area', ...
                                'Continent', 'RatioVol'});

    % Export to Excel
    writetable(T, 'FigureData/Fig_1.xlsx');

    disp('Data exported to plot_data.xlsx');
end