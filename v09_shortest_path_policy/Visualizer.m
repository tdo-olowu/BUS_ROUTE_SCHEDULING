classdef Visualizer < handle
    properties
        G
        hPlot          % handle to graph plot
        fig            % figure handle
        busScatter   % handle for bus markers
        X            % node x-coordinates
        Y            % node y-coordinates
        ax
    end

    methods
        % constructor
        function obj = Visualizer(G)
            % Extra improvements if needed:
            % obj.busScatter.SizeData = 50;
            % obj.busScatter.MarkerFaceAlpha = 0.8;
            obj.G = G;

            obj.fig = figure;
            obj.ax = axes(obj.fig);   % explicitly create axes
            obj.hPlot = plot(obj.ax, G); %-------------------%
            hold(obj.ax, 'on');   % VERY IMPORTANT

            % Store node coordinates
            obj.X = obj.hPlot.XData;
            obj.Y = obj.hPlot.YData;

            % Graph styling
            obj.hPlot.ArrowSize = 18;
            obj.hPlot.LineWidth = 1.5;
            obj.hPlot.EdgeAlpha = 0.7;

            colormap(jet);
            colorbar;

            % Initialize empty bus scatter
            obj.busScatter = scatter(obj.ax, nan, 40, 'ks', 'filled');

            % colors edges by weight
            % if ismember('Weight', obj.G.Edges.Properties.VariableNames)
            %     obj.hPlot.EdgeCData = obj.G.Edges.Weight;
            %     colormap(parula);
            %     colorbar;
            % end
            title('Bus Simulation');

        end

        %% the update function.
        %function obj = update(obj, stations, buses, t)
        function update(obj, stations, buses, t)
            % ---------------------------
            % 1. NODE COLOR = QUEUE SIZE
            % ---------------------------
            % if ~isvalid(obj.hPlot)
            %     error("hPlot was deleted before update()");
            % end
            queueSizes = arrayfun(@(s) length(s.queue), stations);

            % Normalize for coloring
            maxQ = max(queueSizes);
            if maxQ == 0
                colors = zeros(length(queueSizes), 1);
            else
                colors = queueSizes / maxQ;
            end

            % Apply color (heat-like using colormap)
            obj.hPlot.NodeCData = colors;

            % ---------------------------
            % 2. SHOW QUEUE SIZE LABELS AND NODE NAMES
            % ---------------------------
            names = string(obj.G.Nodes.Name(:));
            qs = string(queueSizes(:));
            labels = names + " (" + qs + ")";
            % this line redraws blah-blah.
            labelnode(obj.hPlot, 1:numnodes(obj.G), labels);
            % CGPT suggested the following as an alternative:
            % obj.hPlot.NodeLabel = string(obj.G.Nodes.Name(:)) + " (" + string(queueSizes(:)) + ")";

            % ---------------------------
            % 3. DRAW BUSES (SMOOTH MOTION)
            % ---------------------------
            [bx, by] = obj.getBusPositions(buses);
            set(obj.busScatter, 'XData', bx, 'YData', by);


            % ---------------------------
            % 4. TITLE
            % ---------------------------
            title(obj.ax, ['Time Step ', num2str(t)]);

            drawnow;
        end

        %% computing bus positions
        function [bx, by] = getBusPositions(obj, buses)
            n = length(buses);
            bx = zeros(n,1);
            by = zeros(n,1);

            for i = 1:n
                b = buses(i);

                x1 = obj.X(b.currentNode);
                y1 = obj.Y(b.currentNode);

                x2 = obj.X(b.nextNode);
                y2 = obj.Y(b.nextNode);

                % Interpolate using progress
                bx(i) = (1 - b.progress)*x1 + b.progress*x2;
                by(i) = (1 - b.progress)*y1 + b.progress*y2;
            end
        end

    end
end