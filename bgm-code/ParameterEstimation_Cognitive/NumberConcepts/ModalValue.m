
function [Value Proportion] = ModalValue(Vector);

u=unique(Vector);
nu=length(u);
match=zeros(nu,1);
for i=1:length(u)
match(i)=length(find(Vector==u(i)));
end;
[val ind]=max(match);
Value=u(ind);
Proportion=match(ind)/sum(match);