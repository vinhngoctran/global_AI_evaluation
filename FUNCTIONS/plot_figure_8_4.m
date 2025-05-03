function plot_figure_8()
%%
clc;  

close all;
load('RESULTS_FINAL\R8_Regional_GB_2.mat','Qobs','Qsim',"TimeDATE","StationID",'InforSelec','DataAll','OverlapInfo','AREA_all','overlapdata');
for i=1:size(OverlapInfo,1)
    NSEvalue{1,1}(i,1) = Nash(DataAll{i,1}(:,2),DataAll{i,1}(:,1));
    NSEvalue{1,1}(i,2) = Nash(DataAll{i,1}(:,4),DataAll{i,1}(:,3));  

    [flood_events, event_peaks, event_dates] = find_flood_events(DataAll{i,1}(:,2));
    for j=1:numel(flood_events)
        NSEvalue{1,2}{i}(j,1) = Nash(DataAll{i,1}(event_dates{j},2),DataAll{i,1}(event_dates{j},1));
        NSEvalue{1,2}{i}(j,2) = Nash(DataAll{i,1}(event_dates{j},4),DataAll{i,1}(event_dates{j},3)); 
    end

    NSEvalue{1,3}(i,1) = mean(NSEvalue{1,2}{i}(:,1),'omitnan');
    NSEvalue{1,3}(i,2) = mean(NSEvalue{1,2}{i}(:,2),'omitnan');
end


LocationDat{1} = OverlapInfo;
% figure;scatter(NSEvalue{1}(:,1),NSEvalue{1}(:,2));xlim([0 1]);ylim([0 1])
load('RESULTS_FINAL\R8_Regional_US_2.mat','all_qsim','all_qobs','InforSelec','Time','DataAll','OverlapInfo','AREA_all','overlapdata_US');  
for i=1:size(OverlapInfo,1)
    NSEvalue{2,1}(i,1) = Nash(DataAll{i,1}(:,2),DataAll{i,1}(:,1));
    NSEvalue{2,1}(i,2) = Nash(DataAll{i,1}(:,4),DataAll{i,1}(:,3)); 

    [flood_events, event_peaks, event_dates] = find_flood_events(DataAll{i,1}(:,2));
    for j=1:numel(flood_events)
        NSEvalue{2,2}{i}(j,1) = Nash(DataAll{i,1}(event_dates{j},2),DataAll{i,1}(event_dates{j},1));
        NSEvalue{2,2}{i}(j,2) = Nash(DataAll{i,1}(event_dates{j},4),DataAll{i,1}(event_dates{j},3)); 
    end

    NSEvalue{2,3}(i,1) = mean(NSEvalue{2,2}{i}(:,1),'omitnan');
    NSEvalue{2,3}(i,2) = mean(NSEvalue{2,2}{i}(:,2),'omitnan');
end
LocationDat{2} = OverlapInfo;
% figure;scatter(NSEvalue{2}(:,1),NSEvalue{2}(:,2));xlim([0 1]);ylim([0 1])

