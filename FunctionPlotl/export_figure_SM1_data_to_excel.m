function export_figure_SM1_data_to_excel()
    load('RESULTS2\R3_NearingNSE.mat', "NSEvalue", "NSEmark", "BasinInfo");
    load('RESULTS\R2_Nearring_watershed.mat', "MISSINGBasin", "DamAttribute", 'Area_nearing', 'BasinNearing');
    YearDam = BasinInfo(:,3);
    YearDam = YearDam(~any(YearDam==0, 2), :);
    YearDam2 = YearDam(~any(isnan(YearDam), 2), :);
    
    Ndam = zeros(43, 1);
    Ndam(1) = numel(YearDam) - numel(YearDam2) + numel(find(YearDam2<1980));
    for i = 1980:2021
        Ndam(i-1978) = numel(find(YearDam2==i));
    end
    Damsum = cumsum(Ndam);
    Time = (1979:2021)';

    T1 = table(Time, Ndam, Damsum, 'VariableNames', {'Year', 'NewDams', 'CumulativeDams'});

    DammAll = BasinInfo(:,1);
    for i = 1:size(BasinNearing,1)
        ContinentIn(i,1) = string(BasinNearing.Continent{i});
    end
    uniqContinent = unique(ContinentIn);
    nDAM = zeros(numel(uniqContinent), 3);
    for j = 1:numel(uniqContinent)
        idx = find(ContinentIn==uniqContinent{j});
        cont_Dam = DammAll(idx);
        nDAM(j,1) = numel(cont_Dam);
        cont_Dam = cont_Dam(~any(cont_Dam==0, 2), :);
        nDAM(j,2) = numel(cont_Dam);
        nDAM(j,3) = nDAM(j,1) - nDAM(j,2);
    end

    T2 = table(uniqContinent, nDAM(:,3), nDAM(:,2), 'VariableNames', {'Continent', 'NaturalBasins', 'DammedBasins'});

    filename = 'FigureData/figure_SM1_data.xlsx';
    writetable(T1, filename, 'Sheet', 'DamConstructionData');
    writetable(T2, filename, 'Sheet', 'ContinentData');
    
    disp(['Data exported to ', filename]);
end