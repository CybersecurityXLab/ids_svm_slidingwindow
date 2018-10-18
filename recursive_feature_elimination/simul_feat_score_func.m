%returns predictable simulated feature scores based on list length
function updatedScores = simul_feat_score_func(features);

updatedScores = features;
%gives lowest score f10 f9 f20 f13 f15 f11 f1 f3 f8 f16 f4 f5 f12 f18 f7
if (size(updatedScores,1)==20) %f10 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 10)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
        
elseif (size(updatedScores,1)==19) %f9 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 9)
            
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
elseif (size(updatedScores,1)==18) %f20 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 20)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==17) %f13 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 13)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==16) %f15 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 15)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==15) %f11 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 11)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==14) %f1 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 1)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==13) %f3 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 3)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==12) %f8 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 8)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==11) %f16 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 16)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==10) %f4 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 4)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==9) %f5 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 5)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==8) %f12 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 12)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
    
elseif (size(updatedScores,1)==7) %f18 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 18)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    
    
elseif (size(updatedScores,1)==6) %f7 has lowest score
    for i = 1:size(updatedScores,1)
        if(updatedScores(i,1) == 7)
            updatedScores(i,2) = .1;
        else
            updatedScores(i,2) = .2;
        end
    end
    

end
    


