function write_xy_plt(fname,varnames,linezones,fmt)

% fname - output file name
% varnames - variable names, string array
% linezones - line data, data struct with zone names and actual xyyyyy data
% point packing, nentry*nvariable

% testing input
% fname = 'test.plt';
% varnames = ["x" "y" "frequency (Hz)"];
% linezones(1).name='zone1';
% linezones(1).data=rand(100,3);
% linezones(2).name="zone2";
% linezones(2).data=rand(200,3);


% 
nvar = numel(varnames);
fid = fopen(fname,'w');

fprintf(fid, 'variables = ');
fprintf(fid, '"%s" ',varnames);
fprintf(fid, '\n');

if ~exist('fmt','var')
    fmt = [repmat('%20.12E ',1,nvar) '\n'];
end

for l=linezones
    fprintf(fid,'zone t="%s"\n',l.name);
    fprintf(fid,fmt,l.data');
end 
    
fclose(fid);