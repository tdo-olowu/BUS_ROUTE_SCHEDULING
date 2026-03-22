% NOTES:
% All time is measured in minutes, and distance in metres.
% For simplicity, the time that events take is an integer multiple of the
% time steps.
% Hence, this would be a Discrete Time simulation.
% An upgrade would be to make it continueous time so that events may take
% time whose length is not commensurable with a multiple of the timestep.
% However, that adds more complexity than I'm currently willing to handle.


clear; clc;

% INITIALIZE SIMULATION PARAMETERS
BUS_COUNT = 3; % three buses
STUDENT_COUNT = 100;
TIME_SPAN = 50; % 200 time steps in minutes. About 4 hours

% ROAD NETWORK SETUP
STATION_COUNT = 11; % DO NOT CHANGE THIS!!!
listOfStations = Station.empty;
for i = 1:STATION_COUNT
    listOfStations(i) = Station(i);
    % queue initially empty
end

SPEED_LIMIT = 1; % explanation of this in README.
                 % all speed is a proportion of speed limit.
s = [1 2 3 4 4 4 5 6 7 8 9 10 11];
t = [2 3 4 5 7 9 6 8 8 9 10 11 1]; % (s,t) is an edge
% weights represent avg time it takes to cross road if moving at speed limit.
% actual time spent depends on speed limit and distance
% for this simulation, weights are a number of timesteps, to keep it
% simple.
weights = 2*[5 10 1 3 5 1 5 5 5 2 6 3 7];
names = {'Gate' 'OpaDam' 'BankArea' 'MainBusStop' 'Moremi' ...
         'Awo' 'NewMarket' 'Faj' 'CarPark' 'ReligiousGround' 'LocalGovt'};
G = digraph(s, t, weights, names);

% --------------------------------
% Create Students
% --------------------------------
listOfStudents = Student.empty;
for i = 1:STUDENT_COUNT
    origin = randi(STATION_COUNT);
    destination = randi(STATION_COUNT);
    while destination == origin     % ensures dest != origin
        destination = randi(STATION_COUNT);
    end
    % uniform distribution, probably.
    listOfStudents(i) = Student(i, origin, destination);
    % for debugging
    %fprintf("\tSTUDENT%d ORIGIN %d DESTINATION %d\n", i, origin, destination);
end


% ------------------------------------------
%   CREATE BUSES
% ------------------------------------------
BUS_PARKS = [4, 9];

BUS_CAPACITY = 5;   % in people
BUS_MILEAGE = 20;   % total mileage needed before refuel, in metres
BUS_SPEED = 0.5;     % half the speed limit. keep it b/w 0 and 1
BUS_WAIT_RATE = 1;  % number of minutes spent when bus is idle.
                    % handles upload, offload and refuel time for now.

% Bus(id, startNode, capacity, speed, boardingRate, offloadingRate)
listOfBuses = Bus.empty;
for i = 1:BUS_COUNT
    startNode = BUS_PARKS(randi(2)); % randomly choose either
    listOfBuses(i) = Bus( ...
        i, ...
        startNode, ...
        BUS_CAPACITY, ...
        SPEED_LIMIT, ... % all buses assumed to move at speed limit.
        BUS_WAIT_RATE, ...  % boarding rate
        BUS_WAIT_RATE ...  % offloading rate
    );
end


% -------------------------------
%   Assign students to stations
% -------------------------------
for i = 1:length(listOfStudents)
    s = listOfStudents(i);
    % place the students at their origins
    listOfStations(s.origin).addStudent(s.id);
end
% for debugging
% for i = 1:length(listOfStations)
%     debugPrintList("Q: ", listOfStations(i).queue);
% end


% -------------------------------
%  Metrics
% -------------------------------
% performance_metrics.served = 0;     % proportion of students served during timespan
% performance_metrics.failures = 0;   % proportion of buses that run out of fuel midway
% performance_metrics.totalTransitTime = 0;   % the total transit time aggregated by all students

% --------------------------------
%   Visualizer instantiation
% --------------------------------
viz = Visualizer(G);


% =================================
%   MAIN LOOP
% =================================
for t = 1:TIME_SPAN
    % ---- Visualize ----
    viz.update(listOfStations, listOfBuses, t);
    fprintf("Time step: %d\n", t);
    % ---- Update Buses ----
    for i = 1:length(listOfBuses)
        % the update will depend on a lot more state information than just stations.
        listOfBuses(i) = listOfBuses(i).updateState(G, listOfStations, listOfStudents);
        % fprintf('\tBus %d at %d | Passengers: %d | Fuel: %d\n', ...
        %      i, listOfBuses(i).currentNode, ...
        %         length(listOfBuses(i).currentStudents), ...
        %         listOfBuses(i).remainingMileage);
    end
    % ---- Update Stations ----
    for i = 1:length(listOfStations)
        listOfStations(i) = listOfStations(i).update();
    end
    % ---- Update Students ----
    for i = 1:length(listOfStudents)
        listOfStudents(i) = listOfStudents(i).update();
    end
    % ---- Finally, update metrics ----
    %   will generally depend on object data and parameters
    % performance_metrics = updateMetrics(performance_metrics, listOfStudents);
end


% ==============================
%   FINALIZATION
% ==============================
fprintf("Simulation complete.\n");
% performance_metrics = updateMetrics(performance_metrics, listOfStudents);
% printReport(performance_metrics);