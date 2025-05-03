function [idx_overlap,Data, AREA,R2] = findoverlapdataCN(NearingObs,BasinNearing,NearingSim,Starttime,Qsim,Qobs,TimeDATE,InforSelec,USGSID)
[idx_overlap, ~] = findclosestation_utm([InforSelec(1),InforSelec(2)],[BasinNearing.latitude, BasinNearing.longitude],1000);
AREA = [NaN, NaN];
Data(1:size(NearingObs,1),1:14)=-999;
R2 = NaN;
if ~isnan(idx_overlap)
    Data(1:size(NearingObs,1),1:4)=-999;
    DateTime = [Starttime:days(1):Starttime+days(size(NearingObs,1)-1)]';
    try
        AREA = [BasinNearing.calculated_drain_area(idx_overlap), InforSelec(3)];
    catch
        AREA = [NaN, NaN];
    end
    for i=1:numel(DateTime)
        idx = find(TimeDATE ==DateTime(i) );
        if ~isempty(idx)
            % Get the data from CNRFC file
            Data(i,:) = [NearingSim{idx_overlap}(i,:)*BasinNearing.calculated_drain_area(idx_overlap,1)*10^6/1000/86400, NearingObs(i,idx_overlap), Qsim(idx,:),Qobs(idx)];%[8 1 4 1]
        end
    end
    % Get the daily data from USGS to compute the correlation.
    USGS = readstreamflow(USGSID,DateTime);
    R2 = ComputeR2(Data(:,9),USGS)
    if R2<0.99 || isnan(R2)
        idx_overlap = NaN;
        AREA = [NaN, NaN];
        Data(1:size(NearingObs,1),1:14)=-999;
    end
end

end