function new_conn = reorder_conn(conn,out_fmt)

% reorder the element connectivity from Gambit NEU format to target format
% default is ccx input format

if ~exist('out_fmt','var')
    out_fmt = 'CCX';
end

% neu to ccx connectivity mapper  
n2c_brick = [1 2 4 3 5 6 8 7];

switch out_fmt
    case {'CCX','ccx'}
        
        nnode = size(conn,2);
        
        switch nnode
            case 8
                new_conn = conn(:,n2c_brick);
            case 4
                new_conn = conn;
            otherwise
                fprintf('element with %d nodes not supported\n',nnode);
        end
        
    otherwise
        fprintf('out format "%s" for connectivity not supported\n',out_fmt);
end

