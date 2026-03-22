function printReport(timespan, busCount, studentCount, simStats)

    fprintf("\n===== Simulation Report =====\n");
    fprintf("Timespan (minutes): %d\n", timespan);
    fprintf("Total Number of Buses: %d\n", busCount);
    fprintf("Total Number of Students: %d\n", studentCount);
    fprintf("Students served: %d\n", simStats.studentsServed);
    fprintf("Total transit time: %.2f\n", simStats.totalTransitTime);
    fprintf("Average transit time: %.2f\n", simStats.avgTransitTime);
    fprintf("Number of buses which finished work: %d\n", simStats.stoppedBuses);

end