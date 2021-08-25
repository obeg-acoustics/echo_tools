function [data] = motion_correction(data)

% This script correct the Sv signal for motion. It is based on Dunford et
% al. 2005, Correcting echo-integration data for transducer motion. We
% implement the correction as described in the echoview toolbox.
% J Guiet 12-10-2020

for freq = 1:length(data.pings)

    % Determine the transmission and reception time matrices
    t_trans  = repmat(data.pings(freq).time,[size(data.pings(freq).Sv,1),1]);
    
    c = double(repmat(data.calParms(freq).soundvelocity,[size(data.pings(freq).Sv,1),size(data.pings(freq).Sv,2)]));
    r = double(repmat(data.pings(freq).range,[1,size(data.pings(freq).Sv,2)]));
    t_receiv = t_trans + 2*r./c /3600/24;
    
    % Roll angles at transmission and receiption
    roll_trans = repmat(data.pings(freq).roll,[size(data.pings(freq).Sv,1),1]);
    roll_receiv = roll_trans*NaN;
    for i = 1:size(t_receiv,1)
        roll_receiv(i,:) = interp1(t_trans(i,:),data.pings(freq).roll,t_receiv(i,:));
    end
    
    % Pitch angles at transmission and receiption
    pitch_trans = repmat(data.pings(freq).pitch,[size(data.pings(freq).Sv,1),1]);
    pitch_receiv = pitch_trans*NaN;
    for i = 1:size(t_receiv,1)
        pitch_receiv(i,:) = interp1(t_trans(i,:),data.pings(freq).pitch,t_receiv(i,:));
    end

    t_trans = [];
    t_receiv = [];    

    % Dunford Gamma angle
    [Gamma] = getangle(roll_trans,pitch_trans,roll_receiv,pitch_receiv);

    roll_trans = [];
    pitch_trans = [];
    roll_receiv = [];
    pitch_receiv = [];

    % amplification factor
    x = sind(Gamma) ./ sind(data.calParms(freq).beamwidthalongship / 2); 
    k = 0.17083*x.^5 - 0.39660*x.^4 + 0.53851*x.^3 + 0.13764*x.^2 + 0.039645*x + 1;
    
    % Correction of Sv
    data.pings(freq).Sv = 10 * log10(k.* 10.^(data.pings(freq).Sv/10));
end
    
