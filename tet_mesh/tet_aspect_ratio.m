function ar = tet_aspect_ratio(tet)
% this function computes the aspect ratio of a tetrahedron

% tet - vertex coordinates of the tet, 4*3
% ar  - calculated aspect ratio

% basic tet functions adapted from 
% https://people.sc.fsu.edu/~jburkardt/m_src/tet_mesh_quality/tet_mesh_quality.html


  r_out = tetrahedron_circumsphere_3d ( tet' );

  r_in = tetrahedron_insphere_3d ( tet' );

  ar = r_out/(3.0 * r_in);


end


