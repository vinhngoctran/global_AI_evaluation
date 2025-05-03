function [KGEmark, KGEvalue] = computeKGE(NearingObs,NearingSim,BasinInfo,StartTime)
KGEvalue = [NaN, NaN];
if BasinInfo==0
    KGEmark = [1, 0];
    KGEvalue(1) = metric_KGE(NearingObs,NearingSim);
elseif isnan(BasinInfo)
    KGEmark = [0, 1];
    KGEvalue(2) = metric_KGE(NearingObs,NearingSim);
else
    DamDate = datetime(BasinInfo,1,1);
    DataTime = [StartTime:days(1):StartTime+days(numel(NearingSim)-1)]';
    if DamDate>=DataTime(end)
        KGEmark = [1, 0];
        KGEvalue(1) = metric_KGE(NearingObs,NearingSim);
    else
        idx = find(DataTime==DamDate);
        if isempty(idx)
            KGEmark = [0, 1];
            KGEvalue(2) = metric_KGE(NearingObs,NearingSim);
        else
            KGEmark = [1, 1];
            KGEvalue(1) = metric_KGE(NearingObs(1:idx-1),NearingSim(1:idx-1));
            KGEvalue(2) = metric_KGE(NearingObs(idx:end),NearingSim(idx:end));
        end
    end

end
end