function data = findglofas(GloFASData,GFTime,startdate,datalength)
data(1:datalength,1)=-999;
DateTime = [startdate:days(1):startdate+days(datalength-1)]';
for i=1:datalength
    idx = find(GFTime ==DateTime(i) );
    if ~isempty(idx)
        data(i,1) = GloFASData(idx);
    end
end
end