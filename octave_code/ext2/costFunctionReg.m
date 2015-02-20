function [J, grad] = costFunctionReg(theta, X, y, lambda)
%COSTFUNCTIONREG Compute cost and gradient for logistic regression with regularization
%   J = COSTFUNCTIONREG(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta.
%               You should set J to the cost.
%               Compute the partial derivatives and set grad to the partial
%               derivatives of the cost w.r.t. each parameter in theta
%------------- same as costFunction ----------------------
h_value = sigmoid(X * theta);		% (m, n+1) * (n+1, 1) = (m, 1)
J = 1 / m * ((-y' * log(h_value) - (1 - y') * log(1 - h_value)));		% (1,m) * (m, 1) = (1,1)
grad = 1 / m * (X' * (h_value - y));	% (n+1, m) * (m, 1) = (n+1,1)

%------------- Add Regularization Term ----------------------
%% make sure theta(0) is 0
my_theta = theta;
my_theta(1) = 0;
J += lambda / (2 * m) * (sum(my_theta .^ 2));
grad += lambda / m * my_theta;







% =============================================================

end
