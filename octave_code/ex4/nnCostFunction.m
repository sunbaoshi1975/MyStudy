function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% -------------------------------------------------------------
% Theta1: 25 * 401; Theta2: 10 * 26
% X: 5000 * 400, y: 5000 * 1

% -------------------------------------------------------------
% Part 1: Feedforward, get J
% Layer 1
% Add ones to the X data matrix to get a1: 5000 * (400+1)
a1 = [ones(m, 1) X];

% Layer 2
% Theta1: 25*401, z2: 5000 * 25; a2: 5000 * (25+1)
z2 = a1 * Theta1';
a2 = sigmoid(z2);
a2 = [ones(m, 1) a2];

% Layer 3
% Theta2: 10*26, z3: 5000 * 10; a3: 5000 * 10;
z3 = a2 * Theta2';
a3 = sigmoid(z3);
h = a3;

% Compute J
Q = eye(num_labels);
newy = Q(y,:);

%size(h)
%size(newy)

J = sum(sum((-newy .* log(h) - (1 - newy) .* log(1 - h)))) / m;

my_theta1 = Theta1;
my_theta1(:,1) = 0;
my_theta2 = Theta2;
my_theta2(:,1) = 0;

% -------------------------------------------------------------
% Part 2: Backpropagation, get gradients Theta1_grad and Theta2_grad
% one example at a time
for t = 1:m
  % Layer 1: Set the input layer's values to the t-th training exampe
  a_1 = [1 X(t, :)];         % a_1: 1 * 401
  %size(a_1)
  % Layer 2
  z_2 = a_1 * Theta1';      % z_2: 1 * 25
  a_2 = [1 sigmoid(z_2)];   % a_2: 1 * 26
  %size(a_2)
  % Layer 3
  z_3 = a_2 * Theta2';      % z_3: 1 * 10
  %size(z_3)
  a_3 = sigmoid(z_3);        % a_3: 1 * 10
  %size(a_3)
  
  % Backpropagation
  delta_3 = (a_3 - (y(t) == [1:num_labels]))';   % 10 * 1
  
  % Both are OK
  %delta_2 = Theta2' * delta_3 .* [0; sigmoidGradient(z_2)'];        % 26 * 1
  %delta_2 = delta_2(2:end);     % 25 * 1
  delta_2 = Theta2'(2:end,:) * delta_3 .* sigmoidGradient(z_2)';        % 25 * 1
  
  % unregularized
  Theta1_grad = Theta1_grad + delta_2 * a_1;    % 25 * 401
  Theta2_grad = Theta2_grad + delta_3 * a_2;    % 10 * 26
 
end
  
% Obtain the gradient for the neural network cost function
Theta1_grad = Theta1_grad / m + lambda * my_theta1 / m;
Theta2_grad = Theta2_grad / m + lambda * my_theta2 / m;

% -------------------------------------------------------------
% Part 3: Implement regularization with the cost function and gradients
J += lambda / (2 * m) * (sum(sum(my_theta1 .^ 2)) + sum(sum(my_theta2 .^ 2)));



% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
