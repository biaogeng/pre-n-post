function lambda = calc_plt_line_stretch(subdir,fname,i1,i2)

    plt = readsave_load(subdir,fname);
    
    sln = plt.var{end};
    L0 = norm(plt.x(i1,:) - plt.x(i2,:));
    Lt = norm(plt.x(i1,:)+sln(i1,1:3) - plt.x(i2,:)-sln(i2,1:3));
    lambda = Lt/L0;