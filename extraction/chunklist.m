function [list] = chunklist(list_folder, list_start, list_end)
% Input :
%   - list_folder : the list of chunks to consider 
%   - list_start : the list of chunks of the first day to extract
%   - list_end : the list of chunks of the last day to extract 
% Output :
%   - list : the list of chunks to extract
%
% This function determines the list of chunks to extract
% J Guiet

% First chunk
fileschunk       = dir(list_start);
firstchunk       = fileschunk(1).name;

% Last chunk
fileschunk       = dir(list_end);
lastchunk        = fileschunk(end).name;

% List chunk
fileschunk       = dir(list_folder);
id_start         = 0;
id_end           = 0;
for k = 1:length(fileschunk)
    if strcmp(fileschunk(k).name,firstchunk)
        id_start = k;
    end
    if strcmp(fileschunk(k).name,lastchunk)
        id_end   = k;
    end
end

if id_start >= id_end
    disp(['Error reading the list of chunks !'])
end
list = fileschunk(id_start:id_end);
