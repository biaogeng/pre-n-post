function buffer = skip_lines(fid,n)
% wrapper around fgetl
% fid - file id
% n   - # of lines to skip
% buffer - the last line skipped

for i=1:n
    buffer = fgetl(fid);
end