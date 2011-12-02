% Correlation Coefficient

clear;

% Choose dataset
dset=1;

% Data
switch dset
    case 1, x=[10 8.04;8 6.95;13 7.58;9 8.81;11 8.33;
            14 9.96;6 7.24;4 4.26;12 10.84;7 4.82;5 5.68];
    case 2, x=[10 8.04;8 6.95;13 7.58;9 8.81;11 8.33;
            14 9.96;6 7.24;4 4.26;12 10.84;7 4.82;5 5.68;
            10 8.04;8 6.95;13 7.58;9 8.81;11 8.33;
            14 9.96;6 7.24;4 4.26;12 10.84;7 4.82;5 5.68];
    case 3, x=[10 9.14;8 8.14;13 8.74;9 8.77;11 9.26;
            14 8.1;6 6.13;4 3.10;12 9.13;7 7.26;5 4.74];
    case 4, x=[10 7.46;8 6.77;13 12.74; 9 7.11;11 7.81;
            14 8.84;6 6.08;4 5.39;12 8.15;7 6.42;5 5.73];
    case 5, x=[8 6.58;8 5.76;8 7.71;8 8.84;8 8.47;
            8 7.04;8 5.25;19 12.5;8 5.56;8 7.91;8 6.89];
end;
[n junk]=size(x);

% Sampling Parameters
nchains=1; % number of chains
nburnin=0; % number of burn-in samples
nsamples=5e3; % number of samples

% Data to Supply to WinBugs
datastruct = struct('x',x,'n',n);

% Initial Values to Supply to WinBugs
for i=1:nchains
    S.r = 0;
    S.mu = zeros(1,2);
    S.lambda = ones(1,2);
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Correlation_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'r','mu','sigma'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
figure(dset);clf;hold on;
bins=[-1:.02:1];
subplot(121);hold on;
ph=plot(x(:,1),x(:,2),'ko');
set(ph,'markersize',2,'markerfacecolor','k');
axis square;
set(gca,'box','on','fontsize',14);
subplot(122);hold on;
count=hist(samples.r,bins);
ph=plot(bins,count,'k-');
set(gca,'box','on','fontsize',14,'xtick',[-1:.5:1],'ytick',[]);
axis square;
tmp=corrcoef(x);
ph=plot(ones(1,2)*tmp(1,2),[0 max(get(gca,'ylim'))],'k--');
xlabel('Correlation','fontsize',16);
ylabel('Posterior Density','fontsize',16);