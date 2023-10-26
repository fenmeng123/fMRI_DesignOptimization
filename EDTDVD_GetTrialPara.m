function TrialPara=EDTDVD_GetTrialPara(DifficultyPara,Result_EDTSIP,BlockNum,CatchDiffPara,LastUpdateFlag)
% change the magnitude of small reward according to difficulty parameter
% for Effort Discounting Task - Dissociate Value and Difficulty, using the
% following equation:
% Small Reward=indifference point * (1 + difficulty parameter)
% lower bound: 0.01
% upper bound: Large Reward - 0.01
% Input:
%  DiffcultyPara  - a row vector containing difficulty parameters
%  Result_EDTSIP - a 'TrialResult' table from EDT_SIP task
%  BlockNum - the number of blocks
%  LastUpdateFlag - a logical flag to control the indifference point
%                   values, if true, then update small reward in Result_EDTSIP using the
%                   last iteration in a block to get the IndiffPoint, otherwise, use the
%                   last iteration small reward as the IndiffPoint. (Default: false)
%
% It should be noted that if the number of input parameters is below 3
% (i.e. miss any one of 'DiffcultyPara', 'Result_EDTSIP' or 'BlockNum'),
% this function will call SimulateSIP.m to generate simulated results from
% a EDTSIP task. Therefore, if this functions was called in formal EDTDVD
% task, please give it at least three input parameters.
% Written by Kunru Song 2021.9.21
% Modified by Kunru Song 2021.9.26 fixed some bugs
% Modified by Kunru Song 2021.12.15 add catch trials
% Modified by Kunru Song 2021.12.26 according to Yao's Comments (upper bound)
% Modified by Kunru Song 2021.12.26 now adpated for ExpOption input when
%                                   nargin == 2

 if nargin < 4 && nargin ~=2
    Result_EDTSIP=SimulateSIP('random');
    if nargin == 0 % no input
        DifficultyPara  = [-0.4, -0.1, 0.2, 0.5];
        CatchDiffPara   = [-0.8 0.8];
        BlockNum        = 3;
    elseif nargin == 1 % only input ExpOption
        ExpOption = DifficultyPara;
        DifficultyPara  = ExpOption.DifficultyPara;
        CatchDiffPara   = ExpOption.CatchDiffPara;
        BlockNum        = ExpOption.BlockNum;
        JitterBase      = ExpOption.JitterBase;
        JitterRange     = ExpOption.JitterRange;
        CuePhaseDura    = ExpOption.CuePhaseDura;
        DecisionDura    = ExpOption.DecisionDura;
    end
    LastUpdateFlag=true;
%     warning('EDTDVD: the number of input parameters is insufficient (below 3), now using the simulated EDTSIP results')
elseif nargin == 2 % input ExpOption and Result_EDTSIP
    ExpOption       = DifficultyPara;
    DifficultyPara  = ExpOption.DifficultyPara;
    CatchDiffPara   = ExpOption.CatchDiffPara;
    BlockNum        = ExpOption.BlockNum;
    LastUpdateFlag  = ExpOption.LastUpdateFlag;
end
if exist('LastUpdateFlag','var')
    % if the LastUpdateFlag is input, then use the input var-value
    IndiffPoint=Result_EDTSIP(Result_EDTSIP.IterNum==6,:);% firstly, get IDP 
    if LastUpdateFlag
        IndiffPoint=EDTSIP_RewardChange(IndiffPoint);
    end
else % without LastUpdateFalge, use default set: LastUpdateFlag = False
    IndiffPoint=Result_EDTSIP(Result_EDTSIP.IterNum==6,:);
end

TrialPara=table('Size',[size(IndiffPoint,1)*length(DifficultyPara) 9],...
    'VariableTypes',...
    {'double'    ,'double'      ,'double'    ,'double'       ,'double'       ,...
    'double'    ,'double'      ,'double'    ,'string'},...
    'VariableNames',...
    {'TrialOrder','BlockOrder'  ,'EffortReq' ,'LargeReward'  ,'SmallReward'  ,...
    'Difficulty','IndiffPoint' ,'CBLocation','TrialType'});
BlockPara=[];
for icomb=1:size(IndiffPoint,1)
    SmallReward = round( IndiffPoint.SmallReward(icomb)*(1+DifficultyPara) , 2);
    
    %     % check the lower and upper bound for small reward
    %     if any(SmallReward<0.01)
    %         SmallReward(SmallReward<0.01)=0.01;
    %     elseif any(SmallReward>IndiffPoint.LargeReward(icomb))
    %         SmallReward( SmallReward>IndiffPoint.LargeReward(icomb) )=IndiffPoint.LargeReward(icomb);
    %     end
    
    % repeat trial parameters for a single block
    try % EDT
        SingleBlock = repmat([IndiffPoint.EffortReq(icomb),IndiffPoint.LargeReward(icomb)],length(DifficultyPara),1);
    catch % RDT
        SingleBlock = repmat([IndiffPoint.Risk(icomb),IndiffPoint.LargeReward(icomb)],length(DifficultyPara),1);
    end
    
    SingleBlock = [SingleBlock SmallReward' DifficultyPara' repmat(IndiffPoint.SmallReward(icomb),length(DifficultyPara),1)];
    
    if isempty(BlockPara)
        BlockPara=SingleBlock;
    else
        BlockPara=[BlockPara;SingleBlock];
    end
    
