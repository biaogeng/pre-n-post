function [v,el] = read_surface_dat(inpdir)
% read surface.dat

    fname = fullfile(inpdir,'surface.dat');
    fid = fopen(fname);
    
    tmp = fscanf(fid,'%d',3);
    switch tmp(3)
        case 3 % 3-node triangle
            v = fscanf(fid,'%f',[3,tmp(1)])';
            el = fscanf(fid,'%d',[4,tmp(2)])';
            el(:,4) = []; % last column is vocal fold side info
            
        otherwise
            fprintf('please add support for %d-node surface mesh\n',tmp(3));
    end
    fclose(fid);