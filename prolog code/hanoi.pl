% Solve the Tower of Hanoi puzzle
hanoi(N) :- move(N, left, middle, right).

% Base case: moving one disk
move(1, Source, _, Target) :-
    write('Move disk 1 from '), write(Source),
    write(' to '), write(Target), nl.

% Recursive case: moving N disks
move(N, Source, Auxiliary, Target) :-
    N > 1,
    N1 is N - 1,
    move(N1, Source, Target, Auxiliary),
    write('Move disk '), write(N),
    write(' from '), write(Source),
    write(' to '), write(Target), nl,
    move(N1, Auxiliary, Source, Target).

% Helper predicate to start solving with N disks
solve_hanoi(N) :-
    write('Solution for '), write(N), 
    write(' disks:'), nl,
    hanoi(N).

% Example queries:
% ?- solve_hanoi(3).
% ?- solve_hanoi(4).
