function plot_figure_1()
%%
clc

close all;
load('RESULTS_FINAL\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");
load('RESULTS_FINAL\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')
load Col.mat % Color setup
LevelNSE = [0.5, 0.65, 0.75, 1];
LevelName = ["Unsatisfactory","Acceptable","Good","Very good"];
for i=1:size(BasinNearing,1)
    RatioVol(i,1) = BasinInfo(i,1)/BasinNearing.calculated_drain_area(i);
    ContinentIn(i,1) = string(BasinNearing.Continent{i});
end
close all
figure1 = figure('OuterPosition',[300 0 1000 900]);
axes1 = axes('Parent',figure1,...
    'Position',[0.1 0.5 0.7 0.48]);hold on;
% Load geographic data
load coastlines;
mapshow(coastlon,coastlat, 'DisplayType', 'polygon', 'FaceColor', [0.8 0.8 0.8],'EdgeColor','none');hold on
scatter(BasinNearing.longitude, BasinNearing.latitude, 10, RatioVol, 'filled', 'MarkerEdgeColor', 'none');
% Add colorbar
cb = colorbar(axes1,'Location','southoutside','Position',...
    [0.505081300813012 0.607187112763321 0.15853658536585 0.0237918247530552]);

caxis([0 1]);
ylabel(cb, 'Dam area ratio [km^2/km^2]', 'FontSize', 12);
colormap(cmocean('deep'));
set(axes1,'Color','none','Linewidth',1.5,'FontSize',13,'layer','top','Xcolor','none','Ycolor','none');
title("a",'FontSize',16,'VerticalAlignment','top');axes1.TitleHorizontalAlignment = 'left';


axes1 = axes('Parent',figure1,...
    'Position',[0.101016260162602 0.612391573729864 0.190650406504065 0.12366790582404]); hold on
[sortedDams, sortIndex] = sort(RatioVol);
resorteddam = unique(sortedDams);
for i=1:numel(resorteddam)
    nbasins(i) = numel(find(sortedDams==resorteddam(i)));
end
cumulativeWatersheds = cumsum(nbasins);
plot(resorteddam, cumulativeWatersheds, 'k-', 'LineWidth', 2);
ylim([0 size(BasinNearing,1)])
xlim([0 1])
ylabel('Number of Basins', 'FontSize', 12);
xlabel('Dam area ratio [km^2/km^2]', 'FontSize', 12);
set(axes1,'Color','none','Linewidth',1.5,'FontSize',12,'layer','top','FontSize',12);grid minor


axes1 = axes('Parent',figure1,...
    'Position',[0.1 0.2 0.3 0.28]); hold on
idx = find(NSEmark(:,1)==1);
NSEval = NSEvalue(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
display(['N of natural series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEval>=0.5))),' (',num2str(numel(find(NSEval>=0.5))/numel(NSEval)),')    ; Median NSE: ',num2str(median(NSEval,'omitnan')), '   ; Porpotion of NSE<0.5: ',num2str(numel(find(NSEval<0.5))/numel(NSEval))])
display(['N of natural series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.75: ',num2str(numel(find(NSEval>=0.75))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan'))])

xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",'k','LineWidth',2,'DisplayName','Natural');

idx = find(NSEmark(:,2)==1);
NSEval = NSEvalue(idx,2);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
display(['N of dammed series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEval>=0.5))),' (',num2str(numel(find(NSEval>=0.5))/numel(NSEval)),')    ; Median NSE: ',num2str(median(NSEval,'omitnan')), '   ; Porpotion of NSE<0.5: ',num2str(numel(find(NSEval<0.5))/numel(NSEval))])
display(['N of dammed series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.75: ',num2str(numel(find(NSEval>=0.75))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan'))])

xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",Col(2,:),'LineWidth',2,'DisplayName','Dammed');
for i=1:4
    plot([LevelNSE(i) LevelNSE(i)],[0 1],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1)
    text(LevelNSE(i)-0.06,0.05,LevelName(i),'Rotation',90)
end
legend1 = legend(["Natural","Dammed"],'Box','off'); 
set(legend1,...
    'Position',[0.114532521294386 0.262609648741943 0.116869916760825 0.0599479887614649],...
    'Color',[1 1 1]);
ylabel('CDF [-]')
% xlim([-1 1]);ylim([0 1])
xlabel('NSE [-]')
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');
title("b",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';


CaseName = ["Natural","Dammed"];
for i=1:2
    axes1 = axes('Parent',figure1,...
    'Position',[0.47 0.35-(i-1)*0.15 0.28 0.13]); hold on
    set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');

    idx = find(NSEmark(:,i)==1);
    NSEval = NSEvalue(idx,i);

    Continent = ContinentIn(idx);
    uniqContinent = unique(ContinentIn);
    for j=1:size(uniqContinent,1)
        idx = find(Continent==uniqContinent{j});
        cont_NSE = NSEval(idx);
        if ~isempty(cont_NSE)
        xxx = [-1:0.02:1];
        cont_NSE = cont_NSE(~any(isnan(cont_NSE), 2), :);
        display([CaseName{i},'-',uniqContinent{j},': ',num2str(median(cont_NSE,'omitnan')),';  N = ',num2str(numel(cont_NSE))])
        NSE_cdf = computecdf(xxx,cont_NSE);
        plot(xxx,NSE_cdf,"Color",Col(2+j,:),'LineWidth',2,'DisplayName',uniqContinent(j));
        end
    end
    ylabel('CDF [-]')
     text(-0.9,0.9,CaseName(i),"FontSize",12)
    for l=1:4
    plot([LevelNSE(l) LevelNSE(l)],[0 1],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1)
%     text(LevelNSE(i)-0.06,0.05,LevelName(i),'Rotation',90)
    end
    if i==1
        legend(["AF","AS","AU","EU","GR","NA","AR","SI","SA"],'Box','off',...
            'Position',[0.751031207219289 0.266418841507059 0.0741869912036066 0.22180916344957]); 
    end
    if i==1
        set(axes1,'Xticklabel',{});
        title("c",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';
    else
        xlabel('NSE [-]')
    end
end
num_bins = 15;
axes1 = axes('Parent',figure1,...
    'Position',[0.132723577235774 0.379739776951673 0.16 0.10724907063197]);hold on
    Zerodam(1:size(RatioVol,1),1)=0;
    heatScatterPlot([Zerodam; RatioVol(:,1)],[NSEvalue(:,1);NSEvalue(:,2)],[0 1],[-1 1],num_bins,axes1)
    plot([0 1],[0.5 0.5],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1.5)
    plot([0 1],[0.2 0.2],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1.5)
    
    set(axes1,'Color','none','Linewidth',2,'layer','top','FontSize',10,'YTick',[-1 0.2 0.5 1],'YTickLabel',["-1","0.2","0.5","1"]);
idx = find(NSEmark(:,2)==1);
RatioVol2 = RatioVol(idx,1);
NSEvalue2 =     NSEvalue(idx,2);
idx = find(RatioVol2<=0.1);
NSEvalue3 = NSEvalue2(idx);
NSEvalue3 = NSEvalue3(~any(isnan(NSEvalue3), 2), :);
display(['N dammed area ratio <= 0.1 = ',num2str(numel(NSEvalue3)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEvalue3>=0.5))),'     ; Number of NSE>=0.75: ',num2str(numel(find(NSEvalue3>=0.75))),'     ; Max NSE: ',num2str((median(NSEvalue3,'omitnan')))])

idx = find(RatioVol2>=0.75);
NSEvalue3 = NSEvalue2(idx);
NSEvalue3 = NSEvalue3(~any(isnan(NSEvalue3), 2), :);
display(['N dammed area ratio >= 0.75 = ',num2str(numel(NSEvalue3)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEvalue3>=0.5))),'     ; Number of NSE>=0.75: ',num2str(numel(find(NSEvalue3>=0.75))),'     ; Max NSE: ',num2str((median(NSEvalue3,'omitnan')))])

% Plot fitted line
x = [Zerodam; RatioVol(:,1)];
y = [NSEvalue(:,1);NSEvalue(:,2)];
x_clean0 = x(~isnan(x) & ~isnan(y));
x_clean = x_clean0(x_clean0<=1);
y = y(~isnan(x) & ~isnan(y));
y_clean = y(x_clean0<=1);
x_clean = x_clean';y_clean=y_clean';
num_bins = 15;
[N, edges, bin] = histcounts(x_clean, num_bins);
bin_centers = [0:1/num_bins:1];
median_y = accumarray(bin', y_clean, [], @max);
valid_medians = ~isnan(median_y);
bin_centers = bin_centers(valid_medians);
median_y = median_y(valid_medians);
plot(bin_centers, median_y, 'r-', 'LineWidth', 1);

median_y = accumarray(bin', y_clean, [], @median);
valid_medians = ~isnan(median_y);
bin_centers = bin_centers(valid_medians);
median_y = median_y(valid_medians);
plot(bin_centers, median_y, 'r--', 'LineWidth', 1);

% [numel(find(NSEvalue2(idx)>0.5)) numel(NSEvalue2(idx))]
% [numel(find(NSEvalue2(idx)>0.75)) numel(NSEvalue2(idx))]
% idx = find(RatioVol2>0.5);
% [numel(find(NSEvalue2(idx)>0.5)) numel(NSEvalue2(idx))]
% [numel(find(NSEvalue2(idx)>0.75)) numel(NSEvalue2(idx))]
    exportgraphics(figure1,"Figure_final/F1.jpg",'Resolution',600)
exportgraphics(figure1, "Figure_final/F1.pdf", 'ContentType', 'vector');

end