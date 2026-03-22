% NOTES:
% All time is measured in minutes, and any distance in metres.
% The "speed" of the vehicles is expressed as a proportion of the speed limit, whatever 
%  the speed limit may be. E.g. speed of 0.5 for speed_limit of 30 means speed is 15.
% For simplicity, the time that events take is an integer multiple of the time steps.
% Hence, this would be a Discrete Time simulation.


clear; clc;

% INITIALIZE SIMULATION PARAMETERS
BUS_COUNT = 4; % 2^n buses
STUDENT_COUNT = 500;
TIME_SPAN = 100; % 100 time steps in minutes. About 1.5 hours

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
% for this simulation, weights are a number of timesteps, to keep it simple.
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

BUS_CAPACITY = 14;   % in people
BUS_MILEAGE = 20;   % total mileage needed before refuel, in metres
BUS_SPEED = 1.0;    % move at the speed limit. keep it b/w 0 and 1
BUS_WAIT_RATE = 1;  % number of minutes spent when bus is idle.
                    % handles upload, offload and refuel time for now.

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
    fprintf("Time step: %d\t", t);
    % ---- Update Buses ----
    for i = 1:length(listOfBuses)
        [listOfBuses(i), listOfStations, listOfStudents] = ...
    listOfBuses(i).updateState(G, listOfStations, listOfStudents);
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
end


% ==============================
%   FINALIZATION
% ==============================
fprintf("Simulation complete.\n");
simStats = computeSimStats(listOfStudents, listOfBuses);
printReport(TIME_SPAN, BUS_COUNT, STUDENT_COUNT, simStats);
%saveReport(TIME_SPAN, BUS_COUNT, STUDENT_COUNT, simStats, 'reports/report1.txt');
