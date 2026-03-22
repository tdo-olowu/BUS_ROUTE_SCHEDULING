classdef Visualizer
    properties
        G
        hPlot          % handle to graph plot
        fig            % figure handle
    end

    methods
        % constructor
        function obj = Visualizer(G)
            obj.G = G;

            obj.fig = figure;
            obj.hPlot = plot(G);
            % remove these two lines if causing trouble
            obj.hPlot.XData = obj.hPlot.XData;
            obj.hPlot.YData = obj.hPlot.YData;

            % make directed edges more visible
            obj.hPlot.ArrowSize = 18;      % bigger arrows
            obj.hPlot.LineWidth = 1.5;     % thicker edges
            obj.hPlot.EdgeAlpha = 0.7;     % slightly transparent

            % colors edges by weight
            % if ismember('Weight', obj.G.Edges.Properties.VariableNames)
            %     obj.hPlot.EdgeCData = obj.G.Edges.Weight;
            %     colormap(parula);
            %     colorbar;
        %end

            title('Bus Simulation');
        end

        function obj = update(obj, stations, buses, t)
            % Clear figure and redraw (simple but reliable)
            % clf(obj.fig);
            % 
            % obj.hPlot = plot(obj.G);

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
            % 2. SHOW QUEUE SIZE LABELS AND NODE NAMES
            % ---------------------------
            % labels = string(queueSizes);
            % labelnode(obj.hPlot, 1:length(queueSizes), labels);
            % the above two lines are old visualization code.
            names = string(obj.G.Nodes.Name(:));
            qs = string(queueSizes(:));
            labels = names + " (" + qs + ")";
            labelnode(obj.hPlot, 1:numnodes(obj.G), labels);
            % CGPT suggested the following as an alternative:
            % obj.hPlot.NodeLabel = string(obj.G.Nodes.Name(:)) + " (" + string(queueSizes(:)) + ")";

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

%             %%
%             To animate smoothly, you need:
%                 current node
%                 next node
%             progress (0 → 1 along edge)
%             Step 1: Add interpolation data to buses
%                 bus.currentNode
%                 bus.nextNode
%                 bus.progress   % value between 0 and 1
%             Step 2: Get node coordinates
%                 X = obj.hPlot.XData;
%                 Y = obj.hPlot.YData;
%             Step 3: compute smooth position logic. Replace bus highlighting
%             logic with:
%                 % ---------------------------
% % 3. DRAW MOVING BUSES
% % ---------------------------
% hold on;
% 
% X = obj.hPlot.XData;
% Y = obj.hPlot.YData;
% 
% for i = 1:length(buses)
%     b = buses(i);
% 
%     x1 = X(b.currentNode);
%     y1 = Y(b.currentNode);
% 
%     x2 = X(b.nextNode);
%     y2 = Y(b.nextNode);
% 
%     % Linear interpolation
%     xb = (1 - b.progress)*x1 + b.progress*x2;
%     yb = (1 - b.progress)*y1 + b.progress*y2;
% 
%     plot(xb, yb, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
% end
% 
% hold off;

            % An if you want smooth animation during a timestep
            %     for p = linspace(0,1,10)
            %         for i = 1:length(buses)
            %             buses(i).progress = p;
            %         end
            %         obj = obj.update(stations, buses, t);
            %         pause(0.05);
            %     end
            %%

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