% Define estado inicial do tabuleiro
initial_board([
    [rook(white), knight(white), bishop(white), queen(white), king(white), bishop(white), knight(white), rook(white)],
    [pawn(white), pawn(white), pawn(white), pawn(white), pawn(white), pawn(white), pawn(white), pawn(white)],
    [empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty],
    [pawn(black), pawn(black), pawn(black), pawn(black), pawn(black), pawn(black), pawn(black), pawn(black)],
    [rook(black), knight(black), bishop(black), queen(black), king(black), bishop(black), knight(black), rook(black)]
]).

% Define movimentos válidos pra cada peça
valid_move(pawn(Color), [X1, Y1], [X2, Y2], Board) :-
    pawn_move(Color, [X1, Y1], [X2, Y2], Board).

valid_move(rook(Color), [X1, Y1], [X2, Y2], Board) :-
    rook_move(Color, [X1, Y1], [X2, Y2], Board).

valid_move(knight(_), [X1, Y1], [X2, Y2], _) :-
    knight_move([X1, Y1], [X2, Y2]).

valid_move(bishop(Color), [X1, Y1], [X2, Y2], Board) :-
    bishop_move(Color, [X1, Y1], [X2, Y2], Board).

valid_move(queen(Color), [X1, Y1], [X2, Y2], Board) :-
    queen_move(Color, [X1, Y1], [X2, Y2], Board).

valid_move(king(_), [X1, Y1], [X2, Y2], _) :-
    king_move([X1, Y1], [X2, Y2]).

% Movimento do pião
pawn_move(white, [X, 2], [X, 4], Board) :-
    empty_square([X, 3], Board),
    empty_square([X, 4], Board).
pawn_move(white, [X, Y1], [X, Y2], Board) :-
    Y2 is Y1 + 1,
    empty_square([X, Y2], Board).
pawn_move(white, [X1, Y1], [X2, Y2], Board) :-
    Y2 is Y1 + 1,
    (X2 is X1 + 1; X2 is X1 - 1),
    opponent_piece(white, [X2, Y2], Board).

pawn_move(black, [X, 7], [X, 5], Board) :-
    empty_square([X, 6], Board),
    empty_square([X, 5], Board).
pawn_move(black, [X, Y1], [X, Y2], Board) :-
    Y2 is Y1 - 1,
    empty_square([X, Y2], Board).
pawn_move(black, [X1, Y1], [X2, Y2], Board) :-
    Y2 is Y1 - 1,
    (X2 is X1 + 1; X2 is X1 - 1),
    opponent_piece(black, [X2, Y2], Board).

% Movimento da torre
rook_move(Color, [X, Y1], [X, Y2], Board) :-
    Y1 \= Y2,
    clear_path([X, Y1], [X, Y2], Board),
    not(same_color_piece(Color, [X, Y2], Board)).

rook_move(Color, [X1, Y], [X2, Y], Board) :-
    X1 \= X2,
    clear_path([X1, Y], [X2, Y], Board),
    not(same_color_piece(Color, [X2, Y], Board)).

% Movimento do cavalo
knight_move([X1, Y1], [X2, Y2]) :-
    (
        (X2 is X1 + 1, Y2 is Y1 + 2);
        (X2 is X1 + 1, Y2 is Y1 - 2);
        (X2 is X1 - 1, Y2 is Y1 + 2);
        (X2 is X1 - 1, Y2 is Y1 - 2);
        (X2 is X1 + 2, Y2 is Y1 + 1);
        (X2 is X1 + 2, Y2 is Y1 - 1);
        (X2 is X1 - 2, Y2 is Y1 + 1);
        (X2 is X1 - 2, Y2 is Y1 - 1)
    ).

% Movimento do bispo
bishop_move(Color, [X1, Y1], [X2, Y2], Board) :-
    abs(X2 - X1) =:= abs(Y2 - Y1),
    clear_diagonal_path([X1, Y1], [X2, Y2], Board),
    not(same_color_piece(Color, [X2, Y2], Board)).

