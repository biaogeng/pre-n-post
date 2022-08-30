function smesh = sset2smesh(x,conn,sset)

% take the element side definition of a surface set
% generate the independent surface topology definition

% x - the coordinates of the entire mesh set
% conn - connectivity of the entire mesh set (global)
% sset - element side definition of a surface set


% assuming homogeneous element types
    npe  = size(conn,2);

    smesh.name = sset.name;    
    nel = size(sset.side,1);
    
    if npe==8
        nnode = 4;
        smesh.conn = zeros(nel,nnode);
        for j=1:nel
            iele = sset.side(j,1);
            iface = sset.side(j,2);
            inodes = ccx_brick_face(iface);
            smesh.conn(j,:) = conn(iele,inodes); % global connectivity
        end
    elseif npe==4
        nnode = 3;
        smesh.conn = zeros(nel,nnode);
        for j=1:nel
            iele = sset.side(j,1);
            iface = sset.side(j,2);
            inodes = ccx_tetra_face(iface);
            smesh.conn(j,:) = conn(iele,inodes); % global connectivity
        end
    else
        fprintf('type %s not supported.\n',etype);
        return
    end
    
    smesh.ndlist = unique(smesh.conn);    % global node index

    % reverse correspondence for nodes (global to local)
    npt = size(x,1);
    [~,rev_map] = ismember(1:npt,smesh.ndlist);
%     rev_map = NaN(npt,1)';
%     for i=1:length(smesh.ndlist)
%         rev_map(smesh.ndlist(i))=i;
%     end

    % new connectivity, local to the surface

    smesh.nel = nel;
    smesh.lconn = NaN(smesh.nel,nnode);
    for i=1:smesh.nel
        % connectivity in partial-model index
        smesh.lconn(i,:) = rev_map(smesh.conn(i,:));  
    end



    