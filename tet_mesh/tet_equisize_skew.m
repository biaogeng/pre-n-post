function ess = tet_equisize_skew(tet)
% this function computes the equisize skew of a tetrahedron
% basic tet functions adapted from
% https://people.sc.fsu.edu/~jburkardt/m_src/tet_mesh_quality/tet_mesh_quality.html

% tet - vertex coordinates of the tet, 4*3
% ess  - calculated equisize skew

% about Equisize Skew
% this is a metrics used by the Meshing software Gambit
% calculated as ess = (Veq -V)/Veq
% the Gambit manual gives an over relationship between ess and quality

% ess = 0         Perfect (Equilateral)
% 0<ess<0.25      Excellent
% 0.25<ess<0.5    Good
% 0.5<ess<0.75    Fair
% 0.75<ess<0.9    Poor
% 0.9<ess<1       Very Poor
% ess = 1         Degenerate

r_out = tetrahedron_circumsphere_3d ( tet' );
V = tetrahedron_volume_3d(tet');
aeq = r_out/sqrt(3/8);
Veq = aeq^3/(6*sqrt(2));
ess = (Veq-V)/Veq;