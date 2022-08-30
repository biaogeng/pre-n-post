%% converts *.dlo files output by CGX into surface sets
%  note: CGX can only ? output surface set through dload definition


%%
function sfc2dlo(fname,p)

% subdir = '.';

%
% files = dir (fullfile(subdir,'S-*.dlo'));

%
% fid_sinc = fopen(fullfile(subdir,'surfaces.inc'),'w');
% fprintf(fid_sinc,'** surface definitions \n');
% for file = files'
%     fprintf('%s\n',file.name);
    fid1 = fopen(fname);
    fgetl(fid1);
    buffer = fscanf(fid1,'%d, S%d\n', [2 Inf])';
    fclose(fid1);
    
    nr = size(buffer,1);
    fid2 = fopen([fname(1:end-4) '.dlo'],'w');
    fprintf(fid2,'%10d, P%1d, %12.5f\n', [buffer(:,1:2)'; ones(1,nr)*p]);
    
    fclose(fid2);
    
%     fprintf(fid_sinc, '*INCLUDE, INPUT=surfaces/%s.sfc\n',file.name(1:end-4));
    
end
% fclose(fid_sinc);
