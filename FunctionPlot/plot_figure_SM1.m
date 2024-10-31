function plot_figure_SM1()
%%
close all; clc
load('RESULTS2\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");
load('RESULTS\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')
load Col.mat % Color setup

figure1 = figure('OuterPosition',[300 100 1000 500]);
axes1 = axes('Parent',figure1,...
    'Position',[0.06 0.15 0.37 0.7]);hold on;
YearDam = BasinInfo(:,3);
YearDam = YearDam(~any(YearDam==0, 2), :);
YearDam2 = YearDam(~any(isnan(YearDam), 2), :);
k=1;
Ndam = numel(YearDam)-numel(YearDam2)+numel(find(YearDam2<1980));
for i=1980:2021
    k=k+1;
    Ndam(k,1) = numel(find(YearDam2==i));
end
Damsum = cumsum(Ndam);
Time = [1979:1:2021];
bar(Time(2:end),Ndam(2:end),'FaceColor',Col(1,:));
ylabel('The number of constructed dams')
% plot(Time,Damsum);
xlim([min(Time) max(Time)])
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');
title("a",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';

axes1 = axes('Parent',figure1,...
    'Position',[0.06 0.15 0.37 0.7]);hold on;
ylabel('Total constructed dams')
plot(Time,Damsum,'Color',Col(2,:),'LineWidth',2);
xlim([min(Time) max(Time)])
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top','Xcolor','None','YAxisLocation','right','YColor',Col(2,:));

DammAll = BasinInfo(:,1);
for i=1:size(BasinNearing,1)
    ContinentIn(i,1) = string(BasinNearing.Continent{i});
end
uniqContinent = unique(ContinentIn);
for j=1:size(uniqContinent,1)
    idx = find(ContinentIn==uniqContinent{j});
    cont_Dam = DammAll(idx);
    nDAM(j,1) = numel(cont_Dam);
    cont_Dam = cont_Dam(~any(cont_Dam==0, 2), :);
    nDAM(j,2) = numel(cont_Dam);
    nDAM(j,3) = nDAM(j,1)-nDAM(j,2);
end

axes1 = axes('Parent',figure1,...
    'Position',[0.6 0.15 0.37 0.7]);hold on;
b = bar([nDAM(:,3),nDAM(:,2)],'stacked');
b(1).FaceColor = 'k';
b(2).FaceColor = Col(2,:);
legend(["Natural","Dammed"],'Box','off')
ylabel('The number of Basins')
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top','XTick',[1:1:9],'XTickLabel',["AF","AS","AU","EU","GR","NA","AR","SI","SA"]);
title("b",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';
% exportgraphics(figure1,"Figures2/SF1.jpg",'Resolution',600)
% exportgraphics(figure1, "Figures2/SF1.pdf", 'ContentType', 'vector');
end