function gen_fsi_surf_vol(subdir,vf,imed,iside)

% generate surface.dat and volume.dat from vocal fold finite element model


inpdir = [subdir '/inputs'];

if ~exist(inpdir,'dir')
    mkdir(inpdir);
end

%
fid = fopen([inpdir '/surface.dat'],'w');
iL = imed;
npt_s1 = size(vf.smsh(iL).ndlist,1);
nel_s1 = size(vf.smsh(iL).conn,1);

fprintf(fid,'%d %d %d\n',npt_s1,nel_s1,3);
fprintf(fid,'\n');
fprintf(fid,'%15.8f %15.8f %15.8f\n',vf.x(vf.smsh(iL).ndlist,:)');
fprintf(fid,['%12d %12d %12d ' num2str(iside) '\n'],vf.smsh(iL).lconn');
fclose(fid);

surf2plt(inpdir,subdir);

% write volume.dat

fid = fopen([inpdir '/volume.dat'],'w');
fprintf(fid,'%d %d %d\n',size(vf.x,1),size(vf.conn,1),4);
fprintf(fid,'\n');
fprintf(fid,'%15.8f %15.8f %15.8f\n',vf.x');
fprintf(fid,'%12d %12d %12d %12d\n',vf.conn');
fclose(fid);

vol2plt(inpdir,subdir);


