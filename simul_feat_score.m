%returns predictable simulated feature scores based on list length
numFeatures = 20;

features = 1:numFeatures;
features = features(:);
scoreCol = zeros(numFeatures,1);
features(:,2) = scoreCol;

if (size(features,1)==20) %f10 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 10)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
        
elseif (size(features,1)==19) %f9 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 9)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
elseif (size(features,1)==18) %f20 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 20)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==17) %f13 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 13)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==16) %f15 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 15)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==15) %f11 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 11)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==14) %f1 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 1)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==13) %f3 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 3)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==12) %f8 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 8)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==11) %f16 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 16)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==10) %f4 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 4)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==9) %f5 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 5)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==8) %f12 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 12)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
    
elseif (size(features,1)==7) %f18 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 18)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    
    
elseif (size(features,1)==6) %f7 has lowest score
    for i = 1:size(features,1)
        if(features(i,1) == 7)
            features(i,2) = .1;
        else
            features(i,2) = .2;
        end
    end
    

end

%return features
    

%function simul_feat_score_func = one_v_all_function(features);
