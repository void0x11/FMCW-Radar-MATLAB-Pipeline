% RangeFFT.m
% Author: Ahmed Amin
% Description:
%   Estimates target range from one beat sweep using:
%     1) windowed FFT to get beat frequency peak
%     2) map beat frequency -> range using R = (c * f_b) / (2 * mu)
%
% Inputs:
%   P         - params struct
%   beat_vec  - one column from beatM (complex beat for a single sweep)
%
% Outputs:
%   R_axis        - range axis [m]
%   spectrum_dB   - magnitude spectrum [dB]
%   R_estimate_m  - scalar range estimate [m]
%   fb_est        - estimated beat frequency [Hz]

function [R_axis, spectrum_dB, R_estimate_m, fb_est] = RangeFFT(P, beat_vec)

    % Window to reduce spectral leakage (Hann window)
    xw = beat_vec(:) .* hann(numel(beat_vec));

    % FFT length (zero-padding helps interpolate a cleaner peak)
    Nfft = 131072;
    Y = fft(xw, Nfft);
    Y = Y(1:Nfft/2);  % one-sided

    magY = abs(Y);
    [~, kmax] = max(magY);

    % Frequency axis for the FFT bins
    faxis = (0:(Nfft/2-1)) * (P.fs / Nfft);

    % Basic peak-pick estimate of beat frequency
    fb_est = faxis(kmax);

    % Map beat freq -> range
    % R = (c * f_b) / (2 * mu)
    R_estimate_m = (P.c * fb_est) / (2 * P.mu);

    % Build range axis for plotting spectrum vs range
    R_axis = (P.c * faxis) / (2 * P.mu);

    spectrum_dB = mag2db(magY + eps);
end
