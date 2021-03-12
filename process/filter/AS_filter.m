function [echogram] = AS_filter(echogram, ASthreshold, ASn, R1, R2)

% This function removes the attenuated signal noise (AS) that may be due to the effects of air bubbles on the transmit-and-receive signal. It may occur for one ping but can persists for many pings in case of bad weather. To do that, we define a Deep Scattering Layer which is the layer that is supposed to backscatter the most. Then we compare the median value of a ping in this DSL with the median value of several pings around the ping studied.

% Input :
%	- R1 and R2 are respectively the top and the bottom of the Deep Scattering Layer.
%	- ASn : the number of pings we use to make the median around the studied ping.
%	- ASthreshold : if the difference between the median of one ping and the median of ASn pings around this ping is less than this threshold, the pings is removed.
%	- the echogram we want to filter
% Output :
%	- echogram : the filtered echogram.

for i=1:length(echogram.pings) % Loop upon all the frequencies

	% We replicate the range vector to create a matrix whose vertical size is the length of the range vector and whose horizontal size is the length of time. This matrix will be useful to find all the indexes in Sv matrix that are between depths R1 and R2.
	rangematrix = repmat(echogram.pings(i).range, 1, length(echogram.pings(i).time));

	% We find the indexes of the range vector that are between depths R1 and R2. The length of this vector will be useful to settle the size of the SvDSL matrix later in the script.
	indvec = find(R1 <= echogram.pings(i).range & echogram.pings(i).range <= R2); 

	% We find the indexes of the range matrix that are between depths R1 and R2.
	indmat = find(R1 <= rangematrix & rangematrix <= R2);

	% We create a Sv submatrix (SvDSL, DSL for Deep Scattering Layer) by keeping all the values of Sv matrix that are between depths R1 and R2.
	SvDSL = echogram.pings(i).Sv(indmat); 

	% We just reshape the latter matrix into a matrix whose size represents range and time.
	SvDSL = reshape(SvDSL, [length(indvec), length(echogram.pings(i).time)]); 

	% We create a vector whose each value is the 25th percentile one ping column of SvDSL matrix. 
	% SvDSLmed = 10*log10(nanmedian(10.^(SvDSL/10))); % Alternate formulation
        SvDSLmed = prctile(SvDSL,25,1);

	% We create a vector that is a "block median" of the latter vector, with ASn-sized-blocks. These two vectors need to have the same size since we want to substract one from the other afterwards.
	% The loop does not work until the end of SvDSLmed vector because ASn is not a divisor of length(SvDSLmed). So we must stop before the end of SvDSLmed length.
	SvDSLmedblock = zeros(1,length(SvDSLmed));
	for j=1:ASn:floor(length(SvDSLmed)/ASn)*ASn
		SvDSLmedblock(1,j:j+ASn-1) = 10*log10(nanmedian(10.^(SvDSLmed(1,j:j+ASn-1)/10)));
	end

	% Here we fill the end of SvDSLmedblock vector.
	SvDSLmedblock(1,floor(length(SvDSLmed)/ASn)*ASn+1:end) = nanmedian(SvDSLmed(1,floor(length(SvDSLmed)/ASn)*ASn+1:end));

	% We find the indexes of the vector where the condition is filled to remove AS.
	ind = find(SvDSLmedblock - SvDSLmed > ASthreshold); % Be careful, if a ping is surrounded by NaNs, it cannot be detected as an attenuated signal ping.

	% We replace by NaN the columns of Sv matrix that correpond to the indexes in ind.
	echogram.pings(i).Sv(:,ind) = NaN;

	% Fill the SvNoise matrix of the echogram by adding 7 where attenuated signal noise has been removed (the SvNoise matrix is created if it is the first call)
        if exist('echogram.pings(i).SvNoise(:,ind)','var') == 0
            SvNoise = zeros(size(echogram.pings(i).Sv));
            echogram.pings(i).SvNoise = single(SvNoise);
        end
	echogram.pings(i).SvNoise(:,ind) = echogram.pings(i).SvNoise(:,ind) + single(7);

end



























