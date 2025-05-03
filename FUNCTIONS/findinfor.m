function Daminfo = findinfor(BasinM,DamAttribute)
idx = inpolygon(DamAttribute(:,2), DamAttribute(:,1), BasinM.X, BasinM.Y);
idx = find(idx==1);
Daminfo =[0 0 0];
if ~isempty(idx)
    Daminfo(1) = max(DamAttribute(idx,3));
    Daminfo(2) = sum(DamAttribute(idx,7),'omitnan');
    Daminfo(3) = min(DamAttribute(idx,5));
end
end