load('RESULTS_FINAL\R8_Regional_CNRFC_3.mat','Time','DataAll','OverlapInfo','overlapdata_CNRFC');  
for i=1:size(OverlapInfo,1)
        for LT = 1:4
            NSEvalue{3,1}(i,1,LT) = Nash(DataAll{i,1}(:,9),DataAll{i,1}(:,LT+1));
            NSEvalue{3,1}(i,2,LT) = Nash(DataAll{i,2}(:,9),DataAll{i,2}(:,LT+1));
            NSEvalue{3,1}(i,3,LT) = Nash(DataAll{i,1}(1+LT:end,14),DataAll{i,1}(1:end-LT,9+LT));

            [flood_events, event_peaks, event_dates] = find_flood_events(DataAll{i,1}(:,9));
            for j=1:numel(flood_events)
                NSEvalue{3,2}{i}(j,1,LT) = Nash(DataAll{i,1}(event_dates{j},9),DataAll{i,1}(event_dates{j},LT+1));
                NSEvalue{3,2}{i}(j,2,LT) = Nash(DataAll{i,2}(event_dates{j},9),DataAll{i,2}(event_dates{j},LT+1));
                NSEvalue{3,2}{i}(j,3,LT) = Nash(DataAll{i,1}(event_dates{j},14),DataAll{i,1}(event_dates{j}-LT,9+LT));

                NSEvalue{3,4}{i}(j,1,LT) = computeflooderror2(DataAll{i,1}(event_dates{j},9),DataAll{i,1}(event_dates{j},LT+1));
                NSEvalue{3,4}{i}(j,2,LT) = computeflooderror2(DataAll{i,2}(event_dates{j},9),DataAll{i,2}(event_dates{j},LT+1));
                NSEvalue{3,4}{i}(j,3,LT) = computeflooderror2(DataAll{i,1}(event_dates{j},14),DataAll{i,1}(event_dates{j}-LT,9+LT));
            end
            NSEvalue{3,3}(NSEvalue{3,3} == -Inf) = NaN;
            NSEvalue{3,3}(i,1,LT) = mean(NSEvalue{3,2}{i}(:,1,LT),'omitnan');
            NSEvalue{3,3}(i,2,LT) = mean(NSEvalue{3,2}{i}(:,2,LT),'omitnan');
            NSEvalue{3,3}(i,3,LT) = mean(NSEvalue{3,2}{i}(:,3,LT),'omitnan');

            NSEvalue{3,5}(i,1,LT) = mean(NSEvalue{3,4}{i}(:,1,LT),'omitnan');
            NSEvalue{3,5}(i,2,LT) = mean(NSEvalue{3,4}{i}(:,2,LT),'omitnan');
            NSEvalue{3,5}(i,3,LT) = mean(NSEvalue{3,4}{i}(:,3,LT),'omitnan');
    end
end
LocationDat{3} = OverlapInfo;
save('RESULTS_FINAL\R9_NSE_Benchmark.mat','LocationDat',"NSEvalue")

%%
load('RESULTS_FINAL\R9_NSE_Benchmark.mat','LocationDat',"NSEvalue")
LevelNSE = [0.5, 0.65, 0.75, 1];
LevelName = ["Unsatisfactory","Acceptable","Good","Very good"];
load Col.mat % Color setup
close all;clc
figure1 = figure('OuterPosition',[300 10 1000 900]);
axes1 = axes('Parent',figure1,...
    'Position',[0.1 0.5 0.7 0.48]);hold on;
% Load geographic data
load coastlines;
mapshow(coastlon,coastlat, 'DisplayType', 'polygon', 'FaceColor', [0.8 0.8 0.8],'EdgeColor','none');hold on
scatter(LocationDat{1}(:,4), LocationDat{1}(:,3), 10, 'filled', 'MarkerEdgeColor', 'none','MarkerFaceColor',Col(2,:));
scatter(LocationDat{2}(:,3), LocationDat{2}(:,2), 10, 'filled', 'MarkerEdgeColor', 'none','MarkerFaceColor','k');
scatter(LocationDat{3}(:,2), LocationDat{3}(:,1), 10, 'filled', 'MarkerEdgeColor', 'none','MarkerFaceColor',Col(5,:));
% Add colorbar

set(axes1,'Color','none','Linewidth',1.5,'FontSize',13,'Xcolor','none','Ycolor','none');
% title("a",'FontSize',16,'VerticalAlignment','top');axes1.TitleHorizontalAlignment = 'left';


axes1 = axes('Parent',figure1,...
    'Position',[0.5 0.6 0.171747967479672 0.331474597273854]);hold on; box on
