function ResCell = s_OptfMRI_Calc_Effs(stimTable,GA,PARAMS)
% Calculating design efficiency for three different type of HRF.
% Including SPM: 1) canonical HRF; 2) HRF with time derivatives; 3) HRF
% with time and dispersion derivatives.
% 
% Input:
%   Positional Arguments (Required):
%       stimTable - a stimuli table follows standard OptfMRI format.
%       GA - a struct of generic algorithm settsing, inherits from
%            Canlab-Core's OptimizeDesign11 module.
%       PARAMS - a struct of task-fMRI modelling parameters, inherits from
%               Canlab-Core's Model_building_tools module.
% Output:
%   ResCell - a cell array contains all information about task-fMRI
%               modelling parameters and calculated design efficiency.
% 
% Written by Kunru Song 2023.11.12

fprintf('----------Task Condition Counts----------\n')
tabulate(stimTable.stimType)
fprintf('ISI Mean(SD)[unit] = %.4f (%.4f) [seconds]\n',mean(stimTable.ISI)/1000,std(double(stimTable.ISI))/1000)

onsets = s_stimTable2onsets(stimTable);

fprintf('----------HRF: Canonical HRF (SPM)----------\n')
X = onsets2fmridesign(onsets, GA.TR, GA.scanLength,'hrf');
Eff_type1 = calcEfficiency(1,PARAMS.contrast_type1,pinv(X),[],PARAMS.dflag);
fprintf('Design Efficiency for stimTable = %.4f\n',Eff_type1)
VIF_type1 = getvif(X);
fprintf('VIF = %.4f\n',VIF_type1)

fprintf('----------HRF: Canonical HRF + Time derivative----------\n')
X = onsets2fmridesign(onsets, GA.TR, GA.scanLength,'hrf (with time derivative)');
Eff_type2 = calcEfficiency(1,PARAMS.contrast_type2,pinv(X),[],PARAMS.dflag);
VIF_type2 = getvif(X);

fprintf('Design Efficiency for stimTable = %.4f\n',Eff_type2)
fprintf('VIF = %.4f\n',VIF_type2)

fprintf('----------HRF: Canonical HRF + Time & Dispersion derivatives----------\n')
X = onsets2fmridesign(onsets, GA.TR, GA.scanLength,'hrf (with time and dispersion derivatives)');
Eff_type3 = calcEfficiency(1,PARAMS.contrast_type3,pinv(X),[],PARAMS.dflag);
VIF_type3 = getvif(X);
fprintf('Design Efficiency for stimTable = %.4f\n',Eff_type3)
fprintf('VIF = %.4f\n',VIF_type3)


ResTable = array2table([Eff_type1;Eff_type2;Eff_type3;], ...
    "VariableNames",{'DesignEfficiency'});
ResTable.HRF_Type = {'Canonical HRF (SPM basis set)';...
    'Canonical HRF + Time Derivatives';...
    'Canonical HRF + Time & Dispersion Derivatives'};
ResTable.VIF = {VIF_type1;VIF_type2;VIF_type3};
ResTable = movevars(ResTable,'HRF_Type','Before','DesignEfficiency');
TR = sprintf('%dms',PARAMS.TR*1000);
ISI = sprintf('Target: %dms; Actual: %.4f (%.4f)s',PARAMS.ISI*1000,mean(stimTable.ISI)/1000,std(double(stimTable.ISI))/1000);
HP = sprintf('%ds (%.5fH)z',GA.HPlength,1/GA.HPlength);
nonlinthresh = sprintf('%d times the unit HRF height',GA.nonlinthreshold);
AutoCorr = sprintf('Top five lags: %.2f %.2f %.2f %.2f %.2f',GA.xc(1:5));
TargetContrast = sprintf('%.2f*[(%d) + (%d) + (%d)]',PARAMS.contrastweights,PARAMS.contrast_type1);
TargetFitness = sprintf(['%.2f* Counter-balancing deviation + ' ...
    '%.2f * Contrast detection efficiency + ' ...
    '%.2f * HRF shape estimation efficiency + ' ...
    '%2.f * Input frequnecies deiviation'],...
    GA.cbalColinPowerWeights);
Constraint = sprintf('Counterbalancing Deviation: %.4f; Input Frequencies Deviation: %.4f', ...
    GA.maxCbalDevthresh,GA.maxFreqDevthresh);
ResCell = [ResTable.Properties.VariableNames;...
    table2cell(ResTable);...
    {'fMRI Scanning Settings'},{[]},{[]};...
    {'TR'},{TR},{[]};...
    {'fMRI Auto-correlation'},{AutoCorr},{[]};...
    {'HRF Saturation Threshold'},{nonlinthresh},{[]};...
    {'ISI (Mean[SD])'},{ISI},{[]};...
    {'GLM Modelling Settings'},{[]},{[]};...
    {'High-pass filter'},{HP},{[]};...
    {'Target Contrast Formula'},{TargetContrast},{[]};...
    {'Automatic Optimazation Settings'},{[]},{[]};...
    {'Target Fitness Formula'},{TargetFitness},{[]};...
    {'Max Number of Generations'},{GA.numGenerations},{[]};...
    {'Size of Generations'},{GA.sizeGenerations},{[]};...
    {'Max Time of Optimization'},{GA.maxTime},{[]};...
    {'Hard Constraint'},{Constraint},{[]};];

end