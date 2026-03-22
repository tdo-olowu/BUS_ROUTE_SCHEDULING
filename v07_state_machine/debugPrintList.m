function debugPrintList(name, data)
%DEBUGPRINTLIST Pretty-print a variable for debugging
%   debugPrintList(name, data)
%   - name: string label for the variable
%   - data: array, cell array, struct, or other MATLAB variable

    if nargin < 2
        error('Usage: debugPrintList(name, data)');
    end

    fprintf('--- %s ---\n', name);

    if isnumeric(data) || islogical(data)
        % Numeric or logical arrays
        for i = 1:numel(data)
            fprintf('[%d] = %g\n', i, data(i));
        end

    elseif iscell(data)
        % Cell arrays
        for i = 1:numel(data)
            fprintf('{%d} = ', i);
            disp(data{i});
        end

    elseif isstruct(data)
        % Struct arrays
        for i = 1:numel(data)
            fprintf('Struct element %d:\n', i);
            fields = fieldnames(data);
            for f = 1:numel(fields)
                value = data(i).(fields{f});
                fprintf('  %s: ', fields{f});
                disp(value);
            end
        end

    elseif isstring(data) || ischar(data)
        % Strings / char arrays
        disp(data);

    else
        % Fallback for other types
        disp(data);
    end

    fprintf('-----------------\n\n');
end