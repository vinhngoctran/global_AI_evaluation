function plot_figure_R_GloFas()
%%
clc; close all;
load('RESULTS_FINAL/R5_GloFasComparison.mat','NSEmark_Glo','NSEvalue_Glo','PE_Glo','T2P_Glo');
load('RESULTS_FINAL\R3_NearingNSE.mat');
load('RESULTS_FINAL/R4_2_NearingHydrological_final.mat','PE','T2P');
load('RESULTS_FINAL\R2_Nearing_GloFAS.mat','MISSINGGloFAS');
LevelNSE = [0.5, 0.65, 0.75, 1];
LevelName = ["Unsatisfactory","Acceptable","Good","Very good"];

idx = find(MISSINGGloFAS==1);
disp('Total number basin GloFAS: '+string(numel(idx)))
NSEmark_Glo=NSEmark_Glo(idx,:);
NSEvalue_Glo=NSEvalue_Glo(idx,:);
PE_Glo=PE_Glo(idx,:);
T2P_Glo=T2P_Glo(idx,:);
NSEvalue=NSEvalue(idx,:);
NSEmark=NSEmark(idx,:);
PE=PE(idx,:);
T2P=T2P(idx,:);

load Col.mat % Color setup

%%%%%%%%%%%
figure1 = figure('OuterPosition',[300 0 1300 800]);
axes1 = axes('Parent',figure1,...
    'Position',[0.07 0.6 0.3 0.3]); hold on
