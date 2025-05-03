function [Length_data, results] = floodanalysis(StartTimeS,datar,idx)

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
ReturnY = [5 10 20 50 100];
for i=1:numel(ReturnY)
    idx = find(dataout(:,1)==ReturnY(i));
    results(i) = dataout(idx,3);
end
else
results(1:5)=0;
end
end