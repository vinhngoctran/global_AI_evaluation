function data = readobs(BASNAME,startdate,datalength)
FILENAME = ['Data/Obs/',erase(BASNAME,'GRDC_'),'_Q_Day.Cmd.txt'];
opts = delimitedTextImportOptions("NumVariables", 3);
opts.DataLines = [38, Inf];
opts.Delimiter = ";";
opts.VariableNames = ["Time", "hhmm", "Value"];
opts.VariableTypes = ["datetime", "categorical", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, "hhmm", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Time", "InputFormat", "yyyy-MM-dd");
QDay = readtable(FILENAME, opts);

data(1:datalength,1)=-999;
DateTime = [startdate:days(1):startdate+days(datalength-1)]';
for i=1:datalength
    idx = find(QDay.Time ==DateTime(i) );
    if ~isempty(idx)
        data(i,1) = QDay.Value(idx);
    end
end
end