% Movimento da rainha (Combina o movimento da torre e do bispo)
queen_move(Color, [X1, Y1], [X2, Y2], Board) :-
    (rook_move(Color, [X1, Y1], [X2, Y2], Board);
     bishop_move(Color, [X1, Y1], [X2, Y2], Board)).

% Movimento do rei
king_move([X1, Y1], [X2, Y2]) :-
    abs(X2 - X1) =< 1,
    abs(Y2 - Y1) =< 1,
    (X1 \= X2; Y1 \= Y2).

% Predicado helper
empty_square([X, Y], Board) :-
    nth1(Y, Board, Row),
    nth1(X, Row, empty).

opponent_piece(Color, [X, Y], Board) :-
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    Piece \= empty,
    \+ same_color(Color, Piece).

same_color_piece(Color, [X, Y], Board) :-
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    same_color(Color, Piece).

same_color(white, Piece) :- Piece =.. [_, white].
same_color(black, Piece) :- Piece =.. [_, black].

clear_path([X, Y1], [X, Y2], Board) :-
    Y1 < Y2,
    clear_vertical_path(X, Y1, Y2, Board).
clear_path([X, Y1], [X, Y2], Board) :-
    Y1 > Y2,
    clear_vertical_path(X, Y2, Y1, Board).
clear_path([X1, Y], [X2, Y], Board) :-
    X1 < X2,
    clear_horizontal_path(Y, X1, X2, Board).
clear_path([X1, Y], [X2, Y], Board) :-
    X1 > X2,
    clear_horizontal_path(Y, X2, X1, Board).

clear_vertical_path(_, Y, Y, _).
clear_vertical_path(X, Y1, Y2, Board) :-
    Y1 < Y2,
    Y3 is Y1 + 1,
    empty_square([X, Y3], Board),
    clear_vertical_path(X, Y3, Y2, Board).

clear_horizontal_path(_, X, X, _).
clear_horizontal_path(Y, X1, X2, Board) :-
    X1 < X2,
    X3 is X1 + 1,
    empty_square([X3, Y], Board),
    clear_horizontal_path(Y, X3, X2, Board).

clear_diagonal_path([X1, Y1], [X2, Y2], Board) :-
    X1 < X2,
    Y1 < Y2,
    clear_diagonal_path_ne(X1, Y1, X2, Y2, Board).
clear_diagonal_path([X1, Y1], [X2, Y2], Board) :-
    X1 < X2,
    Y1 > Y2,
    clear_diagonal_path_se(X1, Y1, X2, Y2, Board).
clear_diagonal_path([X1, Y1], [X2, Y2], Board) :-
    X1 > X2,
    Y1 < Y2,
    clear_diagonal_path_nw(X1, Y1, X2, Y2, Board).
clear_diagonal_path([X1, Y1], [X2, Y2], Board) :-
    X1 > X2,
    Y1 > Y2,
    clear_diagonal_path_sw(X1, Y1, X2, Y2, Board).

clear_diagonal_path_ne(X, _, X, _, _).
clear_diagonal_path_ne(X1, Y1, X2, Y2, Board) :-
    X1 < X2,
    X3 is X1 + 1,
    Y3 is Y1 + 1,
    empty_square([X3, Y3], Board),
    clear_diagonal_path_ne(X3, Y3, X2, Y2, Board).

clear_diagonal_path_se(X, _, X, _, _).
clear_diagonal_path_se(X1, Y1, X2, Y2, Board) :-
    X1 < X2,
    X3 is X1 + 1,
    Y3 is Y1 - 1,
    empty_square([X3, Y3], Board),
    clear_diagonal_path_se(X3, Y3, X2, Y2, Board).

clear_diagonal_path_nw(X, _, X, _, _).
clear_diagonal_path_nw(X1, Y1, X2, Y2, Board) :-
    X1 > X2,
    X3 is X1 - 1,
    Y3 is Y1 + 1,
    empty_square([X3, Y3], Board),
    clear_diagonal_path_nw(X3, Y3, X2, Y2, Board).

