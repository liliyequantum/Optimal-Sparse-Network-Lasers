function GA_island_1(num_rng_ga)
   
    % clear;clc;
    maxNumCompThreads(1);
    type_freq_disorder = 'gaussian';
    num_rng_w = 1;
    % num_rng_ga = 0;
    popSize = 200;
    numGenerations = 200;
    numIslands = 4;
    case_type="slow";
    
    data = load('../connectivity_scan/connect_star.mat');
    connect_val = data.connect_val;
    connectivity = connect_val(num_rng_w+1);

    if strcmp(case_type, 'fast')
        mutationRate = 0.1;
        eliteCount = 2;
        migrationInterval = 15;
        migrationFraction = 0.2;
    
    elseif strcmp(case_type, 'slow')
        mutationRate = 0.03;
        eliteCount = 8;
        migrationInterval = 5;
        migrationFraction = 0.05;
    
    elseif strcmp(case_type, 'balanced')
        mutationRate = 0.05;
        eliteCount = 4;
        migrationInterval = 10;
        migrationFraction = 0.1;
    end

    % Parameters
    M = 24; % Nodes (Adjacency Matrix Size)
    % num_rng_w = 1;
    if strcmp(type_freq_disorder, 'gaussian')
        std_w = 14;
        % Load Data
        data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
        num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']); 
    end
    detuning = data.sorted_W;

    rng(num_rng_ga);
    numEdges = round(connectivity * M*(M-1)*0.5); % Possible connections

    % Initialize multiple islands (each has popSize/numIslands individuals)
    islandPopSize = floor(popSize / numIslands);
    islands = cell(numIslands, 1);
    fitnessScores = cell(numIslands, 1);
    coupling_matrix_set = cell(numGenerations+1,numIslands);
    fitnessScores_set = cell(numGenerations+1,numIslands);
    for i = 1:numIslands
        islands{i} = initializePopulation(M, numEdges, islandPopSize);
        fitnessScores{i} = evaluateFitness(islands{i}, detuning);
        coupling_matrix_set{1,i} = islands{i};
        fitnessScores_set{1,i} = fitnessScores{i};
    end

    fprintf('Generation %d: Best Fitness = %.4f\n', 0, max(cellfun(@max, fitnessScores)));
    best_fitness = zeros(numGenerations, 1);
    poolobj = parpool(numIslands);
    c = onCleanup(@() delete(poolobj)); % Always ensure cleanup
    tic
    % GA loop
    for gen = 1:numGenerations
        newIslands = cell(numIslands, 1); 
        newFitnessScores = cell(numIslands, 1);
        % Parallel Evolution for Each Island
        parfor i = 1:numIslands
            % Selection
            parents = selectParents(islands{i}, fitnessScores{i}, islandPopSize);

            % Crossover
            offspring = performCrossover(parents, M);

            % weak Mutation
            offspring = performMutation(offspring, mutationRate, M);

            % Evaluate offspring fitness
            fitnessScores_offspring = evaluateFitness(offspring, detuning);

            % Retain Elite + Offspring
            [newIslands{i}, newFitnessScores{i}] = retainElite(islands{i}, offspring, fitnessScores{i},...
                fitnessScores_offspring, eliteCount);
        end

         % Synchronize all islands
        islands = newIslands;
        fitnessScores = newFitnessScores;
        for i = 1:numIslands
            coupling_matrix_set{gen+1,i} = islands{i};
            fitnessScores_set{gen+1,i} = fitnessScores{i};
        end

        % check parfor whether logic error
        % Perform Migration
        if mod(gen, migrationInterval) == 0
            islands = performMigration(islands, fitnessScores, migrationFraction);
        end
        
        % Store best fitness
        best_fitness(gen) = max(cellfun(@max, fitnessScores));
        fprintf('Generation %d: Best Fitness = %.4f\n', gen, best_fitness(gen));
        % mkdir('data_coupling_matrix_set_GA')
        if mod(gen, 10) == 0
            save(['./data_coupling_matrix_set_GA/updated_GA_island_num_rng_GA_',num2str(num_rng_ga),'.mat'],'-v7.3');
        end
    end
    toc

    % Get the best adjacency matrix from all islands
    [bestValue, bestIndex] = max(cellfun(@max, fitnessScores));
    bestPop = islands{bestIndex};
    bestIdx = find(fitnessScores{bestIndex} == bestValue, 1);
    bestAdjMatrix = bestPop{bestIdx};

    disp('Optimized Adjacency Matrix''s value:');
    disp(bestValue);

    save(['./data_coupling_matrix_set_GA/updated_GA_island_num_rng_GA_',num2str(num_rng_ga),'.mat'],'-v7.3');
    
end

function population = initializePopulation(M, numEdges, popSize)
    rng('shuffle'); % Seeds the generator using the current time
    % Initialize a population of symmetric adjacency matrices
    population = cell(popSize, 1);
    for i = 1:popSize
        adjMatrix = zeros(M, M);
        upperTriangleIdx = find(triu(ones(M), 1)); % Indices of upper triangle
        randomEdges = datasample(upperTriangleIdx, numEdges, 'Replace', false);% default replacmenet
        adjMatrix(randomEdges) = 1;
        adjMatrix = adjMatrix + adjMatrix'; % Make symmetric
        population{i} = adjMatrix;
    end
