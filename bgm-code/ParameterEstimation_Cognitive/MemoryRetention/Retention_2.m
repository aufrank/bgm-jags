% Retention With Full Individual Differences

clear;

% Data
t=[1 2 4 7 12 21 35 59 99 200];
slist=[1:4];
ns=length(slist);
k=[ 18    18    16    13     9     6     4     4     4 nan;
    17    13     9     6     4     4     4     4     4 nan;
    14    10     6     4     4     4     4     4     4 nan;
	nan   nan   nan   nan   nan   nan   nan    nan   nan nan];
nt=length(t);
n=18*ones(ns,nt);

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=1e4; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('k',k,'n',n,'t',t,'ns',ns,'nt',nt);

% Initialize Unobserved Variables
for i=1:nchains
    S.alpha = 1/2*ones(ns,1);
    S.beta = 1/2*ones(ns,1);
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Retention_2.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'alpha','beta','predk'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
% Simplify Data Structure
predk=squeeze(samples.predk);
% Draw Joint Posterior and Marginal
figure(3);clf;hold on;
% proportionate size of joint window
jointsize=.6;
joint=5e2;
clabs=char('k-','r-','g-','b-');
collabs=char('''k''','''r''','''g''','''b''');
linelabs=char('-','-','-','-');
subplot(221);hold on;h10=gca;
bins2=[0:.02:1];
bins1=[0:.02:1];
axis([bins1(1) bins1(end) bins2(1) bins2(end)]);
set(h10,'yaxislocation','right','box','on','fontsize',13);
set(h10,'xtick',[],'ytick',[]);
subplot(222);hold on; h11=gca;
ylabel('\beta','fontsize',14);
axis([0 1 bins2(1) bins2(end)]);
set(h11,'yaxislocation','right','ytick',[bins2(1):bins2(end)],...
	'box','on','xtick',[],'ticklength',[0 0],'fontsize',13);
subplot(223);hold on; h12=gca;
th=xlabel('\alpha','fontsize',14,'rot',0,'hor','left');
axis([bins1(1) bins1(end) 0 1]);
set(h12,'xtick',[bins1(1):bins1(end)],'box','on','ytick',[],...
	'ticklength',[0 0],'fontsize',14);
set(h10,'units','normalized','position',...
	[.1 1-jointsize-.1 jointsize jointsize]);
set(h11,'units','normalized','position',...
	[jointsize+.1+.05 1-jointsize-.1 1-.25-jointsize jointsize]);
set(h12,'units','normalized','position',...
	[.1 .1 jointsize 1-.25-jointsize]);
for i=1:4
    subplot(h10);hold on;
    keep=ceil(rand(joint,1)*nsamples);
    ph=plot(samples.alpha(:,keep,i),samples.beta(:,keep,i),'ko');
    eval(['set(ph,''markeredgecolor'',' deblank(collabs(i,:)) ...
		',''markersize'',2,''markerfacecolor'',' deblank(collabs(i,:)) ');']);
    subplot(h11);hold on;
    count=hist(samples.beta(:,:,i),bins2);
    count=count/max(count);
    ph=plot(1-count,bins2,'k-');
      set(ph,'linewidth',2);
  eval(['set(ph,''color'',' deblank(collabs(i,:)) ');']);
    subplot(h12);hold on;
    count=hist(samples.alpha(:,:,i),bins1);
    count=count/max(count);
    ph=plot(bins1,count,'k-');
    set(ph,'linewidth',2);
    eval(['set(ph,''color'',' deblank(collabs(i,:)) ');']);
end;
set(h11,'xlim',[1-1.2 1-0]);
set(h12,'ylim',[0 1.2]);
% Draw Posterior Predictive Analysis
figure(4);clf;
sc=20; % Scaling Constant for Drawing Boxes
for i=1:ns
    % Subplots for Subjects
    subplot(2,2,i);hold on;
    % Plot Subject Data
    ph=plot([1:nt],k(i,:),'k-');
    set(ph,'linewidth',2);
    % Plot Posterior Predictive
    for j=1:nt
        count=hist(predk(:,i,j),[0:n(i,j)]);
        count=count/sum(count);
        for x=0:n(i,j)
            if count(x+1)>0
                ph=plot(j,x,'ks');
                set(ph,'markersize',sc*sqrt(count(x+1)));
                if k(i,j)==x
                    set(ph,'markerfacecolor','k');
                end;
            end;
        end;
    end;
    % Set the Axes
    axis([0 nt+1 -1 19]);
    % Title the Subplot
    th=title(['Subject ' int2str(i)]);
    set(th,'fontsize',12,'verticalalignment','mid');
    xlabel('Time Lags','fontsize',12);
    ylabel('Retention Count','fontsize',12);
    % Tidy Up the Subplot
    set(gca,'box','on','xtick',[1:nt],'xticklabel',t,'ytick',[0 18]);
end;