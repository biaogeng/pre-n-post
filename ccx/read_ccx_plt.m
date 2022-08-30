function plt = read_ccx_plt(subdir,fname,tmax)
% read ccx tecplot output (.plt file)
% stores in the plt struct

% to do 
% - adapt to number of variables
% - adapt to type of elements

% testing inputs
% clc;clear;
% subdir = 'Z:\bct_talker\fsi_w_activation\lvf_mr_static\ia00\ct00_ta01\solid';
% fname = 'ia00_ct00_ta01.plt';
% tmax = 100;

if ~exist('tmax','var')
    tmax = Inf;
end

%
nvar = 12;
typesChar = cell(1,1);
el = cell(1,1);

fid = fopen([subdir '/' fname]);
plt.name = fname(1:end-4);
if fid<0
    fid = fopen([subdir '/' fname '.plt']);
    plt.name = fname;
end

plt.dir = subdir;


% read 1st frame
for i=1:7
    buff = fgetl(fid);
end
if contains(buff,'FEBRICK')
    npe = 8;
    typesChar{1} = 'FEBRICK';
elseif contains(buff,'FETETRAHEDRON')
    npe = 4;
    typesChar{1} = 'FETETRAHEDRON';
else
    fprintf('%s\n',buff);
    fprintf('zonetype not supported\n');
    return
end

npt = fscanf(fid, ' N = %d',1);
nel = fscanf(fid, ' , E = %d',1);
plt.x = zeros(npt,3); % coordinates
plt.var = cell(0,0);    % displacements
vars = zeros(npt,nvar);

fgetl(fid);
fgetl(fid);

solutiontime{1} = fscanf(fid, ' solutiontime = %f',1);

for i=1:nvar% x,y,z
    vars(:,i) = fscanf(fid,'%f',npt)';
    fgetl(fid);
end

plt.x = vars(:,1:3);
plt.var{1} = vars(:,4:end); % all variables



el{1} = fscanf(fid, '%d', [npe nel])';
buff = fgetl(fid);

ntypes = 1;
nf = 1; % frame count

newframe = false();

%% check number of zonetypes
while ~feof(fid) && ~newframe
    buff=fgetl(fid);
    if contains(buff,'zone t') % 
        buff=fgetl(fid);
        buff=fgetl(fid);
        zt = sscanf(buff,' zonetype = %s');
        for i=1:length(typesChar)
            if strcmp(typesChar{i},zt)
                % old type
                newframe = true();
                break
            else 
                % new type
                ntypes = ntypes + 1;
                typesChar{ntypes} = zt;
                
                if contains(buff,'FEBRICK')
                    npe = 8;
                elseif contains(buff,'FETETRAHEDRON')
                    npe = 4;
                else
                    fprintf('%s\n',buff);
                    fprintf('zonetype not supported\n');
                    return
                end
                npt = fscanf(fid, ' N = %d',1);
                nel = fscanf(fid, ' , E = %d',1);
                fgetl(fid);
                fgetl(fid); % strandID
                solutiontime{nf} = fscanf(fid, ' solutiontime = %f',1);
                fprintf('.');
                if mod(nf,50)==0
                    fprintf('%d\n',nf);
                end
                varshare = fscanf(fid, ' VARSHARELIST = ([%d-%d] = %d  )');
                
                el{ntypes} = fscanf(fid, '%d', [npe nel])';
            end
        end
    end

end
        %    





% rest frames

while ~feof(fid)
    
    if contains(buff,'zonetype') % scan one frame
        %
        nf = nf + 1;
%         fgetl(fid); % packing
%         fgetl(fid); % element type
        npt = fscanf(fid, ' N = %d',1);
        nel = fscanf(fid, ' , E = %d',1);
        fgetl(fid);
        fgetl(fid); % strandID
        solutiontime{nf} = fscanf(fid, ' solutiontime = %f',1);
        fprintf('.');
        if mod(nf,50)==0
            fprintf('%d\n',nf);
        end
        conshare = fscanf(fid, ' CONNECTIVITYSHAREZONE = %d',1);
        varshare = fscanf(fid, ' VARSHARELIST = ([%d-%d]=    %d  )');

         
        for i=varshare(2)+1:nvar % exclude shared variables
            vars(:,i) = fscanf(fid,'%f',npt)';
            fgetl(fid);
        end
        plt.var{nf} = vars(:,4:end);
        
        for i=1:ntypes-1
            skip_lines(fid,9);
        end
    end

    
    if solutiontime{nf} > tmax
        fprintf('too many frames, t>%f not read\n',tmax);
        break
    end
    buff=fgetl(fid);
end
fprintf('\n');
fclose(fid);

plt.solutiontime = cell2mat(solutiontime);
plt.ele = el;


