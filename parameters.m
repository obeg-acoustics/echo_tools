% Pathes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load Matlab tools

addpath('/data/project1/matlabpathfiles')

% Load echolab library

addpath('/data/project3/jguiet/Acoustic/echolab_test');

% Path to acoustic library

addpath(genpath('/data/project3/jguiet/Acoustic/echo_tools'))

% Specify path to data

addpath('/data/project1/data/acoustics/AODN/investigator_20190119_20190125/ek60')



% Extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

frequencies 	 =  [18000,38000,70000,120000,200000];     % List of frequencies to extract
gpsformat 	 = 'GPGGA';%'INGGA';%'GPGGA';              % Flag for GPS data format 
echosounder_sensitivity = -200; 			   % Sensitivity threshold 
inputpath        = '/data/project2/jguiet/Acoustic/processed_data/in2019/in2019_v01-*.raw'
inputpath_start  = '/data/project2/jguiet/Acoustic/processed_data/in2019/in2019_v01-D20190119-*.raw'
inputpath_end    = '/data/project2/jguiet/Acoustic/processed_data/in2019/in2019_v01-D20190120-*.raw'
outputpath       = '/data/project2/jguiet/Acoustic/processed_data/in2019/'; % Path where the extracted data are saved


% Binning %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vertical_binsize = 1; 					   % In meters
horizontal_binsize = 30; 				   % In seconds


% Filters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

INthreshold 	 = 10; 					   % dB.m-1
INn 		 = 1; 					   % Number of pings
INmin            = -80;                                    % dB.m-1

ASthreshold 	 = 8; 					   % dB.m-1
ASn 		 = 100; 				   % Number of pings
R1 		 = 300; 				   % Range lower limit (in meters)
R2 		 = 400; 				   % Range upper limit (in meters)

TNthreshold 	 = 15; 					   % dB.m-1
TNm 		 = 50; 					   % Range number (~10m)
TNn 		 = 50; 					   % Ping number
TNmin            = -70;					   % dB.m-1		
mindepth 	 = 300; 				   % Range limit (in meters) 

BGn 		 = 40; 				   	   % Ping number
BGm 		 = 50; 				   	   % Range number (~10m)
thresholdSNR 	 = 10;	 				   % Threshold for a ratio, dB.m-1
noisemax 	 = -125;     				   % dB.m-1


% Bottom detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bottom_threshold = -40; 				   % dB.m-1
window_radius = 100; 					   % To adapt regarding the vertical binning, number of ranges.
start_depth = 8;					   % Range number (not in meters if the vertical binning is not 1 meter) 
Sv_max_chunks_threshold = -25;				   % dB.m-1
warning_bottom_threshold = 10;				   % In number of range


% False bottom removal #####################################

falsebottom_threshold = -40;
ratio_threshold = 1.3;
SvLim = -60;


% Data removal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meters_above_bottom_removal = 2; 			   % This parameter comes with the belowbottom_removal function. We can choose a certain height above the bottom we want to remove. Just be careful, when the bottom is steep, it's hard to remove all the signal due to the bottom, or you can choose a high height. And also, this height cannot be above sea surface (if the maximum height bottom goes to 15 meters below sea surface, the maximum meters_above_bottom_removal you can choose is 14 meters).
upper_layer_height = 4; 				   % In meters. The height of the upper layer whose signal is very strong.


% Parameters for MFSBI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MFSBI
Sv_threshold     = -66; 				   % dB.m-1


% Parameters for MFI and MFI_analysis %%%%%%%%%%%%%%%%%%%%%%

% MFI
delta 		 = 40; 					   % Parameter taken from Trenkel and Berger, 2013, 
							   % "A fisheries acoustic multi-frequency indicator to inform on large scale spatial patterns of aquatic pelagic ecosystems"

% MFI_analysis
distance_box 	 = 1000; 				   % Meters
depth_box 	 = 25; 					   % Meters
distance_box_map = 10000; 				   % Meters
depth_box_map 	 = [0, 50, 200, 350]; 			   % Meters, boundaries of the layers.


% Paths environmental drivers %%%%%%%%%%%%%%%%%%%%%%
tagyear = '2015';

% SST
sstpath_daily            = '/data/project1/data/MODIS/Aqua/day/sst/';
sstpath_weekly           = '/data/project1/data/MODIS/Aqua/week/sst/';

% Chl
chlpath_daily            = '/data/project1/data/MODIS/Aqua/day/chlor_a/';
chlpath_weekly           = '/data/project1/data/MODIS/Aqua/week/chlor_a/';

% POC
pocpath_daily            = '/data/project1/data/MODIS/Aqua/day/poc/';
pocpath_weekly           = '/data/project1/data/MODIS/Aqua/week/poc/';

% POC
parpath_daily            = '/data/project1/data/MODIS/Aqua/day/par/';
parpath_weekly           = '/data/project1/data/MODIS/Aqua/week/par/';

% SSH
sshpath_weekly           = '/data/project3/jguiet/DATA/SAT/SSH/';

% ERA
erapath_daily            = '/data/project3/jguiet/DATA/ERA/';

% MLD
mldpath_weekly           = '/data/project3/jguiet/DATA/SODA/2015/';

% Bathymetry (ETOPO)
bathypath        = '/data/project3/jguiet/DATA/BATHY/ETOPO_depth.mat';

