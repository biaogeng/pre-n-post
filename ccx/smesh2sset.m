function sset = smesh2sset(x,conn,smesh)

%
% take the independent/dependent surface topology definition
% generate the element side definition of volume mesh

% x - the coordinates of the entire mesh set
% conn - connectivity of the entire mesh set (global)
% smesh - surface mesh topology definition

% sset - element side definition of a surface set


    if ~isfield(smesh,'name')
        smesh.name = 'surface1';
        fprintf('default name assigned\n');
    end
    
    sset.name = smesh.name;
    
    if isfield(smesh,'conn')
        nel = size(smesh.conn,1);
    elseif isfield(smesh,'lconn')
        nel = size(smesh.lconn,1);
        s2v_map = build_correspondence(smesh.x,x); % build surface to volume node map
        smesh.conn = s2v_map(smesh.lconn);
    else
        fprintf('no connectivity defined for surface %s\n',smesh.name);
        return;
    end
    sset.side = zeros(nel,2);
    
    % assume homogeneous volume element types
    npe  = size(conn,2);
    if npe==8
%         smesh.conn = zeros(nel,nnode);
%         for j=1:nel
%             iele = sset.side(j,1);
%             iface = sset.side(j,2);
%             inodes = ccx_brick_face(iface);
%             smesh.conn(j,:) = conn(iele,inodes); % global connectivity
%         end
        fprintf('function not implemented\n');
    elseif npe==4
        fprintf('matching surface elements...\n');
        
        for j=1:nel % loop surface elements
            in_ele = false(size(conn,1),4);
%             fprintf('triangle %d ->',j);
            for k=1:3 % this is so fast
                in_ele = in_ele | conn-smesh.conn(j,k)==0;
            end
            
            iele = find(sum(in_ele,2)==3);
            if numel(iele)>1 % interior face element
                fprintf('face element found in %d elements, invalid surface\n',numel(iele));
                continue
            end
            if iele>0
                [~,inodes] = ismember(smesh.conn(j,:),conn(iele,:)); % get 
                sset.side(j,1) = iele;
                sset.side(j,2) = ccx_tetra_face(inodes);
%                 fprintf('tetra %d\n',iele); 
            else
                fprintf('failed to find volume element for surface element %d\n',j); 
            end
        end
    else
        fprintf('type %s not supported.\n',etype);
        return
    end
    
    

%     sset.nel = nel;
    sset.side(sset.side(1,:)==0,:)=[]; % remove unfound surface elements




    