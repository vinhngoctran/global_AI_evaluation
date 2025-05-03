clear all; close all; clc
addpath(genpath('FUNCTIONS'));
%% Read data
% 1. Kratzert data =====================================================================
fid = fopen('Data\single-basin-vs-regional-model\basin_lists/531_basin_list.txt');
data = textscan(fid, '%s', Inf);
fclose(fid);
Basins = string(data{:});
MissingBasin_S(1:531,1:10) = 1;
TimeArray = [datetime(1989,10,01):days(1):datetime(1999,9,30)]';
for i=1:size(Basins,1)
    for j=1:10
            if ~exist(['RESULTS_FINAL/1.Kratzert/S_',Basins{i},'_',num2str(j),'.p'])
                MissingBasin_S(i,j) = 0;
            end
    end
end
save('RESULTS_FINAL\R1_Krat_meta.mat',"MissingBasin_S","Basins");

% extract Kratzert data using Python
% ! Read_KratzertData.py
MissingBasin_M(1:531,1:10) = 1;
% load('RESULTS\R1_Krat_meta.mat',"MissingBasin_S","Basins")
for i=1:size(Basins,1)
    for j=1:10
        if exist(['RESULTS_FINAL/2.Kratzert_mat/S_',Basins{i},'_',num2str(j),'.mat'])
            load(['RESULTS_FINAL/2.Kratzert_mat/S_',Basins{i},'_',num2str(j),'.mat'])
            Kratz_S_SIM(:,j,i) = qsim;
            Kratz_S_OBS(:,j,i) = qobs;
        end

        if ~exist(['RESULTS_FINAL/2.Kratzert_mat/M_',Basins{i},'_',num2str(j),'.mat'])
                MissingBasin_M(i,j) = 0;
        else
            load(['RESULTS_FINAL/2.Kratzert_mat/M_',Basins{i},'_',num2str(j),'.mat'])
            Kratz_M_SIM(:,j,i) = qsim;
            Kratz_M_OBS(:,j,i) = qobs;
        end
    end
end
save('RESULTS_FINAL\R1_Krat_meta.mat',"MissingBasin_S","Basins","MissingBasin_M");
save('RESULTS_FINAL\R1_Krat_data.mat',"Kratz_M_OBS","Kratz_M_SIM","Kratz_S_OBS","Kratz_S_SIM",'-v7.3');


%% 2. Nearing data =====================================================================
clc
% Read Nearing simulation-UNGAUGED
BasinNearing = readtable('Data\NearingDat\metadata\basin_attributes.csv');
MissingNearing(1:size(BasinNearing,1),1) = 1;
for i=1:size(BasinNearing,1)
    i
    FILENAME = ['Data\NearingDat\model_data/google/dual_lstm/kfold_splits/',BasinNearing.Var1{i},'.nc'];
    try
        preData = ncinfo(FILENAME);
        Time =  ncread(FILENAME,'time')';
        NearingSim{i,1}(1:max(Time)+1,1:8) = NaN; % neeed "+1" because index in python started from 0
        NearingSim{i,1}(Time+1,:) = ncread(FILENAME,'google_prediction')'; % neeed "+1" because index in python started from 0
        StartTime(i,1) = datetime(erase(preData.Variables(2).Attributes(1).Value,'days since '))-days(1);  % Correct right to left datetime labeled
    catch
        i
        MissingNearing(i,1)=0;
    end
