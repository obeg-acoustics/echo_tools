% Filtering Script
%
% This script filters extracted raw transect, bin the data and save
% 2018-2026
% Stanislas Bebin  -  Jerome Guiet

addpath(genpath('filter/'))

% Based on the processing described in Haris et al. 2021 "Sounding out life in the deep using acoustic data from ships of opportunity"

numchunks = 5; % Number of chunks of data
rollpitch = 0; % 1 or 0 if roll & picth measures are available or not
manualthresh = 0; % Eventually set range (Sv index) beyond which data must be ingored
correctabsorption = 1; % 1 or 0 if inter-annual T and S fields are available

% Loop on chunks of extracted echogram structures:
% echogram.pings(f).Sv			(N_r * N_p1)
% 		   .time		(1 * N_p1)
%                  .roll		(1 * N_p1)
%                  .pitch		(1 * N_p1)
%                  .soundvelocity	(1 * N_p1)
%                  .transducerdepth	(1 * N_p1)
%                  .range               (N_r *1)
% echogram.gps(f).time 			(N_p2)
%                .lat 			(N_p2)
%                .lon			(N_p2)
% echogram.calParms(f).frequency   
%                     .soundvelocity	
%                     .absorptioncoefficient	
%                     .pulselength		
%                     .beamwidthalongship
% for each frequency f of N_f, for N_r ranges, for N_p1 or 2 time samples

for echonum = 1:numchunks

% Load the appropriate echogram to process
load(['echogram_part',num2str(echonum),'C.mat'])
clock

% Compute distance vector from start of the cruise
disp('Compute distance')
[echogram] = distance_vector(echogram);

% Prepare echogram by masking deep if necessary and correcting dimensions 
disp('Prepare echogram')
if manualthresh>0
	[echogram] = addnan(echogram,manualthresh); % ATT Manual cleaning for anomalimously deep transects 
end
[echogram] = correct_echogram(echogram);

% Motion correction
if rollpitch
	disp('Motion correction')
	[echogram] = motion_correction(echogram);
end

% Correct ranges
disp('Correct ranges')
for k = 1:length(echogram.pings)
    	echogram.pings(k).range = echogram.pings(k).range - (echogram.calParms(k).pulselength*(echogram.calParms(k).soundvelocity/4));
end

% Remove Impulsive Noise (IN)
 INthreshold = 6;			% dB re m2/m3
 INsmooth    = 5;			% m
 INnmax      = 3; % (up to 4)		% #
 INminSv     = -170;			% dB re m2/m3
disp('IN removal')
[echogram] = IN_filter(echogram, INthreshold, INsmooth, INnmax, INminSv);

% Bottom detection =================
 bottom_threshold = -40;		% dB re m2/m3
 window_radius = 100;			% To adapt regarding the vertical binning, number of ranges.
 start_depth = 8;                       % Range number (not in meters if the vertical binning is not 1 meter)
 Sv_max_chunks_threshold = -25;         % dB re m2/m3
 warning_bottom_threshold = 10;         % In number of range
disp('Bottom detect')
[echogram] = bottom_detection(echogram, bottom_threshold, window_radius, start_depth, Sv_max_chunks_threshold, warning_bottom_threshold);

% Remove Attenuation Signal (AS) ===
 ASthreshold = 8;			% dB re m2/m3
 ASn         = 300; % In [30,300]	% Number of pings
 R1          = 300;			% Range lower limit (in meters)
 R2          = 500;			% Range upper limit (in meters)
disp('AS removal')
[echogram] = AS_filter(echogram, ASthreshold, ASn, R1, R2);

% Remove Transient Noise (TN) ======
 TNthreshold = 15;			% dB re m2/m3
 TNprctile   = 15;			% Detection percentile
 TNsmooth    = 20;			% Vertical size of smoothing window
 TNn         = 50;			% Horizontal size of context window, #
 TNm         = 10;			% Vertical size of context window, #
 TNminSv     = -150;			% dB re m2/m3
 mindepth    = 250;			% Exclude above depth, m
disp('TN removal')
[echogram] = TN_filter(echogram, TNthreshold, TNsmooth, TNn, TNm, TNminSv, mindepth, TNprctile);

% Background noise removal (BG) ====
 BGn              = 10;			% Horizontal size of averaging window, #
 BGm              = 15;			% Vertical size of averaging window, #
 thresholdSNR     = 5.;			% Minimum SNR threshold, dB re m2/m3
 noisemax         = -100;		% Maximum noise threshold
disp('BG removal')
[echogram] = BG_filter(echogram, BGn, BGm, noisemax, thresholdSNR);

% Residual noise removal (RN) ====
 RNthreshold = -50;			% Maximum threshold, dB re m2/m3
 RNminSv     = -160;			% dB re m2/m3
disp('RN removal')
[echogram] = RN_filter(echogram, RNthreshold, RNminSv);

% Velocity vector ==================
disp('Compute velocities')
[echogram] = velocity_detection(echogram);

% Binning =========================
disp('Binning')
% We vertically bin this echogram chunk
[echogram] = vertical_binning(echogram, 1);
% Horizontal binning in time
[echogram] = horizontal_binning_time(echogram, 30);
% Update distance for binned resolution
[echogram] = distance_correct(echogram);

% Correct absorption  =============
if correctabsorption
	disp('Absorption correction')
	[echogram] = absorption_correction_inter(echogram);
end

% Interpolated bottom removal =====
disp('Bottom removal 2')
meters_above_bottom_removal = 2;
upper_layer_height = 4;
[echogram] = bottom_coarsening(echogram);
[echogram] = data_removal(echogram, meters_above_bottom_removal, upper_layer_height);

clock

% Save filtered echogram  =========
disp('Save filtered echogram')
save(['echogram_filtered_part',num2str(echonum),'C.mat'],'echogram','-v7.3')

end
