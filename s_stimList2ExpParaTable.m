clearvars
TimeBin = 1000; % unit: miliseconds
NumConditions = 2;
FinalDesign = './Finalmodel_2023_10_28_22_09.mat';
GAParaList = './GAworkspace.mat';
load(FinalDesign,"M",'P')
load(GAParaList,'GA')

ConditionNumber = [1 2]';
ConditionName = {'Go','Nogo'}';
StimDura = 500;
CondTable = table(ConditionNumber,ConditionName);
ExpParaSets = struct('Cond',CondTable, ...
    'TimeBin',TimeBin, ...
    'NumCond',NumConditions, ...
    'StimDura',StimDura, ...
    'ResponseWindow',0);

stimList = M.stimlist;
TheFirstTrial = find(stimList ~= 0);
TrialOnset = max(TheFirstTrial(1) - 1,1)*ExpParaSets.TimeBin * GA.ISI;
stimOnset_Raw = sampleInSeconds(stimList,GA.ISI);
stimTable = table();
for i = 1:size(ExpParaSets.Cond,1)
    % change unit from .1 seconds to 1 seconds
    stimOnset = find(stimOnset_Raw == i)./10; % the default time bin is 0.1 seconds
    % the fisrt element in a vector strats from 1, it should be changed to 0
    stimOnset = (stimOnset - 0.1).*ExpParaSets.TimeBin + TrialOnset;
    stimOnset = uint32(stimOnset);
    stimType = repmat(ExpParaSets.Cond.ConditionName(i),length(stimOnset),1);
    tmp = table(stimType,stimOnset);
    if ~exist('stimTable','var')
        stimTable = tmp;
    else
        stimTable = [stimTable; tmp];
        stimTable = sortrows(stimTable,"stimOnset");
    end
end

stimTable.TrialNo = (1:height(stimTable))';
stimTable.ISI = [stimTable.stimOnset(1); diff(stimTable.stimOnset)];
stimTable.stimOffset = stimTable.stimOnset + ExpParaSets.StimDura;


stimTable.TrialStart =  stimTable.stimOnset - stimTable.ISI + (ExpParaSets.StimDura + ExpParaSets.ResponseWindow);
stimTable.TrialStart(1) = 0;
% stimTable.TrialStart(2:end) = stimTable.TrialStart(2:end) + TrialOnset;
stimTable.TrialEnd = stimTable.stimOffset + ExpParaSets.ResponseWindow;

stimTable.JitterDura = stimTable.stimOnset - stimTable.TrialStart;
stimTable.TrialDura = stimTable.TrialEnd - stimTable.TrialStart;

stimTable = movevars(stimTable,'TrialNo','Before',1);
stimTable = movevars(stimTable,'stimType','After','TrialNo');
stimTable = movevars(stimTable,'ISI','After','stimType');
stimTable = movevars(stimTable,'TrialStart','After','ISI');
stimTable = movevars(stimTable,'JitterDura','After','TrialStart');
stimTable = movevars(stimTable,'stimOnset','After','JitterDura');
stimTable = movevars(stimTable,'stimOffset','After','stimOnset');
stimTable = movevars(stimTable,'TrialEnd','After','stimOffset');
stimTable = movevars(stimTable,'TrialDura','After','TrialEnd');
%% 
% ValidCheck = sum((stimTable.TrialStart + stimTable.ISI + ExpParaSets.StimDura + ExpParaSets.ResponseWindow) == stimTable.TrialEnd);
% if ValidCheck ~= height(stimTable)
%     error('Can not pass the stimuli time-series validation check!')
% end
tabulate(stimTable.stimType)
fprintf('ISI Mean(SD)[unit] = %.4f (%.4f) [seconds]\n',mean(stimTable.ISI)/1000,std(double(stimTable.ISI))/1000)

% designvector2model

onsets = s_stimTable2onsets(stimTable);
% numsamps = ceil(GA.scanLength/GA.TR);
fprintf('----------HRF: Canonical HRF (SPM)----------\n')
X = onsets2fmridesign(onsets, GA.TR, GA.scanLength,'hrf');
% X = [X;[0,0,1]];
% HRF = spm_hrf(.1);
% HRF = HRF/ max(HRF);
% [~, Vi,~] = getSmoothing(GA.HPlength,GA.LPsmooth,GA.TR,P.numsamps,GA.xc);
% P.contrasts = [GA.contrasts 0];
% P.S = S;
% P.Vi = Vi;
% P.HRF = HRF;
% P.ISI = GA.ISI;
% P.TR = GA.TR;
% eff = efficency(X,P);
stimTableEfficiency = calcEfficiency(P.contrastweights,P.contrasts,pinv(X),[],P.dflag);
fprintf('Design Efficiency for stimTable = %.4f\n',stimTableEfficiency)
fprintf('VIF = %.4f\n',getvif(X))
fprintf('----------HRF: Canonical HRF + Time derivative----------\n')
X = onsets2fmridesign(onsets, GA.TR, GA.scanLength,'hrf (with time derivative)');
stimTableEfficiency = calcEfficiency(1,[1 0 -1 0 0],pinv(X),[],P.dflag);
fprintf('Design Efficiency for stimTable = %.4f\n',stimTableEfficiency)
fprintf('VIF = %.4f\n',getvif(X))
fprintf('----------HRF: Canonical HRF + Time derivative----------\n')
X = onsets2fmridesign(onsets, GA.TR, GA.scanLength,'hrf (with time and dispersion derivatives)');
stimTableEfficiency = calcEfficiency(1,[1 0 0 -1 0 0 0],pinv(X),[],P.dflag);
fprintf('Design Efficiency for stimTable = %.4f\n',stimTableEfficiency)
fprintf('VIF = %.4f\n',getvif(X))

SaveMatName = strrep(FinalDesign,'Finalmodel','FinalStimTable');
save(SaveMatName,'stimTable')
writetable(stimTable,strrep(SaveMatName,'mat','xlsx'))

% [y,x] = sFFT(model(:,2),1/GA.TR);
% plot(x,y)
