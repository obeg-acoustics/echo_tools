function [echogram] = velocity_detection(echogram)

% This script computes the velocity along track

% Input :
%	- echogram

% Output :
%	- echogram.features.velocity : velocity along ping(1) time vector in m/s

% COMPUTE VELOCITY
X = echogram.pings(1).distance; % In m
Y = echogram.pings(1).time * 3600 * 24; % In s
velocity = X * NaN;
velocity(2:end-1) = (X(3:end)-X(1:end-2)) ./ (Y(3:end)-Y(1:end-2));  

echogram.features.velocity = velocity;
echogram.features.time     = echogram.pings(1).time;
