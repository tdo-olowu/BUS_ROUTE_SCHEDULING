clear; clc;

%%% GRAPH SETUP
numStations = 7;

s = [1 1 2 2 3 4 5];
t = [2 3 4 5 6 6 7];
weights = [1 2 1 2 1 2 1];

G = graph(s, t, weights);

busParks = [1, 7];

figure;

%%% CREATE STATIONS
stations = Station.empty;

for i = 1:numStations
    stations(i) = Station(i);
end

%%% CREATE BUSES
buses = [
    Bus(busParks(1), 5, 20), ...
    Bus(busParks(2), 5, 20)
];

%%% SIMULATION
T = 30;

viz = Visualizer(G);

for t = 1:T
    fprintf('\n--- Time %d ---\n', t);

    %%% GENERATE STUDENTS
    for i = 1:numStations
        stations(i) = stations(i).generateStudents(numStations);
    end

    %%% UPDATE BUSES
    for b = 1:length(buses)

        % Drop off
        buses(b) = buses(b).dropOff();

        % Pick up
        node = buses(b).currentNode;
        [buses(b), stations(node)] = buses(b).pickUp(stations(node));

        % Decide next move
        target = buses(b).decideTarget(G, stations, busParks);

        % Move
        buses(b) = buses(b).move(G, target);

        fprintf('Bus %d at %d | Passengers: %d | Fuel: %d\n', ...
            b, buses(b).currentNode, ...
            length(buses(b).passengers), ...
            buses(b).remainingMileage);
    end

    %%% ✅ VISUALIZE ONCE PER TIME STEP
    viz = viz.update(stations, buses, t);
    
    % pause so visualization doesn't fly by
    pause(0.1);

    %% old VISUALIZATION
    %clf;
    %h = plot(G);


    % Highlight buses
    % positions = [buses.currentNode];
    % highlight(h, positions, 'NodeColor', 'r', 'MarkerSize', 8);
    % 
    % title(['Time ', num2str(t)]);
    % drawnow;

end