% Load geographic data
load coastlines;
mapshow(coastlon,coastlat, 'DisplayType', 'polygon', 'FaceColor', [0.8 0.8 0.8],'EdgeColor','none');hold on
scatter(LocationDat{1}(:,4), LocationDat{1}(:,3), 20, 'filled', 'MarkerEdgeColor', 'none','MarkerFaceColor',Col(2,:));
% Add colorbar
xlim([min(LocationDat{1}(:,4))-1 max(LocationDat{1}(:,4))+1]);ylim([min(LocationDat{1}(:,3))-1 max(LocationDat{1}(:,3))+1]);
set(axes1,'Linewidth',1.5,'FontSize',13,'XTickLabel',{},'YTickLabel',{},'XColor',Col(2,:),'YColor',Col(2,:));


axes1 = axes('Parent',figure1,...
    'Position',[0.22 0.55638166047088 0.141869918699187 0.220570012391574]);hold on; box on
% Load geographic data
load coastlines;
mapshow(coastlon,coastlat, 'DisplayType', 'polygon', 'FaceColor', [0.8 0.8 0.8],'EdgeColor','none');hold on
scatter(LocationDat{3}(:,2), LocationDat{3}(:,1), 20, 'filled', 'MarkerEdgeColor', 'none','MarkerFaceColor',Col(5,:));
% Add colorbar
xlim([min(LocationDat{3}(:,2))-1 max(LocationDat{3}(:,2))+1]);ylim([min(LocationDat{3}(:,1))-1 max(LocationDat{3}(:,1))+1]);
set(axes1,'Linewidth',1.5,'FontSize',13,'layer','top','XTickLabel',{},'YTickLabel',{},'XColor',Col(5,:),'YColor',Col(5,:));


annotation(figure1,'arrow',[0.237804878048781 0.237804878048781],...
    [0.806930607187113 0.776951672862453],'Color',Col(5,:),'LineWidth',1);

annotation(figure1,'arrow',[0.46849593495935 0.5],...
    [0.870127633209418 0.870127633209418],'Color',Col(2,:),'LineWidth',1);


annotation(figure1,'textbox',...
    [0.223560975609756 0.809169764560099 0.0284715447154472 0.0384138785625775],...
    'FitBoxToText','off','LineWidth',1,...
    'EdgeColor',Col(5,:));

annotation(figure1,'textbox',...
    [0.217463414634147 0.799256505576208 0.124 0.0755885997521686],...
    'LineWidth',1,...
    'FitBoxToText','off');

annotation(figure1,'textbox',...
    [0.421731707317076 0.848822800495663 0.0437154471544696 0.0495662949194547],...
    'Color',[0 0.447058823529412 0.741176470588235],...
    'LineWidth',1,...
    'FitBoxToText','off',...
    'EdgeColor',[0 0.447058823529412 0.741176470588235]);

axes1 = axes('Parent',figure1,...
    'Position',[0.0668699186991878 0.817843866171004 0.14 0.147459727385378]); hold on;box on
    scatter(NSEvalue{2,1}(:,1),NSEvalue{2,1}(:,2),'MarkerFaceColor',[0.5 0.5 0.5],'MarkerFaceAlpha',0.5,'MarkerEdgeColor','none');
    scatter(-1,median(NSEvalue{2,1}(:,2)),100,'Marker','square','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k');
    scatter(median(NSEvalue{2,1}(:,1)),-1,100,'Marker','^','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k');
    [median(NSEvalue{2,1}(:,2)) median(NSEvalue{2,1}(:,1))]
    scatter(NSEvalue{2,3}(:,1),NSEvalue{2,3}(:,2),100,'Marker','+','MarkerFaceColor','r','MarkerFaceAlpha',0.5,'MarkerEdgeColor','r');
    scatter(-1,median(NSEvalue{2,3}(:,2)),100,'Marker','square','MarkerFaceColor','r','MarkerEdgeColor','k');
    scatter(median(NSEvalue{2,3}(:,1)),-1,100,'Marker','^','MarkerFaceColor','r','MarkerEdgeColor','k');
    [median(NSEvalue{2,3}(:,2)) median(NSEvalue{2,3}(:,1))]
    plot([0.5 0.5],[-1 1],'LineStyle','--','Color',[0 0 0],'LineWidth',1.5);
    plot([-1 1],[0.5 0.5],'LineStyle','--','Color',[0 0 0],'LineWidth',1.5);
    plot([-1 1],[-1 1],'Color','k','LineWidth',1.5)
    xlabel('NSE_{G-AI} [-]');ylabel('NSE_{R-AI} [-]');xlim([-1 1]);ylim([-1 1])
