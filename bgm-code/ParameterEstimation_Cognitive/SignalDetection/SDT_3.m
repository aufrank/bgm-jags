% Hierarchical Signal Detection Theory

clear;

% Load DataSets
% sdt_d has the deduction data, sdt_i the induction
load Heit_Rotello sdt_d sdt_i;

% Sampling Parameters
nchains=1; % number of chains
%nburnin=0; % number of burn-in samples
nburnin=1e3; % number of burn-in samples
%nsamples=1e3; % number of samples
nsamples=1e4; % number of samples

% DO ANALYSIS FOR BOTH CONDITIONS
for dataset=1:2
	switch dataset
		case 1,data=sdt_i;
		case 2,data=sdt_d;
	end;

	% Number of subjects
	[n junk]=size(data);

	% Hit, False-Alarm, Miss, and Correct-Rejection Counts for Conditions A and B
	HR=data(:,1);
	FA=data(:,2);
	MI=data(:,3);
	CR=data(:,4);

	% Data to Supply to WinBugs
	datastruct = struct('HR', HR, 'MI', MI, 'FA', FA, 'CR', CR, 'n', n);

	% Initial Values to Supply to WinBugs
	for i=1:nchains
		S.deltad = zeros(n,1);
		S.deltac = zeros(n,1);
		S.mud = 0;
		S.muc = 0;
		S.lambdadNew = 1;
		S.lambdacNew = 1;
        xiD = 0.5;
        xiC = 0.5;
		init0(i) = S;
	end

	[samples, stats] = matbugs(datastruct, ...
		fullfile(pwd, 'SDT_3.txt'), ...
		'init', init0, ...
		'nChains', nchains, ...
		'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
		'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
		'monitorParams', {'mud','muc','sigmad','sigmac'}, ...
		'Bugdir', 'C:/Program Files/WinBUGS14');

	if dataset==1
		samplesind=samples;
	end;
end;

% Analysis
% Draw Joint Posterior With Marginals
figure(1);clf;
clabs=char('k-','k--'); % d'/c contour line properties
collabs=char('''k''','[.8 .8 .8]'); % joint contour color
linelabs=char('-','--');
% number of joint plot
joint=1e3;
% proportionate size of joint window
jointsize=.6;
subplot(221);hold on;h10=gca;
bins1=[-1:.1:6];
bins2=[-3:.1:3];
axis([bins1(1) bins1(end) bins2(1) bins2(end)]);
set(h10,'yaxislocation','right','box','on','fontsize',13);
set(h10,'xtick',[],'ytick',[]);
subplot(222);hold on; h11=gca;
ylabel('\mu_c','fontsize',14);
axis([0 1 bins2(1) bins2(end)]);
set(h11,'yaxislocation','right','ytick',[bins2(1):bins2(end)],...
	'box','on','xtick',[],'ticklength',[0 0],'fontsize',13);
subplot(223);hold on; h12=gca;
th=xlabel('\mu_d','fontsize',14,'rot',0,'hor','left');
axis([bins1(1) bins1(end) 0 1]);
set(h12,'xtick',[bins1(1):bins1(end)],'box','on','ytick',[],...
	'ticklength',[0 0],'fontsize',14);
set(h10,'units','normalized','position',...
	[.1 1-jointsize-.1 jointsize jointsize]);
set(h11,'units','normalized','position',...
	[jointsize+.1+.05 1-jointsize-.1 1-.25-jointsize jointsize]);
set(h12,'units','normalized','position',...
	[.1 .1 jointsize 1-.25-jointsize]);
for i=1:2
	subplot(h10);hold on;
	keep=ceil(rand(joint,1)*nsamples);
	switch i
		case 1, ph=plot(samplesind.mud(keep),samplesind.muc(keep),'ko');
		case 2, ph=plot(samples.mud(keep),samples.muc(keep),'ko');
	end;
	eval(['set(ph,''markeredgecolor'',' deblank(collabs(i,:)) ...
		',''markersize'',2,''markerfacecolor'',' deblank(collabs(i,:)) ');']);
	subplot(h11);hold on;
	switch i
		case 1, count=hist(samplesind.muc,bins2);
		case 2,  count=hist(samples.muc,bins2);
	end;
	count=count/max(count);
	ph=plot(1-count,bins2,'k-');
	set(ph,'linewidth',2);
	eval(['set(ph,''color'',' deblank(collabs(i,:)) ');']);
	subplot(h12);hold on;
	switch i
		case 1, count=hist(samplesind.mud,bins1);
		case 2,  count=hist(samples.mud,bins1);
	end;
	count=count/max(count);
	ph=plot(bins1,count,'k-');
	set(ph,'linewidth',2);
	eval(['set(ph,''color'',' deblank(collabs(i,:)) ');']);
end;
set(h11,'xlim',[1-1.2 1-0]);
set(h12,'ylim',[0 1.2]);