% Jogo da Velha em Prolog com interface em Português

% Tabuleiro inicial vazio
initial_board([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']).

% Exibir o tabuleiro
display_board(Board) :-
    nl,
    write('-------------'), nl,
    write('| '), nth1(1, Board, X1), write(X1),
    write(' | '), nth1(2, Board, X2), write(X2),
    write(' | '), nth1(3, Board, X3), write(X3), write(' |'), nl,
    write('-------------'), nl,
    write('| '), nth1(4, Board, X4), write(X4),
    write(' | '), nth1(5, Board, X5), write(X5),
    write(' | '), nth1(6, Board, X6), write(X6), write(' |'), nl,
    write('-------------'), nl,
    write('| '), nth1(7, Board, X7), write(X7),
    write(' | '), nth1(8, Board, X8), write(X8),
    write(' | '), nth1(9, Board, X9), write(X9), write(' |'), nl,
    write('-------------'), nl.

% Fazer uma jogada
make_move(Player, Pos, Board, NewBoard) :-
    nth1(Pos, Board, ' '),
    replace(Board, Pos, Player, NewBoard).

% Substituir um elemento em uma lista (indexado em 1)
replace([_|T], 1, X, [X|T]).
replace([H|T], I, X, [H|R]) :-
    I > 1,
    I1 is I - 1,
    replace(T, I1, X, R).

% Verificar vitória
win(Board, Player) :-
    (   (nth1(1, Board, Player), nth1(2, Board, Player), nth1(3, Board, Player));
        (nth1(4, Board, Player), nth1(5, Board, Player), nth1(6, Board, Player));
        (nth1(7, Board, Player), nth1(8, Board, Player), nth1(9, Board, Player));
        (nth1(1, Board, Player), nth1(4, Board, Player), nth1(7, Board, Player));
        (nth1(2, Board, Player), nth1(5, Board, Player), nth1(8, Board, Player));
        (nth1(3, Board, Player), nth1(6, Board, Player), nth1(9, Board, Player));
        (nth1(1, Board, Player), nth1(5, Board, Player), nth1(9, Board, Player));
        (nth1(3, Board, Player), nth1(5, Board, Player), nth1(7, Board, Player))
    ).

% Verificar empate
draw(Board) :-
    \+ member(' ', Board).

% Jogar o jogo
play :-
    write('Bem-vindo ao Jogo da Velha!'), nl,
    write('Use números de 1 a 9 para fazer sua jogada, correspondendo às posições de um teclado de telefone.'), nl,
    initial_board(Board),
    display_board(Board),
    play_turn('X', Board).

% Ler entrada do usuário
read_move(Move) :-
    read_line_to_codes(user_input, Codes),
    string_to_atom(Codes, Atom),
    atom_number(Atom, Move).

play_turn(Player, Board) :-
    write('Jogador '), write(Player), write(', faça sua jogada (1-9): '),
    read_move(Pos),
    (   integer(Pos), Pos >= 1, Pos =< 9, make_move(Player, Pos, Board, NewBoard)
    ->  display_board(NewBoard),
        (   win(NewBoard, Player)
        ->  write('Jogador '), write(Player), write(' venceu!'), nl,
            play_again
        ;   (   draw(NewBoard)
            ->  write('Empate!'), nl,
                play_again
            ;   next_player(Player, NextPlayer),
                play_turn(NextPlayer, NewBoard)
            )
        )
    ;   write('Jogada inválida. Tente novamente.'), nl,
        play_turn(Player, Board)
    ).

% Trocar jogadores
next_player('X', 'O').
next_player('O', 'X').

% Perguntar se os jogadores querem jogar novamente
play_again :-
    write('Deseja jogar novamente? (s/n): '),
    read_line_to_codes(user_input, Codes),
    string_to_atom(Codes, Answer),
    (   Answer == 's'
    ->  play
    ;   write('Obrigado por jogar!'), nl
    ).

% Iniciar o jogo
:- initialization(play).