function fem2plt(subdir,fem)
% write tetrahedron finite element model definition to .plt format for visualization

% homogeneous elements only
% surfaces are written as fetriangle
% node sets are written as felinseg

% subdir - output location
% fem - finite element model

if ~exist(subdir,'dir')
    mkdir(subdir);
end



if ~isfield(fem,'npt')
    fem.npt = size(fem.x,1);
end
if ~isfield(fem,'nel')
    fem.nel = size(fem.conn,1);
end

nnode = size(fem.conn,2);
if nnode == 4
    etype = 'fetetrahedron';
    stype = 'fetriangle';
    nnode_s = 3;
elseif nnode == 8
    etype = 'febrick';
    stype = 'fequadrilateral';
    nnode_s = 4;
else
    fprintf('fem2plt: element type not supported\n');
    return
end

fid = fopen([subdir '/' fem.name '.fem.plt'],'w');
fprintf(fid, 'variables = x,y,z\n');
fprintf(fid, 'zone t = "%s"\n',fem.name);
fprintf(fid, 'zonetype = %s\n',etype);
fprintf(fid, 'datapacking = point\n');
fprintf(fid, 'n=%d, e=%d\n',fem.npt,fem.nel);
fprintf(fid, '%g,%g,%g\n', fem.x');
fprintf(fid, '\n');

fprintf(fid, [repmat('%d ',1,nnode-1) '%d\n'], fem.conn');

% zones
% surfaces
if isfield(fem,'smsh')
for i=1:length(fem.smsh)
    fprintf(fid, 'zone t = "%s"\n',fem.smsh(i).name);
    fprintf(fid, 'zonetype = %s\n',stype);
    fprintf(fid, 'datapacking = point\n');
    fprintf(fid, 'n=%d, e=%d\n',fem.npt,size(fem.smsh(i).conn,1));
    fprintf(fid, 'VARSHARELIST = ([1,2,3]=1)\n');
    
    fprintf(fid, [repmat('%d ',1,nnode_s-1) '%d\n'], fem.smsh(i).conn');
end
end

% volumes
if isfield(fem,'ele')
for i=1:length(fem.ele)
    fprintf(fid, 'zone t = "%s"\n',fem.ele(i).name);
    fprintf(fid, 'zonetype = %s\n',etype);
    fprintf(fid, 'datapacking = point\n');
    fprintf(fid, 'n=%d, e=%d\n',fem.npt,numel(fem.ele(i).set));
    fprintf(fid, 'VARSHARELIST = ([1,2,3]=1)\n');
    fprintf(fid, [repmat('%d ',1,nnode-1) '%d\n'], fem.conn(fem.ele(i).set,:)');
end
end

% node sets
if isfield(fem,'nset')
    for i=1:length(fem.nset)
        
        npt = numel(fem.nset(i).set); % number of nodes in a set
        if npt>0
            fprintf(fid, 'zone t = "%s"\n',fem.nset(i).name);
            fprintf(fid, 'zonetype = felineseg\n');
            fprintf(fid, 'datapacking = point\n');
            fprintf(fid, 'n=%d, e=%d\n',npt,npt);
            % independent node definition for scatter visulization in Tecplot
            fprintf(fid, '%f %f %f\n',fem.x(fem.nset(i).set,:)');
            fprintf(fid, '%d %d\n', [1:npt;1:npt]);
        end
    end  
end
    
fclose(fid);
