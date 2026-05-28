function gantt_scheduling(S, C, sequence, n_jobs)
    figure;
    hold on;
    title('Gantt Chart of Job Schedule');
    xlabel('Time');
    ylabel('Position in Sequence');
    yticks(1:n_jobs);
    yticklabels(arrayfun(@(x) ['Pos ', num2str(x)], 1:n_jobs, 'UniformOutput', false));
    
    % Define a colormap for job colors
    colors = lines(n_jobs);  % Generates distinct colors

    for pos = 1:n_jobs
        job = sequence(pos); % Job ID at this position
        start_time = S(job);
        duration = C(job) - S(job);
        
        % Draw bar (no Y inversion)
        rectangle('Position', [start_time, pos - 0.4, duration, 0.8], ...
                  'FaceColor', colors(job,:), 'EdgeColor', 'k');
        
        % Job label
        text(start_time + duration/2, pos, ...
             sprintf('Job %d', job), 'HorizontalAlignment', 'center', ...
             'FontSize', 9, 'Color', 'w');
    end

    grid on;
    set(gca, 'YDir','reverse');  % Flip the Y-axis direction so pos 1 is at bottom
    hold off;
end

