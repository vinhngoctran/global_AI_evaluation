function heatScatterPlot(x, y, xLim, yLim, numBins,axes1, titleText, xLabel, yLabel)

    if nargin < 2
        error('At least x and y data must be provided.');
    end
    validIndices = ~isnan(x) & ~isnan(y);
    x = x(validIndices);
    y = y(validIndices);
    
    if nargin < 3 || isempty(xLim), xLim = [min(x), max(x)]; end
    if nargin < 4 || isempty(yLim), yLim = [min(y), max(y)]; end
    if nargin < 5 || isempty(numBins), numBins = 100; end
    if nargin < 6, titleText = 'Heat Scatter Plot'; end
    if nargin < 7, xLabel = 'X-axis'; end
    if nargin < 8, yLabel = 'Y-axis'; end
    [N, Xedges, Yedges] = histcounts2(x, y, numBins, 'XBinLimits', xLim, 'YBinLimits', yLim);
    xBin = discretize(x, Xedges);
    yBin = discretize(y, Yedges);
    validBinIndices = ~isnan(xBin) & ~isnan(yBin) & xBin > 0 & yBin > 0;
    xBin = xBin(validBinIndices);
    yBin = yBin(validBinIndices);
    x = x(validBinIndices);
    y = y(validBinIndices);
    density = N(sub2ind(size(N), xBin, yBin));
    scatter(x, y, 10, density, 'filled');
    colormap(jet);
    cb = colorbar;
    colormap(cmocean('deep'));
    xlim(xLim);
    ylim(yLim);
end