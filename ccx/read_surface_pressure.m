

function sp = read_surface_pressure(subdir,fname)

% read the surface output of the Bernoulli-CCX FSI simulation

% subdir = 'Y:\bct_talker\tests\2021-09-22-canine-modal\casefiles\outputs';
% fname = 'canine_modal10_ph11.surface';

if ~strcmpi(fname(end-3:end),'.plt')
    fname = [fname '.plt'];
end

nvar = 7;
fid = fopen(fullfile(subdir,fname));
% count time frames / number of eigenmodes
while ~feof(fid)
    s = fgetl(fid);
    if contains(s,'N=')
        data = sscanf(s,' N=         %d , E=         %d');
        npt = data(1);
        nel = data(2);
        
        fgetl(fid);
        fgetl(fid);
        x = fscanf(fid,'%f',[nvar npt])';
        x(:,4:end)=[];
        ele = fscanf(fid,'%d',[3,nel])';
        break;
    end
end

% nframe = 0;
% fprintf('counting frames ...\n');
% while ~feof(fid)
%     s = fgetl(fid);
%     if contains(s,'solutiontime')
%         nframe = nframe + 1;
%         fprintf('.');
%         if mod(nframe,100)==0
%             fprintf('\n'); 
%         end
%         fgetl(fid);
%         fscanf(fid,'%f',[nvar npt]);
%         
%     end
% end
% 
% st = zeros(nframe,1);
% vars = cell(nframe,1);
% 
% 
% frewind(fid); %

iframe = 0;
fprintf('reading frames ...\n');
while ~feof(fid)
    s = fgetl(fid);
    if contains(s,'solutiontime')
        data = sscanf(s,' solutiontime =   %f');
        s = fgetl(fid);
        if contains(s,'CONNECTIVITYSHAREZONE')
            iframe = iframe +1;
            fprintf('.');
            if mod(iframe,100)==0
                fprintf('\n'); 
            end

            st(iframe) = data;
            vars{iframe} = fscanf(fid,'%f',[nvar npt])';
        end
    end
end

fclose(fid);


sp.x = x;
sp.ele = ele;
sp.st = st;
sp.vars = vars;

