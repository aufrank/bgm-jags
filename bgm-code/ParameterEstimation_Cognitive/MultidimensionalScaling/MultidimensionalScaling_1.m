% Multidimensional Scaling In City-Block Space

clear;

% Load Data
load sizeangle_treat;s=sind;nsubj=9;
% Set Metric
r=1;

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=1e2; % How Many Burn-in Samples?
nsamples=1e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('s',s,'NSTIM',n,'NSUBJ',nsubj,'r',r);

% Initialize Unobserved Variables
for i=1:nchains
    S.pt = zeros(n,2);
    S.sigma = 0.001;
    init0(i) = S;
end;

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'MultidimensionalScaling_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'p','sigma'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Plot Posterior Distribution of Points
figure(1);clf;hold on;
% Some Posterior Points
p=squeeze(samples.p);
howmany=50;
tmp=randperm(nsamples);
keep=tmp(1:howmany);
for i=1:n
    ph=plot(p(keep,i,1),p(keep,i,2),'ko');
    set(ph,'markersize',2,'markerfacecolor',[.5 .5 .5],...
        'markeredgecolor',[.5 .5 .5]);
end;
axis square;
set(gca,'box','on','xtick',[],'ytick',[]);
% Labels
x=squeeze(mean(p));
for i=1:n
    th=text(x(i,1),x(i,2),deblank(labs(i,:)));
    set(th,'vert','mid','hor','cen');
    set(th,'fontweight','bold','fontsize',18);
end;
