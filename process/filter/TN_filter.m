function [echogram] = TN_filter(echogram, TNthreshold, TNsmooth, TNn, TNm, TNminSv, mindepth, TNprctile)

% This function removes the Transient Noise (TN) which could result from broad spectrum high energy sounds generated in bad weather when waves collide with the hull. To do that, we compare values from the initial Sv with a median value from a "box" around the value.

% Input :
%       - echogram : the echogram we want to filter
%       - mindepth : the depth below we can consider a tranisent noise
%       - TNn : the range size of the box around the Sv value
%       - TNm : the ping size of the box around the Sv value
%       - TNthreshold : if the difference between the ping value and the median value of the box around this ping is above this threshold, then the Sv value is removed, not the entire ping.
%       - TNsmooth : vertical smoothing window
%       - TNprctile : Detection percentile
%       - TNminSv : exclusion threshold
% Output :
%       - echogram : the filtered echogram


% CHECK FOR NOISE MASKS
for k=1:length(echogram.pings)
        if exist('echogram.pings(k).SvNoise','var')==0
            echogram.pings(k).SvNoise = single(zeros(size(echogram.pings(k).Sv)));
        end
end


% FUNCTION
fcn_prctile = @(x) prctile(x,TNprctile);


% PROCESS
for k=1:length(echogram.pings) % Loop upon all the frequencies

	% SMOOTHED TRANSECT
        nsmooth  = length(find(echogram.pings(k).range<TNsmooth));
        Svsmooth = movmean(echogram.pings(k).Sv,nsmooth,1,'omitnan');


        % SELECT NOMINAL DEPTH
        indvec = find(mindepth <= echogram.pings(k).range);
        % We create a Sv submatrix (SvDSL, DSL for Deep Scattering Layer) by keeping all the values of Sv matrix that are between depths R1 and R2.
        SvND = Svsmooth(indvec,:);
        Svsmooth = [];

        % CONTEXT PERCENTILE
        % We create a vector that is a "block percentile" with TSnxTSm-sized-blocks.
        SvNDprcblock = colfilt(SvND,[TNm TNn],'sliding',fcn_prctile);
%        SvNDprcblock = zeros(size(SvND,1),size(SvND,2));
%        Ni = size(SvNDprcblock,1);
%        Nj = size(SvNDprcblock,2);
%	parfor i = 1:Ni
%            SvNDprcblock_par = zeros(1,Nj);
%            for j = 1:Nj
%                if i<=TNm/2
%                    if j<=TNn/2
%                        SvNDprcblock_par(j) = prctile(SvND(1:TNm,1:TNn),TNprctile,'all');
%                    elseif j>=Nj-TNn/2
%                        SvNDprcblock_par(j) = prctile(SvND(1:TNm,Nj-TNn:Nj),TNprctile,'all');
%                    else
%                        SvNDprcblock_par(j) = prctile(SvND(1:TNm,j-TNn/2:j+TNn/2),TNprctile,'all');
%                    end
%	        elseif i>=Ni-TNm/2
%                    if j<=TNn/2
%                        SvNDprcblock_par(j) = prctile(SvND(Ni-TNm:Ni,1:TNn),TNprctile,'all');
%                    elseif j>=Nj-TNn/2
%                        SvNDprcblock_par(j) = prctile(SvND(Ni-TNm:Ni,Nj-TNn:Nj),TNprctile,'all');
%                    else
%                        SvNDprcblock_par(j) = prctile(SvND(Ni-TNm:Ni,j-TNn/2:j+TNn/2),TNprctile,'all');
%                    end
%	        else
%                    if j<=TNn/2
%                        SvNDprcblock_par(j) = prctile(SvND(i-TNm/2:i+TNm/2,1:TNn),TNprctile,'all');
%                    elseif j>=Nj-TNn/2
%                        SvNDprcblock_par(j) = prctile(SvND(i-TNm/2:i+TNm/2,Nj-TNn:Nj),TNprctile,'all');
%                    else
%                        SvNDprcblock_par(j) = prctile(SvND(i-TNm/2:i+TNm/2,j-TNn/2:j+TNn/2),TNprctile,'all');
%                    end
%		end
%	    end
%            SvNDprcblock(i,:) = SvNDprcblock_par;
%        end


        % FIND PINGS TO EXTRACT
        % We find the indexes of the vector where the condition is filled to remove TN.
        ind1 = find(SvND(2:end-1,2:end-1) - SvNDprcblock(2:end-1,2:end-1) > TNthreshold); % Be careful, if a ping is surrounded by NaNs, it cannot be detected as an attenuated signal ping.


        % TVT
        SvTemp = echogram.pings(k).Sv(indvec(2:end-1),2:end-1); % We extract from Sv a submatrix SvTemp whose size is the same as Ldelta and Rdelta
        range = echogram.pings(k).range(indvec(2:end-1));
        range(find(range<0)) = NaN;
        TVT   = TNminSv + 20*log10(repmat(range,[1,size(SvTemp,2)])) + 2 * echogram.calParms(k).absorptioncoefficient * (repmat(range,[1,size(SvTemp,2)])-1);
        ind2  = find(SvTemp>TVT);


        % CORRECT
        SvTemp(intersect(ind1,ind2)) = NaN; % At the indexes contained in ind, we replace in the SvTemp matrix the values of Sv with NaN
        echogram.pings(k).Sv(indvec(2:end-1),2:end-1) = SvTemp;
        SvTemp = []; TVT = [];

        
	% NOISE
        subSvNoise = echogram.pings(k).SvNoise(indvec(2:end-1),2:end-1);
        subSvNoise(intersect(ind1,ind2)) = subSvNoise(intersect(ind1,ind2)) + single(3);
        echogram.pings(k).SvNoise(indvec(2:end-1),2:end-1) = subSvNoise;
	subSvNoise = []; ind1 = []; ind2 = [];

end



























