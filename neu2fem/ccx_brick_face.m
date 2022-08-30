function inodes = ccx_brick_face(iface)
% return the element node indices for the given face number
% Calculix convention
% node number orderd clockwise, normal points inward

    switch iface
        case 1
            inodes = [1 2 3 4];
        case 2
            inodes = [5 8 7 6];
        case 3
            inodes = [1 5 6 2];
        case 4
            inodes = [2 6 7 3];
        case 5
            inodes = [3 7 8 4];
        case 6
            inodes = [4 8 5 1];
            
    end
    
    
% Face 1: 1-2-3-4
% Face 2: 5-8-7-6
% Face 3: 1-5-6-2
% Face 4: 2-6-7-3
% Face 5: 3-7-8-4
% Face 6: 4-8-5-1