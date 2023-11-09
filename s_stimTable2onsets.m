function onsets = s_stimTable2onsets(stimTable)

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
%     tmp(:,2) = (stimTable.stimOffset(RowFlag) - stimTable.stimOnset(RowFlag))./1000;
    onsets{i} = double(tmp);
end

end