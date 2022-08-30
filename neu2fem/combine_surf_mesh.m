function newmesh = combine_surf_mesh(x,smsh,list,name)

% combine mesh sets into one set
% x - mesh coordinates, npt*3
% smsh - all surface mesh, structure array
% list - index of surfaces to be merged, array
% name - the name for the merged surface

    
    % put global connectivity together
    if (length(list)<2)
        return;
    end
    conn = smsh(list(1)).conn;
    for i=2:length(list)
        conn = [conn; smsh(list(i)).conn];
    end
    
    nel_s = size(conn,1);
    nnode = size(conn,2);
    ndlist = unique(conn);    % global node index

    % reverse correspondence for nodes
    npt = size(x,1);
    g2l_map = NaN(npt,1)'; % global to local index map
    
    for i=1:length(ndlist)
        g2l_map(ndlist(i))=i;
    end

    % new connectivity, local to the surface
    lconn = NaN(nel_s,nnode);
    for i=1:nel_s
    % connectivity in partial-model index
        lconn(i,:) = g2l_map(conn(i,:));  
    end
    
    % 
    newmesh.name = name;
    newmesh.nel = nel_s;
    newmesh.conn = conn;
    newmesh.ndlist = ndlist;
    newmesh.lconn = lconn;


