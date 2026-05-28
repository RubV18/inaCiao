clear; clc;

% Problem data
J = 1:6; % Jobs
n = length(J);
p = [6,9,7,5,8,10]; % processing times
d = [25,30,22,28,27,35]; % due dates
S = [Inf 3 4 2 3 5;  % setup time matrix (Inf means not used for S(i,i))
     2 Inf 5 4 3 2;
     3 2 Inf 3 5 4;
     4 3 2 Inf 4 3;
     3 5 4 2 Inf 3;
     5 4 2 3 4 Inf];

% Number of stages (positions)
K = n;

% Initialization
cost = containers.Map;  % Cost-to-go
path = containers.Map;  % Store optimal paths

% Final stage: full permutation, no future cost
P = perms(J);

% Enforce position constraint: job 4 in position 2
validP = P(P(:,2)==4, :);
for i = 1:size(validP,1)
    seq = validP(i,:);
    time = 0;
    C = zeros(1,n);
    for k = 1:n
        if k == 1
            time = time + p(seq(k));
        else
            time = time + S(seq(k-1), seq(k)) + p(seq(k));
        end
        C(k) = time;
    end
    tardiness = sum(max(0, C - d(seq)));
    cost(num2str(seq)) = tardiness;
    path(num2str(seq)) = seq;
end

% DP Backward recursion
for k = n-1:-1:1
    subsets = nchoosek(J, k);
    for s = 1:size(subsets,1)
        subset = subsets(s,:);
        % enforce constraint: if position 2 and job 4 not there, skip
        if k == 2 && ~ismember(4, subset)
            continue;
        end
        permsub = perms(subset);
        for i = 1:size(permsub,1)
            partial = permsub(i,:);
            if k == 2 && partial(2) ~= 4
                continue;
            end
            for j = setdiff(J, partial)
                seq = [partial, j];
                if k == 1
                    time = p(seq(1));
                else
                    time = p(seq(1)) + S(seq(1), seq(2));
                    for t = 2:k
                        time = time + p(seq(t)) + S(seq(t-1), seq(t));
                    end
                end
                lastSetup = S(seq(end-1), seq(end));
                complete = time + lastSetup + p(seq(end));
                T = max(0, complete - d(seq(end)));
                tail = seq(2:end);
                tailKey = num2str(tail);
                if isKey(cost, tailKey)
                    totalCost = T + cost(tailKey);
                    key = num2str(seq);
                    if ~isKey(cost, key) || totalCost < cost(key)
                        cost(key) = totalCost;
                        path(key) = seq;
                    end
                end
            end
        end
    end
end

% Find best solution
minCost = inf;
bestSeq = [];
keysList = keys(cost);
for i = 1:length(keysList)
    k = keysList{i};
    if length(str2num(k)) == n
        if cost(k) < minCost
            minCost = cost(k);
            bestSeq = str2num(k);
        end
    end
end

% Output result
disp('Optimal sequence:');
disp(bestSeq);
disp(['Minimum total tardiness: ', num2str(minCost)]);


