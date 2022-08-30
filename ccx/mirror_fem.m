function fem2 = mirror_fem(fem,mp)

% mirror the mesh of a finite element model and associated set definitions.
% mp - mirror plane

% tetrahedron elements only, vertex 2 3 swapped
% 

if isfield(fem,'surf') && ~isfield(fem,'sset')
    fem.sset = fem.surf;
end


fem2 = fem;
fem2.name = [fem.name '_m'];

% mirror coordinates
if strcmp(mp,'x')
    m = 1;
elseif strcmp(mp,'y')
    m = 2;
elseif strcmp(mp,'z')
    m = 3;
end

% mirror points
fem2.x(:,m) = -fem.x(:,m);

% swap 2nd and 3rd vertex
tmp = fem2.conn(:,2);
fem2.conn(:,2) = fem2.conn(:,3);
fem2.conn(:,3) = tmp;

% element sets: connectivity and names
for i=1:numel(fem2.ele)
    iel = fem2.ele(i).set;
    fem2.ele(i).name = replace(fem2.ele(i).name, 'L-','R-');
    fem2.ele(i).conn = fem2.conn(iel,:);
    
end

% surface definitions
tetr_side_map = [1 4 3 2];
for i=1:numel(fem2.sset)
    fem2.sset(i).name = replace(fem2.sset(i).name,'L-','R-');
    % map to mirror order
    fem2.sset(i).side(:,2)=tetr_side_map(fem2.sset(i).side(:,2));
end

if isfield(fem,'smsh')
for i=1:numel(fem2.sset)
    fem2.smsh(i).name = replace(fem2.smsh(i).name,'L-','R-');
end

end
% node set
for i=1:numel(fem2.nset)
    fem2.nset(i).name = replace(fem2.nset(i).name,'L-','R-');    
end