idx = find(NSEmark(:,1)==1);disp('the number of natural flow series: '+string(numel(idx)))
NSEval = NSEvalue(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",'k','LineWidth',2,'DisplayName','Natural');

idx = find(NSEmark(:,2)==1);disp('the number of dammed series: '+string(numel(idx)))
NSEval = NSEvalue(idx,2);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",Col(2,:),'LineWidth',2,'DisplayName','Dammed');


idx = find(NSEmark(:,1)==1);
NSEval = NSEvalue_Glo(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",'k','LineWidth',2,'DisplayName','Natural','LineStyle','--');

idx = find(NSEmark(:,2)==1);
NSEval = NSEvalue_Glo(idx,2);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
xxx = [-1:0.02:1];
NSE_cdf = computecdf(xxx,NSEval); 
plot(xxx,NSE_cdf,"Color",Col(2,:),'LineWidth',2,'DisplayName','Dammed','LineStyle','--');


for i=1:4
    plot([LevelNSE(i) LevelNSE(i)],[0 1],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1)
    text(LevelNSE(i)-0.06,0.05,LevelName(i),'Rotation',90)
end
legend1 = legend(["AI_{Natural}","AI_{Dammed}","GloFAS_{Natural}","GloFAS_{Dammed}"],'Box','off'); 
set(legend1,...
    'Position',[0.116788344347865 0.904134393033815 0.231418914589528 0.0799151321786128],...
    'NumColumns',2,...
    'Color',[1 1 1]);
ylabel('CDF [-]')
% xlim([-1 1]);ylim([0 1])
xlabel('NSE [-]')
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');
title("a",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';

%%%%%%%%%%%
axes1 = axes('Parent',figure1,...
    'Position',[0.44 0.6 0.19 0.3]); hold on
idx = find(NSEmark(:,1)==1);
NSEval = NSEvalue(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
NSEval2 = NSEvalue_Glo(idx,1);
NSEval2 = NSEval2(~any(isnan(NSEval2), 2), :);
[X, Y] = meshgrid(linspace(-1, 1, 100), linspace(-1, 1, 100));
XY = [NSEval, NSEval2];
kde = mvksdensity(XY, [X(:) Y(:)], 'Bandwidth', [0.5 0.5]); % Adjust bandwidth as needed
kde = reshape(kde, size(X));
F = scatteredInterpolant(X(:), Y(:), kde(:), 'linear', 'nearest');
density = F(NSEval, NSEval2);
density = (density - min(density)) / (max(density) - min(density));
scatter(NSEval, NSEval2, 20, density, 'filled', 'Marker', 'o', 'MarkerEdgeColor', 'k');
plot([-1 1],[-1 1],'LineWidth',1,'Color','k')
xlim([-1 1]);ylim([-1 1])
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');
title("b Natural",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';

num_higher = sum(NSEval2 > NSEval);
total_points = length(NSEval);
percentage_higher = (num_higher / total_points) * 100;
fprintf('Number of points where |NSE_GloFAS| > |NSE_AI| in Natural basin: %d\n', num_higher);
fprintf('Percentage of points where |NSE_GloFAS| > |NSE_AI| in Natural basin: %.2f%%\n', percentage_higher);
%%%%%%%%%%%
axes1 = axes('Parent',figure1,...
    'Position',[0.7 0.6 0.19 0.3]); hold on
idx = find(NSEmark(:,2)==1);
NSEval = NSEvalue(idx,2);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
NSEval2 = NSEvalue_Glo(idx,2);
NSEval2 = NSEval2(~any(isnan(NSEval2), 2), :);
[X, Y] = meshgrid(linspace(-1, 1, 100), linspace(-1, 1, 100));
XY = [NSEval, NSEval2];
kde = mvksdensity(XY, [X(:) Y(:)], 'Bandwidth', [0.5 0.5]); % Adjust bandwidth as needed
kde = reshape(kde, size(X));
F = scatteredInterpolant(X(:), Y(:), kde(:), 'linear', 'nearest');
density = F(NSEval, NSEval2);
density = (density - min(density)) / (max(density) - min(density));
scatter(NSEval, NSEval2, 20, density, 'filled', 'Marker', 'o', 'MarkerEdgeColor', 'k');
colormap(flip(jet));
cbar = colorbar(axes1,'Position',...
    [0.906250816203783 0.6 0.0142523364485981 0.3]);;
cbar.Label.String = 'Density';


xlabel('NSE_{AI} [-]');ylabel('NSE_{GloFAS} [-]');
% scatter(NSEval,NSEval2,20,'Marker','o','MarkerEdgeColor','none','MarkerFaceColor',Col(2,:));
plot([-1 1],[-1 1],'LineWidth',1,'Color','k')
xlim([-1 1]);ylim([-1 1])
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');
title("c Dammed",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';
num_higher = sum(NSEval2 > NSEval);
total_points = length(NSEval);
percentage_higher = (num_higher / total_points) * 100;
fprintf('Number of points where |NSE_GloFAS| > |NSE_AI| in Dammed basin: %d\n', num_higher);
fprintf('Percentage of points where |NSE_GloFAS| > |NSE_AI| in Dammed basin: %.2f%%\n', percentage_higher);







%%%%%%%%%%%
x_min = -100;x_max=100;
axes1 = axes('Parent',figure1,...
    'Position',[0.07 0.15 0.3 0.3]); hold on

% Define x-range and number of bins
x_range = linspace(-100, 100, 100);

% Plot PDF for Natural (NSEmark(:,1)==1)
idx = find(NSEmark(:,1)==1);
NSEval = PE(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
xi = linspace(x_min, x_max, 100);  % 100 points between x_min and x_max
[f, xi] = ksdensity(NSEval,  xi);
Med1 = median(NSEval,'omitnan')
plot(xi,f, "Color", 'k', 'LineWidth', 2, 'DisplayName', 'Natural');
l1=plot(Med1,0,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',20,'LineStyle','none','DisplayName','AI-Natural');

% Plot PDF for Dammed (NSEmark(:,2)==1)
idx = find(NSEmark(:,2)==1);
NSEval = PE(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
xi = linspace(x_min, x_max, 100);  % 100 points between x_min and x_max
[f, xi] = ksdensity(NSEval,  xi);
Med2 = median(NSEval,'omitnan')
plot(xi,f, "Color", Col(2,:), 'LineWidth', 2, 'DisplayName', 'Dammed');
l2=plot(Med2,0,'Marker','o','MarkerFaceColor',Col(2,:),'MarkerEdgeColor','b','MarkerSize',20,'LineStyle','none','DisplayName','AI-Dammed');

% Plot PDF for Natural Global (NSEmark(:,1)==1, NSEvalue_Glo)
idx = find(NSEmark(:,1)==1);
NSEval = PE_Glo(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
xi = linspace(x_min, x_max, 100);  % 100 points between x_min and x_max
[f, xi] = ksdensity(NSEval,  xi);
Med3 = median(NSEval,'omitnan')
plot(xi,f, "Color", 'k', 'LineWidth', 2, 'DisplayName', 'Natural', 'LineStyle', '--');
l3=plot(Med3,0,'Marker','^','MarkerEdgeColor','k','MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',20,'LineStyle','none','DisplayName','GloFAS-Natural');

% Plot PDF for Dammed Global (NSEmark(:,2)==1, NSEvalue_Glo)
idx = find(NSEmark(:,2)==1);
NSEval = PE_Glo(idx,1);
NSEval = NSEval(~any(isnan(NSEval), 2), :);
[f, xi] = ksdensity(NSEval,  xi);
Med4 = median(NSEval,'omitnan')
plot(xi,f, "Color", Col(2,:), 'LineWidth', 2, 'DisplayName', 'Dammed', 'LineStyle', '--');
l4=plot(Med2,0,'Marker','^','MarkerFaceColor',Col(2,:),'MarkerEdgeColor','b','MarkerSize',20,'LineStyle','none','DisplayName','GloFAS-Dammed');
legend([l1, l2, l3 l4],'Box','off')
% Update y-label for PDF
ylabel('PDF [-]')
xlabel('NSE [-]')
set(axes1, 'Color', 'none', 'Linewidth', 2, 'FontSize', 13);
title('d', 'FontSize', 16);
axes1.TitleHorizontalAlignment = 'left';

%%%%%%%%%%%
axes1 = axes('Parent',figure1,...
    'Position',[0.44 0.15 0.19 0.3]); hold on
idx = find(NSEmark(:,2)==0);
disp('the number of natural basins: '+string(numel(idx)))
NSEval = abs(PE(idx,1));
NSEval2 = abs(PE_Glo(idx,1));
[X, Y] = meshgrid(linspace(0, 100, 50), linspace(0, 100, 50));
XY = [NSEval, NSEval2];
kde = mvksdensity(XY, [X(:) Y(:)], 'Bandwidth', [5 5]); % Adjust bandwidth as needed
kde = reshape(kde, size(X));
F = scatteredInterpolant(X(:), Y(:), kde(:), 'linear', 'nearest');
density = F(NSEval, NSEval2);
density = (density - min(density)) / (max(density) - min(density));
scatter(NSEval, NSEval2, 20, density, 'filled', 'Marker', 'o', 'MarkerEdgeColor', 'k');
colormap(flip(bone));
% cbar = colorbar;
% cbar.Label.String = 'Density';
plot([-100 100], [-100 100], 'LineWidth', 1, 'Color', 'k')
xlabel('|PE_{AI}| [%]');
ylabel('|PE_{GloFAS}| [%]');
xlim([0 100]);
ylim([0 100]);
set(axes1,'Color','none','Linewidth',2,'FontSize',13,'layer','top');
title("e Natural",'FontSize',16);axes1.TitleHorizontalAlignment = 'left';

num_higher = sum(NSEval2 < NSEval);
total_points = length(NSEval);
percentage_higher = (num_higher / total_points) * 100;
fprintf('Number of points where |PE_GloFAS| < |PE_AI| in Natural basin: %d\n', num_higher);
fprintf('Percentage of points where |PE_GloFAS| > |PE_AI| in Natural basin: %.2f%%\n', percentage_higher);

%%%%%%%%%%%
axes1 = axes('Parent', figure1, ...
    'Position', [0.7 0.15 0.19 0.3]); 
hold on

% Select data
idx = find(NSEmark(:,2) == 1);disp('the number of dammed basins: '+string(numel(idx)))
NSEval = abs(PE(idx,1));
NSEval2 = abs(PE_Glo(idx,1));

[X, Y] = meshgrid(linspace(0, 100, 50), linspace(0, 100, 50));
XY = [NSEval, NSEval2];
kde = mvksdensity(XY, [X(:) Y(:)], 'Bandwidth', [5 5]); % Adjust bandwidth as needed
kde = reshape(kde, size(X));
F = scatteredInterpolant(X(:), Y(:), kde(:), 'linear', 'nearest');
density = F(NSEval, NSEval2);
density = (density - min(density)) / (max(density) - min(density));
scatter(NSEval, NSEval2, 20, density, 'filled', 'Marker', 'o', 'MarkerEdgeColor', 'k');
colormap(jet);
cbar = colorbar(axes1,'Position',...
    [0.906250816203783 0.15 0.0142523364485981 0.3]);;
cbar.Label.String = 'Density';
plot([-100 100], [-100 100], 'LineWidth', 1, 'Color', 'k')
xlabel('|PE_{AI}| [%]');
ylabel('|PE_{GloFAS}| [%]');
xlim([0 100]);
ylim([0 100]);
set(axes1, 'Color', 'none', 'Linewidth', 2, 'FontSize', 13, 'layer', 'top');
title('f Dammed', 'FontSize', 16);
axes1.TitleHorizontalAlignment = 'left';

num_higher = sum(NSEval2 < NSEval);
total_points = length(NSEval);
percentage_higher = (num_higher / total_points) * 100;
fprintf('Number of points where |PE_GloFAS| < |PE_AI| in Dammed basin: %d\n', num_higher);
fprintf('Percentage of points where |PE_GloFAS| > |PE_AI| in Dammed basin: %.2f%%\n', percentage_higher);
hold off
exportgraphics(figure1,"Figure_final/FR3.jpg",'Resolution',600)
% exportgraphics(figure1, "Figures2/F3.pdf", 'ContentType', 'vector');
end