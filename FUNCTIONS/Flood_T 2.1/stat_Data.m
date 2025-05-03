% Example of code to calculate Statistical Parameters of Observed Data
function [Mx,Mn,moy,Var,Ec,c_var,CS,KS] =stat_Data(data)

% *** ---- Statistics of Sample ------  Statistiques de la Serie *** -----

% Max and Min  of Values
Mx=max(data);Mn=min(data);
% Mean of Sample----Moyenne   
moy=mean(data);
%Median  of Values
Med=median(data);
%Variance of Sample ---Variance  
Var=var(data);
%Stand_Deviation---Ecart type
Ec=std(data);
%Coefficient of   variation
c_var=Ec/moy;


%Note that we have added in the main File of Stat File:
% Cs: Coefficient of Skewness--- C.Asymetrie     
% Ks: Coefficient of Kurtosis--- C.Kurtois



