clear all; close all; clc
addpath(genpath('Function_final'));
%% Copy and read data
% 1. Kratzert data =====================================================================
fid = fopen('Data\single-basin-vs-regional-model\basin_lists/531_basin_list.txt');
data = textscan(fid, '%s', Inf);
fclose(fid);
Basins = string(data{:});
MissingBasin_S(1:531,1:10) = 1;
TimeArray = [datetime(1989,10,01):days(1):datetime(1999,9,30)]';
for i=1:size(Basins,1)
    for j=1:10
%             copykratzert(Basins{i},j);

            if ~exist(['RESULTS/1.Kratzert/S_',Basins{i},'_',num2str(j),'.p'])
                MissingBasin_S(i,j) = 0;
            end
    end
end
save('RESULTS\R1_Krat_meta.mat',"MissingBasin_S","Basins");

% read Kratzert data using Python
% ! Read_KratzertData.py
MissingBasin_M(1:531,1:10) = 1;
load('RESULTS\R1_Krat_meta.mat',"MissingBasin_S","Basins")
for i=1:size(Basins,1)
    for j=1:10
        if exist(['RESULTS/2.Kratzert_mat/S_',Basins{i},'_',num2str(j),'.mat'])
            load(['RESULTS/2.Kratzert_mat/S_',Basins{i},'_',num2str(j),'.mat'])
            Kratz_S_SIM(:,j,i) = qsim;
            Kratz_S_OBS(:,j,i) = qobs;
        end

        if ~exist(['RESULTS/2.Kratzert_mat/M_',Basins{i},'_',num2str(j),'.mat'])
                MissingBasin_M(i,j) = 0;
        else
            load(['RESULTS/2.Kratzert_mat/M_',Basins{i},'_',num2str(j),'.mat'])
            Kratz_M_SIM(:,j,i) = qsim;
            Kratz_M_OBS(:,j,i) = qobs;
        end
    end
end
save('RESULTS\R1_Krat_meta.mat',"MissingBasin_S","Basins","MissingBasin_M");
save('RESULTS\R1_Krat_data.mat',"Kratz_M_OBS","Kratz_M_SIM","Kratz_S_OBS","Kratz_S_SIM",'-v7.3');


% 2. Nearing data =====================================================================
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
        NearingSim{i,1}(1:max(Time)+1,1:8) = NaN;
        NearingSim{i,1}(Time+1,:) = ncread(FILENAME,'google_prediction')';
        StartTime(i,1) = datetime(erase(preData.Variables(2).Attributes(1).Value,'days since '));
    catch
        i
        MissingNearing(i,1)=0;
    end
