%% BUS DELIVERY SIMULATION (SKELETON)

clear; clc;

%% -------------------------------
% 1. CREATE GRAPH (7 stations)
% -------------------------------

numStations = 7;

% Define edges (simple connected graph)
s = [1 1 2 2 3 4 5];
t = [2 3 4 5 6 6 7];
weights = [1 2 1 2 1 2 1]; % distance or cost

G = graph(s, t, weights);

% Define bus parks (depots)
busParks = [1, 7];

figure;
h = plot(G);
title('Bus Network');

%% -------------------------------
% 2. INITIALIZE STATIONS
% -------------------------------

% Each station has a queue of students
stations = struct();

for i = 1:numStations
    stations(i).queue = []; % list of destinations
end

%% -------------------------------
% 3. INITIALIZE BUSES
% -------------------------------

numBuses = 2;

buses = struct();

for i = 1:numBuses
    buses(i).currentNode = busParks(i); % start at depot
    buses(i).passengers = [];           % list of destinations
    buses(i).capacity = 5;
    buses(i).remainingMileage = 20;
    buses(i).state = "IDLE"; % IDLE, SERVING, RETURNING
end

%% -------------------------------
% 4. SIMULATION PARAMETERS
% -------------------------------

T = 30; % number of time steps

%% -------------------------------
% 5. MAIN SIMULATION LOOP
% -------------------------------

for t = 1:T
    fprintf('--- Time Step %d ---\n', t);

    %% --------------------------------
    % (A) GENERATE NEW STUDENTS
    % --------------------------------
    for i = 1:numStations
        numNew = randi([0,2]); % random arrivals

        for k = 1:numNew
            dest = randi(numStations);
            while dest == i
                dest = randi(numStations);
            end

            stations(i).queue(end+1) = dest;
        end
    end

    %% --------------------------------
    % (B) UPDATE EACH BUS
    % --------------------------------
    for b = 1:numBuses

        current = buses(b).currentNode;

        % --- DROP OFF PASSENGERS ---
        % Remove passengers whose destination = current node
        buses(b).passengers( ...
            buses(b).passengers == current) = [];

        % --- PICK UP PASSENGERS ---
        availableSeats = buses(b).capacity - length(buses(b).passengers);

        if availableSeats > 0 && buses(b).state ~= "RETURNING"
            pickup = min(availableSeats, length(stations(current).queue));

            % Take first 'pickup' students
            buses(b).passengers = [ ...
                buses(b).passengers, ...
                stations(current).queue(1:pickup)];

            stations(current).queue(1:pickup) = [];
        end

        % --- DECIDE NEXT TARGET ---
        if buses(b).remainingMileage < 3
            buses(b).state = "RETURNING";
        end

        if buses(b).state == "RETURNING"
            % go to nearest bus park
            target = nearestNode(G, current, busParks);

        elseif ~isempty(buses(b).passengers)
            % go to nearest passenger destination
            target = nearestNode(G, current, buses(b).passengers);

        else
            % go to busiest station
            queueSizes = arrayfun(@(x) length(x.queue), stations);
            [~, target] = max(queueSizes);
        end

        % --- MOVE ONE STEP ALONG SHORTEST PATH ---
        if current ~= target
            path = shortestpath(G, current, target);

            if length(path) > 1
                nextNode = path(2); % move one hop
            else
                nextNode = current;
            end
        else
            nextNode = current;
        end

        % --- UPDATE BUS STATE ---
        buses(b).currentNode = nextNode;
        buses(b).remainingMileage = buses(b).remainingMileage - 1;

        fprintf('Bus %d -> Node %d | Passengers: %d | Fuel: %d\n', ...
            b, nextNode, length(buses(b).passengers), ...
            buses(b).remainingMileage);
    end

    %% --------------------------------
    % (C) VISUALIZATION
    % --------------------------------
    clf;
    h = plot(G);

    % Highlight bus positions
    busPositions = [buses.currentNode];
    highlight(h, busPositions, 'NodeColor', 'r', 'MarkerSize', 8);

    title(['Time Step ', num2str(t)]);
    drawnow;

end

%% -------------------------------
% HELPER FUNCTION
% -------------------------------

function nearest = nearestNode(G, startNode, targets)
% Finds the closest node (in targets) from startNode

    minDist = inf;
    nearest = targets(1);

    for i = 1:length(targets)
        [~, d] = shortestpath(G, startNode, targets(i));

        if d < minDist
            minDist = d;
            nearest = targets(i);
        end
    end
end