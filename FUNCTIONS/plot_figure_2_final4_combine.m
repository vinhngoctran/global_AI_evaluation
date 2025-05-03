function plot_figure_2_final3()
%%
clc; close all; clear all
load('RESULTS_FINAL\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");
% load('RESULTS2/R4_NearingHydrological_final.mat','FloodFrequency_delta','checkdata','PE','T2P');
load('RESULTS_FINAL/R4_2_NearingHydrological_final.mat','RP','checkdata','FloodFrequency','FloodFrequency_delta','PE','T2P','StartEndYear');

load Col.mat % Color setup

figure1 = figure('OuterPosition',[300 100 1200 900]);
axes1 = axes('Parent',figure1,...
    'Position',[0.07 0.65 0.25 0.3]);hold on;
plot([0 15],[0 0],'Color','k','LineStyle','--','LineWidth',1.5)
% plot([0 15],[20 20],'Color','k','LineStyle',':','LineWidth',1.5)
% plot([0 15],[-20 -20],'Color','k','LineStyle',':','LineWidth',1.5)
FloodFrequency_delta(FloodFrequency_delta==0)=NaN;
for i=1:5
AAAA(i,:)=[numel(find(FloodFrequency_delta(:,i)<0)) numel(removeNaNRows(FloodFrequency_delta(:,i))) numel(find(FloodFrequency_delta(:,i)<0))/numel(removeNaNRows(FloodFrequency_delta(:,i)))*100];
disp(['Percentage of Delta_FFA < 0: ',num2str(numel(find(FloodFrequency_delta(:,i)<0))/numel(removeNaNRows(FloodFrequency_delta(:,i)))*100)])
end
idx = find(NSEmark(:,2)==0);
FD_nat = FloodFrequency_delta(idx,:); 
FD_nat(FD_nat==0)=NaN;
numel(find(~isnan(FD_nat(:,1))))

PCT = prctile(FD_nat,50)
idx = find(NSEmark(:,2)==1);
FD_hum = FloodFrequency_delta(idx,:);
FD_hum(FD_hum==0)=NaN;
numel(find(~isnan(FD_hum(:,1))))
PCT = prctile(FD_hum,50)
clr1 = repmat(1,size(FD_nat));
clr2 = repmat(2,size(FD_hum));

% These grouping matrices label
grp1 = repmat(1:5,size(FD_nat,1),1);
grp2 = repmat(1:5,size(FD_hum,1),1);

x = [grp1;grp2];
y = [FD_nat;FD_hum];
x = x(:);x = x*2;
y = y(:);
c = [clr1;clr2];
ylim([-100 100]);xlim([1 11])

b = boxchart(x(:),y(:),'GroupByColor',c(:));
b(1).BoxFaceColor = [0.5 0.5 0.5]; % Black for natural
b(2).BoxFaceColor = Col(2,:); % Blue for dammed
b(1).MarkerColor = [0.5 0.5 0.5]; % Black for natural
b(2).MarkerColor = Col(2,:); % Blue for dammed
% b(1).BoxFaceAlpha = 0.3;
% b(2).BoxFaceAlpha = 0.3;
b(1).WhiskerLineStyle = '--';
b(2).WhiskerLineStyle = '--';
% Increase the width of the boxes
b(1).BoxWidth = 0.9; % Adjust the width as needed
b(2).BoxWidth = 0.9; % Adjust the width as needed

xlabel('Return period [year]'); ylabel('\Delta_{FFA} [%]')
legend(["","Natural","Dammed"],'box','off','Position',[0.16041666891946 0.96088393336729 0.183277024132376 0.0297397762130774],...
    'Orientation','horizontal',...
    'Color',[1 1 1])
set(axes1,'Color','none','Linewidth',1.5,'FontSize',13,'layer','top','Xtick',[2:2:10],'Xticklabel',{"5","10","20","50","100"});
title("a",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';

idx = find(NSEmark(:,2)==0);
FET2P_Nat = [PE(idx), T2P(idx)];
idx = find(NSEmark(:,2)==1);
FET2P_Hum = [PE(idx), T2P(idx)];

axes1 = axes('Parent',figure1,...
    'Position',[0.73 0.85 0.25 0.1]);hold on;
data = removeNaNRows(FET2P_Nat(:,1));
[f, xi] = ksdensity(data, 'Bandwidth', 10);
Med1 = median(data,'omitnan');
area(xi,f,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','FaceAlpha',0.5)
disp(['PE median of Natural = ',num2str(median(data))])
data = removeNaNRows(FET2P_Hum(:,1));
data(data>100)=100;
[f, xi] = ksdensity(data, 'Bandwidth', 10);
Med2 = median(data,'omitnan');
xlim([-100 100]);
disp(['PE median of Dammed = ',num2str(median(data))])
area(xi,f,'FaceColor',Col(2,:),'EdgeColor','b','FaceAlpha',0.3) 
l1=plot(Med1,0,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',20,'LineStyle','none','DisplayName','Natural');
l2=plot(Med2,0,'Marker','^','MarkerFaceColor',Col(2,:),'MarkerEdgeColor','b','MarkerSize',20,'LineStyle','none','DisplayName','Dammed');
 xlabel('PE [%]'); ylabel('PDF [-]')
set(axes1,'Color','none','Linewidth',0.5,'FontSize',13);
legend([l1 l2],'box','off')
%  view([90 -90]);
title("c",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';


axes1 = axes('Parent',figure1,...
    'Position',[0.73 0.65 0.25 0.1]);
hold on;

% Natural data
data_nat = removeNaNRows(FET2P_Nat(:,2));
data_hum = removeNaNRows(FET2P_Hum(:,2));
for tt = -10:10
    Ncase(tt+11,:) = [numel(find(data_nat==tt))/numel(data_nat),numel(find(data_hum==tt))/numel(data_hum)];
end
disp(['% T2P fail for natural = ',num2str(100-Ncase(11,1)*100)])
disp(['% T2P fail for dammed = ',num2str(100-Ncase(11,2)*100)])
b=bar([-10:1:10],Ncase);
b(1).FaceColor = [0.5 0.5 0.5];
b(1).BarWidth = 1;
b(2).FaceColor = Col(2,:);
b(2).FaceAlpha = 0.5;
b(2).BarWidth = 1;
legend(["Natural","Dammed"],'box','off')
set(axes1, 'Color', 'none', 'Linewidth', 0.5, 'FontSize', 13);
title("d", 'FontSize', 16);
axes1.TitleHorizontalAlignment = 'left';
xlim([-10 10]);
xlabel('T2P [day]');
ylabel('Frequency');


% LengThD = [10,20,30,41];


XlabelL = ["[10-20]","[21-30]","[31-41]"];
axes1 = axes('Parent',figure1,...
    'Position',[0.4 0.65 0.25 0.3]);hold on;
idx = find(checkdata>=10 & checkdata<=20);
group1 = FloodFrequency_delta(idx, :);
idx = find(checkdata>=21 & checkdata<=30);
group2 = FloodFrequency_delta(idx, :);
idx = find(checkdata>=31 & checkdata<=40);
group3 = FloodFrequency_delta(idx, :);
group_positions = [1:5, 7:11, 13:17];  % Adjust spacing between groups
h=boxplot(group1, 'Positions', group_positions(1:5), 'Width', 0.8);
for k = 1:5
        % Find all the objects in the boxplot
        boxes = findobj(h(:, k), 'Tag', 'Box');
        medians = findobj(h(:, k), 'Tag', 'Median');
        whiskers = findobj(h(:, k), 'Tag', 'Whisker');
        outliers = findobj(h(:, k), 'Tag', 'Outliers');
        caps = findobj(h(:, k), 'Tag', 'Cap');
        
        % Set the colors
        set(boxes, 'Color', 'k');
        set(medians, 'Color','k', 'LineWidth', 2);
        set(whiskers, 'Color', 1-[0.15 0.15 0.15]*k, 'LineStyle', '-');
        set(outliers, 'MarkerEdgeColor', 1-[0.15 0.15 0.15]*k);
        set(caps, 'Color', 1-[0.15 0.15 0.15]*k, 'LineStyle', '-');
        % Fill the boxes with a semi-transparent color
        patch(get(boxes,'XData'), get(boxes,'YData'), 1-[0.15 0.15 0.15]*k, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    end
h=boxplot(group2, 'Positions', group_positions(6:10), 'Width', 0.8);
for k = 1:5
        % Find all the objects in the boxplot
        boxes = findobj(h(:, k), 'Tag', 'Box');
        medians = findobj(h(:, k), 'Tag', 'Median');
        whiskers = findobj(h(:, k), 'Tag', 'Whisker');
        outliers = findobj(h(:, k), 'Tag', 'Outliers');
        caps = findobj(h(:, k), 'Tag', 'Cap');
        
        % Set the colors
        set(boxes, 'Color', 'k');
        set(medians, 'Color','k', 'LineWidth', 2);
        set(whiskers, 'Color', 'k', 'LineStyle', '-');
        set(outliers, 'MarkerEdgeColor', 1-[0.15 0.15 0.15]*k);
        set(caps, 'Color', 1-[0.15 0.15 0.15]*k, 'LineStyle', '-');
        % Fill the boxes with a semi-transparent color
        patch(get(boxes,'XData'), get(boxes,'YData'), 1-[0.15 0.15 0.15]*k, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    end
h=boxplot(group3, 'Positions', group_positions(11:15), 'Width', 0.8);
for k = 1:5
        % Find all the objects in the boxplot
        boxes = findobj(h(:, k), 'Tag', 'Box');
        medians = findobj(h(:, k), 'Tag', 'Median');
        whiskers = findobj(h(:, k), 'Tag', 'Whisker');
        outliers = findobj(h(:, k), 'Tag', 'Outliers');
        caps = findobj(h(:, k), 'Tag', 'Cap');
        
        % Set the colors
        set(boxes, 'Color', 'k');
        set(medians, 'Color','k', 'LineWidth', 2);
        set(whiskers, 'Color', 1-[0.15 0.15 0.15]*k, 'LineStyle', '-');
        set(outliers, 'MarkerEdgeColor', 1-[0.15 0.15 0.15]*k);
        set(caps, 'Color', 1-[0.15 0.15 0.15]*k, 'LineStyle', '-');
        % Fill the boxes with a semi-transparent color
        patch(get(boxes,'XData'), get(boxes,'YData'), 1-[0.15 0.15 0.15]*k, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    end


xticks(group_positions);
new_labels = {'5', '10', '20', '50', '100'};
xticklabels([...
    arrayfun(@(x) sprintf('%s', new_labels{x}), 1:5, 'UniformOutput', false), ...
    arrayfun(@(x) sprintf('%s', new_labels{x}), 1:5, 'UniformOutput', false), ...
    arrayfun(@(x) sprintf('%s', new_labels{x}), 1:5, 'UniformOutput', false)]);


text(mean(group_positions(1:5)), 120, '[10-20]', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold','FontSize',13);
text(mean(group_positions(6:10)), 120, '[21-30]', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold','FontSize',13);
text(mean(group_positions(11:15)),120, '[31-41]', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold','FontSize',13);
plot([0 20],[0 0],'Color','k','LineStyle','--','LineWidth',1.5)
ylabel('\Delta_{FFA} [%]'); xlabel('Return period [year]');ylim([-100 100]);xlim([0 18])
set(axes1,'Color','none','Linewidth',1,'FontSize',13,'Position',[0.4 0.65 0.25 0.3]);
title("b",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';

box off


load('RESULTS_FINAL\R3_Nearing_sim_ungauged.mat','StartTime');
load('RESULTS_FINAL\R6_CheckReliablePrediction.mat',"Raindata","OBS_check","SIM_check",'TimeRain','idx_overlap','NameIDX')
load('RESULTS_FINAL/R7_nophysic.mat','N_event');
load('RESULTS_FINAL\R2_Nearring_watershed.mat','BasinNearing');


idxx = 112;
DATETIME = [StartTime(1):days(1):StartTime(1)+days(size(OBS_check,1)-1)]';

[idx,YYYY] = findmissflood(OBS_check(:,idxx),SIM_check(:,idxx),StartTime(1),-90);
event1 = datetime(YYYY(1),1,1)+days(idx(1));
event2 = datetime(YYYY(2),1,1)+days(idx(2));
% EndT = StaT + days(30);

annotation(figure1,'textbox',...
    [0.0843918918918921 0.46453531598513 0.1 0.03],...
    'String',{'Missed-flood'},...
    'LineStyle','none','FontSize',13);

annotation(figure1,'textbox',...
    [0.0830067567567578 0.315836431226766 0.3 0.03],...
    'String',{'False-flood'},...
    'LineStyle','none','FontSize',13);

axes1 = axes('Parent',figure1,...
    'Position',[0.07 0.43 0.23 0.095]); hold on;
plot(DATETIME,OBS_check(:,idxx),"Color",'k','LineWidth',2);
plot(DATETIME,SIM_check(:,idxx),"Color",Col(2,:),'LineWidth',2);ylabel('Streamflow [m^3/s]','Position',[13832.93382361816,-58.0245959905929,-0.999999999999986])
set(axes1,'Color','none','Linewidth',1,'FontSize',12);
ylim([0 200])
xlim([event1-days(15), event1+days(15)])
title(['e '],'FontSize',15);axes1.TitleHorizontalAlignment = 'left';
legend(["Observation","AI simulation"],'Box','off')
axes1 = axes('Parent',figure1,...
    'Position',[0.07 0.435 0.23 0.095]); hold on;
bar(TimeRain,Raindata(:,idxx),'FaceColor', Col(6,:), 'EdgeColor', 'none','FaceAlpha',0.5);
% ylabel('Precipitation [mm/day]')
ylim([0 60])
set(axes1,'Color','none','Linewidth',1,'FontSize',12,'YAxisLocation','right','XAxisLocation','top','YColor',Col(6,:),'YDir','reverse','XTickLabel',{});
xlim([event1-days(15), event1+days(15)])

axes1 = axes('Parent',figure1,...
    'Position',[0.07 0.265 0.23 0.095]); hold on;
plot(DATETIME,OBS_check(:,idxx),"Color",'k','LineWidth',2);
plot(DATETIME,SIM_check(:,idxx),"Color",Col(2,:),'LineWidth',2);
set(axes1,'Color','none','Linewidth',1,'FontSize',12);
% title(['c '],'FontSize',15);axes1.TitleHorizontalAlignment = 'left';

ylim([0 200])
xlim([event2-days(15), event2+days(15)])
axes1 = axes('Parent',figure1,...
    'Position',[0.07 0.27 0.23 0.099]); hold on;
bar(TimeRain,Raindata(:,idxx),'FaceColor', Col(6,:), 'EdgeColor', 'none','FaceAlpha',0.5);
ylabel('Pr [mm/day]','Position',[14710.18382347024,-14.383590254065112,-1])
ylim([0 60])
set(axes1,'Color','none','Linewidth',1,'FontSize',12,'YAxisLocation','right','XAxisLocation','top','YColor',Col(6,:),'YDir','reverse','XTickLabel',{});
xlim([event2-days(15), event2+days(15)])


PE_threshold = [-99 -95:5:-50];
for j=1:numel(PE_threshold)
    NonphysicEvent(j,:) = [sum(N_event{j,1}(:,2)) sum(N_event{j,1}(:,4))];
end
disp(['% of missed-flood = ',num2str(NonphysicEvent(end,1))])
disp(['% of false-flood = ',num2str(NonphysicEvent(end,2))])
axes1 = axes('Parent',figure1,...
    'Position',[0.4 0.27 0.23 0.25]); hold on;
plot(NonphysicEvent(:,1),"Color",Col(1,:),'LineWidth',2);
plot(NonphysicEvent(:,2),"Color",Col(2,:),'LineWidth',2);
xlim([1 11]);ylim([0 max(NonphysicEvent(:))])
ylabel('N_{event}');xlabel('Threshold [%]')
% plot([3 3],[0 10000],'Color',[0.5 0.5 0.5],'LineStyle','--','LineWidth',2)
legend(["Missed-flood","False-flood"],'box','off','Location','northwest');
set(axes1,'Color','none','Linewidth',1,'FontSize',13,'Xtick',[1:1:11],'XTickLabel',PE_threshold);
title(['f '],'FontSize',15);axes1.TitleHorizontalAlignment = 'left';

axes1 = axes('Parent',figure1,...
    'Position',[0.4 0.27 0.23 0.25]); hold on;
xlim([1 11]);ylim([0 max(NonphysicEvent(:))/sum(N_event{j,1}(:,1))*100])
ylabel('Percentage [%]');xlabel('Threshold [%]')
set(axes1,'Color','none','Linewidth',1,'FontSize',13,'XColor','none','YAxisLocation','right');


for i=1:size(BasinNearing,1)
    ContinentIn(i,1) = string(BasinNearing.Continent{i});
end
uniqContinent = unique(ContinentIn);
for j=1:size(uniqContinent,1)
        idx = find(ContinentIn==uniqContinent{j});
        for i=1:11
            sum(N_event{i,1}(idx,1));
            Nonphysic_continent(j,:,i)= [sum(N_event{i,1}(idx,2))/sum(N_event{i,1}(idx,1)) sum(N_event{i,1}(idx,4))/sum(N_event{i,1}(idx,3))]*100;
        end
end

axes1 = axes('Parent',figure1,...
    'Position',[0.73 0.27 0.25 0.25]); hold on;
ylabel('Percentage [%]')
b=bar(Nonphysic_continent(:,:,11));
b(1).FaceColor = Col(1,:);
b(1).BarWidth = 1;
b(2).FaceColor = Col(2,:);
b(2).FaceAlpha = 0.5;
b(2).BarWidth = 1;

set(axes1,'Color','none','Linewidth',1,'FontSize',13,'Xtick',[1:1:9],'XTickLabel',["AF","AS","AU","EU","GR","NA","AR","SI","SA"]);
title(['g '],'FontSize',15);axes1.TitleHorizontalAlignment = 'left';

legend1 = legend(["Missed-flood","False-flood"],'box','off','Location','northeast');
set(legend1,...
    'Position',[0.859327121909849 0.453716807382508 0.118243241003035 0.0551425016207028]);
exportgraphics(figure1,"Figure_final/F2.jpg",'Resolution',600)
exportgraphics(figure1, "Figure_final/F2.pdf", 'ContentType', 'vector');
% close all
end