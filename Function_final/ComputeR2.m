function R2 = ComputeR2(Obs,Sim)
%%%%%%% Compute R^2: Input=x,y; Output=R^2
Data = [Obs,Sim];
Data(Data==-999)=NaN;
Data = removeNaNRows(Data);
Sim = Data(:,2);
Obs = Data(:,1);
th1 = 0; th2 = 1;  % y=x
TSS = sum( (Sim-mean(Sim)).^2 );
RSS = sum( (Sim-th1-th2*Obs).^2 );
ESS = TSS-RSS;
R2  = ESS/TSS;     % The coefficient of determination

