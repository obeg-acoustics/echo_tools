function echogram = manual_clean(echogram,freq,nfreq)

for k=1:nfreq
    tmp = echogram.pings(freq).Sv.*echogram.mask(k).SvFalseBot.*echogram.mask(k).SvBot.*echogram.mask(k).SvManual;
end

figure, imagesc(tmp)
caxis([-100,-50])
hold on, plot(echogram.bottom.bottom_depth,'r*')
hold on, plot([1,length(echogram.bottom.bottom_depth)],[20,20],'r-')
hold on, plot([1,length(echogram.bottom.bottom_depth)],[520,520],'r-')
input('ZOOM ?')
finished = 0;
p_start = [];
p_end = [];
while finished == 0
    display('SELECT SECTION TO REMOVE')
    [ping,range] = ginput(2);
    keep = input(['REMOVE SECTION ', num2str(ping(1)), ' TO ', num2str(ping(2)), ' (1/0): ']);
    if ~isempty(finished)
        if keep == 1
            p_start = [p_start,ping(1)];
            p_end = [p_end,ping(2)];
        end
    end
    finished = input('MOVE/FINISH(=1)? ');
    if isempty(finished)
        finished = 0;
    end
    if (finished ~=1)
        finished = 0;
    end
end
echogram.clean(freq).p_start = p_start;
echogram.clean(freq).p_end = p_end;