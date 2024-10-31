function heatScatterPlot(x, y, xLim, yLim, numBins,axes1, titleText, xLabel, yLabel)
    % Input validation
    if nargin < 2
        error('At least x and y data must be provided.');
    end
    
    % Remove NaN values
    validIndices = ~isnan(x) & ~isnan(y);
    x = x(validIndices);
    y = y(validIndices);
    
    if nargin < 3 || isempty(xLim), xLim = [min(x), max(x)]; end
    if nargin < 4 || isempty(yLim), yLim = [min(y), max(y)]; end
    if nargin < 5 || isempty(numBins), numBins = 100; end
    if nargin < 6, titleText = 'Heat Scatter Plot'; end
    if nargin < 7, xLabel = 'X-axis'; end
    if nargin < 8, yLabel = 'Y-axis'; end

    % Create 2D histogram
    [N, Xedges, Yedges] = histcounts2(x, y, numBins, 'XBinLimits', xLim, 'YBinLimits', yLim);
    
    % Find bin for each data point
    xBin = discretize(x, Xedges);
    yBin = discretize(y, Yedges);
    
    % Remove invalid bin indices
    validBinIndices = ~isnan(xBin) & ~isnan(yBin) & xBin > 0 & yBin > 0;
    xBin = xBin(validBinIndices);
    yBin = yBin(validBinIndices);
    x = x(validBinIndices);
    y = y(validBinIndices);
    
    % Calculate density for each point
    density = N(sub2ind(size(N), xBin, yBin));
    
    % Create the heat scatter plot
    scatter(x, y, 10, density, 'filled');
    
    % Set colormap and add colorbar
    colormap(jet);
    cb = colorbar;
%     ylabel(cb, 'Density', 'FontSize', 12);
    colormap(cmocean('deep'));
    % Set to log scale if range is large
%     if max(density) / min(density(density>0)) > 100
%         set(axes1, 'ColorScale', 'log');
%         ylabel(cb, 'Log Density', 'FontSize', 12);
%     end
    
    % Set labels and title
%     xlabel(xLabel, 'FontSize', 12);
%     ylabel(yLabel, 'FontSize', 12);
%     title(titleText, 'FontSize', 14);
    
    % Set axis limits
    xlim(xLim);
    ylim(yLim);
    
%     % Adjust figure properties
%     set(gcf, 'Color', 'w');
%     set(gca, 'FontSize', 10);
    
    % Add text with data summary
%     totalPoints = length(validIndices);
%     validPoints = sum(validIndices);
%     stats = sprintf('Total points: %d\nValid points: %d\nRemoved NaNs: %d\nX range: %.2f to %.2f\nY range: %.2f to %.2f', ...
%                     totalPoints, validPoints, totalPoints - validPoints, min(x), max(x), min(y), max(y));
%     annotation('textbox', [0.15, 0.7, 0.2, 0.2], 'String', stats, ...
%                'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'none');
end