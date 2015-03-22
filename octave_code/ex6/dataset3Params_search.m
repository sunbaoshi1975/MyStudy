function [C, sigma] = dataset3Params_search(X, y, Xval, yval)
%EX6PARAMS returns your choice of C and sigma for Part 3 of the exercise
%where you select the optimal (C, sigma) learning parameters to use for SVM
%with RBF kernel
%   [C, sigma] = dataset3Params_search(X, y, Xval, yval) returns your choice of C and 
%   sigma. You should complete this function to return the optimal C and 
%   sigma based on a cross-validation set.
%

% You need to return the following variables correctly.
C = 1;
sigma = 0.3;

% ====================== YOUR CODE HERE ======================
% Instructions: Fill in this function to return the optimal C and sigma
%               learning parameters found using the cross validation set.
%               You can use svmPredict to predict the labels on the cross
%               validation set. For example, 
%                   predictions = svmPredict(model, Xval);
%               will return the predictions on the cross validation set.
%
%  Note: You can compute the prediction error using 
%        mean(double(predictions ~= yval))
%
param_options = [0.01, 0.03, 0.1, 0.3, 1, 3, 10, 30];
C_opt = 0.01;
sigma_opt = 0.01;
min_error = size(yval, 1);

for C_test = param_options;
  for sigma_test = param_options;
    % Traning
    model= svmTrain(X, y, C_test, @(x1, x2) gaussianKernel(x1, x2, sigma_test));
    % Cross validation: prediction
    predictions = svmPredict(model, Xval);
    % Cross validation: measuring error
    error = mean(double(predictions ~= yval));
    % Display result
    fprintf('Training SVM with C=%f, sigma=%f, got mean error = %f\n', C_test, sigma_test, error);
    if min_error > error
      C_opt = C_test;
      sigma_opt = sigma_test;
      min_error = error;
     endif
  endfor
endfor

% Return the best parameters we found
fprintf('The best paramters found are C=%f, sigma=%f with mean error = %f\n', C_opt, sigma_opt, min_error);
C = C_opt;
sigma = sigma_opt;

% =========================================================================

end
