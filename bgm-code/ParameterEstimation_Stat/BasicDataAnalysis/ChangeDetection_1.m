% Change Detection

clear;

% Load Data
load ChangeDetection;c = data;n=length(c);
t=[1:n];tmax=max(t);
        
% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=1e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('c',c,'t',t,'n',n,'tmax',tmax);

% Initialize Unobserved Variables
for i=1:nchains
    S.mu = ones(1,2); % An Intial Value for both means
    S.lambda = 1; % An Intial Value for the common precision
    S.tau= tmax/2; % An initial value for the change-point
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'ChangeDetection_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'mu','sigma','tau'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
figure(1);clf;hold on;
ph=plot([1:n],c,'k-');set(ph,'color',[.5 .5 .5]);
mt=mean(samples.tau);
ph=plot([1 mt],mean(samples.mu(1,:,1))*[1 1],'k-');set(ph,'linewidth',2);
ph=plot([mt n],mean(samples.mu(1,:,2))*[1 1],'k-');set(ph,'linewidth',2);
set(gca,'box','on','xlim',[0 n+1],'fontsize',14);
xlabel('Time','fontsize',16);
ylabel('Count','fontsize',16);



