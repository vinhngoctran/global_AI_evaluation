function plot_Rebut_1()
%%
clc

close all;
load('RESULTS_FINAL\Rebut_NearingKGE.mat',"KGEvalue","KGEmark","BasinInfo");
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
    'Position',[0.1 0.2 0.3 0.28]); hold on
idx = find(KGEmark(:,1)==1);
NSEval = KGEvalue(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
display(['N of natural series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEval>=0.5))),' (',num2str(numel(find(NSEval>=0.5))/numel(NSEval)),')    ; Median NSE: ',num2str(median(NSEval,'omitnan')), '   ; Porpotion of NSE<0.5: ',num2str(numel(find(NSEval<0.5))/numel(NSEval))])
display(['N of natural series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.75: ',num2str(numel(find(NSEval>=0.75))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan'))])

xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",'k','LineWidth',2,'DisplayName','Natural');

idx = find(KGEmark(:,2)==1);
NSEval = KGEvalue(idx,2);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
display(['N of dammed series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEval>=0.5))),' (',num2str(numel(find(NSEval>=0.5))/numel(NSEval)),')    ; Median NSE: ',num2str(median(NSEval,'omitnan')), '   ; Porpotion of NSE<0.5: ',num2str(numel(find(NSEval<0.5))/numel(NSEval))])
display(['N of dammed series = ',num2str(numel(NSEval)),'   ; Number of NSE>=0.75: ',num2str(numel(find(NSEval>=0.75))),'    ; Median NSE: ',num2str(median(NSEval,'omitnan'))])

xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",Col(2,:),'LineWidth',2,'DisplayName','Dammed');
for i=1:1
    plot([LevelNSE(i) LevelNSE(i)],[0 1],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1)
    % text(LevelNSE(i)-0.06,0.05,LevelName(i),'Rotation',90)
end
legend1 = legend(["Natural","Dammed"],'Box','off','Location','northwest'); 
set(legend1,...
    'Color',[1 1 1]);
ylabel('CDF [-]')
% xlim([-1 1]);ylim([0 1])
xlabel('KGE [-]')
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');
title("a",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';


CaseName = ["Natural","Dammed"];
for i=1:2
    axes1 = axes('Parent',figure1,...
    'Position',[0.47 0.35-(i-1)*0.15 0.28 0.13]); hold on
    set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');

    idx = find(KGEmark(:,i)==1);
    NSEval = KGEvalue(idx,i);

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
     text(-0.8,0.8,CaseName(i),"FontSize",12)

    if i==1
        legend(["AF","AS","AU","EU","GR","NA","AR","SI","SA"],'Box','off',...
            'Position',[0.751031207219289 0.266418841507059 0.0741869912036066 0.22180916344957]); 
    end
    if i==1
        set(axes1,'Xticklabel',{});
        title("b",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';
    else
        
        xlabel('KGE [-]')
    end
end
idx = find(KGEmark(:,2)==1);
RatioVol2 = RatioVol(idx,1);
NSEvalue2 =     KGEvalue(idx,2);
idx = find(RatioVol2<=0.1);
NSEvalue3 = NSEvalue2(idx);
NSEvalue3 = NSEvalue3(~any(isnan(NSEvalue3), 2), :);
display(['N dammed area ratio <= 0.1 = ',num2str(numel(NSEvalue3)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEvalue3>=0.5))),'     ; Number of NSE>=0.75: ',num2str(numel(find(NSEvalue3>=0.75))),'     ; Max NSE: ',num2str((median(NSEvalue3,'omitnan')))])

idx = find(RatioVol2>=0.75);
NSEvalue3 = NSEvalue2(idx);
NSEvalue3 = NSEvalue3(~any(isnan(NSEvalue3), 2), :);
display(['N dammed area ratio >= 0.75 = ',num2str(numel(NSEvalue3)),'   ; Number of NSE>=0.5: ',num2str(numel(find(NSEvalue3>=0.5))),'     ; Number of NSE>=0.75: ',num2str(numel(find(NSEvalue3>=0.75))),'     ; Max NSE: ',num2str((median(NSEvalue3,'omitnan')))])

% Plot fitted lin


    exportgraphics(figure1,"Figure_final/R1.jpg",'Resolution',600)
% exportgraphics(figure1, "Figure_final/F1.pdf", 'ContentType', 'vector');

end