set(axes1,'Linewidth',1.5,'FontSize',11,...
    'Xtick',[-1:0.5:1],'Ytick',[-1:0.5:1]);
title("a US("+num2str(numel(NSEvalue{2,1}(:,1)))+")",'FontSize',13,'VerticalAlignment','baseline');axes1.TitleHorizontalAlignment = 'left'


axes1 = axes('Parent',figure1,...
    'Position',[0.745447154471551 0.62912019826518 0.2 0.23]); hold on; box on
    scatter(NSEvalue{1,1}(:,1),NSEvalue{1,1}(:,2),'MarkerFaceColor',[0.5 0.5 0.5],'MarkerFaceAlpha',0.5,'MarkerEdgeColor','none')
    scatter(-1,median(NSEvalue{1,1}(:,2)),100,'Marker','square','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k')
    scatter(median(NSEvalue{1,1}(:,1)),-1,100,'Marker','^','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k')
    [median(NSEvalue{1,1}(:,2)) median(NSEvalue{1,1}(:,1))]
    scatter(NSEvalue{1,3}(:,1),NSEvalue{1,3}(:,2),100,'Marker','+','MarkerFaceColor','r','MarkerFaceAlpha',0.5,'MarkerEdgeColor','r')
    scatter(-1,median(NSEvalue{1,3}(:,2)),100,'Marker','square','MarkerFaceColor','r','MarkerEdgeColor','k')
    scatter(median(NSEvalue{1,3}(:,1)),-1,100,'Marker','^','MarkerFaceColor','r','MarkerEdgeColor','k')

    [median(NSEvalue{1,3}(:,2)) median(NSEvalue{1,3}(:,1))]

    plot([0.5 0.5],[-1 1],'LineStyle','--','Color',[0 0 0],'LineWidth',1.5)
    plot([-1 1],[0.5 0.5],'LineStyle','--','Color',[0 0 0],'LineWidth',1.5)
    plot([-1 1],[-1 1],'Color','k','LineWidth',1.5)
    xlabel('NSE_{G-AI} [-]');ylabel('NSE_{R-AI} [-]');xlim([-1 1]);ylim([-1 1])
set(axes1,'Linewidth',1.5,'FontSize',11,'XColor',Col(2,:),'YColor',Col(2,:),...
    'Xtick',[-1:0.5:1],'Ytick',[-1:0.5:1]);
title("B GB("+num2str(numel(NSEvalue{1,1}(:,1)))+")",'FontSize',13,'VerticalAlignment','baseline');axes1.TitleHorizontalAlignment = 'left'


for i=1:4
axes1 = axes('Parent',figure1,...
    'Position',[0.1+(i-1)*0.2 0.34 0.18 0.2]); hold on; box on
    scatter(NSEvalue{3,1}(:,2,i),NSEvalue{3,1}(:,3,i),'MarkerFaceColor',[0.5 0.5 0.5],'MarkerFaceAlpha',0.5,'MarkerEdgeColor','k')
    scatter(-4,median(NSEvalue{3,1}(:,3,i)),100,'Marker','square','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k')
    scatter(median(NSEvalue{3,1}(:,2,i)),-4,100,'Marker','^','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k')

    scatter(NSEvalue{3,3}(:,2,i),NSEvalue{3,3}(:,3,i),100,'Marker','+','MarkerFaceColor','r','MarkerFaceAlpha',0.5,'MarkerEdgeColor','r')
    scatter(-4,median(NSEvalue{3,3}(:,3,i)),100,'Marker','square','MarkerFaceColor','r','MarkerEdgeColor','k')
    scatter(median(NSEvalue{3,3}(:,2,i)),-4,100,'Marker','^','MarkerFaceColor','r','MarkerEdgeColor','k')
   median(NSEvalue{3,3}(:,2,i))
    plot([0.5 0.5],[-4 1],'LineStyle','--','Color',[0 0 0],'LineWidth',1.5)
    plot([-4 1],[0.5 0.5],'LineStyle','--','Color',[0 0 0],'LineWidth',1.5)
    plot([-4 1],[-4 1],'Color','k','LineWidth',1.5)
    xlabel('NSE_{G-AI} [-]');xlim([-4 1]);ylim([-4 1]);
    if i==1
        ylabel('NSE_{PBM} [-]');
    end
