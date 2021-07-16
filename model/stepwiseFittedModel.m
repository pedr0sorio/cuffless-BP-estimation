function y = stepwiseFittedModel(intercept, finalModel, b, X)
y = intercept + X(:, finalModel) * b(finalModel);
end