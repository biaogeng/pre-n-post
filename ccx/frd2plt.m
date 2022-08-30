% convert .frd output from Calculix to Tecplot format
% function plt = frd2plt(fname,subdir)

    fname = 'frequency';
    subdir = 'Z:\inhouse_fea\modal_dynamic\2layer_vf_casefiles_coarse\ccx';

    if ~contains(fname,'.frd','IgnoreCase',true)
        fname = [fname '.frd'];
    end
    
    if ~exist('subdir','var')
        subdir = '.';
    end
    
    fid = fopen(fullfile(subdir,fname));
    
    % global header section
    while ~feof(fid)
        s = fgetl(fid);
        if strcmp(s(1:6),'    2C')
            buff = sscanf(s(7:end),' %d ');
            npt = buff(1);
            break
        end
        
    end
    % 
    x = zeros(npt,3);
    for i=1:npt
        s = fgetl(fid);
        for j=1:3
            ib = (j-1)*20 + 14;
            ie = ib + 19;
            x(i,j) = sscanf(s(ib:ie),'%f');
        end
    end
    
    % 
    while ~feof(fid)
        s = fgetl(fid);
        if numel(s) > 6 && strcmp(s(1:6),'    3C')
            buff = sscanf(s(7:end),' %d ');
            nel = buff(1);
            break
        end
    end    
    
    % assume all tetrahedron
    conn = zeros(nel,4);
    for i=1:nel
        fgetl(fid);
        s = fgetl(fid);
        conn(i,:) = sscanf(s(4:end),' %d ',4);
    end    
    
    fclose(fid);
