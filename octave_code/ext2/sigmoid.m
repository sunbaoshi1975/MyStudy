function g = sigmoid(z)
%SIGMOID Compute sigmoid functoon
%   J = SIGMOID(z) computes the sigmoid of z.

% You need to return the following variables correctly 
g = zeros(size(z));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the sigmoid of each value of z (z can be a matrix,
%               vector or scalar).
% Method 1: use exp function, which can operate matrix too
%%          note: we must use ./ rather than /
% Method 2: use for loop to process vector and matrix
g = 1 ./ (1 + exp(-z));




% =============================================================

end
