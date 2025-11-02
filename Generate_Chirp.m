% Generate_Chirp.m
% Author: Ahmed Amin
% Description:
%   Generates an FMCW up-chirp waveform (baseband) using the params struct P.
%   Returns:
%       tx         - complex baseband transmit signal for all sweeps [Ns_total x 1]
%       t_all      - time axis for tx [s]
%       Ns_total   - total number of samples (NumSweeps * Nsweep)

function [tx, t_all, Ns_total] = Generate_Chirp(P)

    % Using MATLAB phased toolbox style object.
    waveform = phased.FMCWWaveform( ...
        'SweepTime',      P.sweep_time, ...
        'SweepBandwidth', P.bw, ...
        'SampleRate',     P.fs, ...
        'SweepDirection', 'Up', ...
        'SweepInterval',  'Symmetric', ...
        'NumSweeps',      P.NumSweeps);

    tx = waveform();          % complex baseband multi-chirp
    Ns_total = numel(tx);
    t_all = (0:Ns_total-1).' / P.fs;
end
