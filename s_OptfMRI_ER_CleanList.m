function TrialStats = s_OptfMRI_ER_CleanList(stimList)
% Remove empty trials in a stimuli list
% As default, remove thoese with condition number equals to zero.
% 
% Input:
%   Positional Arguments (Required):
%       stimList - a numeric vector contains the order and sequence of task
%                   stimuli, inherits from Canlab-Core's OptimizeDesign11
%                   module.
% Output:
%   TrialStats - a tabulated statistic matrix about condition number after
%               removing empty trials.
% 
% Written by Kunru Song 2023.11.10

TrialStats = array2table(tabulate(stimList),...
    'VariableNames',{'Condition_Number','Counts','Percentage'});
TrialStats(TrialStats.Condition_Number == 0,:) = [];
disp(TrialStats)
end