clear_diagonal_path_sw(X, _, X, _, _).
clear_diagonal_path_sw(X1, Y1, X2, Y2, Board) :-
    X1 > X2,
    X3 is X1 - 1,
    Y3 is Y1 - 1,
    empty_square([X3, Y3], Board),
    clear_diagonal_path_sw(X3, Y3, X2, Y2, Board).

% Loop principal do jogo
play_chess :-
    initial_board(Board),
    play_turn(white, Board).

play_turn(Color, Board) :-
    display_board(Board),
    write('Vez do '), write(Color), nl,
    write('Digite seu movimento (exemplo: e2e4): '),
    read(Move),
    (
        make_move(Color, Move, Board, NewBoard) ->
        (
            game_over(NewBoard, Color) ->
            (
                display_board(NewBoard),
                write(Color), write(' ganhou!'), nl
            );
            (
                next_color(Color, NextColor),
                play_turn(NextColor, NewBoard)
            )
        );
        (
            write('Movimento inválido. Tente novamente.'), nl,
            play_turn(Color, Board)
        )
    ).

make_move(Color, Move, Board, NewBoard) :-
    move_to_coordinates(Move, [X1, Y1], [X2, Y2]),
    nth1(Y1, Board, Row1),
    nth1(X1, Row1, Piece),
    Piece =.. [_, Color],
    valid_move(Piece, [X1, Y1], [X2, Y2], Board),
    replace_piece(Board, [X1, Y1], empty, TempBoard),
    replace_piece(TempBoard, [X2, Y2], Piece, NewBoard).

move_to_coordinates([File1, Rank1, File2, Rank2], [X1, Y1], [X2, Y2]) :-
    file_to_x(File1, X1),
    file_to_x(File2, X2),
    rank_to_y(Rank1, Y1),
    rank_to_y(Rank2, Y2).

file_to_x(File, X) :- char_code(File, Code), X is Code - 96.
rank_to_y(Rank, Y) :- atom_number(Rank, N), Y is 9 - N.

replace_piece(Board, [X, Y], NewPiece, NewBoard) :-
    nth1(Y, Board, Row),
    replace_nth(X, Row, NewPiece, NewRow),
    replace_nth(Y, Board, NewRow, NewBoard).

replace_nth(1, [_|T], X, [X|T]).
replace_nth(N, [H|T], X, [H|R]) :- N > 1, N1 is N - 1, replace_nth(N1, T, X, R).

next_color(white, black).
next_color(black, white).

game_over(Board, Color) :-
    \+ king_exists(Board, OtherColor),
    next_color(Color, OtherColor).

king_exists(Board, Color) :-
    member(Row, Board),
    member(king(Color), Row).

% Mostra o tabuleiro
display_board(Board) :-
    nl,
    write('  a b c d e f g h'), nl,
    display_rows(Board, 8).

display_rows([], _).
display_rows([Row|Rest], RowNum) :-
    write(RowNum), write(' '),
    display_row(Row),
    write(' '), write(RowNum), nl,
    NextRowNum is RowNum - 1,
    display_rows(Rest, NextRowNum).

display_row([]).
display_row([Piece|Rest]) :-
    display_piece(Piece),
    write(' '),
    display_row(Rest).

display_piece(empty) :- write('.').
display_piece(pawn(white)) :- write('P').
display_piece(pawn(black)) :- write('p').
display_piece(rook(white)) :- write('R').
display_piece(rook(black)) :- write('r').
display_piece(knight(white)) :- write('N').
display_piece(knight(black)) :- write('n').
display_piece(bishop(white)) :- write('B').
display_piece(bishop(black)) :- write('b').
display_piece(queen(white)) :- write('Q').
display_piece(queen(black)) :- write('q').
display_piece(king(white)) :- write('K').
display_piece(king(black)) :- write('k').

% Começa o jogo
:- initialization(main).

