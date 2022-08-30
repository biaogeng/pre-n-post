function tf = isnewer(file1,file2)
% returns true if file1 is newer tha file2

    if ~exist(file2,'file')
        tf = true;
        return
    else
        f1 = dir(file1);
        f2 = dir(file2);
        if f1.datenum > f2.datenum
            tf = true;
        else
            tf = false;
        end
        return
    end
    





