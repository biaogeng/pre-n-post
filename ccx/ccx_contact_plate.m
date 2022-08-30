% contact plate generator
% bgeng
% created on 2020-02-12

%----------------------------------------------------------------------
% set parameters
clear
offset = [6813,33116]; % node and element number in ccx model

xc = [1,0.5,0.75];   % center point of the contact plate
plane = 'x';           % orientation of contact plate

dl = 0.1;              % grid interval
L1 = 1.2;              % length in 1st dimension
L2 = 2;              % length in 2nd dimension


%----------------------------------------------------------------------

switch plane
    case {'X','x'}
        i0 = 1;
        i1 = 2;
        i2 = 3;
        midline = xc(1);
    case {'Y','y'}
        i0 = 2;
        i1 = 3;
        i2 = 1;
        midline = xc(2);
    case {'Z','z'}
        i0 = 3;
        i1 = 1;
        i2 = 2;
        midline = xc(3);
end


n1 = ceil(L1/dl);
n2 = ceil(L2/dl);
dl1 = L1/n1;
dl2 = L2/n2;

x1 = xc(i1)-L1/2:dl1:xc(i1)+L1/2;
x2 = xc(i2)-L2/2:dl2:xc(i2)+L2/2;

npt = (n1+1)*(n2+1);
nodes = zeros(npt,3);

% nodes
ipt = 0;
for j = 1:n2+1
    for k = 1:n1+1
        ipt = ipt + 1;
        nodes(ipt,i0) = midline;
        nodes(ipt,i1) = x1(k);
        nodes(ipt,i2) = x2(j);
    end
end

% elements
el = zeros(n1*n2,4);
iel = 0;
for k = 1:n2
    for j = 1:n1

        iel = iel+1;
        p1 = (n1+1)*(k-1)+j;        
        p2 = p1+1;
        p3 = p2+n1+1;
        p4 = p3-1;        
%         p2 = p1+n1+1;
%         p3 = p2+1;
%         p4 = p1+1;
        el(iel,:) = [ p1 p2 p3 p4];
        
    end
end


% write tecplot file to check
 write_S4_mesh(nodes,el,["x","y","z"],'S4_contact_plate');


%%  write ccx input
fid_ccx = fopen('s4_contact_plate.inp','w');

% nodes
fprintf(fid_ccx, '*node, nset=nplate\r\n');
fprintf(fid_ccx, '**{\r\n');
npt = size(nodes,1);
for i=1:npt
    fprintf(fid_ccx, '%6d, %f, %f, %f\r\n', i+offset(1), nodes(i,:));
end
fprintf(fid_ccx, '**}\r\n');

% element
fprintf(fid_ccx, '*element, type=S4, elset=%s\r\n','plate');
fprintf(fid_ccx, '**{\r\n');
nel = size(el,1);
for j=1:nel
    fprintf(fid_ccx, '%6d', j+offset(2));
    fprintf(fid_ccx, ',%6d', el(j,:)+offset(1));
    fprintf(fid_ccx, '\r\n');
end
fprintf(fid_ccx, '**}\r\n');

% material
fprintf(fid_ccx,'*MATERIAL,NAME=%s\r\n','plate_mat');
fprintf(fid_ccx, '**{\r\n');

fprintf(fid_ccx,'*ELASTIC\r\n');
fprintf(fid_ccx,'%10.3E, %4.2f\r\n',[1e6 0.45]);
fprintf(fid_ccx,'*DENSITY\r\n');
fprintf(fid_ccx,' %g\r\n',10);

fprintf(fid_ccx, '**}\r\n');    
    
% section    
fprintf(fid_ccx, '*SHELL SECTION, ELSET=plate, MATERIAL=plate_mat,');
fprintf(fid_ccx, 'offset=%f\r\n',0.5);
fprintf(fid_ccx, '%f\r\n',0.1); % thickness

% plate surface
fprintf(fid_ccx, '*SURFACE, NAME=%s,', 'contact_plane');
fprintf(fid_ccx, 'type = element\r\n');
fprintf(fid_ccx, '**{\r\n');
fprintf(fid_ccx, '%s,SPOS\r\n', 'plate');
fprintf(fid_ccx, '**}\r\n');        

% surface contact 
% hardcoded
imedial = 1;
fprintf(fid_ccx,'*SURFACE INTERACTION, NAME = VFcontact\r\n');
fprintf(fid_ccx, '*SURFACE BEHAVIOR, PRESSURE-OVERCLOSURE=LINEAR\r\n');
fprintf(fid_ccx, '%e\r\n',1e3);


ctype = 'SURFACE TO SURFACE';
fprintf(fid_ccx, '*CONTACTPAIR,interaction=VFcontact,type=%s\r\n',ctype);
fprintf(fid_ccx,'%s, %s\r\n', 'medial_surface', 'contact_plane');    

% 
fprintf(fid_ccx, '*BOUNDARY\r\n');
fprintf(fid_ccx, 'nplate,1,6\r\n');

fclose(fid_ccx);