end
save('RESULTS2\R3_Nearing_sim_ungauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing",'-v7.3');

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
        StartTime(i,1) = datetime(erase(preData.Variables(2).Attributes(1).Value,'days since '));
    catch
        i
        MissingNearing(i,1)=0;
    end
end
save('RESULTS2\R3_Nearing_sim_gauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing",'-v7.3');


% Read observation GRDC
MISSINGObs(1:size(BasinNearing,1),1) = 1;
for i=1:size(BasinNearing,1)
    try
    NearingObs(:,i) = readobs(BasinNearing.Var1{i},StartTime(i,1),size(NearingSim{1, 1},1));
    catch
        i
        MISSINGObs(i,1)=0;
    end
end
save('RESULTS2\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");

% Read GloFAS data
metadat = ncinfo('E:\PUB_realistic\Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc');
GloFAStime = datetime(erase(metadat.Variables(1).Attributes(3).Value,'days since '));
GloFASData = ncread('E:\PUB_realistic\Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','dis')';
StatNAME = ncread('E:\PUB_realistic\Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','statid')';
StatLat = ncread('E:\PUB_realistic\Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','statlat')';
StatLon = ncread('E:\PUB_realistic\Data\NearingDat\model_data\GRDCstattions_GloFASv40/dis24h_GLOFAS4.0_3arcmin_197901-202212_statsgoogle20230918.nc','statlon')';
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
save('RESULTS2\R2_Nearing_GloFAS.mat',"GloFASmeta","GloFAStime","GloFASData",'NearingFloFAS','MISSINGGloFAS','-v7.3');


% 3. Read dam and basin - Nearing data =====================================================================
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
    FILENAME = ['Data/statbas_shp_zip/grdc_basins_smoothed_md_no_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
    if exist(FILENAME)
        BasinM = shaperead(FILENAME);
        AreaC =computearea(BasinM);
        Area_nearing(i,:) = [BasinNearing.calculated_drain_area(i), AreaC];
    elseif exist( ['RESULTS/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp']) % saved watershed boundary exported from HydroAtlas
        FILENAME = ['RESULTS/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
        BasinM = shaperead(FILENAME);
        AreaC =computearea(BasinM);
        Area_nearing(i,:) = [BasinNearing.calculated_drain_area(i), AreaC];
        MISSINGBasin(i,1) = 2;
    else
        try
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

save('RESULTS\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')


%% ANALYSIS
load('RESULTS2\R3_Nearing_sim.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
load('RESULTS2\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
load('RESULTS\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')
% Results for figure 1 ==================================================================================================
SelectedBasin(1:size(BasinNearing,1),1) = 0;
for i=1:size(BasinNearing,1)
    i
    if MISSINGBasin(i,1) ~= 0 && MISSINGObs(i,1) ~= 0
        FILENAME = ['Data/statbas_shp_zip/grdc_basins_smoothed_md_no_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
        if exist(FILENAME)
            BasinM = shaperead(FILENAME);
        elseif exist( ['RESULTS/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp']) % saved watershed boundary exported from HydroAtlas
            FILENAME = ['RESULTS/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
            BasinM = shaperead(FILENAME);
        end
        SelectedBasin(i,1) = 1;
        BasinInfo(i,:) = findinfor(BasinM,DamAttribute); % Total area, Total volume, Year
        [NSEmark(i,:), NSEvalue(i,:)] = computeNSE(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,BasinInfo(i,3),StartTime(i,1));   % AI data needs to be denormalized
    end
end
save('RESULTS2\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");

%% Compute for gauged basins
load('RESULTS2\R3_Nearing_sim_gauged.mat',"MissingNearing","StartTime","NearingSim","BasinNearing");
load('RESULTS2\R2_Nearing_obs.mat',"MISSINGObs","NearingObs");
load('RESULTS\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')
% Results for figure 1 ==================================================================================================
SelectedBasin(1:size(BasinNearing,1),1) = 0;
for i=1:size(BasinNearing,1)
    i
    if MISSINGBasin(i,1) ~= 0 && MISSINGObs(i,1) ~= 0
        FILENAME = ['Data/statbas_shp_zip/grdc_basins_smoothed_md_no_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
        if exist(FILENAME)
            BasinM = shaperead(FILENAME);
        elseif exist( ['RESULTS/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp']) % saved watershed boundary exported from HydroAtlas
            FILENAME = ['RESULTS/4.NearingWatershed/grdc_',erase(BasinNearing.Var1{i},'GRDC_'),'.shp'];
            BasinM = shaperead(FILENAME);
        end
        SelectedBasin(i,1) = 1;
        BasinInfo(i,:) = findinfor(BasinM,DamAttribute); % Total area, Total volume, Year
        [NSEmark(i,:), NSEvalue(i,:)] = computeNSE(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,BasinInfo(i,3),StartTime(i,1));   % AI data needs to be denormalized
    end
end
save('RESULTS2\R3_NearingNSE_gauged.mat',"NSEvalue","NSEmark","BasinInfo");
%% Results for figure 2 ==================================================================================================
for i=1:size(BasinNearing,1)
    i
    if MISSINGObs(i,1)==1
        [checkdata(i,1), StartEndYear(i,:),idx]= checksystematic10(StartTime(i),NearingObs(:,i));
        if checkdata(i,1) > 10
            % Flood frequency analysis
            [LengthData(i,1) FloodFrequency(i,:,1)] = floodanalysis(StartTime(i),NearingObs(:,i),idx);
            [LengthData(i,2) FloodFrequency(i,:,2)] = floodanalysis(StartTime(i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,idx);
            for k=1:5
                FloodFrequency_delta(i,k) = ((FloodFrequency(i,k,2)-FloodFrequency(i,k,1))/FloodFrequency(i,k,1))*100;
            end
        else
            FloodFrequency_delta(i,1:5) = NaN;
        end
%         % Compute Peak error and Time-to-peak error for biggest flood
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
save('RESULTS2/R4_2_NearingHydrological_final.mat','RP','checkdata','FloodFrequency','FloodFrequency_delta','PE','T2P','StartEndYear');

%% Results for figure 3: Compare Nearing AI to GloFAS ==================================================================================================
% This can be used in SM
load('RESULTS2\R2_Nearing_GloFAS.mat',"GloFASmeta","GloFAStime","GloFASData",'NearingFloFAS','MISSINGGloFAS');

for i=1:size(BasinNearing,1)
    i
    if MISSINGBasin(i,1) ~= 0 && MISSINGObs(i,1) ~= 0 && MISSINGGloFAS(i,1) ~= 0
        [NSEmark_Glo(i,:), NSEvalue_Glo(i,:)] = computeNSE(NearingObs(:,i),NearingFloFAS(:,i),BasinInfo(i,3),StartTime(i,1));
        [PE_Glo(i,1), T2P_Glo(i,1)] = computeflooderror(NearingObs(:,i),NearingFloFAS(:,i));
    end
end
save('RESULTS2/R5_GloFasComparison.mat','NSEmark_Glo','NSEvalue_Glo','PE_Glo','T2P_Glo');

%% Results for figure 4: Investigate non-physic events
load('../PUB/3.Results/Infor.mat')
load('RESULTS2\R3_Nearing_sim.mat',"BasinNearing","NearingSim",'StartTime');
load('RESULTS2\R2_Nearing_obs.mat', 'NearingObs')
Caravan_AU = SUBID{1, 2}.info;
PE_threshold = [-99 -95:5:-50];
for i=1:size(Caravan_AU,1)
     [idx_overlap(i,1), temp_distance(i,1)] = findclosestation([Caravan_AU.gauge_lat(i),Caravan_AU.gauge_lon(i)],[BasinNearing.latitude, BasinNearing.longitude],1000);
     
     if ~isnan(idx_overlap(i,1))
         NameIDX(i,1) = BasinNearing.Var1(idx_overlap(i,1));
         SIM_check(:,i) = NearingSim{idx_overlap(i,1)}(:,1)*BasinNearing.calculated_drain_area(i,1)*10^6/1000/86400;
         OBS_check(:,i) = NearingObs(:,idx_overlap(i,1));
         AREA(i,:) = [BasinNearing.calculated_drain_area(idx_overlap(i,1)), Caravan_AU.area(i)];
        SubName = SUBID{2}.attributes.gauge_id{i};
        ClimateData = readtable(['../PUB/1.Data/csv/camelsaus/',SubName,'.csv']);
        Raindata(:,i) = ClimateData.total_precipitation_sum;
        for j=1:numel(PE_threshold)
            [N_event_AU{j,1}(i,:), PE_AU{j,i}, T2P_AU{j,i} ]= determinenonphysic(OBS_check(:,i),SIM_check(:,i),StartTime(1),PE_threshold(j));
        end
     end
end
TimeRain = ClimateData.date;

save('RESULTS2\R6_CheckReliablePrediction_2.mat','PE_AU','T2P_AU',"PE_threshold","N_event_AU","Raindata","OBS_check","SIM_check",'TimeRain','idx_overlap','NameIDX','AREA')

% Results for figure 5: Investigate non-physic events Globally
for i=1:size(BasinNearing,1)
    if MISSINGObs(i,1)==1
        for j=1:numel(PE_threshold)
            [N_event{j,1}(i,:), PE{j,i}, T2P{j,i} ] = determinenonphysic(NearingObs(:,i),NearingSim{i,1}(:,1)*Area_nearing(i,1)*10^6/1000/86400,StartTime(i),PE_threshold(j));
        end
    end
end
save('RESULTS2/R7_nophysic_2.mat','N_event','PE','T2P');
%%
idx = find(MISSINGObs==1);
AreADam = BasinInfo(idx,:);
N_dammed = numel(find(AreADam(:,1)>0))
N_dammedbefore1980 = N_dammed - numel(find(AreADam(:,3)>=1980))

%% Compare to regional model
% https://hess.copernicus.org/articles/23/5089/2019/
% https://hess.copernicus.org/articles/27/139/2023/#section7
% https://hess.copernicus.org/articles/25/5517/2021/#section6
load('RESULTS2\R3_Nearing_sim.mat',"BasinNearing","NearingSim","StartTime");
load('RESULTS2\R2_Nearing_obs.mat', 'NearingObs')

% Read Thomas data: CAMELS-GB
Qsim = ncread('Data/RegionalPaper/Thomas/preds.nc','LSTM');
Qobs = ncread('Data/RegionalPaper/Thomas/preds.nc','obs');
Time = ncread('Data/RegionalPaper/Thomas/preds.nc','time');
TimeDATE = datetime(1988,1,1)+days(Time-1);
StationID = ncread('Data/RegionalPaper/Thomas/preds.nc','station_id');
InfoGB = xlsread('Data\RegionalPaper\Thomas\Info\data\CAMELS_GB_topographic_attributes.csv');

for i=1:numel(StationID)
    idx = find(InfoGB==StationID(i));
    InforSelec(i,:)=InfoGB(idx,:);
end
save('RESULTS2\R8_Regional_GB.mat','Qobs','Qsim',"TimeDATE","StationID",'InforSelec');

k=0;
for i=1:size(StationID,1)
     [overlapdata(i,1),Data, AREA] = findoverlapdata(NearingObs,BasinNearing,NearingSim,StartTime(1),Qsim(:,i),Qobs(:,i),TimeDATE,[InforSelec(i,3:4),InforSelec(i,8)]);
     if ~isnan(overlapdata(i,1))
        k=k+1;
        DataAll{k,1} = Data;
        OverlapInfo(k,:) = InforSelec(i,:);
        AREA_all(k,:) = AREA;
     end
end
save('RESULTS2\R8_Regional_GB_2.mat','Qobs','Qsim',"TimeDATE","StationID",'InforSelec','DataAll','OverlapInfo','AREA_all','overlapdata');

% Read Kratzert data: CAMELS-US: lstm_seed111
% Run 'Read_KratzertData2.py' to load data
clear; clc
load('RESULTS2\R3_Nearing_sim.mat',"BasinNearing","NearingSim","StartTime");
load('RESULTS2\R2_Nearing_obs.mat', 'NearingObs')
load('RESULTS2\R8_Regional_US.mat')  
InfoUS = readtable('E:\PUB_realistic\Data\camels\camels_attributes_v2.0/camels_topo.txt');
InfoUS = table2array(InfoUS);
Basin = load('Data/single-basin-vs-regional-model/basin_lists/531_basin_list.txt');
Time = datetime(Time,'InputFormat','yyyy/MM/dd');
for i=1:numel(Basin)
    idx = find(InfoUS(:,1)==Basin(i));
    InforSelec(i,:)=InfoUS(idx,:);
end
save('RESULTS2\R8_Regional_US.mat','all_qsim','all_qobs','InforSelec','Time');  


load('RESULTS2\R8_Regional_US.mat','all_qsim','all_qobs','InforSelec','Time');  
k=0;
for i=1:size(InforSelec,1)
     [overlapdata_US(i,1),Data, AREA] = findoverlapdata(NearingObs,BasinNearing,NearingSim,StartTime(1),all_qsim(i,:),all_qobs(i,:),Time,[InforSelec(i,2:3), InforSelec(i,6)]);
     if ~isnan(overlapdata_US(i,1))
        k=k+1;
        DataAll{k,1} = Data;
        OverlapInfo(k,:) = InforSelec(i,:);
        AREA_all(k,:) = AREA;
     end
end
save('RESULTS2\R8_Regional_US_2.mat','all_qsim','all_qobs','InforSelec','Time','DataAll','OverlapInfo','AREA_all','overlapdata_US');  


%% Read forecasts from CNRFC
clear all; clc
load('E:\NWM21\Data2\Results\R3_Qdaily.mat')
load('RESULTS2\R3_Nearing_sim_gauged.mat',"BasinNearing","NearingSim","StartTime");
load('RESULTS2\R2_Nearing_obs.mat', 'NearingObs')
NearingSim1 = NearingSim;
load('RESULTS2\R3_Nearing_sim.mat',"BasinNearing","NearingSim","StartTime");

k=0;
for i=1:numel(Datacheck)
    if Datacheck(i)==1
        [overlapdata_CNRFC(i,1),Data, AREA,R2] = findoverlapdataCN(NearingObs,BasinNearing,NearingSim1,StartTime(1),Q{i}(:,2:end),Q{i}(:,1),Time{i},[latLon(i,:) NaN]);
        [overlapdata_CNRFC(i,1),Data2, AREA,R2] = findoverlapdataCN(NearingObs,BasinNearing,NearingSim,StartTime(1),Q{i}(:,2:end),Q{i}(:,1),Time{i},[latLon(i,:) NaN]);
        
        if ~isnan(overlapdata_CNRFC(i,1))
            k=k+1;
            DataAll{k,1} = Data;
            DataAll{k,2} = Data2;
            OverlapInfo(k,:) = latLon(i,:);
            Rkk(k,1) = R2;
%             AREA_all(k,:) = AREA;
         end
    end
end
save('RESULTS2\R8_Regional_CNRFC_3.mat','Time','DataAll','OverlapInfo','overlapdata_CNRFC');  

%% Compute NSE for regional and glopbal models
load('RESULTS2\R8_Regional_GB.mat','Qobs','Qsim',"TimeDATE","StationID",'InforSelec','DataAll','OverlapInfo','AREA_all','overlapdata');
for i=1:size(OverlapInfo,1)
    NSEvalue{1}(i,1) = Nash(DataAll{i,1}(:,2),DataAll{i,1}(:,1));
    NSEvalue{1}(i,2) = Nash(DataAll{i,1}(:,4),DataAll{i,1}(:,3));  
end
figure;scatter(NSEvalue{1}(:,1),NSEvalue{1}(:,2));xlim([0 1]);ylim([0 1])
load('RESULTS2\R8_Regional_US.mat','all_qsim','all_qobs','InforSelec','Time','DataAll','OverlapInfo','AREA_all','overlapdata_US');  
for i=1:size(OverlapInfo,1)
    NSEvalue{2}(i,1) = Nash(DataAll{i,1}(:,2),DataAll{i,1}(:,1));
    NSEvalue{2}(i,2) = Nash(DataAll{i,1}(:,4),DataAll{i,1}(:,3)); 
end
% figure;scatter(NSEvalue{2}(:,1),NSEvalue{2}(:,2));xlim([0 1]);ylim([0 1]);


%% Plot figure:
plot_figure_1; % Figure 1
plot_figure_2; % Figure 2
plot_figure_3; % Figure 3

plot_figure_SM1; % Extended Data Fig. 1
plot_figure_SM2; % Extended Data Fig. 2
plot_figure_SM3; % Extended Data Fig. 3
