function DataStream = readstreamflow(USGSID,DateTime)
%%
Filename = ['RESULTS_FINAL/downloadData2/',USGSID,'.csv'];
Data = readtable(Filename);
DataStream(1:numel(DateTime),1) = NaN;
DataTime = datetime(Data.Var1);
for i=1:numel(DateTime)
        idx = find(DataTime ==DateTime(i) );
        if ~isempty(idx)
            % Get the data from CNRFC file
            DataStream(i,:) =Data.streamflow_cms(idx);
        end
    end
end