main :-
    write('Digite os movimentos no formado "e2e4". '), nl,
    write('Ou digite quit para sair do jogo.'), nl,
    play_chess.

% Handle user input
play_turn(Color, Board) :-
    display_board(Board),
    write('Vez do '), write(Color), nl,
    write('Digite um movimento (exemplo: e2e4): '),
    read(MoveAtom),
    atom_chars(MoveAtom, MoveChars),
    (
        MoveChars = [q, u, i, t] ->
        write('Fim de jogo.'), nl;
        (
            (make_move(Color, MoveChars, Board, NewBoard) ->
                (
                    game_over(NewBoard, Color) ->
                    (
                        display_board(NewBoard),
                        write(Color), write(' ganhou!'), nl
                    );
                    (
                        next_color(Color, NextColor),
                        play_turn(NextColor, NewBoard)
                    )
                );
                (
                    write('Movimento inválido. Tente novamente.'), nl,
                    play_turn(Color, Board)
                )
            )
        )
    ).

% Check if the game is in checkmate
game_over(Board, Color) :-
    next_color(Color, OtherColor),
    king_in_check(Board, OtherColor),
    \+ any_valid_move(Board, OtherColor).

% Check if the king is in check
king_in_check(Board, Color) :-
    find_king(Board, Color, KingPos),
    next_color(Color, OtherColor),
    any_piece_can_attack(Board, OtherColor, KingPos).

% Find the position of the king
find_king(Board, Color, [X, Y]) :-
    nth1(Y, Board, Row),
    nth1(X, Row, king(Color)).

% Check if any piece of the given color can attack the target position
any_piece_can_attack(Board, Color, TargetPos) :-
    member(Y, [1,2,3,4,5,6,7,8]),
    member(X, [1,2,3,4,5,6,7,8]),
    nth1(Y, Board, Row),
    nth1(X, Row, Piece),
    Piece =.. [PieceType, Color],
    valid_move(Piece, [X, Y], TargetPos, Board).

% Check if theres any valid move for the given color
any_valid_move(Board, Color) :-
    member(Y1, [1,2,3,4,5,6,7,8]),
    member(X1, [1,2,3,4,5,6,7,8]),
    nth1(Y1, Board, Row),
    nth1(X1, Row, Piece),
    Piece =.. [PieceType, Color],
    member(Y2, [1,2,3,4,5,6,7,8]),
    member(X2, [1,2,3,4,5,6,7,8]),
    valid_move(Piece, [X1, Y1], [X2, Y2], Board),
    make_move(Color, [X1, Y1, X2, Y2], Board, NewBoard),
    \+ king_in_check(NewBoard, Color).

% Make a move and ensure the king is not in check afterwards
make_move(Color, [X1, Y1, X2, Y2], Board, NewBoard) :-
    nth1(Y1, Board, Row1),
    nth1(X1, Row1, Piece),
    Piece =.. [PieceType, Color],
    valid_move(Piece, [X1, Y1], [X2, Y2], Board),
    replace_piece(Board, [X1, Y1], empty, TempBoard),
    replace_piece(TempBoard, [X2, Y2], Piece, NewBoard),
    \+ king_in_check(NewBoard, Color).

% Convert move input to coordinates
move_to_coordinates([F1, R1, F2, R2], [X1, Y1], [X2, Y2]) :-
    file_to_x(F1, X1),
    rank_to_y(R1, Y1),
    file_to_x(F2, X2),
    rank_to_y(R2, Y2).

file_to_x(File, X) :- char_code(File, Code), X is Code - 96.
rank_to_y(Rank, Y) :- atom_number(Rank, N), Y is 9 - N.

% Pawn promotion (simplified version - always promotes to queen)
make_move(Color, [X1, Y1, X2, Y2], Board, NewBoard) :-
    nth1(Y1, Board, Row1),
    nth1(X1, Row1, pawn(Color)),
    (Y2 =:= 1; Y2 =:= 8),
    valid_move(pawn(Color), [X1, Y1], [X2, Y2], Board),
    replace_piece(Board, [X1, Y1], empty, TempBoard),
    replace_piece(TempBoard, [X2, Y2], queen(Color), NewBoard),
    \+ king_in_check(NewBoard, Color).

