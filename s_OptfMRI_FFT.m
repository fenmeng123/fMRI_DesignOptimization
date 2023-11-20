function [y,X_Freq]=s_FFT(TimeSeries,SampleRate,varargin)
% [y,X_Freq]=s_FFT(TimeSeries,SampleRate,varargin)
% Fast Fourier Transformation for fMRI Design Matrix Analysis
%
% Input:
%   Positional Arguments (Required):
%       TimeSerires - a vector for reocrded time series, that is, a column
%                       in the generated design matrix.
%       SampleRate  - the sampling rate for time series, in Hz, (i.e. 1/TR)
% 
%   Key-value Pairs Arguments (Optional):
%       'FFTshift'  - logical, flag controls the X-axis shifting for FFT
%                       Default is true
%       'Windowing' - logical, flag controls the application of Hanning 
%                       window, which aims to prevent frequnecy leakage.
%                       Default is false
%       'Spectrum'  - string, 'Power' or 'Magnitude', which determines type
%                       of the output frequency spectrum.
%                       Default is 'Power'
% 
% Output:
%   y - the y-axis value for frequency spectrum
%   X_Freq - the x-axis value for frequency spectrum
%
% Written by Kunru Song 2021.12.23
% Updated by Kunru Song 2023.10.29
% Annotation added by Kunru Song 2023.11.10
% Updated by Kunru Song 2023.11.20

p = s_FFT_ParseInput(TimeSeries,SampleRate,varargin{:});
TimeSeries = p.Results.TimeSeries;
SampleRate = p.Results.SampleRate;
FFTshift = p.Results.FFTshift;
Windowing = p.Results.Windowing;
Spectrum = p.Results.Spectrum;
% Before performing the FFT, it's often beneficial to apply a window
% function to the time series data to reduce spectral leakage.
% Common choices include the Hamming or Hann window.
% This step is not required, but can sometimes improve the quality of
% the frequency-domain representation, depending on the nature of
% the time series data.
if Windowing
    window = hann(length(TimeSeries));  % Create a Hann window
    TimeSeries = TimeSeries .* window;  % Apply the window to TimeSeries
end
% To ensure the length of TimeSeries is a power of 2,
% zero-padding will be implemented to the input TimeSeries, if necessary.
% This will improve the efficiency of the FFT calculation.
n = 2^nextpow2(length(TimeSeries));  % Find the next power of 2
TimeSeries = [TimeSeries; zeros(n - length(TimeSeries), 1)];  % Zero pad TimeSeries
fs = SampleRate;
y = fft(TimeSeries);

if FFTshift
    n = length(TimeSeries);
    X_Freq = (-n/2:n/2-1)*(fs/n);
    y = fftshift(y);
else
    X_Freq = (0:length(y)-1)*fs/length(y);
end

switch Spectrum
    case 'Magnitude'
        y = abs(y);
    case 'Power'
        y = abs(y).^2/n;
end



end

function p = s_FFT_ParseInput(TimeSeries,SampleRate,otherInputs)
% Parse the input of s_FFT
if ~isvector(TimeSeries)
    error('Input TimeSeries must be a vector.');
end
if ~isscalar(SampleRate)
    error('Input SampleRate must be a scalar.');
end
p = inputParser;
addRequired(p,'TimeSeries',@(x)isvector(x));
addRequired(p,'SampleRate',@(x)isdouble(x));
addParameter(p,'FFTshift',true,@(x)islogical(x));
addParameter(p,'Windowing',false,@(x)islogical(x));
addParameter(p,'Spectrum','Power', @(x) any(validatestring(x,{'Power','Magnitude'})));
parse(p,TimeSeries,SampleRate,otherInputs);
end
