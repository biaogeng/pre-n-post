function [submodel,nodelist,elelist] = extract_sub_zones(fem,sname,esets)
% [submodel,nodelist,elelist] = extract_sub_zones(fem,sname,esets)
% this function extracts a sub set of a full finite element model
% returns submodel set definition and sub-to-full maps

% fem - finite element model definition
% sname - submodel name
% esets - list of element sets to be extracted
% related surface and node sets are automatically extracted

% set sub model
if ~isfield(fem,'nset') && isfield(fem,'bset')
    fem.nset = fem.bset;
    for i=1:numel(fem.bset)
        fem.nset(i).set = fem.bset(i).nset;
    end
end

submodel = fem;
submodel.name = sname;

ex_eset = false(numel(fem.ele),1);

% select components
% element sets
if isempty(esets)
    fprintf('esets can not be empty!\n');
else
    ex_eset(esets)=true();
end

if ~isfield(fem,'nel')
    fem.nel = size(fem.conn,1);
end

irm = true(fem.nel,1); % index of elements to be removed
for i=1:numel(esets)
    j = esets(i);
    ele_list = submodel.ele(j).set;
    irm(ele_list) = false; % exclude elements referenced in submodel
    fprintf('extracted %s\n',fem.ele(j).name);
end

% 
idx = (1:size(fem.conn,1))';
idx(irm) = [];
elelist = idx;
[~,ele_map] = ismember((1:size(fem.conn,1))',idx); % full to submodel element map

% remove unneeded sets
submodel.conn(irm,:)=[];
submodel.ele(~ex_eset) = [];

% re index
nodelist = unique(submodel.conn);
submodel.x = fem.x(nodelist,:);

% reverse correspondence for nodes
% full 2 sub model node map
npt = size(fem.x,1);
[~,node_map] = ismember((1:npt)',nodelist);

% new connectivity
for i=1:size(submodel.conn,1)
    % connectivity in submodel index
    submodel.conn(i,:) = node_map(submodel.conn(i,:));
end

% surfaces
if isfield(submodel,'surf')
    submodel.nsurf = numel(submodel.surf);
    irm_s = false(submodel.nsurf,1); 
    for i=1:numel(submodel.surf) % check incompatible surface
        ne = size(submodel.surf(i).side,1);
        irm_se = false(ne,1);
        for ie=1:ne % check if referenced element has been removed
            iel = submodel.surf(i).side(ie,1);
            if irm(iel)
                irm_se(ie) = true;
            end
        end
        submodel.surf(i).side(irm_se,:)=[];
        if isempty(submodel.surf(i).side) % all elements removed
           irm_s(i) = true; % remove surface
        else
           ne1 = size(submodel.surf(i).side,1);
           if ne~=ne1
               fprintf('extracted surface %s,%d->%d\n',submodel.surf(i).name,ne,ne1);
           else
               fprintf('extracted surface %s,intact\n',submodel.surf(i).name);    
           end
        end
        submodel.surf(i).side(:,1) = ele_map(submodel.surf(i).side(:,1));
    end
    submodel.surf(irm_s) = [];
end

% bodies
submodel.n_elset = numel(submodel.ele);
for i=1:numel(submodel.ele)
   submodel.ele(i).set = ele_map(submodel.ele(i).set);
   submodel.ele(i).conn = submodel.conn(submodel.ele(i).set,:);
end

% boundary node sets
if isfield(submodel,'nset')
    irm_n = false(numel(submodel.nset),1); % check incompatible node set
    for i=1:numel(submodel.nset)
       np = numel(submodel.nset(i).set);
       irm_p = false(np,1);
       for ip=1:np
           ipt = submodel.nset(i).set(ip);
           if ~node_map(ipt)
               irm_p(ip) = true;
           end
       end 
       submodel.nset(i).set(irm_p)=[];
        if isempty(submodel.nset(i).set) % all elements removed
           irm_n(i) = true; % remove surface
        else
           np1 = size(submodel.nset(i).set,1);
           if np~=np1
               fprintf('extracted node set %s,%d->%d\n',submodel.nset(i).name,np,np1);
           else
               fprintf('extracted node set %s,intact\n',submodel.nset(i).name);    
           end
           submodel.nset(i).set = node_map(submodel.nset(i).set);
        end
    end
    submodel.nset(irm_n) = [];
end

if isfield(submodel,'nset')
submodel.n_nset = numel(submodel.nset);
end
% other fields
submodel.npt = size(submodel.x,1);
submodel.nel = size(submodel.conn,1);

if isfield(submodel,'bset')
    submodel = rmfield(submodel,'bset');
end
if isfield(submodel,'nsurf')
    submodel = rmfield(submodel,'nsurf');
end

% regenerate surface mesh topology
if isfield(submodel,'smsh')
    submodel=rmfield(submodel,'smsh');
end
if isfield(submodel,'surf')
submodel.n_surf = numel(submodel.surf);

for i=1:numel(submodel.surf)
    submodel.smsh(i) = sset2smesh(submodel.x,submodel.conn,submodel.surf(i));
end
end
