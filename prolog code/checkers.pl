% Checkers game implementation in Prolog

% Define the initial board state
initial_board([
    [empty, black, empty, black, empty, black, empty, black],
    [black, empty, black, empty, black, empty, black, empty],
    [empty, black, empty, black, empty, black, empty, black],
    [empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty],
    [red, empty, red, empty, red, empty, red, empty],
    [empty, red, empty, red, empty, red, empty, red],
    [red, empty, red, empty, red, empty, red, empty]
]).

% Define valid moves
valid_move(red, [X1, Y1], [X2, Y2]) :- 
    X2 is X1 - 1, 
    (Y2 is Y1 + 1; Y2 is Y1 - 1).

valid_move(black, [X1, Y1], [X2, Y2]) :- 
    X2 is X1 + 1, 
    (Y2 is Y1 + 1; Y2 is Y1 - 1).

% Define jump moves
jump_move(Player, [X1, Y1], [X3, Y3]) :-
    valid_move(Player, [X1, Y1], [X2, Y2]),
    valid_move(Player, [X2, Y2], [X3, Y3]),
    middle(X1, X3, X2),
    middle(Y1, Y3, Y2).

middle(A, C, B) :- B is (A + C) // 2.

% Make a move
make_move(Board, Player, [X1, Y1], [X2, Y2], NewBoard) :-
    get_piece(Board, [X1, Y1], Player),
    get_piece(Board, [X2, Y2], empty),
    valid_move(Player, [X1, Y1], [X2, Y2]),
    set_piece(Board, [X1, Y1], empty, TempBoard),
    set_piece(TempBoard, [X2, Y2], Player, NewBoard).

% Make a jump move
make_jump(Board, Player, [X1, Y1], [X3, Y3], NewBoard) :-
    get_piece(Board, [X1, Y1], Player),
    get_piece(Board, [X3, Y3], empty),
    jump_move(Player, [X1, Y1], [X3, Y3]),
    middle(X1, X3, X2),
    middle(Y1, Y3, Y2),
    opposite_player(Player, Opponent),
    get_piece(Board, [X2, Y2], Opponent),
    set_piece(Board, [X1, Y1], empty, TempBoard1),
    set_piece(TempBoard1, [X2, Y2], empty, TempBoard2),
    set_piece(TempBoard2, [X3, Y3], Player, NewBoard).

% Helper predicates
get_piece(Board, [X, Y], Piece) :-
    nth0(X, Board, Row),
    nth0(Y, Row, Piece).

set_piece(Board, [X, Y], NewPiece, NewBoard) :-
    nth0(X, Board, Row),
    replace(Row, Y, NewPiece, NewRow),
    replace(Board, X, NewRow, NewBoard).

replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]) :- I > 0, I1 is I - 1, replace(T, I1, X, R).

opposite_player(red, black).
opposite_player(black, red).

% Game loop
play_game(Board, Player) :-
    display_board(Board),
    write('Player '), write(Player), write(' turn. Enter move (X1-Y1-X2-Y2): '),
    read(Move),
    process_move(Board, Player, Move, NewBoard),
    opposite_player(Player, NextPlayer),
    play_game(NewBoard, NextPlayer).

process_move(Board, Player, X1-Y1-X2-Y2, NewBoard) :-
    (make_move(Board, Player, [X1, Y1], [X2, Y2], NewBoard);
     make_jump(Board, Player, [X1, Y1], [X2, Y2], NewBoard)),
    !.
process_move(Board, Player, _, Board) :-
    write('Invalid move. Try again.'), nl,
    play_game(Board, Player).

% Display the board
display_board([]).
display_board([Row|Rest]) :-
    display_row(Row),
    nl,
    display_board(Rest).

display_row([]).
display_row([Piece|Rest]) :-
    display_piece(Piece),
    write(' '),
    display_row(Rest).

display_piece(empty) :- write('.').
display_piece(red) :- write('R').
display_piece(black) :- write('B').

% Start the game
start_game :- 
    initial_board(Board),
    play_game(Board, red).