% Mixer_IFBeat.m
% Author: Ahmed Amin
% Description:
%   Splits the long Tx/Rx streams into sweeps,
%   mixes each sweep (dechirp) to form beat signal(s),
%   and returns:
%       beatM      - matrix [Nsweep x NumSweeps] of dechirped beats
%       t_fast     - fast-time axis for one sweep [s]
%
% Inputs:
%   P      - params struct
%   tx1d   - transmit signal (column)
%   rx1d   - received signal (column)
%
% Outputs:
%   beatM  - dechirped beat per sweep
%   t_fast - fast-time vector (Nsweep x 1)
%   idx_up - indices of UP chirps (basic slope check, mostly for plotting)

function [beatM, t_fast, idx_up] = Mixer_IFBeat(P, tx1d, rx1d)

    % Ensure integer number of sweeps
    Nsweep = P.Nsweep;
    N_sweeps_total = floor(min(numel(tx1d), numel(rx1d)) / Nsweep);

    txM = reshape(tx1d(1:Nsweep*N_sweeps_total), Nsweep, []);
    rxM = reshape(rx1d(1:Nsweep*N_sweeps_total), Nsweep, []);

    % Dechirp = Rx * conj(Tx)
    beatM = rxM .* conj(txM);

    % Fast-time axis for one chirp
    t_fast = (0:Nsweep-1).' / P.fs;

    % Very light "is this an up-chirp?" check using phase slope
    phi_tx = unwrap(angle(txM));           % [Nsweep x N_sweeps_total]
    Xfit   = [t_fast ones(Nsweep,1)];
    beta_s = zeros(2, N_sweeps_total);

    for k = 1:N_sweeps_total
        beta_s(:,k) = (Xfit.'*Xfit) \ (Xfit.'*phi_tx(:,k));
    end

    slope_tx = beta_s(1,:);      % rad/s; positive => up-sweep
    idx_up   = find(slope_tx > 0);

    if isempty(idx_up)
        idx_up = 1:N_sweeps_total;  % fallback: assume all up
    end
end
