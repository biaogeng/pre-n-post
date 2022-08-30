function gen_ccx_mesh_sets(fem,subdir,config)

% given the fe model topology
% generate the ccx input for the whole model 

if ~exist('config','var')
    config = [];
end

% set offset
if isfield(config,'offset')
    offset.n = config.offset(1);
    offset.e = config.offset(2);
else
    offset.n = 0;
    offset.e = 0;
end

% set optional output directory
if isfield(config,'outdir')
    subdir = fullfile(subdir,config.outdir,'ccx');
else
    subdir = fullfile(subdir,'ccx');
end

if (~exist(subdir,'dir'))
    mkdir(subdir);
end

if ~isfield(fem,'name')
    fem.name = 'fe_model';
end

[fid_inp, errmsg] = fopen([subdir '/' fem.name '.inp'], 'w');
if fid_inp < 0
    disp(errmsg);
    return
end

[fid_ccx, errmsg] = fopen([subdir '/' fem.name '.msh'], 'w');
if fid_ccx < 0
    disp(errmsg);
    return
end
fprintf(fid_inp,'*include,input=%s\n',[fem.name '.msh']);

fprintf(fid_ccx, '**/ ccx model \r\n');
fprintf(fid_ccx, '**/ %s \r\n', fem.name);
fprintf(fid_ccx, '**/ generated with Matlab, %s\r\n', date);
fprintf(fid_ccx, '\r\n');

%% msh
% xyz
if size(fem.x,1)> 0
    fprintf(fid_ccx, '*node, nset=nall\r\n');
    fprintf(fid_ccx, '**{\r\n');
    fem.npt = size(fem.x,1);
    for i=1:fem.npt
        fprintf(fid_ccx, '%6d, %f, %f, %f\r\n', i+offset.n, fem.x(i,:)); 
    end
    fprintf(fid_ccx, '**}\r\n');
end

% connectivity
if size(fem.conn,1)>0
    nnode = size(fem.conn,2);
    if nnode == 8
        etype = 'C3D8';
    elseif nnode == 4
        etype = 'C3D4';
    else
        fprintf('gen_ccx_mesh_sets: %d node type element not supported\n',nnode);
    end
    fprintf(fid_ccx, '*element, type=%s, elset=all\r\n',etype);
    fprintf(fid_ccx, '**{\r\n');
    for i=1:size(fem.conn,1)
        fprintf(fid_ccx, '%6d', i+offset.e);
        fprintf(fid_ccx, ',%6d', fem.conn(i,:)+offset.n);
        fprintf(fid_ccx, '\n');
    end
    fprintf(fid_ccx, '**}\r\n');
end
fclose(fid_ccx);
%% element sets
if isfield(fem,'ele')
eledir = [subdir '/elsets'];
if (~exist(eledir,'dir'))
    mkdir(eledir);
end


% body
for i=1:length(fem.ele)
    [fid_ccx, errmsg] = fopen([eledir '/' fem.ele(i).name '.nam'], 'w');
    if fid_ccx < 0
        disp(errmsg);
        return
    end
    
    fprintf(fid_ccx, '*elset,elset=%s\r\n',fem.ele(i).name);
    fprintf(fid_ccx, '**{\r\n');
    nel = length(fem.ele(i).set);
    for j=1:nel
        fprintf(fid_ccx, '%6d', fem.ele(i).set(j)+offset.e);
        fprintf(fid_ccx, '\r\n');
    end
    fprintf(fid_ccx, '**}\r\n');
    fclose(fid_ccx);
    fprintf(fid_inp,'*include,input=elsets/%s\n',[fem.ele(i).name '.nam']);
end
end


%% node sets
if isfield(fem,'nset') && ~isfield(fem,'bset')
    fem.bset = fem.nset;
end

if isfield(fem,'bset') || isfield(fem,'smsh')
    nodedir = [subdir '/bsets'];
    if (~exist(nodedir,'dir'))
        mkdir(nodedir);
    end
end
if isfield(fem,'smsh')
    % from surfaces
    for i=1:length(fem.smsh)
        [fid_ccx, errmsg] = fopen([nodedir '/' fem.smsh(i).name '.nam'], 'w');
        if fid_ccx < 0
            disp(errmsg);
            return
        end
        fprintf(fid_ccx, '*NSET, NSET=n%s\r\n', fem.smsh(i).name);
        fprintf(fid_ccx, '**{\r\n');
        fprintf(fid_ccx, '%5d,\r\n',fem.smsh(i).ndlist+offset.n);
        fprintf(fid_ccx, '**}\r\n');
        fclose(fid_ccx);
        fprintf(fid_inp,'*include,input=bsets/%s\n',[fem.smsh(i).name '.nam']);
    end
end


% from boundaries
if isfield(fem,'bset')
    for i=1:length(fem.bset)
        [fid_ccx, errmsg] = fopen([nodedir '/' fem.bset(i).name '.nam'], 'w');
        if fid_ccx < 0
            disp(errmsg);
            return
        end

        fprintf(fid_ccx, '*NSET, NSET=n%s\r\n', fem.bset(i).name);
        fprintf(fid_ccx, '**{\r\n');
        fprintf(fid_ccx, '%5d,\r\n',fem.bset(i).set+offset.n);
        fprintf(fid_ccx, '**}\r\n');    
        fclose(fid_ccx);
        fprintf(fid_inp,'*include,input=bsets/%s\n',[fem.bset(i).name '.nam']);
    end
end

%% surfaces (and distributed load files)
if isfield(fem,'surf') && ~isfield(fem,'sset')
    fem.sset = fem.surf;
end

if isfield(fem,'sset')
    surfdir = [subdir '/surfaces'];
    if (~exist(surfdir,'dir'))
        mkdir(surfdir);
    end


    for i=1:length(fem.sset)
        [fid_ccx, errmsg] = fopen([surfdir '/' fem.sset(i).name '.sfc'], 'w');
        if fid_ccx < 0
            disp(errmsg);
            return
        end

        fprintf(fid_ccx, '*SURFACE, NAME=%s,', fem.sset(i).name);
        fprintf(fid_ccx, 'type = element\r\n');
        fprintf(fid_ccx, '**{\r\n');
        fid_dlo = fopen([subdir '/' fem.sset(i).name '.dlo'], 'w');
        fprintf(fid_dlo, '** %s\r\n', fem.sset(i).name);
        nel_s = size(fem.sset(i).side,1);
        for j=1:nel_s
            iel = fem.sset(i).side(j,1);
            iface = fem.sset(i).side(j,end);
            fprintf(fid_ccx, '%6d,S%d\r\n', iel+offset.e,iface);
            fprintf(fid_dlo, '%6d,P%d,-1\r\n', iel+offset.e,iface);
        end

        fprintf(fid_ccx, '**}\r\n');
        fclose(fid_dlo);
        fclose(fid_ccx);
        fprintf(fid_inp,'*include,input=surfaces/%s\n',[fem.sset(i).name '.sfc']);
    end
end

fclose(fid_inp);


