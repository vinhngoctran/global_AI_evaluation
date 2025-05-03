clc; close all;
% Flood Frequency Distribution using  10 Probability Plots -- By  T. Benkaci & N.Dechemi 
% Analyse Frequentielle des crues Avec 10 lois statistiques -- Par T. Benkaci & N.Dechemi 
% Copyright T.Benkaci 2018-2020

%Load the file Data: File_Data.txt, 
PP = load('File_Data.txt');
D=PP(1:end,1:1); % First Column  : The years
P=PP(1:end,2:2); % Second Column : Observed Data, Here Annual Precipitations (mm)
%Note: you can change Data_File from text to excel: PP= xlsread('Data.xlsx','feuil1');  D= Data(:,1); P= Data(:,2);

% Statistics of  Sample--- Caracteristiques statistiques  de la serie
Car_Stat=stat(P); % first File to be loaded (p-code) 
n=length(P);
m=mean(P);
s=std(P);
y=sort(P); %  thus calculates the plot position with Freq(P);  % second file (p-code)

%The main file to Choose 10 Probability Distributions is FFD (p-code)
FFD
% 1 - Loi Normale            ----  Normal Distribution              
% 2 - Loi Log Normale        ----  LogNormal-2p Distribution         
% 3 - Loi de Gumbel          ----  Gumbel Distribution              
% 4 - Loi Racine_Normale     ----  Racine-Normal Distribution        
% 5 - Loi Gene-Extre-Va(GEV) ----  General Ext-Values (GEV)Distribution 
% 6 - Loi GAMMA              ----  GAMMA Distribution (Pearson3)     
% 7 - Loi Log Pearson3       ----  Log Pearson 3 Distribution         
% 8 - Loi Goodrich           ----  Goodrich Distribution            
% 9 - Loi LogNormale3P       ----  LogNormal-3p Distribution         
% 10- Loi de Weibull(2p)     ----  Weibull Distribution (2p)

% Two plots: Frequency distribution and QQplot quantiles/obeservedved
% Results are saved in Results_Flood.txt'
% and Quantile & LB-UB in Data_Sim excel  #  

