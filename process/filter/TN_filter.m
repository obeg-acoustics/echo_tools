function [echogram] = TN_filter(echogram, TNthreshold, TNn, TNm, TNmin, mindepth)

% This function removes the Transient Noise (TN) which could result from broad spectrum high energy sounds generated in bad weather when waves collide with the hull. To do that, we compare values from the initial Sv with a median value from a "box" around the value.

% Input :
%       - echogram : the echogram we want to filter
%       - mindepth : the depth below we can consider a tranisent noise
%       - TNn : the range size of the box around the Sv value
%       - TNm : the ping size of the box around the Sv value
%       - TNthreshold : if the difference between the ping value and the median value of the box around this ping is above this threshold, then the Sv value is removed, not the entire ping.
% Output :
%       - echogram : the filtered echogram


for i=1:length(echogram.pings) % Loop upon all the frequencies

	% Convert to 40 log R TVG

	% Here we calculate the TVG range (then create a matrix), which is useful to remove TVG from the measured data.
        rangeTVG = zeros(size(echogram.pings(i).range));
        rangeTVG = echogram.pings(i).range - (echogram.calParms(i).pulselength*(echogram.calParms(i).soundvelocity/4));
        echogram.pings(i).rangeTVG = rangeTVG;

        rangeTVGmatrix = repmat(echogram.pings(i).rangeTVG, 1, length(echogram.pings(i).time));

	% Calculation of powercal (following De Robertis' paper)
        powercal = zeros(size(echogram.pings(i).Sv));

% WARNING : Since the first values of rangeTVG vector can be negatives, it creates complex numbers with the log10. This is only for first values, which are not really important for the background noise because the noise to signal ratio is very low. So, in what's following, we keep the real part of the complex numbers, so that we avoid any kind of further problems using complex numbers.

        powercal = real(echogram.pings(i).Sv - (20*log10(rangeTVGmatrix) + 2*echogram.calParms(i).absorptioncoefficient*rangeTVGmatrix));

	Sv40     = real(powercal + (40*log10(rangeTVGmatrix) + 2*echogram.calParms(i).absorptioncoefficient*rangeTVGmatrix));

        clear rangeTVGmatrix
        clear powercal

        % We create a block matrix that is the 15th percentile per block of the latter matrix, with TNn-sized-blocks, and dR range depth blocks. These two matrices need to have the same size since we want to substract one from the other afterwards.
        Sv40block = zeros(size(Sv40,1),size(Sv40,2));

        for k = 1:TNm:floor(size(Sv40,1)/TNm)*TNm
            for j = 1:TNn:floor(size(Sv40,2)/TNn)*TNn
		    tmp = Sv40(k:k+TNm-1,j:j+TNn-1);
                    Sv40block(k:k+TNm-1,j:j+TNn-1) = prctile(tmp(:),15);
            end
	end
       
        % We replicate the range vector to create a matrix whose vertical size is the length of the range vector and whose horizontal size is the length of time. This matrix will be useful to find all the indexes in Sv matrix that are between depths R1 and R2.
        rangematrix = repmat(echogram.pings(i).range, 1, length(echogram.pings(i).time));

        % We remove the surface values in order to avoid rejection of samples
        inddepth = find(rangematrix <= mindepth); % We find the indexes where ranges are below mindepth.

	Sv40(inddepth) = 0; % We assign the value 0 to the Sv values that are above mindepth because they are not concerned by the Transient Noise.
        Sv40block(inddepth) = 0; % We assign the value 0 to the Sv values that are above mindepth because they are not concerned by the Transient Noise.

        indsup = find((Sv40 - Sv40block) > TNthreshold); % We find the indexes where the TN condition is filled.
        indinf = find((Sv40 - Sv40block) < -TNthreshold); % We find the indexes where the TN condition is filled.

        clear Sv40
        clear Sv40block

	% We replace by NaN the columns of Sv matrix that correpond to the indexes in ind.
        ind = find(echogram.pings(i).Sv>TNmin);
	echogram.pings(i).Sv(intersect(ind,indsup)) = NaN;
        echogram.pings(i).Sv(intersect(ind,indinf)) = NaN;

	% Fill the SvNoise matrix of the echogram by adding 3 where transient noise has been removed (the SvNoise matrix is created if it is the first call)
        if exist('echogram.pings(i).SvNoise(intersect(ind,indsup))','var') == 0
            SvNoise = zeros(size(echogram.pings(i).Sv));
            echogram.pings(i).SvNoise = single(SvNoise);
        end
	echogram.pings(i).SvNoise(intersect(ind,indsup)) = echogram.pings(i).SvNoise(intersect(ind,indsup)) + single(3);
        echogram.pings(i).SvNoise(intersect(ind,indinf)) = echogram.pings(i).SvNoise(intersect(ind,indinf)) + single(3);

end



























