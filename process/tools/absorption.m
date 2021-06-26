function [absorbcoef] = absorption(T,S,pH,D,f)

% This script computes the absorption coefficient (in dB km^(-1)) on depths x pings matrices
% following R. E. Francois, and G. R. Garrison (1982)
% T in C (depth x pings)
% S in %/10 (depth x pings)
% pH acidity
% D depth of each ping (depth x pings)
% f in kHz

% Returns absorption in dB/m

% Params
c  = 1412 + 3.21*T + 1.19*S + 0.0167*D;

% Boric Acid Contribution
A1 = 8.86 ./c * 10.^(0.78 * pH - 5);    % Absorption in Boric acid
P1 = 1;                                 % Pressure in Boric acid
f1 = 2.8 * (S / 35).^0.5 .* 10.^(4 - 1245./(273+T)); % Frequency in Boric acid
% f1= 0.78 .* (S/35).^(0.5) .* 10.^(T/26);

% MgSO4 Contribution
A2 = 21.44 * S./c .* (1+0.025*T);       % Absorption in MgSO4
P2 = 1 - 1.37 * 10^(-4) * D + 6.2 * 10^(-9) * D.*D; % Pressure in MgSO4
f2 = (8.17 * 10.^(8-1990./(273+T))) ./ (1 + 0.0018 .* (S-35)); %Frequency in MgSO4

% Pure Water Contribution
ind1 = find(T<=20);
ind2 = find(T>20);
A3 = A1*NaN;
A3(ind1) = 4.937 * 10^(-4) - 2.59 * 10^(-5) * T(ind1) + 9.11 * 10^(-7) * T(ind1).^2 - 1.5 * 10^(-8) * T(ind1).^(3); % Absorption in pure water
A3(ind2) = 3.964 * 10^(-4) - 1.146 * 10^(-5) * T(ind2) + 1.45 * 10^(-7) * T(ind2).^2 - 6.5 * 10^(-10) * T(ind2).^(3); % Absorption in pure water
P3 = 1 - 3.83 * 10^(-5) .* D + 4.9 * 10^(-10) * D.^2; % Pressure in Pure water 

% Absorption coefficient
absorbcoef = (A1.*P1.*f1.*f.^2 ./ (f.^2 + f1.^2) + ...
             A2.*P2.*f2.*f.^2 ./ (f.^2 + f2.^2) + ...
             A3.*P3.*f.*f)/1000;
         
return