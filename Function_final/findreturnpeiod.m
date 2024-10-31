function [RP] = findreturnpeiod(StartTimeS,datar,idx)
MaxObs = max(datar);

DATETIME = [StartTimeS:days(1):StartTimeS+days(numel(datar)-1)]';
TT = array2timetable(datar(idx),'RowTimes',DATETIME(idx),'VariableNames',{'Q'});
Qmax = retime(TT,'yearly','max');
data(:,2) = Qmax.Q;
for i=1:size(Qmax,1)
    data(i,1) = str2num(datestr(Qmax.Time(i),'yyyy'));
end
data(data<=0) = NaN;
idx = find(~isnan(data(:,2)));
data = data(idx,:);
Length_data = size(data,1);
if Length_data>=10
    [dataout skews pp XS SS hp] = b17(data);
    
    idx = find(hp(:,2)==MaxObs);
    if ~isempty(idx)
        RP = 1/hp(idx(1),1);
    else
        functiongit = fit(hp(:,2), hp(:,1), 'smoothingspline');
        RP = 1 / functiongit(MaxObs);
    end
else
    RP = NaN;
end
end