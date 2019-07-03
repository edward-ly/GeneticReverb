function [h, beta_hat] = frir_generator(c, fs, r, s, L, beta, nSamples)
% FRIR_GENERATOR Generates an impulse response from the given parameters.
% c = speed of sound (m/s)
% fs = sampling frequency of impulse response
% r = 1 x 3 array specifying the (x,y,z) coordinates of receiver (m)
% s = 1 x 3 array specifying the (x,y,z) coordinates of source (m)
% L = 1 x 3 array specifying the (x,y,z) room dimensions (m)
% beta = T60 reverberation time (s)
% nSamples = total number of samples in impulse response
% h = nsample x 1 column vector containing the calculated room impulse response
% beta_hat = reflection coefficient of the walls based on reverberation time
% Current algorithm: based on the fast image method by McGovern.
    % Calculate reflection coefficient
	if beta > 0
        V = L(1) * L(2) * L(3); % room volume
        S = 2 * (L(1)*L(3) + L(2)*L(3) + L(1)*L(2)); % room surface area
        alfa = 24 * V * log(10.0) / (c * S * beta); % Sabin-Franklin's formula
        if alfa > 1
            error("Error: Reflection coefficient cannot be calculated using the current room parameters, i.e. room size and reverberation time. Please change the room parameters or reverberation time.");
        end
        beta_hat = sqrt(1 - alfa);
    else
        error("Error: Reverberation time must be positive.\n");
	end

    % Calculate total time of impulse response in seconds
    time = nSamples / fs;
    
    % Find highest-order reflection to be used in lookup tables
    xMaxOrder = ceil(c * time / (2 * L(1)));
    yMaxOrder = ceil(c * time / (2 * L(2)));
    zMaxOrder = ceil(c * time / (2 * L(3)));
    
    % Create lookup tables for each dimension
    [xDistSq, xRefCoef] = make_tables(L(1), r(1), s(1), beta_hat, beta_hat, xMaxOrder);
    [yDistSq, yRefCoef] = make_tables(L(2), r(2), s(2), beta_hat, beta_hat, yMaxOrder);
    [zDistSq, zRefCoef] = make_tables(L(3), r(3), s(3), beta_hat, beta_hat, zMaxOrder);
    
    % Initialize impulse response array
    h = zeros(nSamples, 1);
    
    i = 1;
    while i <= 2*xMaxOrder + 1
        j = 1;
        while j <= 2*yMaxOrder + 1
            k = 1;
            while k <= 2*zMaxOrder + 1
                % Find distance from ijk^th image to receiver
                dist = sqrt(xDistSq(i) + yDistSq(j) + zDistSq(k));
                
                % Find sample in impulse response corresponding to distance
                samp = round(dist * fs / c) + 1;
                
                % If echo from ijk^th image occurs at a time beyond range of
                % impulse response, then all images in one strip of circle have
                % been tested.
                if samp > nSamples, break; end
                
                % Add echo to impulse response array
                h(samp) = h(samp) + (xRefCoef(i) * yRefCoef(j) * zRefCoef(k) / dist);
                
                k = k + 1;
            end
            
            % If k-loop broke with k == 1, then all images in "circle of
            % interest" in i-plane have been tested, so no need to find
            % distances for higher values of j.
            if k == 1, break; end
            j = j + 1;
        end
        
        % If j-loop broke with j == 1, then all images in "sphere of interest"
        % have been tested, so no need to find distances for higher values of i.
        if j == 1, break; end
        i = i + 1;
    end
end

function [distSq, refCoef] = make_tables(w, r, s, Bmw, Bw, n)
    Limg = 1;
    Rimg = 1;
    distSq  = zeros(2*n + 1, 1);
    refCoef = zeros(2*n + 1, 1);
    refCoef(1) = 1;
    
    DirSnd = s - r;
    distSq(1) = DirSnd * DirSnd;

    LimgD = DirSnd;
    RimgD = DirSnd;
    
    for i = 2:(n + 1)
        if mod(i, 2) ~= 0
            LimgD = LimgD - (2 * (w + s));
            RimgD = RimgD + (2 * (w - s));
            Limg = Limg * Bmw;
            Rimg = Rimg * Bw;
        else
            LimgD = LimgD - (2 * (w - s));
            RimgD = RimgD + (2 * (w + s));
            Limg = Limg * Bw;
            Rimg = Rimg * Bmw;
        end
        
        if (mod(i, 2) ~= 0 && r + s < 0) || (mod(i, 2) == 0 && r - s < 0)
            distSq(2*i - 2) = LimgD * LimgD;
            distSq(2*i - 1) = RimgD * RimgD;
            refCoef(2*i - 2) = Limg;
            refCoef(2*i - 1) = Rimg;
        else
            distSq(2*i - 2) = RimgD * RimgD;
            distSq(2*i - 1) = LimgD * LimgD;
            refCoef(2*i - 2) = Rimg;
            refCoef(2*i - 1) = Limg;
        end
    end
end