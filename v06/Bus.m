classdef Bus
    properties
        id                  % unique ID

        currentNode         % current node index
        nextNode            % next node index (target along edge)
        progress            % progress along edge (0 → 1)
        edgeWeight            % represents time in minutes

        destinations        % list of nodes to visit (future use)
        currentStudents     % list of students (future use)

        capacity
        remainingMileage

        speed               % for future (not used yet)
        boardingRate        % students per timestep
        offloadingRate      % students per timestep

        state               % "IDLE", "MOVING", "RETURNING", etc
    end

    methods
        %% Constructor
        function obj = Bus(id, startNode, capacity, mileage, speed, boardingRate, offloadingRate)
            obj.id = id;
            obj.currentNode = startNode;
            obj.nextNode = startNode;
            obj.progress = 0;

            obj.capacity = capacity;
            obj.remainingMileage = mileage;
            obj.speed = speed;
            obj.boardingRate = boardingRate;
            obj.offloadingRate = offloadingRate;

            obj.state = "IDLE";
            obj.edgeWeight = 1; % default
        end


        % sets next state based on current state
        function [obj, stations, students] = updateState(obj, G, stations, students)
            switch obj.state
                case "IDLE" % either loading, unloading or etc 
                    % e.g if IDLE and obj.fuel_low() and at depot, then
                    % refuel
                    [obj, stations, students] = ...
                        obj.handleIdleState(G, stations, students);
                case "MOVING" % currently moving
                    obj = obj.handleMovingState(G);
                case "RETURNING"
                    obj = obj.handleReturningState(G);
                case "FAILED"   % ran out of mileage while in transit
                    %obj = obj.handleFailedState(G);
                case "LATE"     % could not make it back to bus garage b4
                    % end of simulation
                    %obj = obj.handleLateState(G);
                otherwise
                    error("Unknown state");
            end
        end


        % ------------------------------------
        %   IMPLEMENTING STATE HANDLERS
        % ------------------------------------
        function [obj, stations, students] = handleIdleState(obj, G, stations, students)
            % --- Drop off students firs10t ---
            [obj, students] = obj.offloadStudents(students);
            % --- Pick up students ---
            [obj, stations(obj.currentNode), students] = ...
                obj.boardStudents(stations(obj.currentNode), students);
            % --- Decide next move ---
            obj = obj.decideNextNode(G);
            % if there is somewhere to go
            if obj.currentNode ~= obj.nextNode
                obj.state = "MOVING";
            end
        end


        % ---- drop off students at Stations ---- %
        function [obj, students] = offloadStudents(obj, students)
            if isempty(obj.currentStudents)
                return;
            end
            % Find students whose destination = current node
            toDrop = [];
            for i = 1:length(obj.currentStudents)
                sid = obj.currentStudents(i);
                if students(sid).destination == obj.currentNode
                    students(sid).state = "ARRIVED";
                    students(sid).busId = -1;
                    students(sid).currentNode = obj.currentNode;
                    toDrop(end+1) = i;
                end
            end
            % Remove them
            obj.currentStudents(toDrop) = [];
            % performance_metrics.served = ...
            %     performance_metrics.served + length(toDrop);
        end


        % ---- board Students on the bus ---- %
        function [obj, station, students] = boardStudents(obj, station, students)
            availableSeats = obj.capacity - length(obj.currentStudents);
            if availableSeats <= 0 || isempty(station.queue)
                return;
            end

            numToBoard = min([obj.boardingRate, availableSeats, length(station.queue)]);
            boardingIDs = station.queue(1:numToBoard);

            for i = 1:length(boardingIDs)
                sid = boardingIDs(i);
                % update student state
                students(sid).state = "ON_BUS";
                students(sid).busId = obj.id;
            end

            % waiting = station.waitingStudents;
            % if isempty(waiting)
            %     return;
            % end
            % take as many as possible
            % numToBoard = min(obj.boardingRate, availableSeats);
            % numToBoard = min(numToBoard, length(waiting));

            % Add students
            % obj.currentStudents = [obj.currentStudents, waiting(1:numToBoard)];
            obj.currentStudents = [obj.currentStudents, boardingIDs];

            % Remove from station
            station.queue(1:numToBoard) = [];
        end

        % --- handleMovingState --- 
        function obj = handleMovingState(obj, G)
            % move along edge
            obj = obj.move(G);
            % If arrived, switch to IDLE
            if obj.progress == 0
                obj.state = "IDLE";
            end
        end

        %--- handleReturningState ---%
        function obj = handleReturningState(obj, G)
            % placeholder for later
            obj = obj.move(G);
        end


        %% Decide next node (simple traversal for now)
        function obj = decideNextNode(obj, G)
            %neighborsList = neighbors(G, obj.currentNode);
            neighborsList = successors(G, obj.currentNode);

            if isempty(neighborsList)
                % Dead end → stay
                obj.nextNode = obj.currentNode;
                obj.state = "IDLE";
                return;
            end

            % Random next node (you can replace this later)
            idx = randi(length(neighborsList));
            obj.nextNode = neighborsList(idx);

            % Get edge weight
            edgeIdx = findedge(G, obj.currentNode, obj.nextNode);
            obj.edgeWeight = G.Edges.Weight(edgeIdx);

            obj.progress = 0;
            obj.state = "MOVING";
        end


        %% Move along edge (smooth motion)
        function obj = move(obj, G)

            % If at node, choose next
            if obj.currentNode == obj.nextNode
                obj = obj.decideNextNode(G);
            end

            % Avoid division issues
            if obj.edgeWeight == 0
                return;
            end

            % Progress increment based on edge weight
            %step = obj.speed / obj.edgeWeight; // this one assumed
            % that edgeWeight was distance?
            step = obj.speed / obj.edgeWeight;
            obj.progress = obj.progress + step;

            % Arrived at next node
            if obj.progress >= 1
                obj.currentNode = obj.nextNode;
                obj.progress = 0;

                % Immediately choose next edge
                obj = obj.decideNextNode(G);
            end

            % Optional mileage tracking
            obj.remainingMileage = obj.remainingMileage - obj.speed;
        end


        %% Get interpolated position (for visualization)
        function [x, y] = getPosition(obj, X, Y)
            x1 = X(obj.currentNode);
            y1 = Y(obj.currentNode);

            x2 = X(obj.nextNode);
            y2 = Y(obj.nextNode);

            % Linear interpolation
            x = (1 - obj.progress)*x1 + obj.progress*x2;
            y = (1 - obj.progress)*y1 + obj.progress*y2;
        end
    end
end