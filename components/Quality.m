classdef Quality < int8
    % QUALITY Defines the quality of the IR generated by the plugin
    % Values affect the parameters of the genetic algorithm and thus CPU usage

    enumeration
        low    (0)
        medium (1)
        high   (2)
        max    (3)
    end
end
