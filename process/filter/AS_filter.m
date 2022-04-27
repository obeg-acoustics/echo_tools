function [echogram] = AS_filter(echogram, ASthreshold, ASn, R1, R2)

% This function removes the attenuated signal noise (AS) that may be due to the effects of air bubbles on the transmit-and-receive signal. It may occur for one ping but can persists for many pings in case of bad weather. To do that, we define a Deep Scattering Layer which is the layer that is supposed to backscatter the most. Then we compare the median value of a ping in this DSL with the median value of several pings around the ping studied.

% Input :
%	- R1 and R2 are respectively the top and the bottom of the Deep Scattering Layer.
%	- ASn : the number of pings we use to make the median around the studied ping.
%	- ASthreshold : if the difference between the ASprctile of one ping and ASprctile of ASn pings around this ping is less than this threshold, the pings is removed.
%	- the echogram we want to filter
% Output :
%	- echogram : the filtered echogram.


% CHECK FOR NOISE MASKS
for k=1:length(echogram.pings)
        if exist('echogram.pings(k).SvNoise','var')==0
            echogram.pings(k).SvNoise = single(zeros(size(echogram.pings(k).Sv)));
        end
end


% PROCESSING
for k=1:length(echogram.pings) % Loop upon all the frequencies

    if max(echogram.pings(k).range)>R1

	% SELECT DSL
	indvec = find(R1 <= echogram.pings(k).range & echogram.pings(k).range <= R2); 
	% We create a Sv submatrix (SvDSL, DSL for Deep Scattering Layer) by keeping all the values of Sv matrix that are between depths R1 and R2.
        SvDSL = echogram.pings(k).Sv(indvec,:);


	% PING PERCENTILE
	% We create a vector whose each value is the median of ping column of SvDSL matrix. 
    	%%SvDSLprc = prctile(SvDSL,ASprctile,1);
        SvDSLmed = median(SvDSL,1,'omitnan');


	% CONTEXT PERCENTILE
	% We create a vector that is a "block median" with ASn-sized-blocks.
        SvDSLmedblock = median(movmedian(SvDSL,ASn,2,'omitnan'),1,'omitnan');
        SvDSL = [];
	%SvDSLprcblock = zeros(1,length(SvDSLprc));
    	%for j = 1:length(SvDSLprcblock)
        %	if j<=ASn/2
        %    	SvDSLprcblock(j) = prctile(SvDSL(:,1:ASn),ASprctile,'all');
        % 	elseif j>=length(SvDSLprc)-ASn/2
        %    	SvDSLprcblock(j) = prctile(SvDSL(:,length(SvDSLprc)-ASn:length(SvDSLprc)),ASprctile,'all');
        %	else
        %    	SvDSLprcblock(j) = prctile(SvDSL(:,j-ASn/2:j+ASn/2),ASprctile,'all');
        %	end
    	%end


	% FIND PINGS TO EXTRACT
	% We find the indexes of the vector where the condition is filled to remove AS.
	ind = find(SvDSLmedblock - SvDSLmed > ASthreshold); % Be careful, if a ping is surrounded by NaNs, it cannot be detected as an attenuated signal ping.
        SvDSLmedblock = []; SvDSLmed = [];


	% CORRECT
	% We replace by NaN the columns of Sv matrix that correpond to the indexes in ind.
	echogram.pings(k).Sv(:,ind) = NaN;


	% NOISE
	echogram.pings(k).SvNoise(:,ind) = echogram.pings(k).SvNoise(:,ind) + single(7);
        ind = []; 

    end
end



























