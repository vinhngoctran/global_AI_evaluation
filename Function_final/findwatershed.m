function mergedBasin = findwatershed(basinAtlas,outletX,outletY,SHAPENAME)
% Create a point object for the outlet
outletPoint = [outletX, outletY];
mergedBasin = 1;
% Find the sub-basin containing the outlet
containingBasinIdx = [];
for i = 1:length(basinAtlas)
    if inpolygon(outletX, outletY, basinAtlas(i).X, basinAtlas(i).Y)
        containingBasinIdx = i;
        HyID = basinAtlas(i).HYBAS_ID;
        break;
    end
end
for i = 1:length(basinAtlas)
    NexDownID(i,1) =  basinAtlas(i).NEXT_DOWN;
end

if ~isempty(containingBasinIdx)
    % Initialize watershed with the containing basin
    watershed = basinAtlas(containingBasinIdx);
    upstreamBasins(1) = watershed;
    
    % Aggregate upstream basins
    % Assuming 'NEXT_DOWN' is the field indicating the downstream basin ID
    upstreamFound = true;
   k=1;
    while upstreamFound

        CheckBas = containingBasinIdx;
        
        for j=k:size(CheckBas,1)
            for i = 1:length(basinAtlas)
                if basinAtlas(CheckBas(j)).HYBAS_ID == basinAtlas(i).NEXT_DOWN
                    idx = find(containingBasinIdx==i);
                    if isempty(idx)  
                        containingBasinIdx = [containingBasinIdx;i];
                        upstreamFound = true;
                    end
                end
            end
        end
        k=numel(CheckBas)+1;
%         containingBasinIdx = unique(containingBasinIdx);
        if sum(containingBasinIdx) - sum(CheckBas)==0
            upstreamFound = false;
        end
        upstreamBasins = basinAtlas(containingBasinIdx);
    end
    

       % Merge all upstream basins into one
    mergedPolygon = [];
    
    for i = 1:length(upstreamBasins)
        if isempty(mergedPolygon)
            mergedPolygon = polyshape(upstreamBasins(i).X, upstreamBasins(i).Y);
        else
            currentPoly = polyshape(upstreamBasins(i).X, upstreamBasins(i).Y);
            mergedPolygon = union(mergedPolygon, currentPoly);
        end
    end


    % Extract the boundary of the merged polygon
[mergedX, mergedY] = boundary(mergedPolygon);


% Create a structure for the merged polygon to save as a shapefile
mergedBasin = struct('Geometry', 'Polygon', ...
                     'X', [mergedX; NaN], ...
                     'Y', [mergedY;NaN], ...
                     'ID', 1);
    % Save the watershed boundary as a shapefile
    shapewrite(mergedBasin, SHAPENAME);
    idxxx = 1;
else
    idxxx = 0;
    disp('Outlet point not found in any basin');
end