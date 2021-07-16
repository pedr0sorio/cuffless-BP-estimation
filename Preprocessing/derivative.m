function dx = derivative(x)
global fs
dx = zeros(length(x) - 1, 1);
for n = 1 : length(dx)
    dx(n) = (x(n + 1) - x(n)) / (1 / fs);
end
end