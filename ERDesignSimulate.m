clc
clear
%% Global Settings for GLM Design Efficiency
InitInterval=10;
TR = 2;
HPlength = [];
dononlin = 0;
IterNum = 2000;
contrast=[1 0 0 0;...
    0 1 0 0];
TrialNum=56;
BlockNum=3;
FeedbackDura = [];%the duration of feedback display will be the rest of DecisionDura
DifficultyPara=[-0.4, -0.1, 0.2, 0.5];
CatchDiffPara=[-0.8 0.8];
%%
% Option(1).JitterBase    = 2;
% Option(1).JitterRange   = 2;
% Option(1).CuePhaseDura  = 2;
% Option(1).DecisionDura  = 2;
% 
% Option(2).JitterBase    = 3;
% Option(2).JitterRange   = 4;
% Option(2).CuePhaseDura  = 5;
% Option(2).DecisionDura  = 4;%the duration of decision-making
% 
% Option(3).JitterBase    = 1;
% Option(3).JitterRange   = 3;
% Option(3).CuePhaseDura  = 2;
% Option(3).DecisionDura  = 2;
% 
% Option(4).JitterBase    = 4;
% Option(4).JitterRange   = 10;
% Option(4).CuePhaseDura  = 3;
% Option(4).DecisionDura  = 0.5;
% 
% Option(5).JitterBase    = 2;
% Option(5).JitterRange   = 1;
% Option(5).CuePhaseDura  = 3;
% Option(5).DecisionDura  = 1;
% 
% Option(6).JitterBase    = 2;
% Option(6).JitterRange   = 10;
% Option(6).CuePhaseDura  = 2;
% Option(6).DecisionDura  = 3;
% 
% Option(7).JitterBase    = 4;
% Option(7).JitterRange   = 4;
% Option(7).CuePhaseDura  = 2;
% Option(7).DecisionDura  = 2;
% 
% Option(8).JitterBase    = 2;
% Option(8).JitterRange   = 4;
% Option(8).CuePhaseDura  = 2;
% Option(8).DecisionDura  = 2;
% 
% Option=LoadComPara(Option,TrialNum,BlockNum,FeedbackDura,DifficultyPara,CatchDiffPara);
% Result=AllInOne(Option,IterNum,InitInterval,TR,HPlength,dononlin,contrast);
%% find optimal design series
IterNum = 10000;
EDTDVD_Option.JitterBase    = 2;
EDTDVD_Option.JitterRange   = 4;
EDTDVD_Option.CuePhaseDura  = 2;
EDTDVD_Option.DecisionDura  = 2;
EDTDVD_Option.TrialNum=TrialNum;
EDTDVD_Option.BlockNum=BlockNum;
EDTDVD_Option.FeedbackDura=FeedbackDura;%the duration of feedback display will be the rest of DecisionDura
EDTDVD_Option.DifficultyPara=DifficultyPara;
EDTDVD_Option.CatchDiffPara=CatchDiffPara;
Result=MainLoop(EDTDVD_Option,IterNum,InitInterval,TR,HPlength,dononlin,contrast);
Result=Result(cell2mat(Result(:,2))>350,:);
%%
TrialPara=Result{3,1};
TrialPara.SmallReward=nan(size(TrialPara,1),1);
TrialPara.IndiffPoint=nan(size(TrialPara,1),1);
save TrialPara_EDT_3.mat TrialPara
TrialPara.Properties.VariableNames = strrep(TrialPara.Properties.VariableNames,'EffortReq','Risk');
RiskLevel=[10 30 50 70];
for i=1:4
TrialPara.Risk(TrialPara.LevelName == i) = RiskLevel(i);
end
save TrialPara_RDT_3.mat TrialPara
%% subfunction
function Option=LoadComPara(Option,TrialNum,BlockNum,FeedbackDura,DifficultyPara,CatchDiffPara)
for i=1:length(Option)
    Option(i).TrialNum=TrialNum;
    Option(i).BlockNum=BlockNum;
    Option(i).FeedbackDura=FeedbackDura;
    Option(i).DifficultyPara=DifficultyPara;
    Option(i).CatchDiffPara=CatchDiffPara;
