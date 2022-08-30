function [A,bar] = is_inside_tet(p,tet)

    p1=tet(1,:);
    p2=tet(2,:);
    p3=tet(3,:);
    p4=tet(4,:);
% determines if p is within the tetrahedron defined by p1,p2,p3,p4
% coordinates defined as row vector 1*3

    tol = 1.0e-9;
    
    S = tetrahedron_volume_3d([p1;p2;p3;p4]');
    
    S1 = tetrahedron_volume_3d([ p;p2;p3;p4]');
    S2 = tetrahedron_volume_3d([p1; p;p3;p4]');
    S3 = tetrahedron_volume_3d([p1;p2; p;p4]');
    S4 = tetrahedron_volume_3d([p1;p2;p3; p]');
    
    if abs((S1+S2+S3+S4)-S)<tol
        A = true;
        bar = [S1,S2,S3,S4]/S;
    else
        A = false;
        bar = [];
    end
end