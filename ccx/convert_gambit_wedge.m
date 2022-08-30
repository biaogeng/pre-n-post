% converts wedge element mesh from Gambit .neu format to CCX input
clc;clear
subdir = 'C:\Users\gbb\Desktop\working\indentor';
fname = 'indentor.neu';
neu = read_neu_file(fullfile(subdir,fname));



fid = fopen(fullfile(subdir,'indentor.inp'),'w');
fprintf(fid,'*node,nset=all\n');
fprintf(fid,'**{\n');
ind = 1:size(neu.x,1);
fprintf(fid,'%6d,%12.8f,%12.8f,%12.8f\n',[ind' neu.x]');
fprintf(fid,'**}\n');
fprintf(fid,'*element,type=C3D6,elset=indentor\n');
fprintf(fid,'**{\n');
ind = 1:size(neu.el,1);
fprintf(fid,'%6d,%7d,%7d,%7d,%7d,%7d,%7d\n',[ind' neu.el]');
fprintf(fid,'**}\n');


wedge_map = [3 4 5 1 2];

for i=1:length(neu.sset)
    fprintf(fid,'*surface,name=%s,type=element\n',neu.sset(i).name);
    fprintf(fid,'**{\n');
    neu.sset(i).side(:,2) = wedge_map(neu.sset(i).side(:,2));
    fprintf(fid,'%6d,S%d\n',neu.sset(i).side');
    fprintf(fid,'**}\n');
end

wedge_nodes = {[1 2 3],[4 5 6],[1 2 5 4],[2 3 6 5],[3 1 4 6]};
for i=1:length(neu.sset)
    inodes = [];
    fprintf(fid,'*nset,nset=n_%s\n',neu.sset(i).name);
    fprintf(fid,'**{\n');
    for j=1:size(neu.sset(i).side,1)
    
    iel = neu.sset(i).side(j,1);
    iside = neu.sset(i).side(j,2);
    inodes = [inodes neu.el(iel,wedge_nodes{iside})];
    
    end
    fprintf(fid,'%d,\n',unique(inodes));
    fprintf(fid,'**}\n');
end
fclose(fid);

