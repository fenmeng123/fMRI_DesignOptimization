function onsets = s_stimTable2onsets(stimTable)
% Convert a Stimuli Table into an onset cell.
% 
% Input:
%   stimTable - a MATLAB table that follows the standard format in README
%               At least two columns are required in the input table.
%               "stimType" and "stimOnset"
% Output:
%   onsets -    The standard cell format onset data that is accpetable by 
%               scripts from Canlab-core.
% 
% 
% Written by Kunru Song 2023.10.29

ConditionName = unique(stimTable.stimType);
NumConditions = length(ConditionName);
onsets = cell(1,NumConditions);
%   **onsets:**
%        - 1st column is onsets for events in seconds,
%        - 2nd column is optional durations for each event
%        - Enter single condition or cell vector with cells for each condition (each event type).
for i = 1:NumConditions
    clearvars tmp
    RowFlag = strcmp(stimTable.stimType,ConditionName(i));
    tmp(:,1) = stimTable.stimOnset(RowFlag)./1000;
    onsets{i} = double(tmp);
end

end