function frd = read_frd(subdir,fname)

% read .frd output from CCX simulation 
% ascii format only


% clear;clc
% subdir = 'Y:\bct_talker\tests\2021-09-22-canine-modal\casefiles\solid';
% fname = 'canine_eigen500';

if ~strcmpi(fname(end-3:end),'.frd')
    fname = [fname '.frd'];
end

nmode = 0;
fid = fopen(fullfile(subdir,fname));
% count time frames / number of eigenmodes
while ~feof(fid)
    s = fgetl(fid);
    if contains(s,'MODAL')
        nmode = nmode + 1;
    end
end

eigf = zeros(nmode,1);
eigv = cell(nmode,1);

%

frewind(fid); %

while ~feof(fid)
    s = fgetl(fid);
    if strcmp(s(1:6),'    2C') % coordinate section header
        data = sscanf(s(7:end),'%d ');
        npt = data(1);
        break
    end
end 

x = zeros(npt,3);
dw = 20; % data entry width
for i=1:npt
    s = fgetl(fid);
    for j=1:3
        ib = (j-1)*dw + 14; % index offset
        ie = ib + dw - 1;
        x(i,j) = sscanf(s(ib:ie),'%f');
    end
end 

while ~feof(fid)
    s = fgetl(fid);
    if numel(s)>=6 && strcmp(s(1:6),'    3C')
        data = sscanf(s(7:end),'%d ');
        nel = data(1);
        break
    end
end 

for i=1:nel
    fgetl(fid);
    fgetl(fid);
%     for j=1:3
%         ib = (j-1)*dw + 14; % index offset
%         ie = ib + dw - 1;
%         x(i,j) = sscanf(s(ib:ie),'%f');
%     end
end 


% read eigenmodes
imode = 0;
while ~feof(fid)

    s = fgetl(fid);
    if numel(s)>=7 && strcmp(s(1:7),'  100CL')
        imode = imode + 1;
        
        if imode > nmode
            break
        end 
        
        data = sscanf(s(8:end),'%f ');
        eigf(imode) = data(2);
        for i=1:5
            fgetl(fid);
        end
        
        eigv{imode} = zeros(npt,3);
        for i=1:npt
            s = fgetl(fid);
            for j=1:3
                ib = (j-1)*dw + 14; % index offset
                ie = ib + dw - 1;
                eigv{imode}(i,j) = sscanf(s(ib:ie),'%f');
            end
        end 
        fprintf('.');
        if mod(imode,100)==0
            fprintf('\n'); 
        end
        
    end
end 


fclose(fid);

frd.x = x;
frd.nel = nel;
frd.eigf = eigf;
frd.eigv = eigv;

