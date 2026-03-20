% NOTES:
% All time is measured in minutes, and distance in metres.

clear; clc;

%%% GRAPH SETUP
numStations = 11;

s = [1 2 3 4 4 4 5 6 7 8 9 10 11];
t = [2 3 4 5 7 9 6 8 8 9 10 11 1]; % (s,t) is an edge
weights = [5 10 1 3 5 1 5 5 5 2 6 3 7]; % time in mins
names = {'Gate' 'OpaDam' 'BankArea' 'MainBusStop' 'Moremi' ...
         'Awo' 'NewMarket' 'Faj' 'CarPark' 'ReligiousGround' 'LocalGovt'};

G = digraph(s, t, weights, names);

busParks = [4, 9];
SPEED_LIMIT = 300; % metres per minute
BUS_CAPACITY = 5;
BUS_MILEAGE = 20;
BUS_SPEED = 10;
BUS_WAIT_RATE = 1;

figure;

%%% CREATE STATIONS
stations = Station.empty;

for i = 1:numStations
    stations(i) = Station(i);
end

%%% CREATE BUSES
% Bus(id, startNode, capacity, mileage, speed, boardingRate, offloadingRate)
buses = [
    Bus(1, busParks(1), BUS_CAPACITY, BUS_MILEAGE, BUS_SPEED, BUS_WAIT_RATE, BUS_WAIT_RATE), ...
    Bus(2, busParks(2), BUS_CAPACITY, BUS_MILEAGE, BUS_SPEED, BUS_WAIT_RATE, BUS_WAIT_RATE)
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
        %buses(b) = buses(b).dropOff();

        % Pick up
        %node = buses(b).currentNode;
        %[buses(b), stations(node)] = buses(b).pickUp(stations(node));

        % Decide next move
        target = buses(b).decideNextNode(G);

        % Move
        buses(b) = buses(b).move(G);

        % fprintf('Bus %d at %d | Passengers: %d | Fuel: %d\n', ...
        %     b, buses(b).currentNode, ...
        %     length(buses(b).passengers), ...
        %     buses(b).remainingMileage);
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