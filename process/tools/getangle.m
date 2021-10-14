function [Gamma] = getangle(roll_trans,pitch_trans,roll_receiv,pitch_receiv)

% This script determines gamma and alpha angles from roll and ping


% Compute Gamma ================

% Azimuth Angle
Phi_trans    = atand(sqrt(tand(roll_trans).^2+tand(pitch_trans).^2));
Phi_receiv   = atand(sqrt(tand(roll_receiv).^2+tand(pitch_receiv).^2));

% Zenith Angle
Omega_trans  = atand(tand(roll_trans)./tand(pitch_trans));
Omega_receiv = atand(tand(roll_receiv)./tand(pitch_receiv));

roll_trans=[];
pitch_trans=[]; 
roll_receiv=[];
pitch_receiv=[];

% Derivation of Gamma
tmp1 = sind(Phi_trans).*cosd(Omega_trans).*sind(Phi_receiv).*cosd(Omega_receiv);
tmp2 = sind(Phi_trans).*sind(Omega_trans).*sind(Phi_receiv).*sind(Omega_receiv);
Omega_trans=[];
Omega_receiv=[];
tmp = tmp1+tmp2;
tmp1 = [];
tmp2 = [];

tmp3 = cosd(Phi_trans).*cosd(Phi_receiv);
Phi_trans=[];
Phi_receiv=[];
tmp = tmp + tmp3;
tmp3 = [];

tmp(find(tmp>1))=NaN;
tmp(find(tmp<-1))=NaN;

Gamma = acosd(tmp);

%Gamma = real(acosd(sind(Phi_trans).*cosd(Omega_trans).*sind(Phi_receiv).*cosd(Omega_receiv)+sind(Phi_trans).*sind(Omega_trans).*sind(Phi_receiv).*sind(Omega_receiv)+cosd(Phi_trans).*cosd(Phi_receiv)));

return
