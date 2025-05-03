function plot_figure_2_SM()
%%
clc; close all; 
load('RESULTS_FINAL\R3_NearingNSE.mat',"NSEvalue","NSEmark","BasinInfo");
% load('RESULTS2/R4_NearingHydrological_final.mat','FloodFrequency_delta','checkdata','PE','T2P');
load('RESULTS_FINAL/R4_2_NearingHydrological_final_GEV.mat','RP','checkdata','FloodFrequency','FloodFrequency_delta','PE','T2P','StartEndYear');

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


exportgraphics(figure1,"Figure_final/F2_gev_SM.jpg",'Resolution',600)
% exportgraphics(figure1, "Figure_final/F2.pdf", 'ContentType', 'vector');
% close all
end