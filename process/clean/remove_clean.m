function echogram = remove_clean(echogram,freq,nfreq)

p_start = echogram.clean(freq).p_start;
p_end   = echogram.clean(freq).p_end;

[m,n] = size(echogram.pings(1).Sv);

p_start(find(p_start<0))=1;
p_start(find(p_start>n))=n;
p_end(find(p_end<0))=1;
p_end(find(p_end>n))=n;

for f = 1:nfreq
    for k = 1:length(p_start)
        echogram.mask(f).SvManual(:,p_start(k):p_end(k))=NaN;
    end
end



   