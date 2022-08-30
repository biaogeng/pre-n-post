function gen_cgx_mesh_sets(fem,subdir)

% given the fe model topology
% generate the cgx input for the whole model 
% slightly different from ccx input


% fem=vf;
subdir = [subdir '/cgx'];
if (~exist(subdir,'dir'))
    mkdir(subdir);
end


[fid_inp, errmsg] = fopen([subdir '/' fem.name '.inp'], 'w');
if fid_inp < 0
    disp(errmsg);
    return
end

[fid_ccx, errmsg] = fopen([subdir '/' fem.name '.xyz'], 'w');
if fid_ccx < 0
    disp(errmsg);
    return
end
fprintf(fid_inp,'*include,input=%s\n',[fem.name '.xyz']);

fprintf(fid_ccx, '**/ ccx model \r\n');
fprintf(fid_ccx, '**/ %s \r\n', fem.name);
fprintf(fid_ccx, '**/ generated with Matlab, %s\r\n', date);
fprintf(fid_ccx, '\r\n');

%% coordinates
fprintf(fid_ccx, '*node, nset=nall\r\n');
fprintf(fid_ccx, '**{\r\n');
fem.npt = size(fem.x,1);
for i=1:fem.npt
    fprintf(fid_ccx, '%6d, %f, %f, %f\r\n', i, fem.x(i,:)./1); % model scaling
end
fprintf(fid_ccx, '**}\r\n');
fclose(fid_ccx);



%% topology
eledir = [subdir '/elsets'];
if (~exist(eledir,'dir'))
    mkdir(eledir);
end


% body
for i=1:length(fem.ele)
    [fid_ccx, errmsg] = fopen([eledir '/' fem.ele(i).name '.ele'], 'w');
    if fid_ccx < 0
        disp(errmsg);
        return
    end
    
    fprintf(fid_ccx, '*element, type=%s, elset=%s\r\n', ...
                                fem.ele(i).type,fem.ele(i).name);
    fprintf(fid_ccx, '**{\r\n');
    nel = length(fem.ele(i).set);
    for j=1:nel
        fprintf(fid_ccx, '%6d', fem.ele(i).set(j));
        fprintf(fid_ccx, ',%6d', fem.ele(i).conn(j,:));
        fprintf(fid_ccx, '\r\n');
    end
    fprintf(fid_ccx, '**}\r\n');
    fclose(fid_ccx);
    fprintf(fid_inp,'*include,input=elsets/%s\n',[fem.ele(i).name '.ele']);
end



%% node sets
% from surfaces
nodedir = [subdir '/bsets'];
if (~exist(nodedir,'dir'))
    mkdir(nodedir);
end

for i=1:length(fem.smsh)
    [fid_ccx, errmsg] = fopen([nodedir '/' fem.smsh(i).name '.nam'], 'w');
    if fid_ccx < 0
        disp(errmsg);
        return
    end
    
    
    fprintf(fid_ccx, '*NSET, NSET=n%s\r\n', fem.smsh(i).name);
    fprintf(fid_ccx, '**{\r\n');
    fprintf(fid_ccx, '%5d,\r\n',fem.smsh(i).ndlist);
    fprintf(fid_ccx, '**}\r\n');
    fclose(fid_ccx);
    fprintf(fid_inp,'*include,input=bsets/%s\n',[fem.smsh(i).name '.nam']);
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
        fprintf(fid_ccx, '%5d,\r\n',fem.bset(i).nset);
        fprintf(fid_ccx, '**}\r\n');    
        fclose(fid_ccx);
        fprintf(fid_inp,'*include,input=bsets/%s\n',[fem.bset(i).name '.nam']);
    end
end

%% surfaces (and distributed load files)
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
        fprintf(fid_ccx, '%6d,S%d\r\n', iel,iface);
        fprintf(fid_dlo, '%6d,P%d,-1\r\n', iel,iface);
    end
    
    fprintf(fid_ccx, '**}\r\n');
    fclose(fid_dlo);
    fclose(fid_ccx);
    fprintf(fid_inp,'*include,input=surfaces/%s\n',[fem.sset(i).name '.sfc']);
end


fclose(fid_inp);


