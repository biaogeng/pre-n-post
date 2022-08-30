function muscles = read_elastic_fiber_muscles(subdir,fname)
% extract model parameters from elastic fiber muscles input

%  subdir = '.';
%  fname = 'muscles.inp';

    inplines = filter_ccx_inp(subdir,fname);
    
    nlines = length(inplines);
    il = 1;
    s = split(inplines{il},',');
    n = numel(s);
    
    nm = 0;
    while il<nlines
        % read nodal coordiantes
        if strcmpi(s(1),'*material') && contains(upper(s{2}),'ELASTIC_FIBER')
            nm = nm + 1;
            m_name = s{2}(19:end);
            if (m_name(1) == '-' || m_name(1) == '_')
                m_name(1) = [];
            end
            muscles(nm).name = m_name;
            
            while(il<nlines)
                il=il+1;
                s = split(inplines{il},',');
                n = length(s);

                if strcmpi(s(1),'*material') % new keyword
                    break
                end
                if strcmpi(s(1),'*USERMATERIAL') % constants
                    nconst = sscanf(upper(s{2}),'CONSTANTS=%d');
                    il=il+1;
                    buff=sscanf(inplines{il},'%f,',[1 Inf]);
                    muscles(nm).consts = buff;
                    n_remainder = nconst-numel(buff);
                    while n_remainder>0
                        il=il+1;
                        buff=sscanf(inplines{il},'%f,',[1 Inf]);
                        muscles(nm).consts = [muscles(nm).consts buff];
                        n_remainder = n_remainder - numel(buff);
                    end
                end
                if strcmpi(s(1),'*density')
                    il=il+1;
                    muscles(nm).density=sscanf(inplines{il},'%f');
                end

            end
            continue
        end

        % all keywords missed
        fprintf('Keyword "%s" in line %d not supported,\n',s{1},il);
        fprintf('following input discarded\n');        
        fprintf('    %s\n',inplines{il});
        while(il<nlines)
            il=il+1;
            s = split(inplines{il},',');
            n = length(s);
            if ~isempty(s{1}) && s{1}(1)=='*' % new keyword
                break
            else
                fprintf('    %s\n',inplines{il});
            end
        end
    end   
    