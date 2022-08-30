%%
%  get model definitions from ccx input file
%  c3d4 element only
%  
%  assuming element sets only contains one type of elements

function fem = inp2fem(subdir,inp,cfg)
% clear;clc
% subdir = 'H:\bgeng_working\canine_mesh_indie\casefiles_coarse';
% inp = 'posture.inp';

% clear
% subdir = '.';
% inp = 'contact_block.inp';

if ~exist('cfg','var')
    cfg=[];
end


if ~exist(fullfile(subdir,inp),'file')
    inp = [inp '.inp'];
end

inplines = filter_ccx_inp(subdir, inp);
%
sz = count_model_sizes(inplines);


% pre allocate
fem.name = inp(1:end-4);
fem.npt = sz.npt;
fem.nel = sz.nel;

fem.x = zeros(sz.npt,4);
fem.conn = zeros(sz.nel,sz.npe+1);
fem.etype = cell(sz.nel,1); % character string for element type

fem.ele = struct('name',{},'type',{},'conn',{},'set',{},'iset',{}); %iset: element set index
fem.surf = struct('name',{},'side',{});
fem.nset = struct('name',{},'set',{});

npt = 0;
nel = 0;
n_elset = 0;
n_surf = 0;
n_nset = 0;

%%
nlines = length(inplines);
il = 1;
s = split(inplines{il},',');

while il<nlines
    
    if strcmpi(s{1},'*NODE') % read nodal coordiantes
        is_set = false;
        n = numel(s);
        for i=2:n % look for nset definition
            if contains(s{i},'NSET=','IgnoreCase',true)
                is_set = true;
                iset = 0;
                setname = s{i}(6:end);
                for j=1:n_nset % check if set already exists
                    if strcmpi(fem.nset(j).name,setname)
                        iset = j;
                        break
                    end
                end
                
                if iset == 0 % new set
                    n_nset = n_nset+1;
                    iset = n_nset;
                    fem.nset(iset).name = setname;
%                     fem.nset(iset).iset = iset;
                end
                break
            end
        end
        
        npt_s = npt;        
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            n = length(s);
            
            if s{1}(1)=='*' % new keyword
                break
            end
            
            npt = npt + 1;
            fem.x(npt,1) = sscanf(s{1},'%d');
            for j=2:n
                fem.x(npt,j) = sscanf(s{j},'%f');
            end
        end
        npt_e = npt;
        if is_set
            fem.nset(iset).set = unique([fem.nset(iset).set;fem.x(npt_s+1:npt_e,1)]);
        end 
        continue
    end
    if strcmpi(s{1},'*ELEMENT') % read elements
        is_set = false;
        n = numel(s);
        
        for i=2:n % check element type
            if contains(s{i},'TYPE=','IgnoreCase',true)
                break;
            end
        end
        
        if contains(s{i},'c3d4','IgnoreCase',true) || ...
           contains(s{i},'c3d8','IgnoreCase',true)
            etype = s{i}(6:end);
        else
            fprintf('element %s not supported\n',s{i});
            
            while(il<nlines)
                il=il+1;
                s = split(inplines{il},',');
                n = length(s);

                if s{1}(1)=='*' % new keyword
                    break
                end
            end
            continue
        end
        
        for i=2:n % look for elset definition
            if contains(s{i},'ELSET=','IgnoreCase',true)
                is_set = true;
                iset = 0;
                setname = s{i}(7:end);
                for j=1:n_elset % check if set already exists
                    if strcmpi(fem.ele(j).name,setname)
                        iset = j;
                        break
                    end
                end
                
                if iset == 0
                    n_elset = n_elset+1;
                    iset = n_elset;
                    fem.ele(iset).name = setname;
                    fem.ele(iset).iset = iset;
                end
                
                break
            end
        end
                
        nel_s = nel;
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            n = length(s);
            if s{1}(1)=='*' % new keyword
                break
            end
            
            % c3d4,c3d8 element
            nel = nel + 1;
            fem.etype{nel} = etype;
            for j=1:n
                fem.conn(nel,j) = sscanf(s{j},'%d');
            end
        end
        nel_e = nel;
        
        if is_set
            fem.ele(iset).set = unique([fem.ele(iset).set;fem.conn(nel_s+1:nel_e,1)]);
        end 
        
        continue
    end
    if strcmpi(s{1},'*ELSET') % 
        setname = s{2}(7:end);
        for j=1:n_elset % check if set already exists
            if strcmpi(fem.ele(j).name,setname)
                iset = j;
                break
            else
                n_elset = n_elset+1;
                iset = n_elset;
                fem.ele(iset).name = setname;
                fem.ele(iset).iset = iset;
                break
            end
        end         
        
        nn = 0;
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            n = length(s);
            if s{1}(1)=='*' % new keyword
                if nn == 0
                   fprintf('elset %s is empty\n', setname);
                end
                break
            end
            
            for j=1:n
                nn = nn + 1;
                fem.ele(iset).set = [fem.ele(iset).set;sscanf(s{j},'%d')];
            end
        end
        fem.ele(iset).set = unique(fem.ele(iset).set);
        continue
    end
    if strcmpi(s{1},'*SURFACE') && ~contains(inplines{il},'TYPE=NODE','IgnoreCase',true)% 
        
        n_surf = n_surf + 1;
        
        for i=2:n
            if contains(s{i},'NAME=','IgnoreCase',true)
                fem.surf(n_surf).name = s{i}(6:end);
                continue
            end
        end
        
        if isempty(fem.surf(n_surf).name)
            fem.surf(n_surf).name = sprintf('surface%d',n_surf);
            fprintf('default name assigned to surface %d\n',n_surf);
        end
        
        nn = 0;
        
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            n = length(s);
            if s{1}(1)=='*' % new keyword
                if nn == 0
                   fprintf('surface %s is empty\n', fem.surf(n_surf).name);
                end
                break
            end
            
            nn = nn + 1;
            iele = sscanf(s{1},'%d');
            iside = sscanf(s{2},'S%d');
            fem.surf(n_surf).side = [fem.surf(n_surf).side;iele iside];
            
        end
        continue
    end
    if strcmpi(s{1},'*NSET') % 

        n_nset = n_nset + 1;
        fem.nset(n_nset).name = s{2}(6:end);
        
        nn = 0;
        
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            n = length(s);
            if s{1}(1)=='*' % new keyword
                if nn == 0
                   fprintf('nset %s is empty\n', fem.nset(n_nset).name);
                end
                break
            end
            
            for j=1:n
                nn = nn + 1;
                fem.nset(n_nset).set = [fem.nset(n_nset).set;sscanf(s{j},'%d')];
            end
        end
        continue
    end

    % all keywords missed
