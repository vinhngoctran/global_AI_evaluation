function Peak_FFA= computePeakEEvent(NearingObs,NearingSim,thresholdQ)
Peak_FFA = [];
NearingObs(NearingObs==-999)=NaN;
k=0; % count the number of event
for i=1:size(NearingObs,1)
    % Only select the peak for 20-day event
    if i<11
        Event_sim = NearingSim(1:i+10);
        Event_obs = NearingObs(1:i+10);
        idx = numel(Event_obs)-10;
    elseif i>size(NearingObs,1)-10
        Event_sim = NearingSim(i-10:end);
        Event_obs = NearingObs(i-10:end);
        idx = 11;
    else
        Event_sim = NearingSim(i-10:i+10);
        Event_obs = NearingObs(i-10:i+10);
        idx = 11;
    end
    if max(Event_obs)>=thresholdQ && Event_obs(11) == max(Event_obs) && numel(find(isnan(Event_obs)))==0
        k=k+1;
        Peak_FFA(k,1) = (max(Event_sim) - max(Event_obs))/max(Event_obs)*100;
    end
end
end