% SIMPLE Model

clear;

% Data
load Murdock1962 k tr nsets ll pc labs
dsets=6;

% Set Dataset to Use
T=zeros(size(k));
dsets=6;
for dset=1:dsets
    switch dset,
        case 1, nwords=10;lag=2;offset=15;
        case 2, nwords=15;lag=2;offset=20;
        case 3, nwords=20;lag=2;offset=25;
        case 4, nwords=20;lag=1;offset=10;
        case 5, nwords=30;lag=1;offset=15;
        case 6, nwords=40;lag=1;offset=20;
    end; % switch
    % Temporal Offset For Free Recall
    T(dset,1:nwords)=offset+[(nwords-1)*lag:-lag:0];

end;
k=k';T=T';

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=1e3; % How Many Burn-in Samples?
nsamples=2e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('k',k,'tr',tr,'listlength',ll,'T',T,'dsets',dsets);

% Initialize Unobserved Variables
for i=1:nchains
    S.c = 1*ones(dset,1);
    S.t = 0.5*ones(dset,1);
    S.s = 1*ones(dset,1);
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'SIMPLE_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',nsamples, ...
    'monitorParams', {'c','s','t','pcpred'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Some Analysis

% Posterior Predictive
figure(1);clf;hold on;
% Drawing Constants
mark=char('o','o','o','o','o','o');
ccc=char('k','k','k','k','k','k');
hm=20;
for dset=1:dsets
    subplot(2,3,dset);hold on;
    for i=1:ll(dset)
        data=squeeze(samples.pcpred(1,:,i,dset));
        ph=plot(i+randn(hm,1)*.1,data(ceil(rand(hm,1)*nsamples)),'ko');
        set(ph,'markersize',2,'markerfacecolor',[.5 .5 .5],'markeredgecolor',[.5 .5 .5]);
    end;
    % Draw the Probability Correct Data
    ph=plot([1:ll(dset)],pc(dset,1:ll(dset)),'ks-');
    set(ph,'color',ccc(dset));
    set(ph,'markersize',4,'marker',mark(dset),'markerfacecolor','w','markeredgecolor',ccc(dset));
    axis([0 41 0 1]);
    set(gca,'xtick',[0:10:40],'ytick',[0:.2:1],'box','on','fontsize',14);
end;
[ax,th]=suplabel('Serial Position','x');set(th,'fontsize',16);
[ax,th]=suplabel('Probability Correct','y');set(th,'fontsize',16);

% Joint Posterior
figure(2);clf;hold on;
% Drawing Constants
mark=char('o','s','d','^','v','<');
ccc=char('k','k','k','k','k','k');
epsc=.05;cx=[5:epsc:25];
cxe=[0+epsc/2:epsc:25-epsc/2];
epss=.05;sx=[7:epss:15];
sxe=[5+epss/2:epss:16-epss/2];
epst=.002;tx=[.45:epst:.65];
txe=[.4+epst/2:epst:.7-epst/2];
sc=.5;joint=20;
% Draw Joint Posterior and Marginal
grid on;view([-25 30]);
for i=1:dsets
    ph=plot(-10,-10,'ko');
    set(ph,'marker',mark(i));
end;
for i=1:dsets
    keep=ceil(rand(joint,1)*nsamples);
    ph=plot3(samples.s(1,keep,i),samples.t(1,keep,i),samples.c(1,keep,i),'kp');
    set(ph,'marker',mark(i),'markersize',7,'markerfacecolor','w');
    ph=plot3(samples.s(1,keep,i),samples.t(1,keep,i),zeros(1,joint),'k.');
    ph=plot3(20*ones(1,joint),samples.t(1,keep,i),samples.c(1,keep,i),'k.');
    ph=plot3(samples.s(1,keep,i),.7*ones(1,joint),samples.c(1,keep,i),'k.');
    count=hist(reshape(samples.s,[],1),sx);
    count=count/sum(count);
    ph=plot3(sx,.3+sc*count,zeros(size(sx)),'k-');
    set(ph,'linewidth',1);
    count=hist(reshape(samples.t,[],1),tx);
    count=count/sum(count);
    ph=plot3(sc*20/.4*count,tx,zeros(size(tx)),'k-');
    set(ph,'linewidth',1);
    count=hist(reshape(samples.c,[],1),cx);
    count=count/sum(count);
    ph=plot3(sc*30/.4*count,.7*ones(size(cx)),cx,'k-');
    set(ph,'linewidth',1);
end;
set(gca,'fontsize',14,'gridline','--','linewidth',.25);
set(gca,'xlim',[0 20],'xtick',[0:5:20]);
set(gca,'ylim',[.3 .7],'ytick',[.3:.1:.7]);
set(gca,'zlim',[0 30],'ztick',[0:10:30]);
xlabel('Threshold Noise (s)','fontsize',16);
ylabel('Threshold (t)','fontsize',16);
zlabel('Distinctiveness (c)','fontsize',16);
[lh oh]=legend(labs,'location','bestoutside');
