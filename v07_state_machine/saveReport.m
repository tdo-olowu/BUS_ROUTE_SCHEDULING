function saveReport(timespan, busCount, studentCount, simStats, filename)

    fid = fopen(filename, 'w');

    fprintf(fid, "===== Simulation Report =====\n");
    fprintf(fid, "Timespan (minutes): %d\n", timespan);
    fprintf(fid, "Total Number of Buses: %d\n", busCount);
    fprintf(fid, "Total Number of Students: %d\n", studentCount);
    fprintf(fid, "Students served: %d\n", simStats.studentsServed);
    fprintf(fid, "Total transit time: %.2f\n", simStats.totalTransitTime);
    fprintf(fid, "Average transit time: %.2f\n", simStats.avgTransitTime);
    fprintf(fid, "Number of buses which finished work: %d\n", simStats.stoppedBuses);

    fclose(fid);

end