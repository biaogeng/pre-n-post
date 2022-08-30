function write_plt_files(vf, subdir)


    % ilayer = zeros(neu.nel,1);
    % for i=1:size(neu.elset,1)
    %     ilayer(neu.elset{i})=i;
    % end
    
    %
    if(~exist(subdir,'dir'))
        mkdir(subdir);
    end
    
    % check body mesh
    plt.x = vf.x;
    plt.v = {};
    % plt.v{1} = ilayer;
    % plt.v{2} = vf.x(:,3);
    % plt.vname = ["x" "y" "z" "ilayer" "dum"];
    plt.vname = ["x" "y" "z"];
    plt.fname = [subdir '/' vf.name '_solid_zones'];
    plt.zonetype = 'fetetrahedron';

    write_plt_homo_fe(plt, vf.ele);

    % check surfaces
    plt.x = vf.x;
    plt.v = {};
    plt.vname = ["x" "y" "z"];
    plt.fname = [subdir '/' vf.name '_surface_zones'];
    plt.zonetype = 'fetriangle';

    write_plt_homo_fe(plt, vf.smsh);