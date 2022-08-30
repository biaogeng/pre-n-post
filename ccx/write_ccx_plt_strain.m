function write_ccx_plt_strain(plt,vf,sig,is)
%
% vf    - struct containing model and set definitions
% plt   - struct containing CCX output
% sig   - write stress
% is    - starting frame


vars = plt.var; % plt.var is cell array containing frames of displacement and stress field
solutiontime = plt.solutiontime;
npt = size(plt.x,1);
if ~isfield(plt,'title')
    plt.title = "calculix result with separated zones";
end

if exist('sig','var')
    nvar = 12;
    fname = [plt.dir '/' plt.name '_sp_strain.plt'];
    fid2 = fopen(fname, 'w');
    % header
    fprintf(fid2, 'title = %s\n',plt.title);    
    fprintf(fid2, 'variables = "x" "y" "z" "u" "v" "w" "exx" "eyy" "ezz" "exy" "eyz" "exz"\n');
else
    nvar = 6;
    fname = [plt.dir '/' plt.name '_sp6v.plt'];
    fid2 = fopen(fname, 'w');
    % header
    fprintf(fid2, 'title = %s\n',plt.title);     
    
    fprintf(fid2, 'variables = "x" "y" "z" "u" "v" "w"\n');
end    

% reference sets (frame0)
% surface sets first so they'll prioritize over bodies in Tecplot
nsurfs = length(vf.smsh);
for i=1:nsurfs
    
    % zone header
    fprintf(fid2, '\n');
    fprintf(fid2, ' zone t = "%s"\n',vf.smsh(i).name);
    fprintf(fid2, ' datapacking = block\n');
    fprintf(fid2, ' zonetype = fetriangle\n');
    fprintf(fid2, ' N = %d , E = %d\n', npt, size(vf.smsh(i).conn,1));
    fprintf(fid2, ' strandid = %d\n',i);
    fprintf(fid2, ' solutiontime = 0.0\n');
    % nodal data
    if i~=1 % share all data with 1st zone
        fprintf(fid2,' VARSHARELIST = ([1-%d]= 1 )\n',nvar);
        
    else  % write coordinates, others passive
        fprintf(fid2, ' PASSIVEVARLIST=[4-%d]\n',nvar);
        for j=1:3
            fprintf(fid2, [repmat(' %13.6E',1,10) '\n'],plt.x(:,j));
        end
    end

    % connectivity
    nnode = size(vf.smsh(i).conn,2);
    fprintf(fid2, [repmat(' %12d',1,nnode) '\n'],vf.smsh(i).conn');
    
end

% element sets
nzones = length(vf.ele);
for i=1:nzones
    
    % zone header
    fprintf(fid2, '\n');
    fprintf(fid2, ' zone t = "%s"\n',vf.ele(i).name);
    fprintf(fid2, ' datapacking = block\n');
    fprintf(fid2, ' zonetype = fetetrahedron\n');
    fprintf(fid2, ' N = %d , E = %d\n', npt, size(vf.ele(i).conn,1));
    fprintf(fid2, ' strandid = %d\n',i+nsurfs);
    fprintf(fid2, ' solutiontime = 0.0\n');
    % nodal data
    fprintf(fid2,' VARSHARELIST = ([1-%d]= 1 )\n',nvar);
        
    % connectivity
    nnode = size(vf.ele(i).conn,2);
    fprintf(fid2, [repmat(' %12d',1,nnode) '\n'],vf.ele(i).conn');
    
end


% write frames
ncounter = 0;
for nframe=is:length(solutiontime)
    ncounter = ncounter + 1;
%     disp(solutiontime(nframe));
    fprintf('.');
    if mod(nframe,50)==0
        fprintf('%d\n',nframe);
    end
    
    imaster = (nzones+nsurfs)*ncounter+1;
    % surface sets
    nsurfs = length(vf.smsh);
    for i=1:nsurfs

        % zone header
        fprintf(fid2, '\n');
        fprintf(fid2, ' zone t = "%s"\n',vf.smsh(i).name);
        fprintf(fid2, ' datapacking = block\n');
        fprintf(fid2, ' zonetype = fetriangle\n');
        fprintf(fid2, ' N = %d , E = %d\n', npt, size(vf.smsh(i).conn,1));
        fprintf(fid2, ' strandid = %d\n',i);
        fprintf(fid2, ' solutiontime = %f\n',solutiontime(nframe));
        fprintf(fid2, ' CONNECTIVITYSHAREZONE = %d\n',i);

        % nodal data
        if i~=1
            fprintf(fid2,' VARSHARELIST = ([1-%d]= %d )\n',nvar,imaster);
        else
            fprintf(fid2,' VARSHARELIST = ([1-3]=1 )\n');
            for j=4:nvar
                fprintf(fid2, [repmat(' %13.6E',1,10) '\n'],vars{nframe}(:,j-3));
            end
            
            
        end

    end
    
    % element sets
    for i=1:nzones

        % zone header
        fprintf(fid2, '\n');
        fprintf(fid2, ' zone t = "%s"\n',vf.ele(i).name);
        fprintf(fid2, ' datapacking = block\n');
        fprintf(fid2, ' zonetype = fetetrahedron\n');
        fprintf(fid2, ' N = %d , E = %d\n', npt, size(vf.ele(i).conn,1));
        fprintf(fid2, ' strandid = %d\n',i+nsurfs);
        fprintf(fid2, ' solutiontime = %f\n',solutiontime(nframe));
        fprintf(fid2, ' CONNECTIVITYSHAREZONE = %d\n',i+nsurfs);
        % nodal data
        fprintf(fid2,' VARSHARELIST = ([1-%d]= %d )\n',nvar,imaster);
    end
    
end
fclose(fid2); 
fprintf('\n');
