% Run_Demo.m
% Author: Ahmed Amin
% Description:
%   High-level script that runs the full FMCW radar processing chain:
%     1. Load parameters
%     2. Generate FMCW waveform
%     3. Simulate target return (range + radial velocity + AWGN)
%     4. Mix Tx/Rx to form beat signal per chirp
%     5. Estimate range from a single sweep using FFT
%     6. Build and plot range-Doppler map for visualization
%
%   This script is meant as an educational pipeline showing practical
%   radar DSP steps. It is not tied to proprietary data or hardware logs.

clc; clear; close all;

%% 1) Parameters
P = FMCW_Params();

fprintf('--- FMCW Radar Demo ---\n');
fprintf('Carrier freq: %.2f GHz\n', P.fc/1e9);
fprintf('Sweep BW: %.1f MHz\n', P.bw/1e6);
fprintf('Chirp time: %.3e s\n', P.sweep_time);
fprintf('Samples/chirp: %d\n', P.Nsweep);
fprintf('True range: %.2f m | True velocity: %.2f m/s\n', ...
    P.range_true, P.velocity_true);
fprintf('Expected ideal beat freq: %.3f MHz\n\n', P.fb_true/1e6);

%% 2) Generate transmit chirps
[tx_all, t_all, Ns_total] = Generate_Chirp(P); %#ok<NASGU>

%% 3) Simulate target scene (one moving point target in free space)
[rx1d, tx1d, t_rx] = Sim_TargetScene(P, tx_all); %#ok<NASGU>

%% 4) Mix to get beat signals per chirp
[beatM, t_fast, idx_up] = Mixer_IFBeat(P, tx1d, rx1d);

% For range estimation, just take one UP sweep (e.g. middle one)
mid_idx = idx_up(round(numel(idx_up)/2));
beat_one = beatM(:, mid_idx);

%% 5) Range estimation via FFT
[R_axis, spectrum_dB, R_estimate_m, fb_est] = RangeFFT(P, beat_one);

fprintf('Estimated beat frequency: %.3f MHz\n', fb_est/1e6);
fprintf('Estimated range: %.3f m (true %.3f m)\n\n', ...
    R_estimate_m, P.range_true);

%% 6) Doppler / Range-Doppler map (visual only)
[RDdB, rng_axis, dop_axis] = RangeDopplerFFT(P, beatM, idx_up);

%% 7) Plots
% 7a) Time-domain view of Rx (first 2000 samples)
figure('Name','Rx time-domain (first samples)');
samples_plot = min(2000, numel(rx1d));
plot(t_rx(1:samples_plot)*1e6, real(rx1d(1:samples_plot))/max(abs(rx1d)));
grid on;
xlabel('Time (\mus)');
ylabel('Rx (norm)');
title('Received signal (time domain, normalized)');

% 7b) Range spectrum (1D FFT result)
figure('Name','Range Spectrum (Single Chirp)');
plot(R_axis, spectrum_dB, 'LineWidth',1.2); grid on;
xlabel('Range (m)');
ylabel('Magnitude (dB)');
title(sprintf('Range FFT (Estimated R = %.2f m)', R_estimate_m));

% 7c) Range-Doppler map
figure('Name','Range-Doppler Map');
imagesc(dop_axis, rng_axis, RDdB);
axis xy;
xlabel('Doppler (Hz)');
ylabel('Range (m)');
title('Range-Doppler magnitude [dB]');
colorbar;
