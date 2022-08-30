% extract nodal history from ccx .plt output


function xt = extract_nodal_history(plt,inode)

% plt - struct containing ccx solution
% inode - nodal index

ntime = length(plt.solutiontime);
xt = zeros(ntime,4);

for i=1:ntime
    xt(i,1) = plt.solutiontime(i);
    xt(i,2:4) = plt.var{i}(inode,1:3);
end