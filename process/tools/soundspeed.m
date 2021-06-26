function [speedcoef] = soundspeed(T,S,D)

% This script computes the sound speed (in m/s) on depths x pings matrices
% following ?acKenzie equation (1981)
% T in C (depth x pings)
% S in %/10 (depth x pings)
% D in m, depth of each ping (depth x pings) 


% Sound speed coefficient
speedcoef = 1448.96 + 4.591 * T - 5.304*10^(-2) * T.^2 + 2.374 * 10^(-4) * T.^3 + ...
            1.340 * (S-35) + 1.630 * 10^(-2) * D + 1.675 * 10^(-7) * D.*D - ...
            1.025 * 10^(-2) * T .* (S-35) - 7.139 * 10^(-13) * T .* D.^3;
         
return