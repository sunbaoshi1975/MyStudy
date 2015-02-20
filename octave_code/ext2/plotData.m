function plotData(X, y)
%PLOTDATA Plots the data points X and y into a new figure 
%   PLOTDATA(x,y) plots the data points with + for the positive examples
%   and o for the negative examples. X is assumed to be a Mx2 matrix.

% Create New Figure
figure; hold on;

% ====================== YOUR CODE HERE ======================
% Instructions: Plot the positive and negative examples on a
%               2D plot, using the option 'k+' for the positive
%               examples and 'ko' for the negative examples.
%
% Labels will be added in the main program, so we don't have to do labelling here.
% Split Positive and Negative examples
%% find will return an index vector, refer to help find
y_pos = find(y == 1);
y_neg = find(y == 0);

% Plotting: X(1) on x axis; X(2) on y axis
%% Useful properties to modify are "linestyle", "linewidth", "color", "marker", "markersize", "markeredgecolor", "markerfacecolor".
plot(X(y_pos, 1), X(y_pos, 2), 'k+', 'LineWidth', 2, 'MarkerSize', 7);
plot(X(y_neg, 1), X(y_neg, 2), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 7);








% =========================================================================



hold off;

end
