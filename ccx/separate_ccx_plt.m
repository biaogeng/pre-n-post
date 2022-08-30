function separate_ccx_plt(subdir,fname,fem,st)

% separates ccx solution (.plt) into different zones for visualization in
% Tecplot

% subdir - data path
% fname - ccx output file
% fem - Matlab struct with zone definitions
% st  - solutiontime range [tmin tmax]



    % clear
    % load 'rev_vis/LVF.mat';

    %
    tmax = st(2);

    % subdir = 'tests';
    % fname = 'fsi_mr.plt';
    % tmax = 20;
    plt = read_ccx_plt(subdir,fname,tmax);


    %
    write_ccx_plt(plt,fem,1,st);

