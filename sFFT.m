function [y,X_Freq]=sFFT(TimeSeries,SampleRate,varargin)
% Fast Fourier Transformation
% 
% Input:
% TimeSerires - a vector for reocrded time series
% SampleRate - the sampling rate for time series, in Hz, (i.e. 1/TR)
% 
% Output:
% y - the y-axis value for frequency spectrum
% X_Freq - the x-axis value for frequency spectrum
% 
% Written by Kunru Song 2021.12.23
pnames = {'FFTshift', 'Spectrum'};
dflts =  {true      , 'Magnitude' };

[FFTshift,Spectrum] = internal.stats.parseArgs(pnames, dflts, varargin{:});


y = fft(TimeSeries);
fs = SampleRate;

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