classdef Student
    properties
        id
        origin
        destination
        isServed = false
        hasFailed = false
        transitTime = 0
    end

    methods
        function obj = Student(id, origin, destination)
            obj.id = id;
            obj.origin = origin;
            obj.destination = destination;
        end

        function obj = update(obj)
            if ~obj.isServed
                obj.transitTime = obj.transitTime + 1;
            end
        end
    end
end