classdef Student
    properties
        id
        origin
        currentNode
        busId
        destination
        isServed = false
        % hasFailed = false
        state                   % "WAITING", "ON_BUS", "ARRIVED"
        transitTime
    end

    methods
        function obj = Student(id, origin, destination)
            obj.id = id;
            obj.origin = origin;
            obj.destination = destination;
            obj.state = "WAITING";
            obj.currentNode = origin;
            obj.busId = -1;
            obj.transitTime = 0;
        end

        function obj = update(obj)
            % if ~obj.isServed
            %     obj.transitTime = obj.transitTime + 1;
            % end
            if obj.state ~= "ARRIVED" && obj.state ~= "FAILED"
                obj.transitTime = obj.transitTime + 1;
            end
        end
    end
end

