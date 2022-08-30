%
% extract c3d4 (4-node tetrahedron) from c3d10 (10-node tetrahedron)
% input
% x - nodal coordinates, npt*3
% ele10 - connectivity, nel*10
% it's assumed that the first 4 nodes are the apex nodes
% output
% msh - struct containing the c3d4 mesh.

function msh = ten2four(x,ele10)

    npt10 = size(x,1);
    nel = size(ele10,1);
    
    ele4 = ele10(:,1:4);
    
    nodelist = unique(ele4);
    
    [~,inew] = ismember(1:npt10,nodelist);
    
    for i=1:nel
        
        ele4(i,:) = inew(ele4(i,:));
    end
    
    msh.x = x(nodelist,:);
    msh.ele = ele4;
    
    
    
    