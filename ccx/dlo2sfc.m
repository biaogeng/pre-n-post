%% converts *.dlo files output by CGX into surface sets
%  note: CGX can only ? output surface set through dload definition


%%
function dlo2sfc(subdir,fname)

    if ~exist('fname','var')
        files = dir([subdir '/*.dlo']);
    else
        if ~contains(fname,'.dlo')
            fname = [fname '.dlo'];
        end
        files(1).name = fname;
    end
    n = 0;
    for i=1:numel(files)
        fname = files(i).name;
        
        fdlo = fullfile(subdir,fname);
        fsfc = fullfile(subdir,replace(fname,'.dlo','.sfc'));
        if isnewer(fdlo,fsfc)
            n = n + 1;
            fid1 = fopen(fdlo);
            fgetl(fid1);
            buffer = fscanf(fid1,'%d, P%d, %f\n', [3 Inf])';
            fclose(fid1);

            fid2 = fopen(fsfc,'w');
            fprintf(fid2,'*SURFACE,NAME=%s\n',fname(1:end-4));
            fprintf(fid2,'%d, S%d\n', buffer(:,1:2)');

            fclose(fid2);
            fprintf('Converted %s to %s\n',fdlo,fsfc);
%         else
%             fprintf('%s is up to date\n',fsfc);
        end
    end

