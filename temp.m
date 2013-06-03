for i = 1:200
    if ~isempty(data(i).chn)
        for j = 1:length(data(1))
            [a b] = regexp(data(i).chn(j).ch_name,'(\S*?\.\.\S\S)E','match');
            if (b)
                [a b] = regexp(data(i).chn(j).ch_name,'(\S*?\.\.\S\S)\S','tokens','match');
                if strcmp(strcat(a{1}{1},'N'),data(i).chn(j+1).ch_name) && strcmp(strcat(a{1}{1},'Z'),data(i).chn(j+2).ch_name)
                   data(i).chn(j+1).Q = data(i).chn(j).Q;
                   data(i).chn(j+1).p1 = data(i).chn(j).p1;
                   data(i).chn(j+1).p2 = data(i).chn(j).p2;
                   data(i).chn(j+1).p3 = data(i).chn(j).p3;
                   data(i).chn(j+1).p4 = data(i).chn(j).p4;
                   data(i).chn(j+1).modtime = data(i).chn(j).modtime;
                   data(i).chn(j+2).Q = data(i).chn(j).Q;
                   data(i).chn(j+2).p1 = data(i).chn(j).p1;
                   data(i).chn(j+2).p2 = data(i).chn(j).p2;
                   data(i).chn(j+2).p3 = data(i).chn(j).p3;
                   data(i).chn(j+2).p4 = data(i).chn(j).p4;
                   data(i).chn(j+2).modtime = data(i).chn(j).modtime;
                   
                end
            end
        end
    end
end
