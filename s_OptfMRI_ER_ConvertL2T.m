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
stimOnset_Raw = sampleInSeconds(stimList,GA.ISI);% the default time bin is 0.1 seconds
stimTable = table();
for i = 1:size(ExpParaSets.Cond,1)
    % change unit from .1 seconds to 1 seconds
    stimOnset = find(stimOnset_Raw == i)./10; 
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


PARAMS.contrast_type1 = [1 -1 0];
PARAMS.contrast_type2 = [1 0 -1 0 0];
PARAMS.contrast_type3 = [1 0 0 -1 0 0 0];

OptimParas = s_OptfMRI_Calc_Effs(stimTable,GA,PARAMS);

SaveMatName = strrep(FinalDesign,'Finalmodel','FinalStimTable');
save(SaveMatName,'stimTable')
SaveExcelName = strrep(SaveMatName,'mat','xlsx');

writetable(stimTable,SaveExcelName,'Sheet','fMRI_Experiment_Design_Table')
writecell(OptimParas,SaveExcelName,'Sheet','Optimization_Parameters')

