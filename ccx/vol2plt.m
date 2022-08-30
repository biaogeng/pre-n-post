function vol2plt(inpdir,outdir)
% add tecplot header to volume.dat used in Bernoulli FSI simulation

    if ~exist('outdir','var')
        outdir = inpdir;
    end

    [v, el] = read_volume_dat(inpdir);

    write_plt_fe(outdir,v,el,["x" "y" "z"],'volume');
