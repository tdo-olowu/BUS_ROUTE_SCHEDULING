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

        state               % "IDLE", "MOVING", "RETURNING"
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