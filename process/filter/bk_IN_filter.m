function [echogram] = IN_filter(echogram, INthreshold, INn, INminSv)

% This function removes the Impulsive Noise (IN) in the data, which may result from the transmit pulse from an unsynchronized echosounder.

% Input :
%	- echogram : the echogram we want  to filter
%	- INthreshold : the threshold between a difference of data above which the data is removed because considered as an impulsive noise
%	- INn : for the two-sided comparison. Pings that are +/-INn number pings either side of current ping
%       - INminSv : minimum Sv value to apply the filter
% Output :
%	- echogram : the echogram filtered from Impulsive Noise

% keyboard
for i=1:length(echogram.pings) % Loop upon all the frequencies
i
	Ldelta = echogram.pings(i).Sv(:,INn+1:end-INn) - echogram.pings(i).Sv(:,1:end-2*INn); % We calculate the difference in time between the column of index i, and the column of index i-INn
	Lind = find(Ldelta > INthreshold); % We find in the new matrix the indexes where the Sv value is above INthreshold, the threshold settled before.

        clear Ldelta

	Rdelta = echogram.pings(i).Sv(:,INn+1:end-INn) - echogram.pings(i).Sv(:,2*INn+1:end); % We calculate the difference in time between the column of index i, and the column of index i+INn
	Rind = find(Rdelta > INthreshold); % We find in the new matrix the indexes where the Sv value is above INthreshold, the threshold settled before.

        clear Rdelta

	ind1 = intersect(Lind,Rind); % We extract the indexes where the two conditions are filled

        clear Lind
        clear Rind
 
	SvTemp = echogram.pings(i).Sv(:,INn+1:end-INn); % We extract from Sv a submatrix SvTemp whose size is the same as Ldelta and Rdelta
	ind2 = find(SvTemp>INminSv);

	SvTemp(intersect(ind1,ind2)) = NaN; % At the indexes contained in ind, we replace in the SvTemp matrix the values of Sv with NaN


	% Here we concatenate SvTemp with the first and the last columns that were not taken into account to verify the condition because of matrix' size limits.
	SvTemp = [echogram.pings(i).Sv(:,1:INn), SvTemp];
	echogram.pings(i).Sv = [SvTemp, echogram.pings(i).Sv(:,end-INn+1:end)];
	
        clear SvTemp

	%% Fill the SvNoise matrix of the echogram by adding 1 where impulsive noise has been removed
    if exist('echogram.pings(i).SvNoise','var')==0
        echogram.pings(i).SvNoise = single(zeros(size(echogram.pings(i).Sv)));
    end
	subSvNoise = echogram.pings(i).SvNoise(:,INn+1:end-INn);
	subSvNoise(intersect(ind1,ind2)) = subSvNoise(intersect(ind1,ind2)) + single(1);
% 	subSvNoise = [echogram.pings(i).SvNoise(:,1:INn), subSvNoise];
% 	subSvNoise = [subSvNoise, echogram.pings(i).SvNoise(:,end-INn+1:end)];
	echogram.pings(i).SvNoise(:,INn+1:end-INn) = subSvNoise;

        clear subSvNoise
        clear ind1
        clear ind2
end
