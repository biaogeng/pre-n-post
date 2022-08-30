
function iout = ccx_tetra_face(iin)


% return the element node indices for the given face number or vice versa
% Calculix convention
% node number orderd clockwise, normal points inward
tetface=[1 2 3; 1 4 2; 2 4 3; 3 4 1];

if numel(iin) == 1 % find element node number
    % node number orderd clockwise, normal points inward
    iout = tetface(iin,:);
    
elseif numel(iin) == 3 % find element face number
    iout = 0;
    for i=1:4
        if sum(ismember(iin,tetface(i,:)))==3
            iout = i;
            break
        end
    end
    if iout==0
        fprintf('can not find surface for nodes %d %d %d\n',iin);
        iout = [];
    end
else
    fprintf('ccx_tetra_face: incorrect input\n');
    iout = [];
    return;
end