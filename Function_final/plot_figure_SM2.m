function plot_figure_SM2()
%%
close all;
load('RESULTS2\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");
load('RESULTS\R2_Nearring_watershed.mat',"MISSINGBasin","DamAttribute",'Area_nearing','BasinNearing')
load Col.mat % Color setup
LevelNSE = [0.5, 0.65, 0.75, 1];
LevelName = ["Unsatisfactory","Acceptable","Good","Very good"];
for i=1:size(BasinNearing,1)
    RatioVol(i,1) = BasinInfo(i,1)/BasinNearing.calculated_drain_area(i);
    ContinentIn(i,1) = string(BasinNearing.Continent{i});
end
close all
figure1 = figure('OuterPosition',[300 0 1200 900]);
CaseName = ["Natural","Dammed"];

k=0;
for i=1:3
    for j=1:3
        k=k+1;
        POSS(k,:)= [0.07+(j-1)*0.31 0.73-(i-1)*0.3 0.26 0.20];
    end
end
ContName = ["AF","AS","AU","EU","GR","NA","AR","SI","SA"];
close all
figure1 = figure('OuterPosition',[300 0 1200 900]);
uniqContinent = unique(ContinentIn);
for i=1:9
    axes1 = axes('Parent',figure1,...
        'Position',POSS(i,:)); hold on

    for j=1:2
        idx = find(NSEmark(:,j)==1);
        NSEval = NSEvalue(idx,j);
        Continent = ContinentIn(idx);
        uniqContinent = unique(ContinentIn);
        idx = find(Continent==uniqContinent{i});
        cont_NSE = NSEval(idx);
        if ~isempty(cont_NSE)
            xxx = [-1:0.02:1];
            cont_NSE = cont_NSE(~any(isnan(cont_NSE), 2), :);
            NSE_cdf = computecdf(xxx,cont_NSE);
            if j==1
                plot(xxx,NSE_cdf,"Color",'k','LineWidth',2,'DisplayName',uniqContinent(i));
            else
                plot(xxx,NSE_cdf,"Color",Col(2,:),'LineWidth',2,'DisplayName',uniqContinent(i));
            end
        end

    end
    for l=1:4
        plot([LevelNSE(l) LevelNSE(l)],[0 1],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1)
        text(LevelNSE(l)-0.06,0.05,LevelName(l),'Rotation',90)
    end

    if i==1
        legend(["Natural","Dammed"],'Box','off','Location','northwest')
    end
    if i>6
        xlabel('NSE [-]')
    end
    if i==1||i==4||i==7
        ylabel('CDF [-]')
    end
    set(axes1,'Color','none','Linewidth',2,'FontSize',12,'layer','top','YTick',[0:0.2:1]);
    title(ContName(i),'FontSize',14);axes1.TitleHorizontalAlignment = 'left';
end

% exportgraphics(figure1,"Figures2/SF2.jpg",'Resolution',600)
% exportgraphics(figure1, "Figures2/SF2.pdf", 'ContentType', 'vector');

end