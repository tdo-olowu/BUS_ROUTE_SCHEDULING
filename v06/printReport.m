function printReport(metrics)

    fprintf("\n==== Simulation Report ====\n");
    fprintf("Students served: %d\n", metrics.served);
    fprintf("Students failed: %d\n", metrics.failed);
    fprintf("Average transit time: %.2f\n", metrics.avgTransitTime);

end