set(axes1,'Linewidth',1.5,'FontSize',11,'XColor',Col(5,:),'YColor',Col(5,:),...
    'Xtick',[-4:1:1],'Ytick',[-4:1:1]);
if i>1
    axes1.YTickLabel = {};
end
if i==1
title("c CNRFC("+num2str(numel(NSEvalue{3,1}(:,2,i)))+")",'FontSize',13,'VerticalAlignment','baseline');axes1.TitleHorizontalAlignment = 'left';
end
annotation(figure1,'textbox',...
    [0.157154471544716+(i-1)*0.2 0.35 0.0873983716819345 0.0334572484428259],...
    'String',{['LT = ',num2str(i),'-day']},'LineStyle','none');
end


LevelNSE = [0.5, 0.65, 0.75, 1];
LevelName = ["Unsatisfactory","Acceptable","Good","Very good"];
for i=1:4
axes1 = axes('Parent',figure1,...
    'Position',[0.1+(i-1)*0.2 0.07 0.18 0.2]); hold on; box on
%     scatter(NSEvalue{3,1}(:,2,i),NSEvalue{3,1}(:,3,i),'MarkerFaceColor',[0.5 0.5 0.5],'MarkerFaceAlpha',0.5,'MarkerEdgeColor','k')
   Data1 = [];Data2 = [];
   for j=1:numel(NSEvalue{3, 4}  )
        Data1 = [Data1;NSEvalue{3, 2}{j}(:,2,i)];
        Data2 = [Data2;NSEvalue{3, 2}{j}(:,3,i)];
   end
xxx = [-3:0.02:1];
NSE_cdf = computecdf(xxx,Data1); 
plot(xxx,NSE_cdf,"Color",'k','LineWidth',2,'DisplayName','G-AI');

NSE_cdf = computecdf(xxx,Data2); 
plot(xxx,NSE_cdf,"Color",Col(2,:),'LineWidth',2,'DisplayName','PBM');

for j=1:4
    plot([LevelNSE(j) LevelNSE(j)],[0 1],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1)
    if i==4
    text(LevelNSE(j)-0.06,0.05,LevelName(j),'Rotation',90,'Color',[0.5 0.5 0.5])
    end
end
% plot([0.5 0.5],[0 1],'LineStyle','--','Color',[0 0 0],'LineWidth',1.5)
    xlabel('NSE [-]');xlim([-1 1]);ylim([0 1])
    if i==1
        ylabel('CDF [-]');
    end
set(axes1,'Linewidth',1.5,'FontSize',11,'XColor',Col(5,:),'YColor',Col(5,:),...
    'Xtick',[-1:0.5:1],'Ytick',[0:0.2:1]);
if i>1
    axes1.YTickLabel = {};
end
if i==1
    legend1 = legend(["G-AI","PBM"],'Box','off','Location','northwest'); 
% title("c CNRFC(11)",'FontSize',13,'VerticalAlignment','baseline');axes1.TitleHorizontalAlignment = 'left'
end
annotation(figure1,'textbox',...
    [0.13+(i-1)*0.2 0.07 0.0873983716819345 0.0334572484428259],...
    'String',{['LT = ',num2str(i),'-day']},'LineStyle','none');
end



  exportgraphics(figure1,"Figure_final/F3.jpg",'Resolution',600)
exportgraphics(figure1, "Figure_final/F3.pdf", 'ContentType', 'vector');

end