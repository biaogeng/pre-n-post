

function surf = read_ccx_inp_dlo(fname)

% store input lines in a cell array


inplines = splitlines(fileread([fname '.dlo']));


%% get rid of blanks and comment lines
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


nlines = length(inplines);
nfacet = 0;

eside = zeros(nlines,2); % element side definition of facets
il = 0;
while il<nlines
    
    il=il+1;
    s = split(inplines{il},',');


    if ~isempty(s{1}) && s{1}(1)=='*' % new keyword
        break
    end

    nfacet = nfacet + 1;
    eside(nfacet,1) = sscanf(s{1},'%d');
    eside(nfacet,2) = sscanf(upper(s{2}),'P%d');
    

end

surf.name = fname;
surf.side = eside;



