clc
clearvars
TimeBin = 1000; % unit: miliseconds
NumConditions = 2;
FinalDesign = './Finalmodel_2023_11_10_14_46.mat';
GAParaList = './GAworkspace.mat';
load(FinalDesign,"M",'PARAMS')
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
% ==========================DO NOT CHANGE=================================%
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
stimTable.ISI = [stimTable.stimOnset(1)  - ExpParaSets.StimDura; diff(stimTable.stimOnset)];
% Manually Changeing to reduce scanning length, which is useful to insert
% some empty durations at the beginning and the end of experiment
stimTable.ISI(stimTable.ISI == uint32(3000)) = 2500;
stimTable.ISI(stimTable.ISI == uint32(6000)) = 3500;
stimTable.stimOnset = cumsum(stimTable.ISI);


stimTable.stimOffset = stimTable.stimOnset + ExpParaSets.StimDura;
stimTable.TrialStart =  stimTable.stimOnset - stimTable.ISI + (ExpParaSets.StimDura + ExpParaSets.ResponseWindow);
stimTable.TrialStart(1) = 0;
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

PARAMS.contrast_type1 = [1 -1 0];
PARAMS.contrast_type2 = [1 0 -1 0 0];
PARAMS.contrast_type3 = [1 0 0 -1 0 0 0];
OptimParas = s_CalcEfficiency_3types(stimTable,GA,PARAMS);

SaveMatName = strrep(FinalDesign,'Finalmodel','FinalStimTable');
save(SaveMatName,'stimTable')
writetable(stimTable,strrep(SaveMatName,'mat','xlsx'),'Sheet','fMRI_Experiment_Design_Table')
writecell(OptimParas,strrep(SaveMatName,'mat','xlsx'),'Sheet','Optimization_Parameters')

