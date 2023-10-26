function [X, e] = ER_simulate(TR, ons, HPlength, dononlin, scanLength,contrasts,varargin)
% Create and plot design for one or more event types
%
% % :Usage:
% ::
%
% [X, e, ons] = create_random_er_design(TR, ISI, eventduration, freqConditions, HPlength, dononlin, varargin)
%
%
% :Inputs:
%
% Enter all values in sec:
% TR = time repetition for scans
% ISI = inter-stimulus interval
% eventduration = duration in sec of events
% freqConditions = vector of frequencies of each event type, e.g. [.2 .2 .2] for 3 events at 20% each (remainder is rest)
%   - do not have to sum to one
%
% HPlength is high-pass filter length in sec, or Inf or [] for no filter.
%
% :Outputs:
%
%   **X:**
%        design matrix, sampled at TR. [images x regressors]
%        Intercept is added as last column.
%
%   **e:**
%        design efficiency
%
%   **ons:**
%        A cell array of onsets and durations (in seconds) for each event
%        type. ons{1} corresponds to Condition 1, ons{2} to Condition 2,
%        and so forth. ons{i} can be an [n x 2] array, where the first
%        column is onset time for each event, and the second column is the event duration
%        (in sec)
%
% Examples:
% create_figure;
% [X, e] = create_random_er_design(1, 1.3, 1, [.2 .2], 180, 0);
% axis tight

% -------------------------------------------------------------------------
% DEFAULT ARGUMENT VALUES
% -------------------------------------------------------------------------
if nargin <= 4
    scanLength = 200; % in sec
end
% -------------------------------------------------------------------------
% OTHER FIXED INPUTS
% -------------------------------------------------------------------------


if ~isempty(HPlength) && ~isinf(HPlength), dohpfilt = 1; else dohpfilt = 0; end

if dononlin
    nonlinstr = 'nonlinsaturation';
else
    nonlinstr = 'nononlin';
end

% Build Design Matrix
% ----------------------------------------------------------------
% plotDesign(ons,[], TR, 'samefig', nonlinstr); % Redundant: 'durs', 1,
% set(gca, 'XLim', [0 scanLength], 'XTick', round(linspace(0, scanLength, 10)));
X = onsets2fmridesign(ons, TR, scanLength, 'hrf', nonlinstr,varargin{:});

% high-pass filtering
if dohpfilt
    
    X(:, 1:end-1) = hpfilter(X(:, 1:end-1), TR, HPlength, round(scanLength ./ TR));
    
end

 
% Create contrasts
% ----------------------------------------------------------------
if isempty(contrasts)
    contrasts = create_orthogonal_contrast_set(size(X,2)-1);
    contrasts(:, end+1) = 0; % for intercept
end
% Test efficiency
% ----------------------------------------------------------------

e = calcEfficiency(ones(1, size(contrasts, 1)), contrasts, pinv(X), []);

% related to (same as without contrasts, autocorr, filtering):
% 1 ./ diag(inv(X' * X))


end % function




