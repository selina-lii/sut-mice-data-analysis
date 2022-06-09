
function dataPools = pools(matrix,grid)

% Segment a matrix by given grid

%%% INPUT
% matrix: a*b or a*b*c matrix to be pooled
% grid: cell(1, 2) or cell(1, 3) containing edges for each segmentation of
%       the matrix

% OUTPUT: 2D or 3D cell array of dimensions x*y*z where x is the number of 
%        segmentations on a, likewise for y & b and z & c

    function [lefts,rights] = grid_edges(grid,dim)
        x=grid{dim};
        lefts=x(1:end-1)+1;
        lefts(1)=1;
        rights=x(2:end);
    end

    dimensionality=ndims(matrix);

    if dimensionality==3 && size(grid,2)==2
        grid{3}=grid{2};grid{2}=grid{1};grid{1}=0:size(matrix,1);
    end % if input is a 3-D matrix with a 2-D grid, then by default
        % the grid applies to the 2nd and 3rd dimensions of the
        % matrix (first dimension is seen as the 'neuron' level)

    if dimensionality>3 || dimensionality<2 %sanity check
        error([ num2str(dimensionality) '-dimensional matrix pooling is not supported by this function']);
    end

    dims=cellfun(@(x) length(x), grid)-1;
    dataPools=cell(dims);

    switch dimensionality

        case 2
            [lefts1,rights1] = grid_edges(grid,1);
            for ii=1:dims(1)
                [lefts2,rights2] = grid_edges(grid,2);
                matCrop1=matrix(lefts1(ii):rights1(ii),:);
                for jj=1:dims(2)
                    matCrop2=matCrop1(:,lefts2(jj):rights2(jj));
                    dataPools{ii,jj}=matCrop2(:);
                end
            end

        case 3
            [lefts1,rights1] = grid_edges(grid,1);
            for ii=1:dims(1)
                matCrop1=matrix(lefts1(ii):rights1(ii),:,:);
                [lefts2,rights2] = grid_edges(grid,2);
                for jj=1:dims(2)
                    [lefts3,rights3] = grid_edges(grid,3);
                    matCrop2=matCrop1(:,lefts2(jj):rights2(jj),:);
                    for kk=1:dims(3)
                        matCrop3=matCrop2(:,:,lefts3(kk):rights3(kk));
                        dataPools{ii,jj,kk}=matCrop3(:);
                    end
                end
            end
    end
end

%% test script

%3D:
%grid=cell(1,3);
%grid{1}=[1 3 5 7 9 10];
%grid{2}=[1 2 3 4 5];
%grid{3}=1:2;
%matrix=reshape(1:100,10,5,2);
%dataPools=pools(matrix,grid)

%2D:
%grid=cell(1,2);
%grid{1}=[1 3 5 7 9 10];
%grid{2}=[1 3 5];
%matrix=reshape(1:50,10,5);
%dataPools=pools(matrix,grid)

