function out = crossover(in, SELECTION_SIZE, POPULATION_SIZE, NUM_SAMPLES)
% CROSSOVER Generate children and replace least fit individuals.
%
% Input arguments:
% in = input population
% SELECTION_SIZE = number of impulse responses to keep per generation
% POPULATION_SIZE = number of impulse responses
% NUM_SAMPLES = length in samples of each impulse response
%
% Output arguments:
% out = output population
%
% Current algorithm: three-point crossover where the points are random (and
% distinct) along the length of the impulse response.
%
    % Require all arguments
    if nargin < 4, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    out = in;
    
    for i = (SELECTION_SIZE + 1):POPULATION_SIZE
        parents = randperm(SELECTION_SIZE, 2);
        points = sort(randperm(NUM_SAMPLES, 3));

        out(:, i) = in(:, parents(1));
        for j = 1:length(points)
            if j == length(points)
                out(points(j):end, i) = ...
                    in(points(j):end, parents(mod(j, 2) + 1));
            else
                out(points(j):(points(j+1)-1), i) = ...
                    in(points(j):(points(j+1)-1), parents(mod(j, 2) + 1));
            end
        end
    end
end
