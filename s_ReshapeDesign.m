clc
clearvars
ExpectedCondtionNum = [105 35];
TimeBin = 1000; % unit: miliseconds
NumConditions = 2;
OptimizedDesign = './model1_10-28-2023.mat';
GAParaList = './GAworkspace.mat';
load(OptimizedDesign,"M")
load(GAParaList,'GA')
PARAMS = load('./model1_10-28-2023_auxpara.mat');

[Efficiency,TrialStats] = s_OptimDesign_DispStimList(StimList,PARAMS);

NumToBeReplaced = TrialStats(:,2)' - ExpectedCondtionNum;
if all(NumToBeReplaced < 0)
    ReloadFlag = true;
else
    ReloadFlag = false;
    ReduantTrials = [0; diff(M.stimlist)];% find the second trial in two consequently repeated trials
    DuplicatedTrialsLoc = nan(length(M.stimlist),NumConditions);
    for i=1:NumConditions
        DuplicatedTrialsLoc(:,i) = (ReduantTrials == 0) & (M.stimlist == i);
    end
end
rng shuffle

FinalEfficiency = 0;
IterCounts = 1;
while FinalEfficiency < InitialEfficiency - 2.4
    load(OptimizedDesign,"M")
    if ReloadFlag
        M.stimlist = repmat(M.stimlist,2,1);
        TrialStats = tabulate(M.stimlist);
        TrialStats(1,:) = [];
        ReduantTrials = [0; diff(M.stimlist)];% find the second trial in two consequently repeated trials
        DuplicatedTrialsLoc = nan(length(M.stimlist),NumConditions);
        for i=1:NumConditions
            DuplicatedTrialsLoc(:,i) = (ReduantTrials == 0) & (M.stimlist == i);
        end
        NumToBeReplaced = TrialStats(:,2)' - ExpectedCondtionNum;
    end
    fprintf('# Iter %d \n',IterCounts)
    tabulate(M.stimlist)
    for i=1:NumConditions
        ReplaceLoc = find(DuplicatedTrialsLoc(:,i));
        if length(ReplaceLoc) > NumToBeReplaced(i)
            ReplaceTrialIndex = randsample(ReplaceLoc,NumToBeReplaced(i),false);
            M.stimlist(ReplaceTrialIndex) = 0;
        else
            ReplaceTrialIndex = ReplaceLoc;
            M.stimlist(ReplaceTrialIndex) = 0;
            TrialStats_New = tabulate(M.stimlist);
            TrialStats_New(TrialStats_New(:,1) == 0,:) = [];
            NumToBeReplaced_New = TrialStats_New(:,2)' - ExpectedCondtionNum;
            DiffValue_New = [0; diff(M.stimlist)];
            % If consecutive pattern is "condition 2, condition 1", the diff
            % value would be -1, combined with value 1 in the corresponding
            % element located in the M.stimlist.
            % If consecutive pattern is "condition 1, condition 2", the diff
            % value would be 1, combined with value 2 in the corresponding
            % element located in the M.stimlist
            ConsecutiveTrials = ( ((DiffValue_New == -1) & M.stimlist == 1) | ...
                ((DiffValue_New ==  1) & M.stimlist == 2) ) & ...
                (M.stimlist == i);
            ConsecutiveTrials = find(ConsecutiveTrials);
            if length(ConsecutiveTrials) > NumToBeReplaced_New(i)
                ReplaceTrialIndex = randsample(ConsecutiveTrials,NumToBeReplaced_New(i),false);
            else
                ReplaceTrialIndex = ConsecutiveTrials;
            end
            M.stimlist(ReplaceTrialIndex) = 0;
            TrialStats_New = tabulate(M.stimlist);
            TrialStats_New(TrialStats_New(:,1) == 0,:) = [];
            NumToBeReplaced_New = TrialStats_New(:,2)' - ExpectedCondtionNum;
            if NumToBeReplaced_New(i) > 0
                ReplaceTrialIndex = randsample(find(M.stimlist==i),NumToBeReplaced_New(i),false);
                M.stimlist(ReplaceTrialIndex) = 0;
            end
            %         NumToBeReplaced_Step2 = ExpectedCondtionNum(i)
        end
        tabulate(M.stimlist)
    end
    model = designvector2model(M.stimlist,P.ISI,P.HRF,GA.TR,P.numsamps,P.nonlinthreshold,P.S);
    xtxitx = pinv(model);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
    FinalEfficiency = calcEfficiency(P.contrastweights,[GA.contrasts 0],xtxitx,P.svi,P.dflag);
    fprintf('Design Efficiency = %.2f \n',FinalEfficiency)
    %     numStim = ceil(GA.scanLength / (GA.ISI));
    %     if ~isfield(GA,'LPsmooth'),GA.LPsmooth = 1; end
    %     numsamps = ceil(numStim*GA.ISI/GA.TR);
    %     HRF = spm_hrf(.1);
    %     HRF = HRF/ max(HRF);
    %     [S, ~, svi] = getSmoothing(GA.HPlength,GA.LPsmooth,GA.TR,numsamps,GA.xc);
    %     model = designvector2model(M.stimlist,GA.ISI,HRF,GA.TR,numsamps,GA.nonlinthreshold,S);
    %     xtxitx = pinv(model);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
    %     FinalEfficiency = calcEfficiency([],[],xtxitx,svi,0);
    IterCounts = IterCounts + 1;
end
fprintf('------------outputs------------\n')
tabulate(M.stimlist)

save(sprintf('Finalmodel_%s.mat', ...
    datetime('now','TimeZone','Asia/Hong_Kong','Format','yyyy_MM_dd_HH_mm')), ...
    'M','FinalEfficiency','P')

