% Example of code to calculate Plot position
function [f]=Freq(P)
% For Plot Position Formula  there is: --Pour le  Calcul des Fréquences empiriques, il y a : 
% 1- Hazen Method  
% 2- Weibull Method     
% 3- Cunane Method  
% 4- Chegodayev Method   
% 5- Gringorten Method 

% 1- Hazen Method  
    for i=1:n 
    f(i)=(i-0.5)/(n);
    end
    
% 2- Weibull Method     
    for i=1:n
    f(i)=i/(n+1);
    end
    
%Note that We have added:
% 3- Cunane Method   
% 4- Chegodayev Method   
% 5- Gringorten Method 