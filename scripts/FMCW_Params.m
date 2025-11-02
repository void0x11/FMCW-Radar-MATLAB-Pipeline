% FMCW_Params.m
% Author: Ahmed Amin
% Description:
%   Centralized parameter file for the FMCW radar simulation.
%   Defines physical constants, waveform settings, scenario values,
%   and derived quantities like chirp slope and expected beat frequency.

function P = FMCW_Params()

    % Physical constants
    P.c  = 3e8;              % speed of light [m/s]

    % Radar / carrier settings
    P.fc = 5.8e9;            % carrier frequency [Hz]
    P.lambda = P.c / P.fc;   % wavelength [m]

    % Scenario (single point target for demo)
    P.range_true   = 37;     % [m]
    P.velocity_true= 50;     % [m/s] radial (toward +x)
    P.SNR_dB       = 5;      % AWGN level after LNA, demo value

    % Coverage / design
    P.Rmax       = 100;                     % desired max range [m]
    P.Ts_min     = (2*P.Rmax)/P.c;          % min sweep time to avoid ambiguity
    P.bw         = 150e6;                   % sweep bandwidth [Hz]
    P.fs         = 2*P.bw;                  % ADC sample rate [Hz]
    P.sweep_time = 5 * P.Ts_min;            % sweep duration [s]
    P.NumSweeps  = 128;                     % number of chirps in a CPI window

    % Derived slope and beat frequency
    P.mu       = P.bw / P.sweep_time;       % chirp slope [Hz/s]
    P.fb_true  = P.mu * (2*P.range_true/P.c);  % ideal beat freq [Hz]

    % Helpful secondary values
    P.Nsweep   = round(P.sweep_time * P.fs);   % samples per chirp
    P.PRI      = P.sweep_time;                 % Pulse Repetition Interval ~ sweep_time
    P.IF_FMAX  = 50e6;                         % conceptual IF cap for realism

    % LNA gain (scalar)
    P.LNA_gain = 1e3;   % ~60 dB, arbitrary scaling

end
