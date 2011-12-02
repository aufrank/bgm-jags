% Signal Detection Theory

clear;

% Choose a DataSet
dataset=1;

% Sampling Parameters
nchains=1; % number of chains
nburnin=0; % number of burn-in samples
nsamples=1e4; % number of samples

% LOAD DATASET
switch dataset
	case 1, % Demo
		data=[70 50 30 50;
			7 5 3 5;
			10 0 0 10];
	case 2; % Lehrner Et Al (1995) data
		data=[148 29 32 151;
			150 40 30 140;
			150 51 40 139];

end; % switch data set

% Number of subjects
[n junk]=size(data);

% Hit, False-Alarm, Miss, and Correct-Rejection Counts
%  for Conditions A and B
HR=data(:,1);
FA=data(:,2);
MI=data(:,3);
CR=data(:,4);

% Data to Supply to WinBugs
datastruct = struct('HR', HR, 'MI', MI, 'FA', FA, 'CR', CR, 'n', n);

% Initial Values to Supply to WinBugs
for i=1:nchains
	S.d = zeros(n,1);
	S.c = zeros(n,1);
	init0(i) = S;
end

[samples, stats] = matbugs(datastruct, ...
	fullfile(pwd, 'SDT_1.txt'), ...
	'init', init0, ...
	'nChains', nchains, ...
	'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
	'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
	'monitorParams', {'d','c','h','f'}, ...
	'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
% Draw The Posteriors
figure(1);clf;
dbins=[-2:.05:6];
cbins=[-2:.05:2];
ratebins=[0:.01:1];
ls=char('-','--',':');
col=char('r','g','b');
% Discriminability
subplot(221);hold on;
for i=1:3
	count=hist(samples.d(1,:,i),dbins);
	ph=plot(dbins,count/sum(count),'k-');
	set(ph,'linewidth',1.5,'linestyle',deblank(ls(i,:)),'color',col(i,:));
end;
xlim([dbins(1) dbins(end)]);
set(gca,'fontsize',12,'xtick',[dbins(1):dbins(end)],...
	'ytick',[],'box','on','ticklength',[0 0]);
xlabel('Discriminability','fontsize',12);
ylabel('Probability Density','fontsize',12);
% Bias
subplot(222);hold on;
for i=1:3
	count=hist(samples.c(1,:,i),cbins);
	ph=plot(cbins,count/sum(count),'k-');
	set(ph,'linewidth',1.5,'linestyle',deblank(ls(i,:)),'color',col(i,:));
end;
xlim([cbins(1) cbins(end)]);
set(gca,'fontsize',12,'xtick',[cbins(1):cbins(end)],...
	'ytick',[],'box','on','ticklength',[0 0]);
xlabel('Bias','fontsize',12);
ylabel('Probability Density','fontsize',12);
% Hit Rate
subplot(223);hold on;
for i=1:3
	count=histc(samples.h(1,:,i),ratebins);
	ph=plot(ratebins,count/sum(count),'k-');
	set(ph,'linewidth',1.5,'linestyle',deblank(ls(i,:)),...
		'color',col(i,:));
end;
xlim([ratebins(1) ratebins(end)]);
set(gca,'fontsize',12,'xtick',[0:.2:1],'ytick',[],...
	'box','on','ticklength',[0 0]);
xlabel('Hit Rate','fontsize',12);
ylabel('Probability Density','fontsize',12);
% Currently Need To Set This Legend Manually
switch dataset
	case 1, lh=legend('H=70/100, F=50/100',...
			'H=7/10,     F=5/10','H=10/10,   F=0/10','location','northwest');
	case 2, lh=legend('Controls','Group I',...
			'Group II','location','northwest');
end;
set(lh,'fontsize',8);
% False-Alarm Rate
subplot(224);hold on;
for i=1:3
	count=histc(samples.f(1,:,i),ratebins);
	ph=plot(ratebins,count/sum(count),'k-');
	set(ph,'linewidth',1.5,'linestyle',deblank(ls(i,:)),'color',col(i,:));
end;
xlim([ratebins(1) ratebins(end)]);
set(gca,'fontsize',12,'xtick',[0:.2:1],'ytick',[],...
	'box','on','ticklength',[0 0]);
xlabel('False-Alarm Rate','fontsize',12);
ylabel('Probability Density','fontsize',12);