function unstruc2plt(subdir,fname)

if ~exist('fname','var')
    fname = 'unstruc_surface_in.dat';
end

fid = fopen(fullfile(subdir,fname));
% while ~feof(fid)
    
    npt = fscanf(fid, '%d',1);
    nel = fscanf(fid, '%d',1);

    buffer = fscanf(fid, ' %d %f %f %f\n', [4 npt])';
    mesh.x = buffer(:,2:end);

    buffer = fscanf(fid, ' %d ', [4 nel])';
    mesh.el = buffer(:,2:end);
%     buffer = fscanf(fid, '%f',3);

    s=mesh;
    write_S3_mesh(s.x,s.el,["x" "y" "z"],erase(fname,'.dat'),subdir);

% end
fclose(fid);

