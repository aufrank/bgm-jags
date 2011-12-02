% Take The Best With Unknown Search Order

clear;

% Load Data
load citworld; % German cities and their populations (83 objects and 9 cues)
% load prfworld; % Professors and their salaries (51 objects and 5 cues)

% Number of Cities and Cues
c=cues;
[n nc]=size(cues);

% Correct decisions for all possible questions
cc=1;
for i=1:n-1
	for j=i+1:n
		% Record two objects in cc-th question
		p(cc,1)=i;
		p(cc,2)=j;
		% Record correct answer (1=first object; 0=second)
		k(cc)=(pop(i)>pop(j));
		cc=cc+1;
	end;
end;
% Total number of questions
nq=cc-1;

% Setup Base
base=zeros(nc,nc^2);
for i=1:nc
	base(i,i:nc:end)=1/nc;
end;
M=nc^2;
		
% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=1e2; % How Many Burn-in Samples?
nsamples=2e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('c',c,'p',p,'k',k,'nc',nc,'nq',nq,'M',M,'base',base);

% Initialize Unobserved Variables
for i=1:nchains
    S.gamma = 0.5; 
    S.cv = [1:nc];
	init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'TakeTheBest_2.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',1, ...
    'monitorParams', {'gamma','cvo','sc'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Beginning analysis of the search order posterior
t=squeeze(samples.cvo);
sc=squeeze(samples.sc);

% What search orders are there in the posterior?
ut=unique(t,'rows');
[nut junk]=size(ut);

% What's the estimated mass of each, and how accurate is it?
for i=1:nut
    tmp=strmatch(ut(i,:),t);
    match(i)=length(tmp);
    pc(i)=sc(tmp(1));
end;

% Sort in decreasing order
[val ind]=sort(-match);
match=match(ind);
ut=ut(ind,:);
pc=pc(ind);

% Display results
home;
disp(sprintf('There are %d search orders sampled in the posterior.\n',nut));
for i=1:nut
 disp(sprintf('Order=(%s), Estimated Mass=%1.4f, Accuracy=%1.4f',...
     int2str(ut(i,:)),match(i)/sum(match),pc(i)));
end;
   
