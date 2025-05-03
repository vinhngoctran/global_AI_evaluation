function [Length_data, results] = floodanalysis_gev(StartTimeS,datar,idx)

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
    % save('test.mat','data')
    results = flood_frequency_analysis(data);
else
    results(1:5)=0;
end
end