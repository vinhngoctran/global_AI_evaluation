function plot_figure_SM3()
%%
close all;
load('RESULTS2\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");
NSEvalue1 = NSEvalue;
load('RESULTS2\R3_NearingNSE_gauged.mat',"NSEvalue");
NSEvalue2 = NSEvalue;
load('RESULTS\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')
load Col.mat % Color setup
LevelNSE = [0.5, 0.65, 0.75, 1];
LevelName = ["Unsatisfactory","Acceptable","Good","Very good"];

clc
close all
figure1 = figure('OuterPosition',[300 0 1300 900]);
axes1 = axes('Parent',figure1,...
    'Position',[0.07 0.2 0.28 0.28]); hold on
idx = find(NSEmark(:,1)==1);
NSEval = NSEvalue1(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
display(['Ungauged - N of natural series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEval>=0.5))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan')), '   ; Porpotion of NSE<0.5: ',num2str(numel(find(NSEval<0.5))/numel(NSEval))])
display(['Ungauged - N of natural series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.75: ',num2str(numel(find(NSEval>=0.75))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan'))])
xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",'k','LineWidth',2,'DisplayName','Ungauged Natural');

idx = find(NSEmark(:,2)==1);
NSEval = NSEvalue1(idx,2);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
display(['Ungauged - N of dammed series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEval>=0.5))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan')), '   ; Porpotion of NSE<0.5: ',num2str(numel(find(NSEval<0.5))/numel(NSEval))])
display(['Ungauged - N of dammed series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.75: ',num2str(numel(find(NSEval>=0.75))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan'))])
xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",Col(2,:),'LineWidth',2,'DisplayName','Ungauged Dammed');

idx = find(NSEmark(:,1)==1);
NSEval = NSEvalue2(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
display(['Gauged - N of natural series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEval>=0.5))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan')), '   ; Porpotion of NSE<0.5: ',num2str(numel(find(NSEval<0.5))/numel(NSEval))])
display(['Gauged - N of natural series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.75: ',num2str(numel(find(NSEval>=0.75))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan'))])
xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",'k','LineWidth',2,'DisplayName','Gauged Natural','LineStyle','--');

idx = find(NSEmark(:,2)==1);
NSEval = NSEvalue2(idx,2);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
display(['Gauged - N of dammed series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEval>=0.5))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan')), '   ; Porpotion of NSE<0.5: ',num2str(numel(find(NSEval<0.5))/numel(NSEval))])
display(['Gauged - N of dammed series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.75: ',num2str(numel(find(NSEval>=0.75))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan'))])
xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",Col(2,:),'LineWidth',2,'DisplayName','Gauged Dammed','LineStyle','--');


for i=1:4
    plot([LevelNSE(i) LevelNSE(i)],[0 1],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1)
    text(LevelNSE(i)-0.06,0.05,LevelName(i),'Rotation',90)
end
legend1 = legend(["Ungauged Natural","Ungauged Dammed","Gauged Natural","Gauged Dammed"],'Box','off',...
    'Location','best'); 
ylabel('CDF [-]')
xlabel('NSE [-]')
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');
title("a",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';


CaseName = ["b Natural","c Dammed"];
for i=1:2
    axes1 = axes('Parent',figure1,...
    'Position',[0.42+(i-1)*0.26 0.2 0.2 0.28]); hold on
    set(axes1,'Color','none','Linewidth',2,'FontSize',13);
    idxxx{i} = find(NSEvalue1(:,i) < 0.5 & NSEvalue2(:,i) < 0.5);
    scatter(NSEvalue1(:,i),NSEvalue2(:,i),'MarkerFaceColor',[0.5 0.5 0.5],'MarkerFaceAlpha',0.5,'MarkerEdgeColor','none')
    scatter(-1,median(NSEvalue2(:,i),'omitnan'),200,'Marker','square','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k')
    scatter(median(NSEvalue1(:,i),'omitnan'),-1,200,'Marker','^','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k')

    plot([-1 0.5 0.5],[0.5 0.5 -1],'LineStyle','--','Color',[0 0 0],'LineWidth',1.5)
    plot([- 1 1],[-1 1],'Color','k','LineWidth',1.5)
    xlabel('NSE_{Ungauged} [-]');ylabel('NSE_{Gauged} [-]');xlim([-1 1]);ylim([-1 1])
     title(CaseName(i),'FontSize',16);axes1.TitleHorizontalAlignment = 'left'; 
end

%     exportgraphics(figure1,"Figures2/FS4.jpg",'Resolution',600)
% exportgraphics(figure1, "Figures2/FS4.pdf", 'ContentType', 'vector');

end