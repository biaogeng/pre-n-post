
function [nodes,el] = read_ccx_inp_msh(fname)

% store input lines in a cell array
inplines = splitlines(fileread(fname));


%
blanks = {'\r\n','\r','\n','\t',' '};
nlines = length(inplines);
ie = false(nlines,1);

for i=1:nlines
   s = replace(inplines{i},blanks,'');
   
   if(length(s)>=2 && strcmp(s(1:2),'**'))
       s = '';
   end
   
   inplines{i} = s;
   ie(i) = isempty(s);
    
end


inplines(ie) = [];

% pre allocate
nlines = length(inplines);
nodes = zeros(nlines,4);
npt = 0;

nnode_max = 2;
el = zeros(nlines,21);
nel = 0;


il = 1;
s = split(inplines{il},',');
while il<nlines
    
    if strcmpi(s(1),'*NODE') % read nodal coordiantes
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            n = length(s);
            
            if s{1}(1)=='*' % new keyword
                break
            end
            
            npt = npt + 1;
            nodes(npt,1) = sscanf(s{1},'%d');
            for j=2:n
                nodes(npt,j) = sscanf(s{j},'%f');
            end
        end
    elseif strcmpi(s(1),'*element') % read elements
        
        s = split(inplines{il+1},',');
        n = length(s);
        if n-1>nnode_max
            nnode_max = n-1;
        end
        
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            n = length(s);
            if s{1}(1)=='*' % new keyword
                break
            end
            
            nel = nel + 1;
            for j=1:n
                el(nel,j) = sscanf(s{j},'%d');
            end
            
            
        end
        
    else
        
        fprintf('Keyword "%s" in line %d not supported,\n',s{1},il);
        fprintf('following input discarded\n');        
        fprintf('    %s\n',inplines{il});

        
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            if ~isempty(s{1}) && s{1}(1)=='*' % new keyword
                break
            else
                fprintf('    %s\n',inplines{il});
            end
        end
    end

    
end

nodes(npt+1:end,:)=[];
el(nel+1:end,:)=[];
el(:,nnode_max+2:end)=[];



