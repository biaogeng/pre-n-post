
blk = ccx_tetra_contact_block([0.98,3,3],[-1,0,-1]);

fid = fopen('tetra_block.plt','w');
fprintf(fid, 'VARIABLES = "X", "Y", "Z"\n');
fprintf(fid, 'ZONE T="T5", DATAPACKING=POINT,N=8,E=1,ZONETYPE=FETetrahedron\n');
fprintf(fid, '%g %g %g\n', blk.X');

fprintf(fid, '2 7 4 5\n');

fprintf(fid, 'ZONE T="T1",DATAPACKING=POINT,N=8,E=1,ZONETYPE=FETetrahedron,VARSHARELIST=([1-3]=1)\n');
fprintf(fid, '2 5 4 1\n');
fprintf(fid, 'ZONE T="T2",DATAPACKING=POINT,N=8,E=1,ZONETYPE=FETetrahedron,VARSHARELIST=([1-3]=1)\n');
fprintf(fid, '2 7 5 6\n');
fprintf(fid, 'ZONE T="T3",DATAPACKING=POINT,N=8,E=1,ZONETYPE=FETetrahedron,VARSHARELIST=([1-3]=1)\n');
fprintf(fid, '4 5 7 8\n');
fprintf(fid, 'ZONE T="T4",DATAPACKING=POINT,N=8,E=1,ZONETYPE=FETetrahedron,VARSHARELIST=([1-3]=1)\n');
fprintf(fid, '2 4 7 3\n');
fclose(fid);

%%
noffset = 10100;
eoffset = 30000;
fid = fopen('contact_block.inp','w');
fprintf(fid,'** tetrahedral block for contact surface\n');
fprintf(fid,'*node,nset=contact_block\n');
fprintf(fid, '%d,%g,%g,%g\n', [(1:8)+noffset;blk.X']);
fprintf(fid,'*element,type=C3D4,elset=contact_block\n');
fprintf(fid, '%d,%d,%d,%d,%d,\n', [(1:5)+eoffset;blk.tetra'+noffset]);

fprintf(fid,'*surface,type=element,name=contact_surface\n');
fprintf(fid,'%d,S%d\n',2+eoffset,2);
fprintf(fid,'%d,S%d\n',4+eoffset,4);


fclose(fid);