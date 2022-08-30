function gen_flow_inputs(subdir,vf,imed)

%  input files for the flow solver
%  vf - finite element model definition

    % subdir = 'ccx_model';
    subdir = [subdir '/inputs'];
    if (~exist(subdir,'dir'))
        mkdir(subdir);
    end


    % flow.inp
%     fid = fopen([subdir '/flow.inp'], 'w');
%     fprintf(fid, 'nsec\r\n');
%     fprintf(fid, '%d\r\n', vf.flow.nsec);
%     fprintf(fid, 'psub\r\n');
%     fprintf(fid, '%f\r\n', vf.flow.psub);
%     fprintf(fid, 'density\r\n');
%     fprintf(fid, '%f\r\n', vf.flow.rho);
%     fprintf(fid, 'ntime ndump\r\n');
%     fprintf(fid, '%d  %d\r\n', vf.flow.ntime, vf.flow.ndump);
%     fprintf(fid, 'dt\r\n');
%     fprintf(fid, '%e\r\n', vf.time.dt);
%     fprintf(fid, 'acoustic solution & feedback\r\n');
%     fprintf(fid, '%s   %s\r\n', vf.flow.ac_solve, vf.flow.ac_feedback);
%     fprintf(fid, 'midline\r\n');
%     fprintf(fid, '%f\r\n', vf.midline);
%     fprintf(fid, 'penalty force direction\r\n');
%     fprintf(fid, '%d\r\n', vf.flow.penalty_dir);
%     fclose(fid);
    
    % volume.dat
    nnodes = size(vf.conn,2);
    fid = fopen([subdir '/volume.dat'], 'w');
    fprintf(fid, '%d %d %d \r\n', size(vf.x,1), size(vf.conn,1), nnodes);
    fprintf(fid, '\r\n');
    fprintf(fid, '%15.8f %15.8f %15.8f\r\n', vf.x');
    fmt_str = repmat('%6d ', 1, nnodes);
    fprintf(fid, [fmt_str '\r\n'], vf.conn');
    fclose(fid);
    
    
    % surface.dat
    s = vf.smsh(imed);
    npt = numel(s.ndlist);
    nel = size(s.conn,1);
    nnode = size(s.conn,2);
    
    
    fid = fopen([subdir '/surface.dat'], 'w');
    switch nnode
        case 4
            fprintf(fid, '%d %d %d\r\n', npt, nel*2, 3);
            fprintf(fid, '\r\n');
            fprintf(fid, '%15.8f %15.8f %15.8f\r\n', vf.x(s.ndlist,:)');
            fmt_str = repmat('%6d', 1, 4);
            fprintf(fid, [fmt_str '\r\n'], [s.lconn(:,[1 2 3]) ones(nel,1)]');
            fprintf(fid, [fmt_str '\r\n'], [s.lconn(:,[3 4 1]) ones(nel,1)]');
            fclose(fid);
            
        case 3
            fprintf(fid, '%d %d %d\r\n', npt, nel, 3);
            fprintf(fid, '\r\n');
            fprintf(fid, '%15.8f %15.8f %15.8f\r\n', vf.x(s.ndlist,:)');
            fmt_str = repmat('%6d', 1, nnode+1);
            fprintf(fid, [fmt_str '\r\n'], [s.lconn ones(nel,1)]');
            fclose(fid);
    end
    
    
    
    
    
    
    