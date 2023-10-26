ConditionNum=4;
BlockDura=20;
EVDura=4;
InterBlockDura=20;
BlockNum=6;

TR=2;
InitOnset=8;
RestTime=4;
Time=InitOnset+(BlockDura+EVDura+InterBlockDura)*BlockNum*ConditionNum+RestTime;
TRNum=Time/TR;
DesignSeries_TR=zeros(ConditionNum,TRNum);
DesignSeries_Time=zeros(ConditionNum,Time);
BlockOnset=InitOnset+((1:BlockNum*ConditionNum)-1)*(BlockDura+EVDura+InterBlockDura);
BlockOnset=reshape(BlockOnset,ConditionNum,[]);
BlockOffset=BlockOnset+(BlockDura+EVDura);
BlockOffset=reshape(BlockOffset,ConditionNum,[]);

for i=1:BlockNum
    for j=1:ConditionNum
        onset=BlockOnset(j,i);
        offset=BlockOffset(j,i);
        DesignSeries_Time(j,onset:offset)=1;
        DesignSeries_TR(j,(onset/TR):(offset/TR))=1;
    end
end
plot(DesignSeries_Time')
line([Time Time],[-0.5 1.5],'LineStyle','--','Color','k')
set(gcf,'Position',[237.800000000000,225.800000000000,1188,420.000000000000])
set(gca,'YLim',[-0.5 1.5])
set(gca,'YTick',[0 1])
set(gca,'YTickLabel',{'stimulus offset','stimulus onset'})
set(gca,'XTick',0:60:Time)
legend({'Food','Money','Game','Neutral','End of Run'},'Location','best')
xlabel('Time (in seconds)')
%% FFT for design series (combined all condtions)
DesignSeries_All=sum(DesignSeries_Time);
Y=fft(DesignSeries_All);
f = (0:length(Y)-1)/length(Y);
plot(f,abs(Y))
title('Magnitude')
xlabel('Frequency (Hz)')

%% design efficiency analysis
scanLength=Time;
nconditions=ConditionNum+1;
blockduration=[20 20 20 20 4];
HPlength=128;
dononlin=0;
InitBias=InitOnset;
figure()
create_figure('design');
ons = cell(1, nconditions);
for i=1:ConditionNum
    ons{i}(:,1)=BlockOnset(i,:)';
    ons{i}(:,2)=repmat(blockduration(i),BlockNum,1);
end
ons{i+1}(:,1)=reshape(BlockOffset,[],1)-EVDura;
ons{i+1}(:,2)=repmat(EVDura,numel(BlockOffset),1);
contrasts=[1 0 0 -1 0 0;...
           0 1 0 -1 0 0;...
           0 0 1 -1 0 0;...
           1 -1 0 0 0 0;...
           1 0 -1 0 0 0;...
           0 1 -1 0 0 0];
HRFname='hrf';       
[X, e] = block_simulate(scanLength, TR, nconditions,ons, HPlength, dononlin,contrasts,HRFname);
fprintf('Efficiency = %.4f\n',e)
axis tight
drawnow, snapnow
%% design matrix
figure()
imagesc(X)
colormap gray
colorbar
title('Design Matrix')
set(gca,'XTickLabel',{'Food','Money','Game','Neutral','EV','Intercept'})
xlabel('Regressors in GLM')
ylabel('Time in scans')
%% orthogonality 
orth=corr(X);
imagesc(orth)
clr=gray;clr=sort(clr,'descend');
colormap(clr)
colorbar
set(gca,'XTickLabel',{'Food','Money','Game','Neutral','EV','Intercept'})
set(gca,'YTickLabel',{'Food','Money','Game','Neutral','EV','Intercept'})


%% FFT for HRF
figure()
X = onsets2fmridesign(ons, TR, scanLength, 'hrf', 'nononlin');
DesignSeries_All=sum(X(:,1:5),2);
Y=fft(DesignSeries_All);
f = (0:length(Y)-1)/2/length(Y);
plot(f,abs(Y))
title('Magnitude')
xlabel('Frequency (Hz)')
%% view contrast
figure()
imagesc(contrasts)
set(gca,'YTickLabel',{'Food','Money','Game','Neutral','EV','Intercept'})
set(gca,'XTickLabel',{'Food','Money','Game','Neutral','EV','Intercept'})
colormap gray
colorbar
% figure()
% create_figure('design');
% contrasts=[1 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0;...
%            0 0 0 1 0 0 0 0 0 -1 0 0 0 0 0 0;...
%            0 0 0 0 0 0 1 0 0 -1 0 0 0 0 0 0;...
%            1 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0;...
%            1 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0;...
%            0 0 0 1 0 0 -1 0 0 0 0 0 0 0 0 0];
% HRFname='hrf (with time and dispersion derivatives)';       
% [X, e] = block_simulate(scanLength, TR, nconditions,ons, HPlength, dononlin,contrasts,HRFname);