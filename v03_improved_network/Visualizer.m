% VISUALIZER

classdef Visualizer
    properties
        G
        hPlot          % handle to graph plot
        fig            % figure handle
    end

    methods
        function obj = Visualizer(G)
            obj.G = G;

            obj.fig = figure;
            obj.hPlot = plot(G);

            title('Bus Simulation');
        end

        function obj = update(obj, stations, buses, t)
            % Clear figure and redraw (simple but reliable)
            clf(obj.fig);

            obj.hPlot = plot(obj.G);

            % ---------------------------
            % 1. NODE COLOR = QUEUE SIZE
            % ---------------------------
            queueSizes = arrayfun(@(s) length(s.queue), stations);

            % Normalize for coloring
            maxQ = max(queueSizes);
            if maxQ == 0
                colors = zeros(length(queueSizes), 1);
            else
                colors = queueSizes / maxQ;
            end

            % Apply color (heat-like using colormap)
            colormap(jet);
            obj.hPlot.NodeCData = colors;
            colorbar;

            % ---------------------------
            % 2. SHOW QUEUE SIZE LABELS
            % ---------------------------
            labels = string(queueSizes);
            labelnode(obj.hPlot, 1:length(queueSizes), labels);

            % ---------------------------
            % 3. HIGHLIGHT BUS POSITIONS
            % ---------------------------
            positions = [buses.currentNode];
            % highlight(obj.hPlot, positions, ...
            %     'NodeColor', 'r', ...
            %     'MarkerSize', 8);
            % that was causing errors. Instead...
            % Start from base colors
            nodeColors = obj.hPlot.NodeCData;

            % Force bus nodes to max intensity (red in jet colormap)
            nodeColors(positions) = 1.2; % slightly above max for emphasis

            obj.hPlot.NodeCData = nodeColors;

            % Optional: increase marker size for buses
            obj.hPlot.MarkerSize = 6 * ones(numnodes(obj.G),1);
            obj.hPlot.MarkerSize(positions) = 10;

            % ---------------------------
            % 4. TITLE
            % ---------------------------
            title(['Time Step ', num2str(t)]);

            drawnow;
        end
    end
end