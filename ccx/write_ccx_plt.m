function write_ccx_plt(plt,vf,sig,st)
    %
    % vf    - struct containing model and set definitions
    % plt   - struct containing CCX output
    % sig   - write stress
    % st    - solution time range for output

    vars = plt.var; % plt.var is cell array containing frames of displacement and stress field
    solutiontime = plt.solutiontime;

    if ~exist('st','var')
        st = [min(solutiontime) max(solutiontime)];
    end

    if ~isfield(plt,'title')
        plt.title = "calculix result with separated zones";
    end

    if ~isfield(plt,'dir')
        plt.dir = '.';
    end

    if ~isfield(plt,'name')
        plt.name = 'ccx_solution';
    end

    if exist('sig','var')
        nvar = 12;
        fname = [plt.dir '/' plt.name '_sp12v.plt'];
        fid2 = fopen(fname, 'w');
        % header
        fprintf(fid2, 'title = %s\n',plt.title);    
        fprintf(fid2, 'variables = "x" "y" "z" "u" "v" "w" "sxx" "syy" "szz" "sxy" "syz" "sxz"\n');
    else
        nvar = 6;
        fname = [plt.dir '/' plt.name '_sp6v.plt'];
        fid2 = fopen(fname, 'w');
        % header
        fprintf(fid2, 'title = %s\n',plt.title);     
        
        fprintf(fid2, 'variables = "x" "y" "z" "u" "v" "w"\n');
    end    

    % reference sets (frame0)
    % all elements
    npt = size(plt.x,1);
    nel = size(vf.conn,1);
    nnode = size(vf.conn,2);
    if nnode == 8
        fezonetype = 'febrick';
    elseif nnode == 4
        fezonetype = 'fetetrahedron';
    else
        printf('element type with %d nodes is not supported\n');
    end
    % zone header
    print_block_header(fid2,'all',fezonetype,npt,nel,1,0)
    % nodal data
    % write coordinates, others passive
    fprintf(fid2, ' PASSIVEVARLIST=[4-%d]\n',nvar);
    for j=1:3
        fprintf(fid2, [repmat(' %13.6E',1,10) '\n'],plt.x(:,j));
    end
    % connectivity
    fprintf(fid2, [repmat(' %12d',1,nnode) '\n'],vf.conn');

    % surface sets before body sets so they'll prioritize over bodies in Tecplot
    if isfield(vf,'smsh')
        nsurfs = length(vf.smsh);
    else
        nsurfs = 0;
    end

    for i=1:nsurfs
        % zone header
        ne=size(vf.smsh(i).conn,1); sid=i+1;
        print_block_header(fid2,vf.smsh(i).name,'fetriangle',npt,ne,sid,0);
        
        % nodal data
        % share all data with 1st zone
        fprintf(fid2,' VARSHARELIST = ([1-%d]= 1 )\n',nvar);
        % connectivity
        nnode = size(vf.smsh(i).conn,2);
        fprintf(fid2, [repmat(' %12d',1,nnode) '\n'],vf.smsh(i).conn');
    end

    % element sets
    if isfield(vf,'ele')
        nzones = length(vf.ele);
    else
        nzones = 0;
    end
    for i=1:nzones
        % zone header
        ne=size(vf.ele(i).conn,1); sid=i+nsurfs+1;
        print_block_header(fid2,vf.ele(i).name,'fetetrahedron',npt,ne,sid,0);

        % nodal data
        fprintf(fid2,' VARSHARELIST = ([1-%d]= 1 )\n',nvar);
        % connectivity
        nnode = size(vf.ele(i).conn,2);
        fprintf(fid2, [repmat(' %12d',1,nnode) '\n'],vf.ele(i).conn');
    end


    % write frames
    nout = 0;
    for nframe=1:length(solutiontime)
    %     disp(solutiontime(nframe));
        soltime = solutiontime(nframe);
        if soltime < st(1) || soltime > st(2)
            continue
        end
        nout = nout + 1;
        fprintf('.');
        if mod(nframe,50)==0
            fprintf('%d\n',nframe);
        end
        
        % all elements
        % zone header
        print_block_header(fid2,'all',fezonetype,npt,nel,1,soltime,1)
        % nodal data
        fprintf(fid2,' VARSHARELIST = ([1-3]=1 )\n');
        for j=4:nvar
            fprintf(fid2, [repmat(' %13.6E',1,10) '\n'],vars{nframe}(:,j-3));
        end

        imaster = (nzones+nsurfs+1)*nout+1; % data zone index
        % surface sets
        for i=1:nsurfs
            % zone header
            ne=size(vf.smsh(i).conn,1); sid=i+1; iCON=sid;
            print_block_header(fid2,vf.smsh(i).name,'fetriangle',npt,ne,sid,soltime,iCON);
            % nodal data
            fprintf(fid2,' VARSHARELIST = ([1-%d]= %d )\n',nvar,imaster);
        end
        
        % element sets
        for i=1:nzones
            % zone header
            ne=size(vf.ele(i).conn,1); sid=i+nsurfs+1;iCON=sid;
            print_block_header(fid2,vf.ele(i).name,'fetetrahedron',npt,ne,sid,soltime,iCON);
            % nodal data
            fprintf(fid2,' VARSHARELIST = ([1-%d]= %d )\n',nvar,imaster);
        end
    end

    fclose(fid2); 
    fprintf('\n');

end

function print_block_header(fid,ztitle,ztype,N,E,sid,soltime,iCON)
    
    fprintf(fid, '\n');
    fprintf(fid, ' zone t = "%s"\n',ztitle);
    fprintf(fid, ' datapacking = block\n');
    fprintf(fid, ' zonetype = %s\n',ztype);
    fprintf(fid, ' N = %d , E = %d\n', N, E);
    fprintf(fid, ' strandid = %d\n',sid);
    fprintf(fid, ' solutiontime = %f\n',soltime);
    if exist('iCON','var')
        fprintf(fid, ' CONNECTIVITYSHAREZONE = %d\n',iCON);
    end
end

