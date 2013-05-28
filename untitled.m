
x = 0;
fid = fopen('result.txt','rt');
while (~strcmpi(x,'END_HEADER'))
   x=fgetl(fid); 
end
fgetl(fid); fgetl(fid);
A = zeros(16384,15);
i = 1;
while (x ~= -1)
    x=fgetl(fid); 
    if x ~= -1
        A(i,:) = str2num(x);
    end
        i = i+1;
end
