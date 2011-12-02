% Inferring Number of Surveys Distributed and Return Rate Simultataneously

clear;

% Data
dataset=2;

Nmax=500;
switch dataset
	case 1, k=[16 18 22 25 27];
	case 2, k=[16 18 22 25 28];
end;
m=length(k);

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=5e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('k',k,'m',m,'Nmax',Nmax);

% Initialize Unobserved Variables
for i=1:nchains
    S.theta = 0.5;
	S.n = Nmax/2;
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Rate_6.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'theta','n'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
n=squeeze(samples.n);
theta=squeeze(samples.theta);
figure(dataset);clf;hold on;
set(gcf,'units','norm','pos',[.2 .2 .6 .6],'paperpositionmode','auto');
scatterhist(n,theta);
ph=get(gcf,'children');axes(ph(3));hold on;
set(gca,'ylim',[0 1],'ytick',[0:.2:1],'xlim',[0 Nmax],'xtick',[0:100:Nmax]);
set(gca,'fontsize',12);
set(get(gca,'children'),'marker','.','color','k');
xlabel('Number of Surveys','fontsize',14);
ylabel('Rate of Return','fontsize',14);

% Expectation
ph=plot(mean(n),mean(theta),'rx');set(ph,'markersize',12,'linewidth',2);

% Maximum Likelihood
cc=-inf;
ind=0;
for i=1:nsamples
	logL=0;
	for j=1:m
	logL=logL+gammaln(n(i)+1)-gammaln(k(j)+1)-gammaln(n(i)-k(j)+1);
	logL=logL+k(j)*log(theta(i))+(n(i)-k(j))*log(1-theta(i));
	end;
	if logL>cc
		ind=i;
		cc=logL;
	end;
end;
ph=plot(n(ind),theta(ind),'go');set(ph,'markerfacecolor','g');		
