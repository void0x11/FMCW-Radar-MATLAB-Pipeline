% RangeDopplerFFT.m
% Author: Ahmed Amin
% Description:
%   Builds a simple Range-Doppler map from multiple sweeps:
%     - FFT along fast-time (range dimension)
%     - FFT along slow-time (Doppler dimension)
%   Returns magnitude map in dB plus axes.
%
% Inputs:
%   P      - params
%   beatM  - [Nsweep x Nchirps] matrix of dechirped beats
%   idx_up - indices of up-chirps (useful to keep chirp direction consistent)
%
% Outputs:
%   RDdB      - Range-Doppler magnitude map [dB]
%   rng_axis  - range axis [m]
%   dop_axis  - Doppler frequency axis [Hz]

function [RDdB, rng_axis, dop_axis] = RangeDopplerFFT(P, beatM, idx_up)

    % Use only UP sweeps for Doppler consistency
    M = beatM(:, idx_up);

    % Windowing in both dimensions
    win_fast = hann(size(M,1));
    win_slow = hann(size(M,2)).';

    Mwin = (M .* win_fast) .* win_slow;

    % FFT sizes (can be tuned)
    Nf = 2048;      % fast-time FFT (range)
    Ns = 128;       % slow-time FFT (Doppler)

    RD = fftshift( fft( fft(Mwin, Nf, 1), Ns, 2), 2 );
    RDmag = abs(RD) + eps;
    RDdB = mag2db(RDmag);

    % Range axis from beat frequency bins
    f_range = (0:Nf-1) * (P.fs / Nf);            % beat freq bins
    rng_axis = (P.c * f_range) / (2 * P.mu);     % map beat freq -> range [m]

    % Doppler axis from slow-time FFT bins
    dop_axis = ((-Ns/2):(Ns/2-1)) * (1 / (Ns * P.PRI)); % [Hz]
end
