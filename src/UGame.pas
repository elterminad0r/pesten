{$MODE OBJFPC}

unit UGame;

uses UPlayer;

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
    private
        players: array of TPestenPlayer;
        num_packs: integer;
        card_pack: TPack;
        num_discarded: integer;
        discard_pile: array of TCard;
        curr_player_no: integer;
        history: array of string;
        history_start: integer;
        direction_is_clockwise: boolean;
        constructor Create(n_players, start_player, n_packs: integer);
    public
        function GetGlobalState: string;
        function GetPrivateState(i: integer): string;
        constructor UICreate(querier: IUIQuerier);
        procedure HandleTurn(querier: IUIQuerier);
    end;

implementation

constructor TPestenGame.UICreate(querier: IUIQuerier);
var
    i: integer;
begin
    Create(query.GetInt('How many players?'),
           query.GetInt('Which player number starts?'),
           query.GetInt('How many packs?'));
end;

constructor TPestenGame.Create(n_players, start_player, n_packs: integer);
begin
    players.SetLength(n_players);
    history.SetLength(n_players * 2);
    history_start := 0
    num_packs := n_packs
    card_pack := TPack.Create(n_packs);

    for i := 0 to players.length - 1 do
        players[i] := TPestenPlayer.Create(card_pack);

    curr_player_no := start_player;
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
    if not players[curr_player_no].has_cardstring(user_card) then begin
        querier.log('This card is not in your hand');
        HandleTurn(querier);
    end;
    players[curr_player_no].PlayCard(user_card);
end;

end.
