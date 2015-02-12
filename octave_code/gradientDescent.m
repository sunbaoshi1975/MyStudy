function [theta, J_history] = gradientDescent(X, y, theta, alpha, num_iters)
%GRADIENTDESCENT Performs gradient descent to learn theta
%   theta = GRADIENTDESENT(X, y, theta, alpha, num_iters) updates theta by 
%   taking num_iters gradient steps with learning rate alpha

% Initialize some useful values
m = length(y); % number of training examples
J_history = zeros(num_iters, 1);

for iter = 1:num_iters

    % ====================== YOUR CODE HERE ======================
    % Instructions: Perform a single gradient step on the parameter vector
    %               theta. 
    %
    % Hint: While debugging, it can be useful to print out the values
    %       of the cost function (computeCost) and gradient here.
    %
    real_diff = X * theta - y;      % m*1
    delta = 1 / m * (real_diff' * X);   % (1,m) * (m,n) = (1,n)
    theta = theta - alpha * delta';
    J_this = computeCost(X, y, theta);
    
    %disp(sprintf("iter: %d J = %0.2f", iter, J_this)) % Debug print
    %theta'   % Debug print


    % ============================================================

    % Save the cost J in every iteration    
    J_history(iter) = J_this;

end

disp(sprintf("iter: %d J = %0.2f", iter, J_this)) % Debug print last time
theta'   % Debug print

end
