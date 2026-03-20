% BUS

classdef Bus
    properties
        currentNode
        %nextNode
        passengers
        capacity
        remainingMileage
        state % "IDLE", "SERVING", "RETURNING"
    end

    methods
        function obj = Bus(startNode, capacity, mileage)
            obj.currentNode = startNode;
            obj.passengers = [];
            obj.capacity = capacity;
            obj.remainingMileage = mileage;
            obj.state = "IDLE";
        end

        function obj = dropOff(obj)
            % Remove passengers whose destination is current node
            obj.passengers(obj.passengers == obj.currentNode) = [];
        end

        function [obj, station] = pickUp(obj, station)
            % Pick up students from a station queue

            if obj.state == "RETURNING"
                return;
            end

            availableSeats = obj.capacity - length(obj.passengers);
            pickup = min(availableSeats, length(station.queue));

            if pickup > 0
                obj.passengers = [obj.passengers, station.queue(1:pickup)];
                station.queue(1:pickup) = [];
            end
        end

        function target = decideTarget(obj, G, stations, busParks)
            % Decide where to go next

            if obj.remainingMileage < 3
                obj.state = "RETURNING";
            end

            if obj.state == "RETURNING"
                target = obj.nearestNode(G, busParks);
                return;
            end

            if ~isempty(obj.passengers)
                target = obj.nearestNode(G, obj.passengers);
            else
                % find busiest station
                queueSizes = arrayfun(@(s) length(s.queue), stations);
                [~, target] = max(queueSizes);
            end
        end

        function obj = move(obj, G, target)
            % Move one step toward target

            if obj.currentNode ~= target
                path = shortestpath(G, obj.currentNode, target);

                if length(path) > 1
                    obj.currentNode = path(2);
                end
            end

            obj.remainingMileage = obj.remainingMileage - 1;
        end
    end

    methods (Access = private)
        function nearest = nearestNode(obj, G, targets)
            % Find closest node among targets

            minDist = inf;
            nearest = targets(1);

            for i = 1:length(targets)
                [~, d] = shortestpath(G, obj.currentNode, targets(i));

                if d < minDist
                    minDist = d;
                    nearest = targets(i);
                end
            end
        end
    end
end