end
TrialPara.EffortReq=BlockPara(:,1);
TrialPara.LargeReward=BlockPara(:,2);
TrialPara.SmallReward=BlockPara(:,3);
TrialPara.Difficulty=BlockPara(:,4);
TrialPara.IndiffPoint=BlockPara(:,5);
TrialPara.BlockOrder=ones(size(TrialPara,1),1);
% randomly permute the order of trials in one block and repeat blocks to
% generate the whole task TrialPara
PermFlag=randperm(size(TrialPara,1));
TrialPara=TrialPara(PermFlag,:);
for iblock = 1:BlockNum
    PermFlag=randperm(size(TrialPara,1));
    TrialPara.BlockOrder=ones(size(TrialPara,1),1)*iblock;
    if exist('tmp','var')
        tmp=[tmp;TrialPara(PermFlag,:)];
    else
        tmp=TrialPara(PermFlag,:);
    end
end
TrialPara=tmp;

% attach trial type to TrialPara
TrialPara.TrialType=repmat("Regular",size(TrialPara,1),1);
% get effort requirements level and its name
EffortReq=sort(unique(IndiffPoint.EffortReq),'ascend');
EffortReqName=sort(unique(IndiffPoint.LevelName),'ascend');
% attach catch trials to TrialPara

CatchEffort = repmat(EffortReq,1,length(CatchDiffPara) );
CatchDiff = repmat(CatchDiffPara,size(CatchEffort,1),1);
CatchEffort = reshape(CatchEffort,[],1);
CatchDiff = reshape(CatchDiff,[],1);

LargeReward=unique(Result_EDTSIP.LargeReward(Result_EDTSIP.IterNum==1));
BlockPara=cell(BlockNum,1);
warning off
for i=1:BlockNum
    BlockPara{i}=TrialPara(TrialPara.BlockOrder==i,:);
    StartRow=size(BlockPara{i},1)+1;
    EndRow=StartRow+length(CatchEffort)-1;
    CatchIDP=zeros(length(CatchEffort),1);
    CatchLargeReward=randsample(LargeReward,length(CatchEffort),true);
    for icatch=1:length(CatchEffort)
        IDP_TrialFlag=BlockPara{i}.EffortReq==CatchEffort(icatch) & BlockPara{i}.LargeReward==CatchLargeReward(icatch);
        CatchIDP(icatch)=unique(BlockPara{i}.IndiffPoint(IDP_TrialFlag));
    end
    CatchSmallReward=round(CatchIDP.*(1+CatchDiff),2);
    BlockPara{i}.EffortReq( StartRow : EndRow )=CatchEffort;
    BlockPara{i}.LargeReward( StartRow : EndRow )=CatchLargeReward;
    BlockPara{i}.IndiffPoint( StartRow : EndRow )=CatchIDP;
    BlockPara{i}.SmallReward( StartRow : EndRow )=CatchSmallReward;
    BlockPara{i}.Difficulty( StartRow : EndRow )=CatchDiff;
    BlockPara{i}.BlockOrder( StartRow : EndRow )=repmat(i,length(CatchEffort),1);
    BlockPara{i}.TrialType( StartRow : EndRow )=repmat("Catch",length(CatchEffort),1);
    % random permute trial order in this block
    BlockPara{i}=BlockPara{i}(randperm(size(BlockPara{i},1)) ,:);
    
end
warning on

TrialPara=vertcat(BlockPara{:});

% set small reward to lower bound and upper bound
TrialPara.SmallReward(TrialPara.SmallReward<0.01)=0.01;
TrialPara.SmallReward(TrialPara.SmallReward>=TrialPara.LargeReward)...
    =...
    TrialPara.LargeReward(TrialPara.SmallReward>=TrialPara.LargeReward);

% attach trial order to TrialPara
TrialPara.TrialOrder=[1:size(TrialPara,1)]';
% generate the choice box location (CBLocation)
CBLocation=ones(1,size(TrialPara,1));
CBLocation(1:length(CBLocation)/2)=2;
CBLocation=CBLocation(randperm(length(CBLocation)));
TrialPara.CBLocation=CBLocation';
% add LevelName to TrialPara
for i=1:length(EffortReqName)
    TrialPara.LevelName(TrialPara.EffortReq==EffortReq(i))=EffortReqName(i);
end

%%
Jitter=round(JitterBase+JitterRange*rand(size(TrialPara,1),1),1);
% histogram(Jitter,4,'BinLimits',[2 4])
TrialPara.FixDura=Jitter;
TrialPara.CuePhaseDura=ones(size(TrialPara,1),1)*CuePhaseDura;
TrialPara.DecisionDura=ones(size(TrialPara,1),1)*DecisionDura;
