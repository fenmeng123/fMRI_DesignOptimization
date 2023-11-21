function [Efficiency,TrialStats] = s_OptfMRI_ER_DispList(stimList,PARAMS,varargin)
% Display the Stimuli List in a table and calculate design efficiency.
% 
% 
% 
% Written by Kunru Song 2023.10.29
% Updated by Kunru Song 2023.11.10

[p,PARAMS] = s_DispStimList_ParseInput(stimList,PARAMS);
stimList = p.Results.StimList;
TrialStats = array2table(tabulate(stimList),...
    'VariableNames',{'Condition_Number','Counts','Percentage'});
disp(TrialStats);
model = designvector2model(stimList,...
    PARAMS.ISI,PARAMS.HRF,PARAMS.TR,...
    PARAMS.numsamps,PARAMS.nonlinthreshold,PARAMS.S);
xtxitx = pinv(model);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
Efficiency = calcEfficiency(PARAMS.contrastweights,PARAMS.contrasts, ...
    xtxitx, ...
    PARAMS.svi,PARAMS.dflag);
fprintf('Design Efficiency = %.2f \n',Efficiency)
end



function [p,PARAMS] = s_DispStimList_ParseInput(stimList,PARAMS)
% Parse the input of s_OptfMRI_Disp_stimList
if ~isvector(stimList)
    error('Input StimList must be a vector.');
end
if ~isstruct(PARAMS)
    error('Input PARAMS must be a struct.');
end
p = inputParser;
addRequired(p,'StimList',@isvector);
addRequired(p,'PARAMS',@isstruct);
parse(p,stimList,PARAMS);
PARAMS = validatePARAMS(p.Results.PARAMS);
end



function PARAMS = validatePARAMS(PARAMS)
if ~isfield(PARAMS,'ISI')
    warning('The ISI has not been clarified! Using 1 seconds as default.')
    PARAMS.ISI = 1;
elseif isempty(PARAMS.ISI)
    warning('Input ISI is empty! Using 1 seconds as default.')
    PARAMS.ISI = 1;
end
if ~isfield(PARAMS,'TR')
    warning('The TR has not been clarified! Using 2 seconds as default.')
    PARAMS.TR = 2;
elseif isempty(PARAMS.TR)
    warning('Input TR is empty! Using 2 seconds as default.')
    PARAMS.TR = 2;
end
if ~isfield(PARAMS,'nonlinthreshold')
    warning('The nonlinthreshold has not been clarified! Using 2 as default.')
    PARAMS.nonlinthreshold = 2;
elseif isempty(PARAMS.nonlinthreshold)
    warning('Input nonlinthreshold is empty! Using 2 as default.')
    PARAMS.nonlinthreshold = 2;
end
if ~isfield(PARAMS,'dflag')
    warning('The dflag has not been clarified! Using 2 as default.')
    PARAMS.dflag = 0;
elseif isempty(PARAMS.dflag)
    warning('Input dflag is empty! Using 2 as default.')
    PARAMS.dflag = 0;
end
if ~isfield(PARAMS,'numsamps') || ~isfield(PARAMS,'contrastweights') ||...
        ~isfield(PARAMS,'S') || ~isfield(PARAMS,'svi') ||...
        ~isfield(PARAMS,'HRF') || ~isfield(PARAMS,'contrasts')
    error('One of the numsamps, contrasts, contrastweights, S, svi, and HRF does not exist! Check your input!')
elseif isempty(PARAMS.numsamps) || isempty(PARAMS.contrastweights) ||...
        isempty(PARAMS.S) || isempty(PARAMS.svi) ||...
        isempty(PARAMS.HRF) || isempty(PARAMS.contrasts)
    error('One of the numsamps, contrasts, contrastweights, S, svi, and HRF is empty! Check your input!')
end
end