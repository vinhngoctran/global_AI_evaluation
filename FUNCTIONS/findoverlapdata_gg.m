function [idx_overlap,R2] = findoverlapdata_gg(NearingObs,Caravan,Starttime,InforSelec,CaravanFolder)

[idx_overlap, ~] = findclosestation_utm([InforSelec(1),InforSelec(2)],[Caravan.gauge_lat, Caravan.gauge_lon],1000);
AREA = [NaN, NaN];
R2=NaN;
if ~isnan(idx_overlap)
    Filename = [CaravanFolder,Caravan.gauge_id{idx_overlap},'.mat'];load(Filename);
    Qcaravan = Data(:,1);
    TimeDATE = [datetime(1980,1,1):days(1):datetime(2022,12,31)];
    Data_Q(1:size(NearingObs,1),1:2)=-999;
    DateTime = [Starttime:days(1):Starttime+days(size(NearingObs,1)-1)]';
    for i=1:numel(DateTime)
        idx = find(TimeDATE ==DateTime(i));
        if ~isempty(idx)
            Data_Q(i,:) = [NearingObs(i), Qcaravan(idx)*Caravan.area(idx_overlap)*10^6/1000/86400];
        end
    end
    Data_Q(Data_Q<0) = NaN;
    R2 = ComputeR2(Data_Q(:,1)/max(Data_Q(:,1)),Data_Q(:,2)/max(Data_Q(:,2)));
    if R2<0.99
        idx_overlap = NaN;
    end
end

end