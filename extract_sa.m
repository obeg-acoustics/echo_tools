% Area Backscatter Extraction Script
%
% This script extracts area backscatter Sa on selected depth range, fo MFI ranger selected MFI range 
% 
% Jerome Guiet
% keyboard
 
clear all

% Load the different pathes and parameters in parameters.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters

% Parameters
DL = 4000;
depth_range = [20:120];
MFI_range   = [0,1];
 
% Load echogram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('echogram_filtered_Cleaned.mat')

% Remove masked pings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(echogram.pings)
    echogram.pings(k).Sv = echogram.pings(k).Sv.*...
                                echogram.mask(k).SvBot.*...
                                echogram.mask(k).SvFalseBot.*...
                                echogram.mask(k).SvManual;
end

% MFI information
[echogram] = MFI(echogram, 40)

% Aerial backscatter in surface layer for all
[sva] = calculate_sa(echogram, DL, depth_range, MFI_range)

% Save chunk
save('sa_test.mat','sva')

% % Plot
% figure, hold on
% scatter(sva(1).lon_sva,sva(1).lat_sva,[],10.*log10(sva(1).sva),'filled')
% shading flat
% load coastlines.mat
% plot(coastlon,coastlat,'linewidth',3)
% xlim([-128,-118])
% ylim([31,46])
% set(gca,'FontSize',40,'linewidth',3)
% axis square
% box on
% caxis([-75,-45])
% colorbar

