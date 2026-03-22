%% DEAL WITH THIS LATER

function metrics = updateMetrics(metrics, students)

    served = 0;
    failed = 0;
    totalTime = 0;

    for i = 1:length(students)
        s = students(i);

        if s.isServed
            served = served + 1;
            totalTime = totalTime + s.transitTime;
        % elseif s.hasFailed
        %     failed = failed + 1;
        end
    end

    metrics.served = served;
    metrics.failed = failed;

    if served > 0
        metrics.avgTransitTime = totalTime / served;
    else
        metrics.avgTransitTime = 0;
    end
end