end
save('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing",'-v7.3');

clc
% Read Nearing simulation-GAUGED
BasinNearing = readtable('Data\NearingDat\metadata\basin_attributes.csv');
MissingNearing(1:size(BasinNearing,1),1) = 1;
for i=1:size(BasinNearing,1)
    i
    FILENAME = ['Data\NearingDat\model_data/google/dual_lstm/full_run/',BasinNearing.Var1{i},'.nc'];
    try
        preData = ncinfo(FILENAME);
        Time =  ncread(FILENAME,'time')';
        NearingSim{i,1}(1:max(Time)+1,1:8) = NaN;
        NearingSim{i,1}(Time+1,:) = ncread(FILENAME,'google_prediction')';
        StartTime(i,1) = datetime(erase(preData.Variables(2).Attributes(1).Value,'days since '))-days(1);  % Correct right to left datetime labeled
    catch
        i
        MissingNearing(i,1)=0;
    end
end
save('RESULTS_FINAL\R3_Nearing_sim_gauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing",'-v7.3');


%% Read observation GRDC
load('RESULTS_FINAL\R3_Nearing_sim_gauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
MISSINGObs(1:size(BasinNearing,1),1) = 1;
for i=1:size(BasinNearing,1)
    try
    NearingObs(:,i) = readobs(BasinNearing.Var1{i},StartTime(i,1),size(NearingSim{1, 1},1));
    catch
        i
        MISSINGObs(i,1)=0;
    end
end
save('RESULTS_FINAL\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
%%
% Read GloFAS data
clear all; clc
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
metadat = ncinfo('Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc');
GloFAStime = datetime(erase(metadat.Variables(1).Attributes(3).Value,'days since '))+days(ncread('Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','time'));
GloFASData = ncread('Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','dis')';
StatNAME = ncread('Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','statid')';
StatLat = ncread('Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','statlat')';
StatLon = ncread('Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','statlon')';
GloFASmeta = [StatNAME',StatLat',StatLon'];

MISSINGGloFAS(1:size(BasinNearing,1),1) = 1;
for i=1:size(BasinNearing,1)
    idx = find(GloFASmeta(:,1)==str2num(erase(BasinNearing.Var1{i},'GRDC_')));
    if ~isempty(idx)
        NearingFloFAS(:,i) = findglofas(GloFASData(:,idx),GloFAStime,StartTime(i,1),size(NearingSim{1, 1},1)); 
    else
        i
        MISSINGGloFAS(i,1) = 0;
    end
end
save('RESULTS_FINAL\R2_Nearing_GloFAS.mat',"GloFASmeta","GloFAStime","GloFASData",'NearingFloFAS','MISSINGGloFAS','-v7.3');
%%
% 3. Read dam and basin  =====================================================================
Daminfo = shaperead('Data\DAM Tracker\data\GDAT_v1_dams.shp');
DamMap = shaperead('Data\DAM Tracker\data\GDAT_v1_catchments.shp');

damarea = computearea(DamMap);

for i=1:size(DamMap,1)
    if isempty(DamMap(i).Area_Con)
        DamMap(i).Area_Con = NaN;
    end
    if isempty(DamMap(i).Year_Fin)
        DamMap(i).Year_Fin = 'NaN';
    elseif DamMap(i).Year_Fin=="BLANK"
        DamMap(i).Year_Fin = 'NaN';
    end

    if isempty(DamMap(i).Height1)
        DamMap(i).Height1 = 'NaN';
    end
    if isempty(DamMap(i).Volume_Max)
        DamMap(i).Volume_Max = NaN;
    end

    DamAttribute(i,:) = [DamMap(i).Lat1, DamMap(i).Long, damarea(i),DamMap(i).Area_Con,str2num(DamMap(i).Year_Fin),...
        max(str2num(DamMap(i).Height1)), DamMap(i).Volume_Max]; % Y, X, Catchment area, Area conso, Year finished, Dam height, Volume max
end


% Read basin data
shapeaf = shaperead('Data\HydroATLAS\hybas_af_lev12_v1c.shp');
shapear = shaperead('Data\HydroATLAS\hybas_ar_lev12_v1c.shp');
shapeas = shaperead('Data\HydroATLAS\hybas_as_lev12_v1c.shp');
shapeau = shaperead('Data\HydroATLAS\hybas_au_lev12_v1c.shp');
shapeeu = shaperead('Data\HydroATLAS\hybas_eu_lev12_v1c.shp');
shapegr = shaperead('Data\HydroATLAS\hybas_gr_lev12_v1c.shp');
shapena = shaperead('Data\HydroATLAS\hybas_na_lev12_v1c.shp');
shapesa = shaperead('Data\HydroATLAS\hybas_sa_lev12_v1c.shp');
shapesi = shaperead('Data\HydroATLAS\hybas_si_lev12_v1c.shp');

MISSINGBasin(1:size(BasinNearing,1),1) = 1;
for i=1:size(BasinNearing,1)
    FILENAME = ['Data/statbas_shp_zip/grdc_basins_smoothed_md_no_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp']; % This watersehd boundary shapefile was downloaded from GRDC dataset
    if exist(FILENAME)
        BasinM = shaperead(FILENAME);
        AreaC =computearea(BasinM);
        Area_nearing(i,:) = [BasinNearing.calculated_drain_area(i), AreaC];
    elseif exist( ['RESULTS_FINAL/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp']) % saved watershed boundary exported from HydroAtlas
        FILENAME = ['RESULTS_FINAL/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
        BasinM = shaperead(FILENAME);
        AreaC =computearea(BasinM);
        Area_nearing(i,:) = [BasinNearing.calculated_drain_area(i), AreaC];
        MISSINGBasin(i,1) = 2;
    else
        try % (only extract missing shapefile) Extract the watershed boundary from HydroAtlas based on the stream gauge location. This boundary is primarily used to define the extent of the watershed and to identify any dams located within it.
            if BasinNearing.Continent(i) == "AFRICA"
                BasinM = findwatershed(shapeaf,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end

            if BasinNearing.Continent(i) == "ASIA"
                BasinM = findwatershed(shapeas,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end

            if BasinNearing.Continent(i) == "AUSTRALIA"
                BasinM = findwatershed(shapeau,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end

            if BasinNearing.Continent(i) == "EUROPE"
                BasinM = findwatershed(shapeeu,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end

            if BasinNearing.Continent(i) == "GREENLAND"
                BasinM = findwatershed(shapegr,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end

            if BasinNearing.Continent(i) == "NORTH_AMERICA"
                BasinM = findwatershed(shapena,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end

            if BasinNearing.Continent(i) == "NORTH_AMERICAN_ARCTIC"
                BasinM = findwatershed(shapear,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end

            if BasinNearing.Continent(i) == "SIBERIA"
                BasinM = findwatershed(shapesi,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end

            if BasinNearing.Continent(i) == "SOUTH_AMERICA"
                BasinM = findwatershed(shapesa,BasinNearing.longitude(i),BasinNearing.latitude(i),FILENAME);
            end
            display(['HydroAtlas:  ', num2str(i)])
            AreaC =computearea(BasinM);
            Area_nearing(i,:) = [BasinNearing.calculated_drain_area(i), AreaC];
            MISSINGBasin(i,1) = 2;
        catch
            display(['check:  ', num2str(i)])
            MISSINGBasin(i,1) = 0;
        end
    end
end

save('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')


%% ANALYSIS
% Ungauged basins
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
load('RESULTS_FINAL\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
load('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')

SelectedBasin(1:size(BasinNearing,1),1) = 0;

for i=1:size(BasinNearing,1)
    i
    if MISSINGBasin(i,1) ~= 0 && MISSINGObs(i,1) ~= 0
        FILENAME = ['Data/statbas_shp_zip/grdc_basins_smoothed_md_no_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
        if exist(FILENAME)
            BasinM = shaperead(FILENAME);
        elseif exist( ['RESULTS_FINAL/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp']) % saved watershed boundary exported from HydroAtlas
            FILENAME = ['RESULTS_FINAL/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
            BasinM = shaperead(FILENAME);
        end
        SelectedBasin(i,1) = 1;
        BasinInfo(i,:) = findinfor(BasinM,DamAttribute); % Total area, Total volume, Year
        [NSEmark(i,:), NSEvalue(i,:)] = computeNSE(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,BasinInfo(i,3),StartTime(i,1));   % AI data needs to be denormalized from mm/day to m3/s
    end
end
save('RESULTS_FINAL\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");
plot_figure_1;  % Figure 1

%% Gauged basins
load('RESULTS_FINAL\R3_Nearing_sim_gauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
load('RESULTS_FINAL\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
load('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')

SelectedBasin(1:size(BasinNearing,1),1) = 0;
for i=1:size(BasinNearing,1)
    i
    if MISSINGBasin(i,1) ~= 0 && MISSINGObs(i,1) ~= 0
        FILENAME = ['Data/statbas_shp_zip/grdc_basins_smoothed_md_no_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
        if exist(FILENAME)
            BasinM = shaperead(FILENAME);
        elseif exist( ['RESULTS_FINAL/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp']) % saved watershed boundary exported from HydroAtlas
            FILENAME = ['RESULTS_FINAL/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
            BasinM = shaperead(FILENAME);
        end
        SelectedBasin(i,1) = 1;
        BasinInfo(i,:) = findinfor(BasinM,DamAttribute); % Total area, Total volume, Year
        [NSEmark(i,:), NSEvalue(i,:)] = computeNSE(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,BasinInfo(i,3),StartTime(i,1));   % AI data needs to be denormalized
    end
end
save('RESULTS_FINAL\R3_NearingNSE_gauged.mat',"NSEvalue","NSEmark","BasinInfo");
% plot_figure_7; % Gauged vs Ungauged
%% Results for figure 2 ==================================================================================================
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
for i=1:size(BasinNearing,1)
    i
    if MISSINGObs(i,1)==1
        [checkdata(i,1), StartEndYear(i,:),idx]= checksystematic10(StartTime(i),NearingObs(:,i));
        if checkdata(i,1) > 10 % Only do FFA for gauges with >10 continuous years of data available
            % Flood frequency analysis
            [LengthData(i,1) FloodFrequency(i,:,1)] = floodanalysis(StartTime(i),NearingObs(:,i),idx);
            [LengthData(i,2) FloodFrequency(i,:,2)] = floodanalysis(StartTime(i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,idx);
            for k=1:5
                FloodFrequency_delta(i,k) = ((FloodFrequency(i,k,2)-FloodFrequency(i,k,1))/FloodFrequency(i,k,1))*100;
            end
        else
            FloodFrequency_delta(i,1:5) = NaN;
        end
        % Compute Peak error and Time-to-peak error for biggest flood
        [PE(i,1), T2P(i,1)] = computeflooderror(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400);
        if checkdata(i,1) > 10
            RP(i,1) = findreturnpeiod(StartTime(i),NearingObs(:,i),idx);
        else
            RP(i,1) = NaN;
        end
    else
        checkdata(i,1) = 0;
    end
end
n10 = numel(find(checkdata>10));disp(n10)
save('RESULTS_FINAL/R4_2_NearingHydrological_final.mat','RP','checkdata','FloodFrequency','FloodFrequency_delta','PE','T2P','StartEndYear');

%% Using GEV distribution
clear all; clc
load('RESULTS_FINAL\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
load('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
for i=1:size(BasinNearing,1)
    i
    if MISSINGObs(i,1)==1
        [checkdata(i,1), StartEndYear(i,:),idx]= checksystematic10(StartTime(i),NearingObs(:,i));
        if checkdata(i,1) > 10 % Only do FFA for gauges with >10 continuous years of data available
            % Flood frequency analysis
            [LengthData(i,1) FloodFrequency(i,:,1)] = floodanalysis_gev(StartTime(i),NearingObs(:,i),idx);
            [LengthData(i,2) FloodFrequency(i,:,2)] = floodanalysis_gev(StartTime(i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,idx);
            for k=1:5
                FloodFrequency_delta(i,k) = ((FloodFrequency(i,k,2)-FloodFrequency(i,k,1))/FloodFrequency(i,k,1))*100;
            end
            for threshold=1:5
                Peak_FFA{i,threshold} = computePeakEEvent(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,FloodFrequency(i,threshold,1));
            end
        else
            FloodFrequency_delta(i,1:5) = NaN;
        end
        % Compute Peak error and Time-to-peak error for biggest flood
        [PE(i,1), T2P(i,1)] = computeflooderror(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400);

        % Compute peak error for events with peak flow higher than FFA
        
        if checkdata(i,1) > 10
            RP(i,1) = findreturnpeiod(StartTime(i),NearingObs(:,i),idx);
        else
            RP(i,1) = NaN;
        end
    else
        checkdata(i,1) = 0;
    end
end
n10 = numel(find(checkdata>10));disp(n10)
save('RESULTS_FINAL/R4_2_NearingHydrological_final_GEV.mat','RP','checkdata','FloodFrequency','FloodFrequency_delta','PE','T2P','StartEndYear','Peak_FFA');
plot_figure_2_final4_combine_gev
plot_figure_2_final4_combine_gev_new
plot_figure_2_SM
%% Investigate non-physic events
clear all; clc
load('RESULTS_FINAL/CaravanInfor.mat')
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"BasinNearing","NearingSim",'StartTime');
load('RESULTS_FINAL\R2_Nearing_obs.mat')
load('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')

PE_threshold = [-99 -95:5:-50];
for i=1:size(BasinNearing,1)
    i
    if MISSINGObs(i,1)==1
        for j=1:numel(PE_threshold)
            [N_event{j,1}(i,:), PE{j,i}, T2P{j,i} ] = determinenonphysic(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,StartTime(i),PE_threshold(j));
        end
    end
end
save('RESULTS_FINAL/R7_nophysic.mat','N_event','PE','T2P');

plot_figure_2_final4_combine; % Figure 2

%% Compare to regional model
% https://hess.copernicus.org/articles/23/5089/2019/
% https://hess.copernicus.org/articles/27/139/2023/#section7
% https://hess.copernicus.org/articles/25/5517/2021/#section6
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"BasinNearing","NearingSim","StartTime");
load('RESULTS_FINAL\R2_Nearing_obs.mat', 'NearingObs')

% Read Thomas data: CAMELS-GB
Qsim = ncread('Data/RegionalPaper/Thomas/preds.nc','LSTM');
Qobs = ncread('Data/RegionalPaper/Thomas/preds.nc','obs');
Time = ncread('Data/RegionalPaper/Thomas/preds.nc','time');
TimeDATE = datetime(1988,1,1)+days(Time);
StationID = ncread('Data/RegionalPaper/Thomas/preds.nc','station_id');
InfoGB = xlsread('Data\RegionalPaper\Thomas\Info\data\CAMELS_GB_topographic_attributes.csv');

for i=1:numel(StationID)
    idx = find(InfoGB==StationID(i));
    InforSelec(i,:)=InfoGB(idx,:);
end
save('RESULTS_FINAL\R8_Regional_GB.mat','Qobs','Qsim',"TimeDATE","StationID",'InforSelec');
k=0;
for i=1:size(StationID,1)
     [overlapdata(i,1),Data, AREA,R2] = findoverlapdata(NearingObs,BasinNearing,NearingSim,StartTime(1),Qsim(:,i),Qobs(:,i),TimeDATE,[InforSelec(i,3:4),InforSelec(i,8)]);
     if ~isnan(overlapdata(i,1))
        k=k+1;
        TotalR2(k,1) = R2;
        DataAll{k,1} = Data;
        OverlapInfo(k,:) = InforSelec(i,:);
        AREA_all(k,:) = AREA;
     end
end
save('RESULTS_FINAL\R8_Regional_GB_2.mat','Qobs','TotalR2','Qsim',"TimeDATE","StationID",'InforSelec','DataAll','OverlapInfo','AREA_all','overlapdata');
%%
% Read Kratzert data: CAMELS-US: Run 'Read_KratzertData2.py' to load data
clear; clc
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"BasinNearing","NearingSim","StartTime");
load('RESULTS_FINAL\R2_Nearing_obs.mat', 'NearingObs')
load('RESULTS_FINAL\R8_Regional_US.mat')  
InfoUS = readtable('Data\camels\camels_attributes_v2.0/camels_topo.txt');
InfoUS = table2array(InfoUS);
Basin = load('Data/single-basin-vs-regional-model/basin_lists/531_basin_list.txt');
Time = datetime(Time,'InputFormat','yyyy/MM/dd');
for i=1:numel(Basin)
    idx = find(InfoUS(:,1)==Basin(i));
    InforSelec(i,:)=InfoUS(idx,:);
end
save('RESULTS_FINAL\R8_Regional_US.mat','all_qsim','all_qobs','InforSelec','Time');  
%
k=0;
for i=1:size(InforSelec,1)
     [overlapdata_US(i,1),Data, AREA, R2] = findoverlapdata(NearingObs,BasinNearing,NearingSim,StartTime(1),all_qsim(i,:),all_qobs(i,:),Time,[InforSelec(i,2:3), InforSelec(i,6)]);
     if ~isnan(overlapdata_US(i,1))
        k=k+1;
        TotalR2(k,1) = R2;
        DataAll{k,1} = Data;
        OverlapInfo(k,:) = InforSelec(i,:);
        AREA_all(k,:) = AREA;
     end
end
save('RESULTS_FINAL\R8_Regional_US_2.mat','all_qsim','all_qobs','TotalR2','InforSelec','Time','DataAll','OverlapInfo','AREA_all','overlapdata_US');  


%% Read forecasts from CNRFC
clear all; clc
load('..\NWM21\Data2\Results\R3_Qdaily.mat')
load('RESULTS_FINAL\R3_Nearing_sim_gauged.mat',"BasinNearing","NearingSim","StartTime");
load('RESULTS_FINAL\R2_Nearing_obs.mat', 'NearingObs')
NearingSim1 = NearingSim;
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"BasinNearing","NearingSim","StartTime");
% Load USGS ID
USGS = readtable('Data\nwps_all_gauges_report.csv');
NWSID = string(USGS.Var4);
for i=1:numel(NameS)
    idx = find(NWSID==NameS{i});
    if isempty(idx)
        USGS_ID(i,1) = NaN;
    else
        USGS_ID(i,1) = USGS.Var6(idx);
    end
end
save('RESULTS_FINAL\CNRFC.txt','USGS_ID','-ascii')
%
k=0;
for i=1:numel(Datacheck)
    if Datacheck(i)==1 && ~isnan(USGS_ID(i))
        [overlapdata_CNRFC(i,1),Data, AREA,R2] = findoverlapdataCN(NearingObs,BasinNearing,NearingSim1,StartTime(1),Q{i}(:,2:end),Q{i}(:,1),Time{i},[latLon(i,:) NaN],num2str(USGS_ID(i)));
        [overlapdata_CNRFC(i,1),Data2, AREA,R2] = findoverlapdataCN(NearingObs,BasinNearing,NearingSim,StartTime(1),Q{i}(:,2:end),Q{i}(:,1),Time{i},[latLon(i,:) NaN],num2str(USGS_ID(i)));
        
        if ~isnan(overlapdata_CNRFC(i,1))
            k=k+1;
            DataAll{k,1} = Data;
            DataAll{k,2} = Data2;
            OverlapInfo(k,:) = latLon(i,:);
            TotalR2(k,1) = R2;
            StationNAme(k,1) = NameS(i);
         end
    end
end
save('RESULTS_FINAL\R8_Regional_CNRFC_3.mat','Time','DataAll','OverlapInfo','overlapdata_CNRFC','TotalR2');  
plot_figure_8_4; % Figure 3

%% Compare Nearing AI to GloFAS ==================================================================================================
% This can be used in SM
% load('RESULTS_FINAL\R2_Nearing_GloFAS.mat',"GloFASmeta","GloFAStime","GloFASData",'NearingFloFAS','MISSINGGloFAS');
load('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin")
load('RESULTS_FINAL\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
load('RESULTS_FINAL\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");
for i=1:size(BasinNearing,1)
    i
    if MISSINGBasin(i,1) ~= 0 && MISSINGObs(i,1) ~= 0 && MISSINGGloFAS(i,1) ~= 0
        [NSEmark_Glo(i,:), NSEvalue_Glo(i,:)] = computeNSE(NearingObs(:,i),NearingFloFAS(:,i),BasinInfo(i,3),StartTime(i,1));
        [PE_Glo(i,1), T2P_Glo(i,1)] = computeflooderror(NearingObs(:,i),NearingFloFAS(:,i));
    end
end
save('RESULTS_FINAL/R5_GloFasComparison.mat','NSEmark_Glo','NSEvalue_Glo','PE_Glo','T2P_Glo');
plot_figure_R_GloFas
%%
% idx = find(MISSINGObs==1);
% AreADam = BasinInfo(idx,:);
% N_dammed = numel(find(AreADam(:,1)>0))
% N_dammedbefore1980 = N_dammed - numel(find(AreADam(:,3)>=1980))


%% Rebuttal
% Compute KGE
clear all; clc
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
load('RESULTS_FINAL\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
load('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')

SelectedBasin(1:size(BasinNearing,1),1) = 0;

for i=1:size(BasinNearing,1)
    i
    if MISSINGBasin(i,1) ~= 0 && MISSINGObs(i,1) ~= 0
        FILENAME = ['Data/statbas_shp_zip/grdc_basins_smoothed_md_no_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
        if exist(FILENAME)
            BasinM = shaperead(FILENAME);
        elseif exist( ['RESULTS_FINAL/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp']) % saved watershed boundary exported from HydroAtlas
            FILENAME = ['RESULTS_FINAL/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
            BasinM = shaperead(FILENAME);
        end
        SelectedBasin(i,1) = 1;
        BasinInfo(i,:) = findinfor(BasinM,DamAttribute); % Total area, Total volume, Year
        [KGEmark(i,:), KGEvalue(i,:)] = computeKGE(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,BasinInfo(i,3),StartTime(i,1));   % AI data needs to be denormalized from mm/day to m3/s
    end
end
save('RESULTS_FINAL\Rebut_NearingKGE.mat',"KGEvalue","KGEmark","BasinInfo");
plot_Rebut_1;  % Figure 1





%% Rebuttal 2: Plot NSE and PE
pEAKERROR1 = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\1980\dual_lstm\full_run/NSE.csv');
pEAKERROR2 = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\1980\dual_lstm\kfold_splits/NSE.csv');

Data = [pEAKERROR1.Var2, pEAKERROR2.Var2];Data = Data(2:end,:); % Remove the first row ID
for i=1:2
    disp(['Percentage N < 0.5: ',num2str(numel(find(Data(:,i)<0.5))/numel(Data(:,1))*100)])
end
figure;
subplot(1,2,1); hold on
boxplot(Data); ylim([0 1]);ylabel('NSE [-]'); hold on; xlim([0.5 2.5]);title('a')
plot([0 5],[0.5 0.5],'LineStyle','--')
xticklabels(["fullrun", "kfoldsplit"]);

% Rebuttal 2: Plot PE
% clear all; clc
subplot(1,2,2); hold on
pEAKERROR1 = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\1980\dual_lstm\full_run/Peak-MAPE.csv');
pEAKERROR2 = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\1980\dual_lstm\kfold_splits/Peak-MAPE.csv');

Data = [pEAKERROR1.Var2, pEAKERROR2.Var2];Data = Data(2:end,:); % Remove the first row ID
% figure;
boxplot(Data); ylim([0 100]);ylabel('PE (MAPE) [%]'); hold on
xticklabels(["fullrun", "kfoldsplit"]);xlim([0.5 2.5]);title('b')
exportgraphics(gca,"Figure_final/R2.jpg",'Resolution',600)
disp(median(Data,'omitnan'))

%% Rebuttal 2: Plot KGE
pEAKERROR1 = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\1980\dual_lstm\full_run/KGE.csv');
pEAKERROR2 = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\1980\dual_lstm\kfold_splits/KGE.csv');
pEAKERROR3 = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\2014\dual_lstm\full_run/KGE.csv');
pEAKERROR4 = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\2014\dual_lstm\kfold_splits/KGE.csv');

Data = [pEAKERROR1.Var2, pEAKERROR2.Var2, pEAKERROR3.Var2, pEAKERROR4.Var2];Data = Data(2:end,:); % Remove the first row ID
figure;boxplot(Data); ylim([0 1]);ylabel('KGE [-]'); hold on
xticklabels(["1980-Gauged", "1980-Ungauged", "2014-Gauged", "2014-Ungauged"]);
exportgraphics(gca,"Figure_final/R4.jpg",'Resolution',600)


%% Compute KGE metrics
clear all; close all; clc
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
load('RESULTS_FINAL\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
load('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')
Period = [datetime(1979,12,31):days(1):datetime(2023,8,30)];
for i=1:size(BasinNearing,1)
   IDgage(i,1) = string(BasinNearing.Var1{i});
end
NSE_GG = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\1980\dual_lstm\kfold_splits/NSE.csv');
KGE_GG = readtable('D:\PUB_realistic\Data\NearingDat\metrics\hydrograph_metrics\per_metric\google\1980\dual_lstm\kfold_splits/KGE.csv');
Data = [NSE_GG.Var2, KGE_GG.Var2];Data = Data(2:end,:); % Remove the first row ID
for i=1:size(KGE_GG,1)-1
   IDgage_gg(i,1) = string(KGE_GG.Var1{i+1});
end
for i=1:size(BasinNearing,1)
    i
    Metricall(i,1) = Nash(NearingObs(1:numel(Period),i),NearingSim{i,1}(1:numel(Period),1)*Area_nearing(i,1)*10^6/1000/86400);
    Metricall(i,2) = metric_KGE(NearingObs(1:numel(Period),i),NearingSim{i,1}(1:numel(Period),1)*Area_nearing(i,1)*10^6/1000/86400);
    idx = find(IDgage_gg ==IDgage(i,1));
    if ~isempty(idx)
    Metricall(i,3:4) = Data(idx,:);
    else
        Metricall(i,3:4) = NaN;
    end
end

%% Find overlap between GRDC and CARAVAN
clear all; close all; clc
load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat',"BasinNearing","StartTime");
load('RESULTS_FINAL\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
CaravanFolder = 'F:\Model\GlobalDynamic\Data/Collect/';
Caravan = readtable('F:\Model\GlobalDynamic\Data/Attribute_Caravan.csv');
CaravanID = string(Caravan.gauge_id);
NearingID = string(BasinNearing.Var1);
k=0;
for i=1:numel(NearingID)
    idx = find(CaravanID==NearingID(i));
    if ~isempty(idx)
        k=k+1;
        SelectID(k,:) = [NearingID(i),CaravanID(idx)];
    end
end
save('RESULTS_FINAL\R10_overlap_Basin.mat',"SelectID");

%%
clear; clc
load('RESULTS_FINAL\R8_Regional_US_2.mat','all_qsim','all_qobs','TotalR2','InforSelec','Time','DataAll','OverlapInfo','AREA_all','overlapdata_US');
opts = detectImportOptions('Data\camels\camels_attributes_v2.0/camels_topo.txt');
opts = setvartype(opts, 'gauge_id', 'string');
InfoUS = readtable('Data\camels\camels_attributes_v2.0/camels_topo.txt', opts);
InfoID = double(InfoUS.gauge_id);
for i=1:size(OverlapInfo,1)
    idx = find(InfoID==OverlapInfo(i,1));
    SelectID_CAMELS(i,1) = "camels_"+InfoUS.gauge_id(idx);
end
save('RESULTS_FINAL\R10_overlap_Basin_US.mat','SelectID_CAMELS');  


%% USGS: https://water.noaa.gov/about/data-and-web-services-catalog
clear all; clc
data =readtable('Data\nwps_all_gauges_report.csv');
Inservice = string(data.Var25);
idx = find(Inservice=='true');
R = 6371;
minDist = inf;
nsta = 0;
lat = data.Var7(idx);
lon = data.Var8(idx);
for i = 1:size(idx,1)
    lat1 = deg2rad(lat(i));
    lon1 = deg2rad(lon(i));
    for j = i+1:1000
        lat2 = deg2rad(lat(j));
        lon2 = deg2rad(lon(j));

        dlat = lat2 - lat1;
        dlon = lon2 - lon1;
        a = sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2;
        c = 2 * atan2(sqrt(a), sqrt(1-a));
        d = R * c;
        if d < minDist
            minDist = d;
            point1 = i;
            point2 = j;
        end
        if d<=1
            nsta = nsta+1;
        end
    end
end
fprintf('Shortest distance is %.4f km between point %d and point %d.\n', minDist, point1, point2);
fprintf('The number of station with distance<1km: %d.\n',nsta/2)