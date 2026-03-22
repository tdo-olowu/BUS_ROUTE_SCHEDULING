classdef Bus
    properties
        % remainingMileage is gone.
        id

        % Position
        currentNode
        nextNode
        progress
        %edgeWeight Not needed as a property

        % Path traversal
        path                % aka destinations?
        pathIndex

        % Passengers
        currentStudents   % array of student IDs

        % Capacity
        capacity

        % Rates and Times
        boardingRate    % for now, number of students per timestep
        offloadingRate
        speed           % not in m/s, but proportion of speed limit e.g. 0.5, 1
        expectedTimeOfJourney   % how many time steps a journey is expected to take

        % State machine
        state
        timer

        % Trip tracking
        startDepot
        hasBoardedThisTrip
    end

    methods
        %% Constructor
        function obj = Bus(id, startNode, capacity, speed, boardingRate, offloadingRate)
            obj.id = id;

            obj.currentNode = startNode;
            obj.nextNode = startNode;
            obj.progress = 0;

            %obj.edgeWeight = 1;  % default

            obj.path = [];
            obj.pathIndex = 1;

            obj.currentStudents = [];

            obj.capacity = capacity;
            obj.speed = speed;

            obj.boardingRate = boardingRate;
            obj.offloadingRate = offloadingRate;

            obj.state = "START";
            obj.timer = 0;
            obj.expectedTimeOfJourney = 0;

            obj.startDepot = startNode;
            obj.hasBoardedThisTrip = false;
        end

        %% State Update
        function [obj, stations, students] = updateState(obj, G, stations, students)
            switch obj.state
                case "START"
                    [obj, stations, students] = obj.handleStart(stations, students, G);
                case "PARKED"
                    [obj, stations, students] = obj.handleParked(stations, students, G);
                case "BOARDING"
                    [obj, stations, students] = obj.handleBoarding(stations, students, G);
                case "DROPPING"
                    [obj, students] = obj.handleDropping(students);
                case "TRANSIT"
                    obj = obj.handleTransit(G);
                case "STOP"
                    % Do nothing
                otherwise
                    error("Unknown state");
            end
        end

        %% Handler for START state
        function [obj, stations, students] = handleStart(obj, stations, students, G)
            if ~isempty(stations(obj.currentNode).queue)
                obj = obj.enterBoarding(stations, students);
                obj.state = "BOARDING";
            else
                obj = obj.planNextMove(G);
                obj = obj.enterTransit(G);
                obj.state = "TRANSIT";
            end
        end

        %% Enter the transit state. Mainly sets timer for progress calculation
        function obj = enterTransit(obj, G)
            edgeIdx = findedge(G, obj.currentNode, obj.nextNode);
            weight = G.Edges.Weight(edgeIdx);

            obj.expectedTimeOfJourney = ceil(weight / obj.speed);
            obj.timer = 0;
        end

        %% Hanlder for TRANSIT state
        function obj = handleTransit(obj, G)
            % edgeIdx = findedge(G, obj.currentNode, obj.nextNode);
            % weight = G.Edges.Weight(edgeIdx);

            % this part is the trickiest.
            % step = obj.speed / weight;
            % obj.progress = obj.progress + step;

            % calculate progress inefficiently
            obj.progress = (obj.timer / obj.expectedTimeOfJourney);
            % fprintf("\tProgress for Bus %d: %f\n", obj.id, obj.progress);
            obj.timer = obj.timer + 1;
            % if obj.timer > obj.expectedTimeOfJourney
            %     fprintf("\tTIME LARGER THAN EXPECTED for Bus%d!: t=%d, e=%d\n", ...
            %         obj.id, obj.timer, obj.expectedTimeOfJourney);
            % end

            % better idea - cf time with expected for flow control
            % progress is not needed but compute it by end.
            if obj.progress < 1
                return;
            elseif obj.progress >= 1 && obj.progress <= 1.01 % MgnOfError
                obj.currentNode = obj.nextNode;
                obj.progress = 0;

                % Advance along path
                if obj.pathIndex < length(obj.path)
                    obj.pathIndex = obj.pathIndex + 1;
                    obj.nextNode = obj.path(obj.pathIndex);
                end

                obj.state = "PARKED";
            else    % e.g. negative prorgess
                fprintf("unusual progress");
                %error("Progress overflow error");
            end
        end

        %% handler for PARKED state
        function [obj, stations, students] = handleParked(obj, stations, students, G)

            % If passengers need to drop
            if any(arrayfun(@(sid) students(sid).destination == obj.currentNode, obj.currentStudents))
                obj = obj.enterDropping(students);
                obj.state = "DROPPING";
                return;
            end

            % If passengers waiting on queue
            if ~isempty(stations(obj.currentNode).queue)
                obj = obj.enterBoarding(stations, students);
                obj.state = "BOARDING";
                return;
            end

            % No work → STOP
            obj.state = "STOP";
        end

        %% handler for BOARDING state
        function [obj, stations, students] = handleBoarding(obj, stations, students, G)

            obj.timer = obj.timer - 1;

            if obj.timer > 0
                return;
            end

            % Boarding actually happens instantly
            [obj, stations, students] = obj.performBoarding(stations, students);

            obj.hasBoardedThisTrip = true;

            obj = obj.planNextMove(G);
            obj = obj.enterTransit(G);    % set things up before changing state
            obj.state = "TRANSIT";

        end

        %% handler for DROPPING state aka offboarding
        function [obj, students] = handleDropping(obj, students)
            obj.timer = obj.timer - 1;
            if obj.timer > 0
                return;
            end
            [obj, students] = obj.performDropping(students);
            obj.state = "BOARDING";
        end

        %% function to enter the boarding state. It sets the timer
        function obj = enterBoarding(obj, stations, students)
            waiting = length(stations(obj.currentNode).queue);
            available = obj.capacity - length(obj.currentStudents);
            n = min(waiting, available);
            obj.timer = ceil(n / obj.boardingRate);
        end

        %% function to enter the drop state. It sets the timer
        function obj = enterDropping(obj, students)
            count = 0;

            for sid = obj.currentStudents
                if students(sid).destination == obj.currentNode
                    count = count + 1;
                end
            end
            % n students / (s students per timestep) = ceil(n/s) timesteps
            obj.timer = ceil(count / obj.offloadingRate);
        end

        %% perform Boarding
        function [obj, stations, students] = performBoarding(obj, stations, students)

            station = stations(obj.currentNode);
            available = obj.capacity - length(obj.currentStudents);
            n = min(available, length(station.queue));
            ids = station.queue(1:n);
            obj.currentStudents = [obj.currentStudents, ids];

            for sid = ids
                students(sid).state = "ON_BUS";
                students(sid).busId = obj.id;
            end

            station.queue(1:n) = [];
            stations(obj.currentNode) = station;
        end

        %% perform Dropping
        function [obj, students] = performDropping(obj, students)
            keep = [];

            for sid = obj.currentStudents
                if students(sid).destination == obj.currentNode
                    students(sid).state = "ARRIVED";
                else
                    keep(end+1) = sid;
                end
            end

            obj.currentStudents = keep;
        end

        %% planNextMove - network traversal policy
        function obj = planNextMove(obj, G)
            neighborsList = successors(G, obj.currentNode);

            if isempty(neighborsList)
                obj.nextNode = obj.currentNode;
                return;
            end
            
            % here we pick the successor at random.
            % better planning would pick a successor that optimizes some
            % metric
            obj.nextNode = neighborsList(randi(length(neighborsList)));
            % in general, a path should be a list of stations to visit in
            % order? maybe like priority queue?
            obj.path = [obj.currentNode, obj.nextNode];
            obj.pathIndex = 2;
            obj.progress = 0;
        end
    end

end