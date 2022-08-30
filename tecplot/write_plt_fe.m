% write finite element dataset in tecplot format
% single zone
% point packing

function write_plt_fe(outdir,v,el,vname,casename,eletype)

%  v - variables, including x,y,z
% el - connectivity
% vname - string array of variable names
% casename - character array, name for zone and file
% eletype - character array, tecplot fe zone type
    
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end

    if ~exist('eletype','var')
        eletype = 'null';
    end

    nvar = size(v,2);
    nnode= size(el,2); 
    
    if nvar~=numel(vname)
        fprintf('please check variable names, eg ["x" "y" "z"]\n');
    end
    
    switch eletype
    case {'S4', 's4'}
        zonetype = 'fequadrilateral';
    otherwise

        switch nnode
            case 2
                zonetype = 'felineseg';
            case 3
                zonetype = 'fetriangle';
            case 4
                zonetype = 'fetetrahedron';
                fprintf('element type not specified, c3d4 assumed, specify ''S4'' otherwise\n');
            case 8
                zonetype = 'febrick';

            otherwise
                fprintf('%d node element type not supported.\n',nnode);
        end

    end

    
    %
    fname = [casename '.plt'];
    fid = fopen(fullfile(outdir,fname),'w');
    npt = size(v,1);
    nel = size(el,1);    
    
    fprintf(fid, ['variables = ' repmat('%s, ',1,nvar) '\r\n'], vname);
    fprintf(fid, 'zone t="%s"\r\n', casename);
    fprintf(fid, 'zonetype = %s\r\n',zonetype);
    fprintf(fid, 'datapacking = point\r\n');
    fprintf(fid, 'N=%d, E=%d\r\n', npt, nel);
    
    for i =1:npt
        fprintf(fid, [repmat('%12.8f ',1,nvar) '\r\n'], v(i,:));
    end
    for i =1:nel
        fprintf(fid, [repmat('%6d ',1,nnode) '\r\n'], el(i,:));
    end
    fclose(fid);
    
    
