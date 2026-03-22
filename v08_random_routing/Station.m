% STATION

classdef Station < handle
    properties
        id
        queue
    end

    methods
        % Constructor
        function obj = Station(id)
            obj.id = id;
            obj.queue = [];
        end

        % adds a student with given ID to the queue for the bus
        function obj = addStudent(obj, studentId)
            obj.queue(end+1) = studentId;
        end

        function obj = removeStudents(obj, indices)
            obj.queue(indices) = [];
        end

        % updates the queue as students board the Bus
        function obj = update(obj)
            % placeholder...is this even useful?
        end
    end
end
