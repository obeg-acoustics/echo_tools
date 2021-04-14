% Co-occuring Drivers Extraction Script 
%
% This script extract environmental drivers along an echogram, at a selected resoluton 
%
% Jerome Guiet
% keyboard
 
clear all
 
% Load the different paths and parameters in parameters.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters
DL = 4000;

% Load echogram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('echogram_filtered_Cleaned.mat')

%[echogram] = distance_vector(echogram)


%SOLAR ANGLE
[echogram] = solar_elevation(echogram);
solar.solar_angle = echogram.solar_elevation;
[solar.solar_angle_bin,solar.lon_bin,solar.lat_bin,solar.time_bin] = ...
        calculate_driver(solar.solar_angle,DL,echogram.pings(1).time,echogram.pings(1).lon,echogram.pings(1).lat,echogram.pings(1).distance);
 
%CHL
[echogram] = chloro(echogram,chlpath_daily,chlpath_weekly,tagyear);
chl = echogram.chl;
[chl.weekly_chl_bin,chl.lon_chl_bin,chl.lat_chl_bin,chl.time_chl_bin] = ...
        calculate_driver(chl.weekly_chl,DL,chl.time_chl,chl.lon_chl,chl.lat_chl,echogram.pings(1).distance);

%POC
[echogram] = poc(echogram,pocpath_daily,pocpath_weekly,tagyear);
poc = echogram.poc;
[poc.weekly_poc_bin,poc.lon_poc_bin,poc.lat_poc_bin,poc.time_poc_bin] = ...
        calculate_driver(poc.weekly_poc,DL,poc.time_poc,poc.lon_poc,poc.lat_poc,echogram.pings(1).distance);

%PAR
[echogram] = par(echogram,parpath_daily,parpath_weekly,tagyear);
par = echogram.par;
[par.weekly_par_bin,par.lon_par_bin,par.lat_par_bin,par.time_par_bin] = ...
        calculate_driver(par.weekly_par,DL,par.time_par,par.lon_par,par.lat_par,echogram.pings(1).distance);

%SST
[echogram] = sst(echogram,sstpath_daily,sstpath_weekly);
sst = echogram.sst;
[sst.weekly_sst_bin,sst.lon_sst_bin,sst.lat_sst_bin,sst.time_sst_bin] = ...
        calculate_driver(sst.weekly_sst,DL,sst.time_sst,sst.lon_sst,sst.lat_sst,echogram.pings(1).distance);
%SSH
[echogram] = ssh(echogram,sshpath_weekly);
ssh = echogram.ssh;
[ssh.weekly_ssh_bin,ssh.lon_ssh_bin,ssh.lat_ssh_bin,ssh.time_ssh_bin] = ...
        calculate_driver(ssh.weekly_ssh,DL,ssh.time_ssh,ssh.lon_ssh,ssh.lat_ssh,echogram.pings(1).distance);

%%FRONT
%[echogram] = front_dw(echogram,sstpath_daily,sstpath_weekly);
%front = echogram.front;
%
%%Wind
%[echogram] = era(echogram,erapath_daily);
%vel10 = echogram.vel10;
%
%%bathy
%[echogram] = topo_extract(echogram,bathypath);
%topo.lon_topo = vel10.lon_vel10;
%topo.lat_topo = vel10.lat_vel10;
%topo.values   = echogram.topo;
%
%%MLD
%[echogram] = mld(echogram,mldpath_weekly,tagyear);
%mld = echogram.mld;

%save('Env_echogram.mat', 'sst', 'ssh', 'par', 'poc', 'chl', 'front', 'vel10', 'topo', 'mld')
save('Env_echogram.mat', 'sst', 'ssh', 'par', 'poc', 'chl', 'solar')

