function [class_mat,class_prop] = createClassifier(D,method,param)
%createClassifier Takes input of RGB (3D) or 2D matrix of image data to
%classify into the specified number of classes
%   D: Data grid input. Can be RGB or single 2D matrix
%   method: kmeans or threshold. Threshold method only accepts 2D matrix
%   param: if kmeans, input number of classes. If threshold, input
%   threshold(s). If single number is put in the threshold will define a
%   binary classifier, if multiple values, will define based upon each gap
%   between inputs. For example [2 4] would create 3 classes. <= 2, >2 and
%   <= 4 or > 4
method = lower(method);

if strcmp(method,'kmeans')
    if size(D,3) == 1 %is 2D
        class_mat = reshape(kmeans(D(:),param,'Replicates',10),size(D));
    elseif size(D,3) == 3 %is RGB, 3D
        R = D(:,:,1);
        G = D(:,:,2);
        B = D(:,:,3);
        class_mat = reshape(kmeans([R(:) G(:) B(:)],param,'Replicates',10),size(D,[1 2]));
    end
    
    %compute proportion of area that falls into each class
    d = unique(class_mat(~isnan(class_mat)));
    class_prop = cell(2,length(d));
    for i = 1:length(d)
        c = d(i);
        class_prop{1,i} = ['Class ' num2str(c) ' proportion'];
        class_prop{2,i} = sum(class_mat == c,'all')/sum(~isnan(class_mat),'all');
    end
    
elseif strcmp(method,'threshold') %only works for 2D matrix
    param = sort(param);
    class_mat = NaN(size(D));
    for i = 1:length(param)
        param_i = param(i);
        if i == 1
            class_mat(D <= param_i) = i;
            param_prev = param_i;
        else
            class_mat(D > param_prev & D <= param_i) = i;
            param_prev = param_i;
        end
        
        if i == length(param)
            class_mat(D > param_prev & D <= param_i) = i;
            class_mat(D > param_i) = i+1;
        end
    end
    
    %compute proportion of area that falls into each class
    d = unique(class_mat(~isnan(class_mat)));
    class_prop = cell(2,length(d));
    for i = 1:length(d)
        c = d(i);
        class_prop{1,i} = ['Class ' num2str(c) ' proportion'];
        class_prop{2,i} = sum(class_mat == c,'all')/sum(~isnan(class_mat),'all');
    end
    
end

end