%     fprintf('Keyword "%s" in line %d not supported,\n',s{1},il);
%     fprintf('following input discarded\n');        
%     fprintf('    %s\n',inplines{il});
    while(il<nlines)
        il=il+1;
        s = split(inplines{il},',');
        n = length(s);
        if ~isempty(s{1}) && s{1}(1)=='*' % new keyword
            break
        else
%             fprintf('    %s\n',inplines{il});
        end
    end

end



%% 
fem.npt = npt;
fem.nel = nel;
fem.conn(nel+1:end,:) = [];
fem.nsurf = n_surf;
fem.n_nset = n_nset;
fem.n_elset =n_elset;


fem.x = sortrows(fem.x); % original index ascending
fem.conn = sortrows(fem.conn);
% return as is
if isfield(cfg,'reindex')&&(~cfg.reindex)
    return
end

% re-index nodes
nodemap = NaN(fem.x(end,1),1); % largest number in original index
for i=1:npt
    nodemap(fem.x(i,1)) = i;
end
for i=1:numel(fem.nset)
    fem.nset(i).set = nodemap(fem.nset(i).set);
end

if nel==0
    return
end

% re-index elements and connectivity
fem.conn(:,2:end) = nodemap(fem.conn(:,2:end));

elemap = NaN(fem.conn(end,1),1); % largest element number in original index
for i=1:nel
    elemap(fem.conn(i,1))=i;
end

% generate set connectivity
for i=1:fem.n_elset
    fem.ele(i).set = elemap(fem.ele(i).set);    
    fem.ele(i).type = fem.etype{fem.ele(i).set(1)}; % assuming homogenous element type
    fem.ele(i).conn = fem.conn(fem.ele(i).set,2:end);
end

% remove index
fem.conn(:,1) = [];
fem.x(:,1) = [];

% generate surface mesh topology from element side
for i=1:length(fem.surf)
    fem.surf(i).side(:,1) = elemap(fem.surf(i).side(:,1));
    fem.smsh(i) = sset2smesh(fem.x,fem.conn,fem.surf(i));
end


