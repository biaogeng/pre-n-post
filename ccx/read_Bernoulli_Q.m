function Q=read_Bernoulli_Q(subdir,fname)

% read the Q output of the Bernoulli-CCX FSI simulation

% subdir = 'T:\bgeng_working\modal_dynamic\pigeon_model\half\tweak\2022-03-11\a';
% fname = 'pigeon_modal50_1.0_ph11.Q.plt';

if ~strcmpi(fname(end-3:end),'.plt')
    fname = [fname '.plt'];
end


fid = fopen(fullfile(subdir,fname));
s = fgetl(fid);
nvar = numel(find(s==','))+1;
fgetl(fid);

Q = fscanf(fid,'%f',[nvar Inf])';
Q(:,3:end) = [];


fclose(fid);

