function TrialStats = s_RemoveEmptyTrials(stimList)
% Remove the empty trials in a stimuli list
% 
% As default, remove thoese with condition number equals to zero.
% Written by Kunru Song 2023.11.10

TrialStats = array2table(tabulate(stimList),...
    'VariableNames',{'Condition_Number','Counts','Percentage'});
TrialStats(TrialStats.Condition_Number == 0,:) = [];
disp(TrialStats)
end