end

function fitnessScores = evaluateFitness(population, detuning)
    % Evaluate fitness for each individual
    fitnessScores = zeros(length(population), 1);
    for i = 1:length(population)
        adjMatrix = population{i};
        fitnessScores(i) = calculateSpatialCoherence(detuning, adjMatrix);
    end
end

function parents = selectParents(population, fitnessScores, popSize)
    rng('shuffle'); % Seeds the generator using the current time
    % Select parents using roulette wheel selection
    fitnessProbs = fitnessScores / sum(fitnessScores);
    cumProbs = cumsum(fitnessProbs);
    parents = cell(popSize, 1);
    for i = 1:popSize
        r = rand; % exploration
        parentIdx = find(cumProbs >= r, 1, 'first');
        parents{i} = population{parentIdx}; % self-offspring
    end
end

function offspring = performCrossover(parents, M)
    rng('shuffle'); % Seeds the generator using the current time
    % Perform crossover with shared edges directly inherited, remaining
    % random selected with the same number of edges from parents
    offspring = cell(length(parents), 1);
    for i = 1:2:length(parents)-1
            parent1 = parents{i};
            parent2 = parents{i+1};
            
            % Identify shared edges
            shared_edges = find(triu(parent1 & parent2, 1));
            
            % Identify non-shared edges for each parent
            parent1_only = setdiff(find(triu(parent1, 1)), shared_edges);
            parent2_only = setdiff(find(triu(parent2, 1)), shared_edges);
            
            % Determine total number of edges (assumes both parents have same count)
            num_edges = length(shared_edges) + length(parent1_only) + length(parent1_only);
            
            % Randomly distribute remaining edges between offspring
            num_remaining = (num_edges - length(shared_edges)) / 2;
            offspring1_add = randsample([parent1_only; parent2_only], num_remaining, false); % replacement false
            offspring2_add = setdiff([parent1_only; parent2_only], offspring1_add);
            
            % Create offspring adjacency matrices
            child1 = zeros(M);
            child2 = zeros(M);
            
            % Add shared edges
            child1(shared_edges) = 1;
            child2(shared_edges) = 1;
            
            % Add additional edges
            child1(offspring1_add) = 1;
            child2(offspring2_add) = 1;
            
            % Make symmetric
            child1 = child1 + child1';
            child2 = child2 + child2';

            offspring{i} = child1;
            offspring{i+1} = child2;
    end
end

function offspring = performMutation(offspring, mutationRate, M)
    rng('shuffle'); % Seeds the generator using the current time
    % Perform mutation on offspring while preserving the number of edges
    for i = 1:length(offspring)
        if rand < mutationRate
            adjMatrix = offspring{i};

            % Get upper triangle indices
            upperTriangleIdx = find(triu(ones(M), 1)); % Indices of upper triangle
            currentEdges = find(triu(adjMatrix, 1));  % Indices of existing edges
            nonEdges = setdiff(upperTriangleIdx, currentEdges); % Indices of non-edges

            % Ensure there are edges to remove and non-edges to add
            if ~isempty(currentEdges) && ~isempty(nonEdges)
                % Randomly select an edge to remove
                edgeToRemove = datasample(currentEdges, 1);

                % Randomly select a non-edge to add
                edgeToAdd = datasample(nonEdges, 1);

                % Perform mutation: remove one edge and add one edge
                adjMatrix(edgeToRemove) = 0; % Remove the selected edge
                adjMatrix(edgeToAdd) = 1;   % Add the selected non-edge

                % Ensure symmetry
                adjMatrix = triu(adjMatrix, 1); % Excludes main diagonal, keeps elements above it
                adjMatrix = adjMatrix + adjMatrix';

                % Update offspring
                offspring{i} = adjMatrix;
            end
        end
    end
end

 function [newPopulation,newFitnessScores] = retainElite(population, offspring, fitnessScores,...
     fitnessScores_offspring, eliteCount)
        % Retain the top elite individuals
        [~, sortedIdx] = sort(fitnessScores, 'descend');
        elite = population(sortedIdx(1:eliteCount));
        elite_fitness = fitnessScores(sortedIdx(1:eliteCount));
        [~, sortedIdx] = sort(fitnessScores_offspring, 'descend');
        offspring = offspring(sortedIdx(1:end-eliteCount));
        offspring_fitness = fitnessScores_offspring(sortedIdx(1:end-eliteCount));
        newPopulation = [elite; offspring];
        newFitnessScores =  [elite_fitness; offspring_fitness];
 end

function islands = performMigration(islands, fitnessScores, migrationFraction)
    numIslands = length(islands);
    numMigrants = ceil(migrationFraction * length(islands{1})); % Number of individuals to migrate

    for i = 1:numIslands
        nextIsland = mod(i, numIslands) + 1; % Ring topology: migrate to next island

        % Select best individuals to migrate
        [~, sortedIdx] = sort(fitnessScores{i}, 'descend');
        migrants = islands{i}(sortedIdx(1:numMigrants)); % cell

        % Replace weakest individuals in the next island
        [~, worstIdx] = sort(fitnessScores{nextIsland}, 'ascend');
        islands{nextIsland}(worstIdx(1:numMigrants)) = migrants;
    end
end