end
end

function Result=AllInOne(Option,IterNum,InitInterval,TR,HPlength,dononlin,contrast)
Result=cell(length(Option),6);
Result{1,1}='JitterRange';
Result{1,2}='CuePhaseDura';
Result{1,3}='DecisionFeedbackDura';
Result{1,4}='MaxEfficiency';
Result{1,5}='MeanScanLength';

for i=2:(length(Option)+1)
    Effc_Result=MainLoop(Option(i-1),IterNum,InitInterval,TR,HPlength,dononlin,contrast);
    Result{i,1}=[num2str(Option(i-1).JitterBase) '-' num2str(Option(i-1).JitterBase+Option(i-1).JitterRange) 's' ];
    Result{i,2}=Option(i-1).CuePhaseDura;
    Result{i,3}=Option(i-1).DecisionDura;
    Result{i,4}=max([Effc_Result{:,2}]);
    Result{i,5}=mean([Effc_Result{:,4}]);
end
end
function Result=MainLoop(EDTDVD_Option,IterNum,InitInterval,TR,HPlength,dononlin,contrast)
Result=cell(IterNum,4);
for i=1:IterNum
    fprintf('#Iter %d ',i)
    TrialPara=Get_DVD_TrialPara(EDTDVD_Option);
    [e, vifs,scanLength] = EsimateEfficiency(InitInterval,TrialPara,TR,HPlength,dononlin,contrast);
    Result{i,1}=TrialPara;
    Result{i,2}=e;
    Result{i,3}=vifs;
    Result{i,4}=scanLength;
    fprintf('\n')
end

end
function [e, vifs,scanLength] = EsimateEfficiency(InitInterval,TrialPara,TR,HPlength,dononlin,contrast)

TotalLength=InitInterval+sum(TrialPara.FixDura+TrialPara.CuePhaseDura+TrialPara.DecisionDura);
NumVol=ceil(TotalLength/TR);
scanLength=NumVol*TR;

[ons,ParaMod]=ExtractOnset(InitInterval,TrialPara);
%   **ons:**
%        A cell array of onsets and durations (in seconds) for each event
%        type. ons{1} corresponds to Condition 1, ons{2} to Condition 2,
%        and so forth. ons{i} can be an [n x 2] array, where the first
%        column is onset time for each event, and the second column is the event duration
%        (in sec)
%
fprintf('Build Design Matrix and Calculating Efficiency...')
[X, e] = ER_simulate(TR, ons, HPlength, dononlin, scanLength,contrast,'parametric_standard',ParaMod);

% Plot the variance inflation factors
% subplot(1,2,2)
figure()
[Magnitude,Freq]=sFFT(X(:,2),1/TR);
plot(Freq,Magnitude)

vifs = getvif(X, false);

end

function [ons,ParaMod]=ExtractOnset(InitInterval,TrialPara)
%   **ons:**
%        A cell array of onsets and durations (in seconds) for each event
%        type. ons{1} corresponds to Condition 1, ons{2} to Condition 2,
%        and so forth. ons{i} can be an [n x 2] array, where the first
%        column is onset time for each event, and the second column is the event duration
%        (in sec)
%

% Extract Condition 1: CuePhase
ons{1}=[InitInterval+TrialPara.TrialOnset+TrialPara.FixDura TrialPara.CuePhaseDura];
% Extract Condition 2: Decision and Feedback
ons{2}=[InitInterval+TrialPara.TrialOnset+TrialPara.FixDura+TrialPara.CuePhaseDura TrialPara.DecisionDura];
% Extract Parametric Modulators
ParaMod={TrialPara.Difficulty,[]};

end