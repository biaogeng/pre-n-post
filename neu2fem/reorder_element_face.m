function new_sset = reorder_element_face(ele_type,sset,out_fmt)

% reorder the element face number from Gambit NEU format to target format
% default is ccx input format

if ~exist('out_fmt','var')
    out_fmt = 'CCX';
end

% neu to ccx face number mapping
n2c_brick = [3 4 5 6 1 2]';

new_sset = sset;

faceno = sset(:,2);

switch out_fmt
    case {'CCX','ccx'}        
        switch ele_type
            case 'C3D8'
                new_sset(:,2) = n2c_brick(faceno);
            case 'C3D4'

            otherwise
                fprintf('element type %s not supported\n',ele_type);
        end
        
    otherwise
        fprintf('out format "%s" for connectivity not supported\n',out_fmt);
end

