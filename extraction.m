% Extraction Script
%
% This script loads the different raw files we want to process. Then it concatenates them into a single structure named echogram
%
% Stanislas Bebin  -  Jerome Guiet
%keyboard 

clear all

% Load the different pathes and parameters in parameters.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA EXTRACTION + VERTICAL BINNING % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Get list of files to process %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileschunk = chunklist(inputpath,inputpath_start,inputpath_end);


% Read initial raw file and initialize echogram structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Reading initial .raw file...');


% Read first echogram raw data
[header1, rawData1] = readEKRaw_test(fileschunk(1).name, 'Frequencies',frequencies, 'GPSSource',gpsformat);


%  extract calibration parameters from raw data structure %%
%
%    calParms is a structure array containing transceiver specific settings
%  such as gain, frequency, transmitpower, etc.
%    We make the assumption that, for all the chunks of a single cruise, 
%  the parameters are the same, so we extract the calParms just for the first chunk.

calParms 	 = readEKRaw_GetCalParms(header1, rawData1);


% Convert power to Sv for first raw file and extract angle

data1 		 = readEKRaw_Power2Sv(rawData1, calParms);
% data1            = readEKRaw_ConvertAngles(data1, calParms);


% Create structure echogram 

[echogram] 	 = echogram_extract(data1, echosounder_sensitivity);


% We add to this structure all the parameters that are important for the data process

for i=1:length(calParms)
	echogram.calParms(i).frequency 	           = calParms(i).frequency;
	echogram.calParms(i).soundvelocity         = calParms(i).soundvelocity;
	echogram.calParms(i).absorptioncoefficient = calParms(i).absorptioncoefficient;
	echogram.calParms(i).pulselength           = calParms(i).pulselength;
    echogram.calParms(i).beamwidthalongship    = calParms(i).beamwidthalongship;
end


% Read following raw files and concatenate echogram structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=2:length(fileschunk)
	% Load the new chunk that will be concatenated in this loop
	disp(['Reading chunks .raw file... ' num2str(i) ' / ' num2str(length(fileschunk))]);
	[header2, rawData2] 			   = readEKRaw_test(fileschunk(i).name, 'Frequencies', frequencies,'GPSSource',gpsformat);

        % Convert power to Sv chuncks
	data2                          = readEKRaw_Power2Sv(rawData2, calParms);

	% Load structure echogram
	[echogram2] 				   = echogram_extract(data2, echosounder_sensitivity);

	% We concatenate the echograms
    if (size(echogram2.pings)==size(echogram.pings))
	    [echogram]                 = echogram_concatenate(echogram,echogram2, 0);
    else
        disp('This chunk does not include enough frequencies, concatenation impossible')
    end
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE EXTRACTED ECHOGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save([outputpath,'echogram.mat'], 'echogram', '-v7.3');






