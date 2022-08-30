
function write_plt_homo_fe(plt, zone)
%  write fem dataset to tecplot format
%  homogeneous finite element dataset (same element type for all zones)
%  can be used for multiple zones sharing the same node set

%  put general information of the tecplot data in the plt structure
%  plt.x - coordinates
%  plt.v - cell array,nx1, each cell contains a vector of variables
%  plt.zonetype - zonetype
%  plt.vname - variable names
%  plt.fname - file name
    
%  put zone information in the zone structure

%     zone = vf.surf;

    fid = fopen([plt.fname '.plt'],'w');
    fprintf(fid, 'title = "%s"\n',plt.fname);
    
    npt = size(plt.x,1);
    ndim = size(plt.x,2);
    
    nzones = length(zone);
    if isfield(plt,'e')
        nel_tot = size(plt.e,1);
    else
        nel_tot = 0;
        for i=1:nzones
            nel_tot = nel_tot + size(zone(i).conn,1);
        end
    end

    nvar = length(plt.v);
    if nvar ~= length(plt.vname)-ndim
        disp('check plt.vname/n');
        return;
    end
    % get cell-centered variables 
    datapacking = 'block';
    ncenter = 0;
    centered = false(1,ndim+nvar);
    for i=1:nvar
        if length(plt.v{i})==nel_tot
            ncenter=ncenter+1;
            centered(ndim+i) = true ;
        end
    end
    ind = 1:ndim+nvar;
    

    
    % write header
    fprintf(fid, 'variables = ');
    fprintf(fid, '"%s" ', plt.vname);
    fprintf(fid, '\r\n');
    
    % master domain, with all nodal data ( x,y,z and other nodal variables)
    nel = size(zone(1).conn,1);
    fprintf(fid, 'zone t="%s"\r\n', zone(1).name);
    fprintf(fid, 'zonetype = %s\r\n',plt.zonetype);
    fprintf(fid, 'datapacking = %s\r\n',datapacking);
    fprintf(fid, 'N=%d, E=%d\r\n', npt, nel);
    
    % write variables
    % block packing
    if ncenter>0
        fprintf(fid,'VARLOCATION=([');
        fprintf(fid, repmat('%d,',1,ncenter), ind(centered));
        fprintf(fid, ']=CELLCENTERED)\r\n');
    end
    for i=1:ndim
        fprintf(fid, [repmat('%g ',1,10) '\r\n'], plt.x(:,i));
        fprintf(fid,'\r\n');
    end

    for i=1:nvar
        if centered(i+ndim)
            fprintf(fid, [repmat('%g ',1,10) '\r\n'], plt.v{i}(zone(1).set));
            fprintf(fid,'\r\n');
        else
            fprintf(fid, [repmat('%g ',1,10) '\r\n'], plt.v{i});
            fprintf(fid,'\r\n');
        end
    end        
    
    nnode = size(zone(1).conn,2);
    for j =1:nel
        fprintf(fid, [repmat('%6d ',1,nnode) '\r\n'], zone(1).conn(j,:));
    end
        
    % zones
    indc = ind(centered)-ndim;
    for i=2:nzones
        fprintf('zone %d\n', i);
        nel = size(zone(i).conn,1);
        fprintf(fid, 'zone t="%s"\r\n', zone(i).name);
        fprintf(fid, 'zonetype = %s\r\n', plt.zonetype);        
        fprintf(fid, 'datapacking = %s\r\n',datapacking);
        fprintf(fid, 'N=%d, E=%d\r\n', npt, nel);
        
        fprintf(fid, 'VARSHARELIST = ([');
        fprintf(fid, repmat('%d,',1,ndim+nvar-ncenter),ind(~centered));
        fprintf(fid, ']=1)\r\n');
        
        if ncenter>0
            fprintf(fid,'VARLOCATION=([');
            fprintf(fid, repmat('%d,',1,ncenter), ind(centered));
            fprintf(fid, ']=CELLCENTERED)\r\n');
            
            for j=1:length(indc)
                fprintf(fid, [repmat('%g ',1,10) '\r\n'], plt.v{indc(j)}(zone(i).set));
                fprintf(fid,'\r\n');
            end
        end
        
        nnode = size(zone(i).conn,2);
        for j =1:nel
            fprintf(fid, [repmat('%6d ',1,nnode) '\r\n'], zone(i).conn(j,:));
        end
        
    end
    
    fclose(fid);

    
    