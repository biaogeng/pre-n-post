% contact plate generator
% bgeng
% created on 2020-02-12
% changed to brick element 2020-10-20

%----------------------------------------------------------------------
% set parameters
clear
offset = [6813,33116]; % node and element number in ccx model
% offset = [0,0];
type = 'brick';

dh = 0.1;            % thickening amplitude and direction
xc = [1.01,0.5,0.75];   % center point of the contact plate
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

if strcmpi(type,'brick') % extra layer
    for j = 1:n2+1
    for k = 1:n1+1
        ipt = ipt + 1;
        nodes(ipt,i0) = midline+dh;
        nodes(ipt,i1) = x1(k);
        nodes(ipt,i2) = x2(j);
    end
    end
end

% elements
if strcmpi(type,'brick')
    el = zeros(n1*n2,8);
    iel = 0;
    nn = (n1+1)*(n2+1);
    for k = 1:n2
        for j = 1:n1
            iel = iel+1;
            p1 = (n1+1)*(k-1)+j;        
            p2 = p1+1;
            p3 = p2+n1+1;
            p4 = p3-1;
            p5 = p1 + nn;
            p6 = p2 + nn;
            p7 = p3 + nn;
            p8 = p4 + nn;
            el(iel,:) = [p1 p2 p3 p4 p5 p6 p7 p8];
        end
    end
    %
    write_ccx_brick_mesh(nodes,el,["x","y","z"],'brick_contact_plate');
else
    el = zeros(n1*n2,4);
    iel = 0;
    for k = 1:n2
        for j = 1:n1
            iel = iel+1;
            p1 = (n1+1)*(k-1)+j;        
            p2 = p1+1;
            p3 = p2+n1+1;
            p4 = p3-1;        
            el(iel,:) = [ p1 p2 p3 p4];
        end
    end
    
    % write tecplot file to check
     write_S4_mesh(nodes,el,["x","y","z"],'S4_contact_plate');
end


%%  write ccx input
if strcmpi(type,'shell')
    fid_ccx = fopen('s4_contact_plate.inp','w');
    ele_type = 'S4';
else
    fid_ccx = fopen('brick_contact_plate.inp','w');
    ele_type = 'C3D8';
end
% nodes
fprintf(fid_ccx, '*node, nset=nplate\r\n');
fprintf(fid_ccx, '**{\r\n');
npt = size(nodes,1);
for i=1:npt
    fprintf(fid_ccx, '%6d, %f, %f, %f\r\n', i+offset(1), nodes(i,:));
end
fprintf(fid_ccx, '**}\r\n');

% element
fprintf(fid_ccx, '*element, type=%s, elset=plate\r\n',ele_type);
fprintf(fid_ccx, '**{\r\n');
nel = size(el,1);
for j=1:nel
    fprintf(fid_ccx, '%6d', j+offset(2));
    fprintf(fid_ccx, ',%6d', el(j,:)+offset(1));
    fprintf(fid_ccx, '\r\n');
end
fprintf(fid_ccx, '**}\r\n');

% plate surface

fprintf(fid_ccx, '*SURFACE, NAME=%s,', 'contact_plane');
fprintf(fid_ccx, 'type = element\r\n');
fprintf(fid_ccx, '**{\r\n');
fprintf(fid_ccx, '%6d,S1\r\n',(1:nel)+offset(2));
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
fprintf(fid_ccx, '*SOLID SECTION, ELSET=plate, MATERIAL=plate_mat\r\n');

% surface contact 
% hardcoded
imedial = 1;
fprintf(fid_ccx,'*SURFACE INTERACTION, NAME = VFcontact\r\n');
fprintf(fid_ccx, '*SURFACE BEHAVIOR, PRESSURE-OVERCLOSURE=LINEAR\r\n');
fprintf(fid_ccx, '%e\r\n',1e3);

ctype = 'NODE TO SURFACE';
fprintf(fid_ccx, '*CONTACTPAIR,interaction=VFcontact,type=%s\r\n',ctype);
fprintf(fid_ccx,'%s, %s\r\n', 'medial_surface_n', 'contact_plane');    

% 
fprintf(fid_ccx, '*BOUNDARY\r\n');
fprintf(fid_ccx, 'nplate,1,3\r\n');

fclose(fid_ccx);



