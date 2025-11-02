% Sim_TargetScene.m
% Author: Ahmed Amin
% Description:
%   Simulates a single moving point target in free space:
%   - Transmit through radiator
%   - Propagate two-way path
%   - Reflect off target with given RCS
%   - Collect at receiver
%   Adds AWGN at specified SNR.
%
% Inputs:
%   P      - parameter struct from FMCW_Params()
%   tx     - complex baseband transmit signal for all sweeps
%
% Outputs:
%   rx1d   - received complex baseband signal (after LNA + noise), column vector
%   tx1d   - transmit signal truncated/matched to rx1d
%   t_rx   - time axis for rx1d [s]

function [rx1d, tx1d, t_rx] = Sim_TargetScene(P, tx)

    % Example RCS at this band (not from any proprietary dataset)
    rcs_val = 0.020;   % [m^2], arbitrary illustrative value

    % Radar/target objects (phased toolbox style)
    target_obj  = phased.RadarTarget('MeanRCS',rcs_val,'OperatingFrequency',P.fc);
    channel_obj = phased.FreeSpace('OperatingFrequency',P.fc, ...
                                   'TwoWayPropagation',true, ...
                                   'SampleRate',P.fs);

    % Motion (target moving along +x with radial velocity)
    target_motion = phased.Platform( ...
        'InitialPosition', [P.range_true;0;0], ...
        'Velocity',        [P.velocity_true;0;0]);

    radar_motion  = phased.Platform( ...
        'InitialPosition', [0;0;0], ...
        'Velocity',        [0;0;0]);

    collector_obj   = phased.Collector('OperatingFrequency',P.fc);
    radiator_obj    = phased.Radiator('OperatingFrequency',P.fc);
    transmitter_obj = phased.Transmitter('PeakPower',1,'Gain',30);

    % Angle between radar and target (for radiator/collector pattern calc)
    % We'll just grab final positions to estimate broadside angle.
    [tgt_pos, tgt_vel]     = target_motion(P.sweep_time);
    [radar_pos, radar_vel] = radar_motion(P.sweep_time);
    [~, ang] = rangeangle(tgt_pos, radar_pos);

    % Transmit chain -> free space -> target -> back
    tx_pwr      = transmitter_obj(tx);
    tx_radiated = radiator_obj(tx_pwr, ang);
    prop_sig    = channel_obj(tx_radiated, radar_pos, tgt_pos, radar_vel, tgt_vel);
    rx_clean    = target_obj(prop_sig);
    rx_collected= collector_obj(rx_clean, ang);

    % Simple LNA gain
    rx_gain = rx_collected * P.LNA_gain;

    % Add AWGN to simulate noise figure + environment
    rx_noisy = awgn(rx_gain, P.SNR_dB, 'measured');

    % Match lengths: some toolboxes can return slightly different lengths
    tx1d = tx(:);
    rx1d = rx_noisy(:);

    L = min(numel(tx1d), numel(rx1d));
    tx1d = tx1d(1:L);
    rx1d = rx1d(1:L);

    t_rx = (0:L-1).' / P.fs;
end
