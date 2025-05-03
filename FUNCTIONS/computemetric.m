function [NSEv, PE] = computemetric(Obs, Sim)
NSEv = Nash(Obs, Sim);
[PE,~] = computeflooderror(Obs,Sim);
end