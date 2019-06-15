function f = fitness( ir, SAMPLE_RATE, ZERO_THRESHOLD, T60, ITDG, EDT, C80 )
% FITNESS Calculate fitness value of impulse response.
% ir = impulse response
% f = fitness value
    % Find highest sample and ignore previous samples for some descriptors.
    [ impulse_max_amplitude, impulse_max_sample ] = max( ir( :, 1 ) );
    impulse_max_dB = 20 * log10( abs(impulse_max_amplitude) );
    IR = ir( ( impulse_max_sample + 1 ):end, 1 );

    % ITDG (initial time delay gap)
    ir_ITDG = impulse_max_sample / SAMPLE_RATE;

    % T60
    impulse_T60_sample = find( ...
        ( IR > ZERO_THRESHOLD ) & ( 20 * log10(IR) - impulse_max_dB < -60 ), 1 ...
    );
    if isempty(impulse_T60_sample)
        impulse_T60_sample = Inf;
    end
    ir_T60 = impulse_T60_sample / SAMPLE_RATE;

    % EDT (early decay time, a.k.a. T10)
    impulse_EDT_sample = find( ...
        ( IR > ZERO_THRESHOLD ) & ( 20 * log10(IR) - impulse_max_dB < -10 ), 1 ...
    );
    if isempty(impulse_EDT_sample)
        impulse_EDT_sample = Inf;
    end
    ir_EDT = impulse_EDT_sample / SAMPLE_RATE;

    % C80 (clarity)
    sample_80ms = 0.08 * SAMPLE_RATE;
    early_reflections = ir( 1:sample_80ms, 1 );
    late_reflections = ir( ( sample_80ms + 1 ):end, 1 );
    early_energy = sum( early_reflections .^ 2 );
    late_energy = sum( late_reflections .^ 2 );
    ir_C80 = 10 * log10( early_energy / late_energy );

    f = ( ir_T60 - T60 )^2 + ...
        ( ir_ITDG - ITDG )^2 + ...
        ( ir_EDT - EDT )^2 + ...
        ( ir_C80 - C80 )^2;
end
