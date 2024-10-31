function valuecdf = computecdf(xxx,observation)
for i=1:numel(xxx)
    valuecdf(i,1) = numel(find(observation<=xxx(i)))/numel(observation);
end
end