% En passant (simplified version - doesnt check if the pawn moved two squares in the previous turn)
pawn_move(white, [X1, 5], [X2, 6], Board) :-
    abs(X2 - X1) =:= 1,
    nth1(5, Board, Row),
    nth1(X2, Row, pawn(black)).

pawn_move(black, [X1, 4], [X2, 3], Board) :-
    abs(X2 - X1) =:= 1,
    nth1(4, Board, Row),
    nth1(X2, Row, pawn(white)).

make_move(Color, [X1, Y1, X2, Y2], Board, NewBoard) :-
    nth1(Y1, Board, Row1),
    nth1(X1, Row1, pawn(Color)),
    pawn_move(Color, [X1, Y1], [X2, Y2], Board),
    replace_piece(Board, [X1, Y1], empty, TempBoard1),
    replace_piece(TempBoard1, [X2, Y1], empty, TempBoard2),
    replace_piece(TempBoard2, [X2, Y2], pawn(Color), NewBoard),
    \+ king_in_check(NewBoard, Color).

% Castling (simplified version - doesnt check if the king or rook has moved before)
king_move([5, Y], [7, Y]) :- % Kingside castling
    member(Y, [1, 8]).
king_move([5, Y], [3, Y]) :- % Queenside castling
    member(Y, [1, 8]).

make_move(Color, [5, Y1, 7, Y1], Board, NewBoard) :- % Kingside castling
    member(Y1, [1, 8]),
    nth1(Y1, Board, Row),
    nth1(5, Row, king(Color)),
    nth1(8, Row, rook(Color)),
    clear_path([5, Y1], [8, Y1], Board),
    replace_piece(Board, [5, Y1], empty, TempBoard1),
    replace_piece(TempBoard1, [8, Y1], empty, TempBoard2),
    replace_piece(TempBoard2, [7, Y1], king(Color), TempBoard3),
    replace_piece(TempBoard3, [6, Y1], rook(Color), NewBoard),
    \+ king_in_check(NewBoard, Color).

make_move(Color, [5, Y1, 3, Y1], Board, NewBoard) :- % Queenside castling
    member(Y1, [1, 8]),
    nth1(Y1, Board, Row),
    nth1(5, Row, king(Color)),
    nth1(1, Row, rook(Color)),
    clear_path([5, Y1], [1, Y1], Board),
    replace_piece(Board, [5, Y1], empty, TempBoard1),
    replace_piece(TempBoard1, [1, Y1], empty, TempBoard2),
    replace_piece(TempBoard2, [3, Y1], king(Color), TempBoard3),
    replace_piece(TempBoard3, [4, Y1], rook(Color), NewBoard),
    \+ king_in_check(NewBoard, Color).

% Add stalemate check
game_over(Board, Color) :-
    next_color(Color, OtherColor),
    \+ any_valid_move(Board, OtherColor),
    \+ king_in_check(Board, OtherColor),
    write('Stalemate! The game is a draw.'), nl.

% Update play_turn to handle stalemate
play_turn(Color, Board) :-
    display_board(Board),
    (
        game_over(Board, Color) ->
        true;
        (
            write('Vez do'), write(Color), nl,
            write('Digite o movimento (exemplo: e2e4): '),
            read(MoveAtom),
            atom_chars(MoveAtom, MoveChars),
            (
                MoveChars = [q, u, i, t] ->
                write('Fim de jogo.'), nl;
                (
                    (make_move(Color, MoveChars, Board, NewBoard) ->
                        (
                            next_color(Color, NextColor),
                            play_turn(NextColor, NewBoard)
                        );
                        (
                            write('Movimento inválido. Tente novamente.'), nl,
                            play_turn(Color, Board)
                        )
                    )
                )
            )
        )
    ).