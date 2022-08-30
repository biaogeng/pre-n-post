function [v,el] = read_volume_dat(inpdir)
% read volume.dat

    fname = fullfile(inpdir,'volume.dat');
    fid = fopen(fname);
    
    tmp = fscanf(fid,'%d',3);
    switch tmp(3)
        case 4 % 4-node triangle
            v = fscanf(fid,'%f',[3,tmp(1)])';
            el = fscanf(fid,'%d',[4,tmp(2)])';            
        otherwise
            fprintf('please add support for %d-node volume mesh\n',tmp(3));
    end
    fclose(fid);