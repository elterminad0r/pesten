{$MODE OBJFPC}

unit UGame;

uses UPlayer, UCard, UUIQuerier;

interface

type
    IGame = interface
        function GetGlobalState: string;
        function GetPrivateState(i: integer): string;
        function GetHelp: string;
        function GetCurrentPlayer: integer;
        procedure HandleTurn(querier: IUIQuerier);
        constructor UICreate(querier: IUIQuerier);
    end;

    TPestenGame = class(IGame)
    protected
        players: array of TPestenPlayer;
        num_packs: integer;
        card_pack: TPack;
        top_discard: TCard;
        suit_exemption: integer;
        curr_player_no, original_game_start: integer;
        history: array of string;
        history_start: integer;
        two_in_play: boolean;
        cur_two_rank, cur_two_suit, cur_two_acc: integer;
        curr_direction: integer;
        constructor Create(n_players, start_player, n_packs: integer);
        procedure WriteHistory(s: string);
        procedure HandleNormal(card: TCard; querier: IUIQuerier);
        procedure HandleTwo(card: TCard);
        procedure AdvanceSteps(steps: integer);
        procedure FreeAll;
    public
        function GetGlobalState: string;
        function GetPrivateState(i: integer): string;
        constructor UICreate(querier: IUIQuerier);
        procedure HandleTurn(querier: IUIQuerier);
        procedure HandlePickup;
        procedure HandleCardPlay
        function CardValid(card: TCard): boolean;
    end;

implementation

constructor TPestenGame.UICreate(querier: IUIQuerier);
var
    i: integer;
begin
    Create(querier.GetInt('How many players?'),
           querier.GetInt('Which player number deals?'),
           querier.GetInt('How many packs?'));
end;

constructor TPestenGame.Create(n_players, start_player, n_packs: integer);
var
    i: integer;
begin
    two_in_play := false;
    players.SetLength(n_players);
    history.SetLength(n_players * 2);
    history_start := 0;
    direction := 1;
    for i := 0 to history.length do
        WriteHistory('Game start');
    num_packs := n_packs
    card_pack := TPack.Create(n_packs);

    HandleCardPlay(card_pack.Deal);

    for i := 0 to players.length - 1 do
        players[i] := TPestenPlayer.Create(card_pack);

    curr_player_no := start_player;
    original_game_start := start_player;
end;

function GetGlobalState: string;
var
    i: integer;
begin
    result := 'history:' + #10;
    for i := history_start to history_start + history.length() - 1
        result := result + history[i mod history.length()] + #10;
    result := result + 'Top of discard is '
                     + discard_pile[num_discarded].GetString
                     + #10;
end;

function TPestenGame.GetPrivateState(i: integer): string;
begin
    result := players[i].GetState;
end;

function TPestenGame.GetCurrentPlayer: integer;
begin
    result := curr_player_no;
end;

procedure TPestenGame.HandleTurn(querier: IUIQuerier);
var
    user_card: string;
begin
    user_card := querier.GetString('What card would you like to play?');

    if user_card = 'take' then
        HandlePickup
    else begin
        if not players[curr_player_no].has_cardstring(user_card) then begin
            querier.log('This card is not in your hand');
            HandleTurn(querier);
        end else if not CardValid(player[curr_player_no].PeekCard(user_card)) then
            querier.log('This card is not valid to play')
            HandleTurn(querier);
        else
            HandleCardPlay(players[curr_player_no].PlayCard(user_card));
    end;
end;

function TPestenGame.CardValid(card: TCard): boolean;
begin
    if top_discard.GetRank = 10 then
        result := (card.Rank = 10) or (card.Suit = suit_exemption)
    else
        result := (card.Rank = top_discard.GetRank)
               or (card.Suit = top_discard.GetSuit);
end;

procedure TPestenGame.WriteHistory(s: string);
begin
    history[history_start] := s;
    history_start := (history_start + 1) mod history.length;
end;

procedure TPestenGame.HandlePickup;
begin
    if two_in_play then begin
        WriteHistory(Format('Player %d picks up %d cards', [curr_player_no, cur_two_acc]));
        players[curr_player_no].pickup(card_pack, cur_two_acc);
        two_in_play := false;
    end;
        WriteHistory(Format('Player %d picks up a card', [curr_player_no]));
        players[curr_player_no].pickup(card_pack);
end;

procedure TPestenGame.HandleCardPlay(card: TCard, querier: IUIQuerier);
begin
    if Player.GetCards = 1 then begin
        WriteHistory(Format('Player %d wins', [curr_player_no]));
        FreeAll;
        if querier.GetBool('Do you want to continue playing?') then
            Create(players.length, original_game_start, card_pack.length div 52)
        else
            raise EGameEnded.Create('Game is over');
    end;

    WriteHistory(Format('Player %d playrs a %s', [curr_player_no, card.GetString]));
    if two_in_play then
        HandleTwo(card)
    else
        HandleNormal(card, querier);
end;

procedure AdvanceSteps(steps: integer);
begin
    curr_player_no := proper_mod(curr_player_no + curr_direction * steps, players.length);
end;

procedure TPestenGame.HandleTwo(card: TCard);
begin
    if card.GetRank = cur_two_rank then
        cur_two_acc := cur_two_acc + cur_two_rank + 1
    else if (card.GetRank = cur_two_rank + 1)
        and (card.GetSuit = cur_two_suit) then begin
        inc(cur_two_rank);
        cur_two_acc := cur_two_acc + cur_two_rank + 1;
    end;
    AdvanceSteps(1);
end;


procedure TPestenGame.HandleNormal(card: TCard, querier: IUIQuerier);
begin
    case card.GetRank in
        1: begin
            two_in_play := true;
            cur_two_rank := 1
            cur_two_suit := card.GetSuit;
            cur_two_acc := 2;
            AdvanceSteps(1);
        end;
        6: begin
            WriteHistory(Format('Player %d gets another turn', [curr_player_no]));
        end;
        7: begin
            WriteHistory(Format('Player %d skips a turn', [(curr_player_no + 1) mod players.length]));
            AdvanceSteps(2);
        9: begin
            WriteHistory(Format('Play goes back one turn', [(curr_player_no + 1) mod players.length]));
            AdvanceSteps(-1);
        10: begin do
                suit_exemption := querier.GetInt(
                        'What suit do you want to make it (ref:♠♣♥♦)');
            while not suit_exemption in [0..3];
            WriteHistory('Player %d sets suit to %s', [curr_player_no, suits[suit_exemption]]);
        12: begin
            curr_direction := -curr_direction;
            AdvanceSteps(1);
        end;
    end;
end;

end.



{Things that aren't implemented:
    - jokers
    - runs
    - autoselection/ list of choices for user
    - better ui using ncurses, or a gui
        - which would ideally require proper XML communication
    - declaration of last card mechanism
}
