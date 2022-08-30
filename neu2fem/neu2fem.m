function fem = neu2fem (subdir,fname,modelname,config)
%
%  reads in a .neu file and outputs fem model in CCX format
%  files saved in the same directory
%  also returns the data structure
%  tetrahedron mesh only
% 

if ~exist('config','var')
    config = [];
end

%% read in neu file
if ~strcmp(fname(end-3:end),'.neu')
    fname = [fname '.neu'];
end
neufile = [subdir '/' fname];
matfile = [subdir '/' fname '.mat'];
if isnewer(neufile,matfile)
    % read
    fprintf('reading from input %s ...\n',neufile);
    neu = read_neu_file(neufile);
    % save
    save(matfile,'neu');
else
    %
    fprintf('loading from mat file %s ...\n',matfile);
    load(matfile);
end

%% convert mesh definition to CCX input format 
% (node and face order are different between CCX and Gambit)
fem.name = modelname;

% transform mesh
fem.x = neu.x;
if isfield(config,'transforms')
    T = config.transforms;
    for i=1:numel(T)
        switch T{i}.type
            case 'rotate'
                origin = [0 0 0];
                if isfield(T{i},'origin')
                    origin = T{i}.origin;
                end
                fem.x = rotate_mesh(fem.x,T{i}.axis,T{i}.angle,origin);
            case 'translate'
                fem.x = fem.x + T{i}.dX;
            case 'scale'
                fem.x = fem.x * T{i}.K;
            otherwise
                fprintf('transform type %s not supported, no action taken.\n',T{i}.type);
        end
    end
end

fem.npt = size(fem.x,1);
fem.nel = size(neu.el,1);
fem.conn = reorder_conn(neu.el);
nnode = size(fem.conn,2);

switch nnode
    case 8
        ele_type = 'C3D8';
    case 4
        ele_type = 'C3D4';
    otherwise
        fprintf('element with %d nodes not supported!\n',nnode);
end


%
fem.sset = neu.sset;
for i=1:numel(neu.sset)
    if strcmp(neu.sset(i).name,'wall')
        fem.sset(i).name = ['s-' modelname '-wall'];
    end
    fem.sset(i).side =  reorder_element_face(ele_type,fem.sset(i).side);
    fem.smsh(i) = sset2smesh(fem.x,fem.conn,fem.sset(i));
end


% fem.smsh = neu.smsh;

%
fem.n_elset = length(neu.elset);
for i=1:fem.n_elset
    fem.ele(i).name = neu.elset_name{i};
    fem.ele(i).type = ele_type;
    fem.ele(i).set  = neu.elset{i};
    fem.ele(i).conn = fem.conn(fem.ele(i).set,:);
end


%% write files
% write ccx files
gen_ccx_mesh_sets(fem,subdir,config);

% plt
if isfield(config,'outdir')
    fem2plt(fullfile(subdir,config.outdir),fem);
else
    fem2plt(subdir,fem);
end




