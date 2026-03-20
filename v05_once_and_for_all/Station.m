% STATION

% NEW SUGGESTION:
% classdef Station
%     properties
%         id
%         waitingStudents
%     end
% 
%     methods
%         function obj = Station(id)
%             obj.id = id;
%             obj.waitingStudents = [];
%         end
% 
%         function obj = addStudent(obj, studentId)
%             obj.waitingStudents(end+1) = studentId;
%         end
% 
%         function obj = update(obj)
%             % placeholder
%         end
%     end
% end


%%
classdef Station
    properties
        id
        queue % list of destinations
    end

    methods
        function obj = Station(id)
            obj.id = id;
            obj.queue = [];
        end

        function obj = generateStudents(obj, numStations)
            % Random student arrivals

            numNew = randi([0,2]);

            for k = 1:numNew
                dest = randi(numStations);
                while dest == obj.id
                    dest = randi(numStations);
                end

                obj.queue(end+1) = dest;
            end
        end
    end
end