function neu = read_neu_file(fname_neu)
% given the pathname of a neu file
% returns the mesh structure and body and boundary sets in a neu struct
% 
    if ~strcmp(fname_neu(end-3:end),'.neu')
        fname_neu = [fname_neu '.neu'];
    end
    [fid_neu,errmsg] = fopen(fname_neu);
    if fid_neu<0
        disp(errmsg);
        disp(fname_neu);
        disp('where did you put the mesh?');
        
        return;
    end

    % skip header
    for i=1:6
        fgetl(fid_neu);
    end

    % general info
    tmp_array = fscanf(fid_neu, ' %d ');
    neu.npt = tmp_array(1);
    neu.nel = tmp_array(2);
    neu.ngrp = tmp_array(3);
    neu.nbset= tmp_array(4);
    neu.ndim = tmp_array(5);
    fgetl(fid_neu);

    % nodal coordinate
    fgetl(fid_neu);
    fmt_str = [' %d ' repmat('%f ',1,neu.ndim) ];
    tmp_array = fscanf(fid_neu, fmt_str, [neu.ndim+1 neu.npt])';
    if neu.ndim==2
        neu.x = [tmp_array(:,2:3) zeros(neu.npt,1)];
        neu.ndim = neu.ndim+1;
    else
        neu.x = tmp_array(:,2:4);
    end
    fgetl(fid_neu);

    % element topology, assumes the same type for all elements
    fgetl(fid_neu);
    tmp_array = fscanf(fid_neu, ' %d ', 3); 
    nnodes = tmp_array(3); % # of nodes per element
    neu.el = zeros(neu.nel,nnodes);
    
    tmp_array = fscanf(fid_neu, ' %d ', nnodes)';
    neu.el(1,:) = tmp_array(:);
    
    tmp_array = fscanf(fid_neu, ' %d ', [nnodes+3 neu.nel-1])';
    neu.el(2:end,:) = tmp_array(:,4:end);        
    fgetl(fid_neu);

    % groups
    neu.elset = cell(neu.ngrp,1);
    neu.elset_name = cell(neu.ngrp,1);
    for i=1:neu.ngrp
        fgetl(fid_neu); % section header
        fgetl(fid_neu); % group info
        neu.elset_name{i} = fscanf(fid_neu, ' %s', 1); % group name
        fgetl(fid_neu); % 
        fgetl(fid_neu); % 
        neu.elset{i} = fscanf(fid_neu, ' %d ');
        fgetl(fid_neu);
    end

    % boundary sets
    
    
    nsset = 0; % # of surface sets
    nnset = 0; % # of node sets
    for i=1:neu.nbset
        fgetl(fid_neu); % section header
        bset_name = fscanf(fid_neu, ' %s ', 1); % name and type
        bset_type = fscanf(fid_neu, ' %d ', 1);
        fgetl(fid_neu);
        if bset_type ==0
            nnset = nnset + 1;
            neu.nset(nnset).name = bset_name;
            neu.nset(nnset).ndlist = fscanf(fid_neu, '%d');
        else
            nsset = nsset + 1;
            neu.sset(nsset).name = bset_name;
            buffer = fscanf(fid_neu, ' %d %d %d \n', [ 3 Inf])'; 
            buffer(:,2) = [];
            neu.sset(nsset).side = buffer;
        end
        fgetl(fid_neu);
    end
    
    % extract surface set topology
    if 1==0
    for i=1:nsset
       % to do: 
       % - add support for quadrilateral surface
       neu.smsh(i) = sset2trimesh(neu.x,neu.el,neu.sset(i));
    end
    end
    fclose(fid_neu);

