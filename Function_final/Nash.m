function NS = Nash(Qobs,Qtt)
%Nash-Sutcliffe coefficient calculation
Data = [Qobs,Qtt];
Data(Data==-999)=NaN;
Data = removeNaNRows(Data);
A = 0.;
B = 0.;
C = 0.;
N = numel(Data(:,1));
for i = 1:N
    A = A+(Data(i,2)-Data(i,1))^2;
    B = B+Data(i,1);
end
X = B/N;
AA = A;
for i = 1:N
    C = C+(Data(i,1)-X)^2;
end
NS = 1-A/C;
end