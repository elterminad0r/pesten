{$MODE OBJFPC}

unit UGame;

interface

uses UPlayer, UCard, UUIQuerier, UPack, SysUtils;

type
    IGame = interface
        function GetGlobalState: string;
        function GetPrivateState: string;
        function GetHelp: string;
        procedure HandleTurn(querier: IUIQuerier);
    end;

    EGameStop = class(Exception);

    TPestenGame = class(TInterfacedObject, IGame)
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
        procedure WriteHistory(s: string);
        procedure HandleNormal(card: TCard; querier: IUIQuerier);
        procedure HandleTwo(card: TCard);
        procedure AdvanceSteps(steps: integer);
        procedure HandlePickup;
        procedure HandleCardPlay(card: TCard; querier: IUIQuerier);
        function CardValid(card: TCard): boolean;
    public
        function GetGlobalState: string;
        function GetHelp: string;
        function GetPrivateState: string;
        procedure HandleTurn(querier: IUIQuerier);
        constructor Create(n_players, start_player, n_packs: integer; querier: IUIQuerier);
        constructor UICreate(querier: IUIQuerier);
        destructor Destroy; override;
    end;

implementation

constructor TPestenGame.UICreate(querier: IUIQuerier);
begin
    Create(querier.GetInt('How many players?'),
           querier.GetInt('Which player number deals?'),
           querier.GetInt('How many packs?'),
           querier);
end;

constructor TPestenGame.Create(n_players, start_player, n_packs: integer; querier: IUIQuerier);
var
    i: integer;
begin
    two_in_play := false;
    SetLength(players, n_players);
    SetLength(history, n_players * 2);
    history_start := 0;
    curr_direction := 1;
    for i := 0 to length(history) - 1 do
        WriteHistory('Game start');
    num_packs := n_packs;

    card_pack := TPack.Create(n_packs);

    for i := 0 to length(players) - 1 do
        players[i] := TPestenPlayer.Create(card_pack);

    curr_player_no := start_player;
    original_game_start := start_player;
    HandleCardPlay(card_pack.Deal, querier);
end;

destructor TPestenGame.Destroy;
var
    i: integer;
begin
    card_pack.Destroy;
    for i := 0 to length(players) - 1 do
        players[i].Destroy;
end;

function TPestenGame.GetGlobalState: string;
var
    i: integer;
begin
    result := 'history:' + #10;
    for i := history_start to history_start + length(history) - 1 do
        result := result + history[i mod length(history)] + #10;
    result := result + 'Top of discard is '
                     + top_discard.GetName
                     + #10;
end;

function TPestenGame.GetPrivateState: string;
begin
    result := players[curr_player_no].GetState;
end;

function TPestenGame.GetHelp: string;
begin
    result := 'This is pesten, see the pdf. Cards denoted as '
            + '([23456789TJQKA][SCHD]|take)';
end;

procedure TPestenGame.HandleTurn(querier: IUIQuerier);
var
    user_card: string;
begin
    user_card := querier.GetString('What card would you like to play?');

    if user_card = 'take' then
        HandlePickup
    else begin
        if players[curr_player_no].GetHand.FindCard(user_card) = -1 then begin
            querier.log('This card is not in your hand');
            HandleTurn(querier);
        end else if not CardValid(players[curr_player_no].GetHand.ViewCard(user_card)) then begin
            querier.log('This card is not valid to play');
            HandleTurn(querier);
        end else
            HandleCardPlay(players[curr_player_no].GetHand.PopCard(user_card), querier);
    end;
end;

function TPestenGame.CardValid(card: TCard): boolean;
begin
    if two_in_play then
        result := (card.GetRank = cur_two_rank)
               or ((card.GetRank = cur_two_rank + 1)
               and (card.GetSuit = cur_two_suit))
    else begin
        if top_discard.GetRank = 10 then
            result := (card.GetRank = 10) or (card.GetSuit = suit_exemption)
        else
            result := (card.GetRank = top_discard.GetRank)
                   or (card.GetSuit = top_discard.GetSuit);
    end;
end;

procedure TPestenGame.WriteHistory(s: string);
begin
    history[history_start] := s;
    history_start := (history_start + 1) mod length(history);
end;

procedure TPestenGame.HandlePickup;
begin
    if two_in_play then begin
        WriteHistory(Format('Player %d picks up %d cards', [curr_player_no, cur_two_acc]));
        players[curr_player_no].pickup(card_pack, cur_two_acc);
        two_in_play := false;
    end else begin
        WriteHistory(Format('Player %d picks up a card', [curr_player_no]));
        players[curr_player_no].pickup(card_pack);
    end;
end;

procedure TPestenGame.HandleCardPlay(card: TCard; querier: IUIQuerier);
var
    nsize, i: integer;
begin
    if players[curr_player_no].GetHand.GetSize = 1 then begin
        WriteHistory(Format('Player %d wins', [curr_player_no]));
        if querier.GetBool('Do you want to continue playing?') then begin
            nsize := card_pack.GetMaxSize;
            card_pack.Destroy;
            for i := 0 to length(players) - 1 do
                players[i].Destroy;
            Create(length(players), original_game_start, nsize div 52, querier)
        end else
            raise EGameStop.Create('Game is over');
    end;
    WriteHistory(Format('Player %d plays a %s', [curr_player_no, card.GetName]));

    if two_in_play then
        HandleTwo(card)
    else
        HandleNormal(card, querier);
end;

procedure TPestenGame.AdvanceSteps(steps: integer);
begin
    curr_player_no := proper_mod(curr_player_no + curr_direction * steps, length(players));
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
    top_discard := card;
end;

procedure TPestenGame.HandleNormal(card: TCard; querier: IUIQuerier);
begin
    case card.GetRank of
        1: begin
            two_in_play := true;
            cur_two_rank := 1;
            cur_two_suit := card.GetSuit;
            cur_two_acc := 2;
            AdvanceSteps(1);
        end;
        6: begin
            WriteHistory(Format('Player %d gets another turn', [curr_player_no]));
        end;
        7: begin
            WriteHistory(Format('Player %d skips a turn', [(curr_player_no + 1) mod length(players)]));
            AdvanceSteps(2);
        end;
        9: begin
            WriteHistory(Format('Play goes back one turn', [(curr_player_no + 1) mod length(players)]));
            AdvanceSteps(-1);
        end;
        10: begin
            repeat
                suit_exemption := querier.GetInt(
                        'What suit do you want to make it (ref:SCHD)');
            until suit_exemption in [0..3];
            WriteHistory(Format('Player %d sets suit to %s', [curr_player_no, suits[suit_exemption]]));
        end;
        12: begin
            curr_direction := -curr_direction;
            AdvanceSteps(1);
        end;
        else
            AdvanceSteps(1);
    end;
    top_discard := card;
end;

end.
