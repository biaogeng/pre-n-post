%
% determine model sizes from input character string
% bgeng 2020-01-24

function sz = count_model_sizes(inplines)

nlines = length(inplines);
npt = 0; % # of nodes
nel = 0; % # of elements
npe = 0; % # of nodes per element

% n_elset = 0;
% n_nset = 0;
% n_surf = 0;


il = 1;
s = split(inplines{il},',');

while il<nlines
    
    % nodal coordiantes
    if strcmpi(s(1),'*NODE')
%         if contains(upper(inplines{il}),'NSET=')
%             % to do, check set name
%             n_nset = n_nset + 1;
%         end
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            
            if s{1}(1)=='*' % new keyword
                break
            end
            npt = npt + 1;
        end
        
    elseif strcmpi(s(1),'*element') % read elements
        n = numel(s);
        for i=1:n
            if contains(s(i),'TYPE=') 
                if contains(s(i),'C3D8')
                    npe = 8;
                elseif contains(s(i),'C3D4')
                    npe = 4;   
                else
                    fprintf('element %s not supported\n',s(i));
                    return
                end
                break
            end
        end
%         if contains(inplines{il},'ELSET=')
%             n_elset = n_elset + 1;
%         end
        
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            if s{1}(1)=='*' % new keyword
                break
            end
            nel = nel + 1;           
        end
        
%     elseif strcmpi(s(1),'*elset') % 
%         n_elset = n_elset + 1;
% 
%         while(il<nlines)
%             il=il+1;
%             s = split(inplines{il},',');
%             if s{1}(1)=='*' % new keyword
%                 break
%             end       
%         end
%         
%     elseif strcmpi(s(1),'*nset') % 
%         n_nset = n_nset + 1;
% 
%         while(il<nlines)
%             il=il+1;
%             s = split(inplines{il},',');
%             if s{1}(1)=='*' % new keyword
%                 break
%             end       
%         end
%         
%     elseif strcmpi(s(1),'*surface') && ~contains(upper(inplines{il}),'TYPE=NODE')
%             n_surf = n_surf + 1;
% 
% 
%         while(il<nlines)
%             il=il+1;
%             s = split(inplines{il},',');
%             if s{1}(1)=='*' % new keyword
%                 break
%             end       
%         end
        
        
    else
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            if ~isempty(s{1}) && s{1}(1)=='*' % new keyword
                break
            end
        end
    end

    
end

sz.npt = npt;
sz.nel = nel;
sz.npe = npe;
% sz.n_nset = n_nset;
% sz.n_elset = n_elset;
% sz.n_surf = n_surf;

