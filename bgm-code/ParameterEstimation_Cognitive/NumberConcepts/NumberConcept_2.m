% Number Concept Using Analog Representation

clear;

% Load Data
load NumberConcept g q age Q S Z N

% WinBUGS Parameters
nchains=1;
nburnin=1e3;
nsamples=2e3;

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('S', S, 'Q', Q, 'N', N, 'g', g, 'q', q, 'Z', Z);

% RUN THE GRAPHICAL MODEL

% params
nchains=1;
nburnin=1e3;
nsamples=2e3;

% data
datastruct = struct('S', S, 'Q', Q, 'N', N, 'g', g, 'q', q);

% inits
for i=1:nchains
    S0.sigma=ones(S,1)
    S0.pitmp=1/N*ones(1,N);
    init0(i) = S0;
end

% sample
[samples, stats, structarray] = matbugs(datastruct, ...
    fullfile(pwd, 'NumberConcept_2.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',nsamples, ...
    'monitorParams', {'sigma','pp','ppb'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
% Posterior for BaseRate
figure(6);clf;hold on;
bins=[1:N];threshold=0;
count=hist(samples.ppb,bins);
ph=bar(bins,count/sum(count));
set(ph,'facecolor','k');
set(gca,'xlim',[0 N+1],'xtick',[1:N],'ytick',[],'box','on','fontsize',14);
xlabel('Number','fontsize',16);
ylabel('Probability','fontsize',16);
% Coefficient of Variation by Age
figure(7);clf;hold on;
mc=zeros(S,1)
for i=1:S
    mc(i)=mean(samples.sigma(1,:,i));
end;
ph=plot(age,mc,'kx');
set(ph,'markersize',8,'linewidth',2);
r=corrcoef(age,mc);
r=r(1,2);
th=text(30,2,[' r=' num2str(r,2)]);
set(th,'fontsize',14,'vert','top','hor','left');
set(gca,'box','on','fontsize',14);
axis([30 55 0 2]);
set(gca,'xtick',[30:5:55],'ytick',[0:.2:1 2]);
xlabel('Age (Months)','fontsize',16);
ylabel('Coefficient of Variation','fontsize',16);
% Posterior Prediction For Six Subjects
figure(8);clf;
subjlist=[79 77 73 70 72 69]
sc=10;sc2=.1;
for z=1:length(subjlist)
    subj=subjlist(z);
	subplot(2,3,z);hold on;
	for i=1:N
		count=hist(squeeze(samples.pp(1,:,subj,i)),bins);
		count=count/max(count);
		for j=1:N
			if count(j)>eps
				ph=plot(i,j,'ks');
				set(ph,'markersize',count(j)*sc);
			end;
		end;
	end;
	ph=plot(q(subj,1:Q(subj))+randn(1,Q(subj))*sc2,...
			g(subj,1:Q(subj))+randn(1,Q(subj))*sc2,'kx');
	set(ph,'markersize',8,'linewidth',2);
axis([0 N+1 0 N+1]);
set(gca,'box','on','fontsize',12);
set(gca,'xtick',setdiff(unique(q),0),'ytick',[1:N]);
xlabel('Question','fontsize',14);
ylabel('Answer','fontsize',14);
th=title(['Subject ' int2str(subj) ' (\sigma=' num2str(mc(subj),'%1.2f') ')']);
set(th,'fontsize',15,'vert','mid');
end;

