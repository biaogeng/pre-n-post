function surf2plt(inpdir,outdir)
% add tecplot header to surface.dat used in Bernoulli FSI simulation


    [v, el] = read_surface_dat(inpdir);


    write_plt_fe(outdir,v,el,["x" "y" "z"],'medial');