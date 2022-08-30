%
% read ccx input (using the same logic as Calculix)
%   - bgeng 2020-01-24
%   - 
%   - filter comments and blanks
%   - expand *include files
%   - store in a cell array of character strings
%

function inplines = filter_ccx_inp(subdir,inp)

    % store input lines in a cell array
    
    blanks = {'\r\n','\r','\n',' '};
    inplines = cell(2,1);
    nt = 0; % total non-trivial lines
    
    ifile = 1;
    fid{ifile} = fopen([subdir '/' inp]);
    nl{ifile} = 0; % lines of each file
    fname = inp;
    
    while ifile>0
        if ~feof(fid{ifile})
        
            s = fgetl(fid{ifile});
            nl{ifile} = nl{ifile} + 1;
            
            % remove blanks
            s = replace(s,blanks,'');
            s = regexprep(s,'\t','');

            if isempty(s)
               % empty line
            elseif length(s)==1
               % single character line
               if strcmp(s,'*') || strcmp(s,',')
                    s = '';
               end
            else
               if s(1) == ','
                   fprintf('warning: line %d in [%s] begins with comma\n',nl{ifile},fname);
                   s = s(2:end);

               % comment lines
               elseif strcmp(s(1:2),'**') 
                    s = '';
               %
               elseif contains(upper(s),'*INCLUDE')
                   ifile = ifile + 1;
                   if ifile > 10 % 
                       fprintf('too many layers of *include\n');
                       break
                   end
                   
                   ss = split(s,',');
                   fid{ifile} = fopen([subdir '/' ss{2}(7:end)]);

                   if fid{ifile}>0
                        nl{ifile} = 0;                       
                        fname = ss{2}(7:end);
                        continue
                   else
                       s = '';
                       fprintf('cant open file %s\n',ss{2}(7:end));
                       fprintf('check line %d in [%s]\n',nl{ifile-1},fname);
                       ifile = ifile - 1;
                   end
               end

            end

            % store non trivial lines
            if isempty(s) 
                continue 
            else
                if s(end) ==','
                    s = s(1:end-1);
                end
                nt = nt + 1;
                inplines{nt} = s;
            end
        
        else
           fclose(fid{ifile});              
           ifile = ifile - 1;
           continue
        end
    end




    
    