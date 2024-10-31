function [NSEmark, NSEvalue] = computeNSE(NearingObs,NearingSim,BasinInfo,StartTime)
NSEvalue = [NaN, NaN];
if BasinInfo==0
    NSEmark = [1, 0];
    NSEvalue(1) = Nash(NearingObs,NearingSim);
elseif isnan(BasinInfo)
    NSEmark = [0, 1];
    NSEvalue(2) = Nash(NearingObs,NearingSim);
else
    DamDate = datetime(BasinInfo,1,1);
    DataTime = [StartTime:days(1):StartTime+days(numel(NearingSim)-1)]';
    if DamDate>=DataTime(end)
        NSEmark = [1, 0];
        NSEvalue(1) = Nash(NearingObs,NearingSim);
    else
        idx = find(DataTime==DamDate);
        if isempty(idx)
            NSEmark = [0, 1];
            NSEvalue(2) = Nash(NearingObs,NearingSim);
        else
            NSEmark = [1, 1];
            NSEvalue(1) = Nash(NearingObs(1:idx-1),NearingSim(1:idx-1));
            NSEvalue(2) = Nash(NearingObs(idx:end),NearingSim(idx:end));
        end
    end

end
end