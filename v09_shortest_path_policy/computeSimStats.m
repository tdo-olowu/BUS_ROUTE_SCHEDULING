function simStats = computeSimStats(students, buses)

    totalTime = 0;
    served = 0;

    for i = 1:length(students)
        s = students(i);

        %totalTime = totalTime + s.transitTime;
        % if s.state == "ARRIVED"
        %     served = served + 1;
        % end
        if s.state == "ARRIVED"
            totalTime = totalTime + s.transitTime;
            served = served + 1;
        end

    end

    % Average transit time (only for served students)
    if served > 0
        avgTime = totalTime / served;
    else
        avgTime = 0;
    end

    % Count stopped buses
    stoppedBuses = sum(arrayfun(@(b) b.state == "STOP", buses));
    % stoppedBuses = 0;
    % 
    % for i = 1:length(buses)
    %     if buses(i).state == "STOP"
    %         stoppedBuses = stoppedBuses + 1;
    %     end
    % end

    % Store results
    simStats.totalTransitTime = totalTime;
    simStats.studentsServed = served;
    simStats.avgTransitTime = avgTime;
    simStats.stoppedBuses = stoppedBuses;

end