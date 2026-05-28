function [bestSequence , Sstart , bestMakespan] = NEH_Modified(p)
% NEH_Modified  – insertion-based heuristic for a 5-stage re-entrant flow-shop
%                (stages 3 & 5 share one verifier).  Returns:
%   bestSequence   1×n vector of job indices
%   Sstart         5×n matrix of start-times produced by the final schedule
%   bestMakespan   scalar Cmax of that schedule
%   busyV          shared verifier
%

    [~,numJobs] = size(p);

    %% 1. priority – total processing time

    % computes total processing time per job, then sorts descending -> longest jobs first
    [~,sortedJobs] = sort(sum(p,1),'descend');

    % Picking the first element and run the scheduling simulation
    currentSequence = sortedJobs(1);
    [currentMakespan,~] = simulateSchedule(currentSequence,p);

    %% 2. insertion loop
    for k = 2:numJobs
        % picking one-for-one job from the sequence
        jIns = sortedJobs(k);
        bestSeq = [];  bestMs = inf;
        
        % Complexity O(n^2); builds a near-optimal permutation quickly
        for pos = 1:length(currentSequence)+1
        %   For each remaining job jIns:
        %    -try it in every position of current sequence     
        %    -simulate each candidate order
        %    -keep the one with smallest makespan
            candSeq = [currentSequence(1:pos-1) jIns currentSequence(pos:end)];
            [ms,~]  = simulateSchedule(candSeq,p);
            if ms < bestMs
                bestMs  = ms;   bestSeq = candSeq;
            end
        end
        currentSequence = bestSeq;   currentMakespan = bestMs;
    end

    %% 3. single-pass 2-opt
    for a = 1:length(currentSequence)-1
        for b = a+1:length(currentSequence)
    % Swap every unordered pair once; if the swap shortens makespan, keep it.
            cand = currentSequence;  cand([a b]) = cand([b a]);
            [ms,~] = simulateSchedule(cand,p);
            if ms < currentMakespan
                currentSequence = cand;  currentMakespan = ms;
            end
        end
    end

    %% 4. final schedule → start-time matrix
    [bestMakespan,Sstart] = simulateSchedule(currentSequence,p);
    bestSequence = currentSequence;
end
%───────────────────────────────────────────────────────────────────────────
function [Cmax,S] = simulateSchedule(sequence,p)
% Returns makespan Cmax **and** matrix S( stage , job ) of start times.
    numStages = 5;                        % fixed for this problem
    nJobs     = numel(sequence);

    S = zeros(numStages,nJobs);           % start times
    C = zeros(numStages,nJobs);           % completion times
    busy      = zeros(numStages,1);       % machine clocks
    busyV     = 0;                        % shared verifier (stages 3 & 5)

    % ---------- stage-1 (retrieval) processed strictly in sequence ----------
    for k = 1:nJobs
        j        = sequence(k);
        S(1,k)   = busy(1);
        C(1,k)   = S(1,k) + p(1,j);
        busy(1)  = C(1,k);
    end

    % ---------- remaining stages, one job at a time in given order ----------
    for k = 1:nJobs
        j = sequence(k);

        % stage-2  transport
        S(2,k) = max(C(1,k), busy(2));
        C(2,k) = S(2,k) + p(2,j);     busy(2) = C(2,k);

        % stage-3  verification-1  (shared clock)
        S(3,k) = max(C(2,k), busyV);
        C(3,k) = S(3,k) + p(3,j);     busyV   = C(3,k);

        % stage-4  customs
        S(4,k) = max(C(3,k), busy(4));
        C(4,k) = S(4,k) + p(4,j);     busy(4) = C(4,k);

        % stage-5  verification-2  (same shared clock)
        S(5,k) = max(C(4,k), busyV);
        C(5,k) = S(5,k) + p(5,j);     busyV   = C(5,k);
    end

    Cmax = C(5,end);
end
