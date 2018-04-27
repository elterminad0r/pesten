{$MODE OBJFPC}

unit UPack;

interface

uses SysUtils, UCard;

type
    TPack = class
    protected
        cards, all_cards: TCardArray;
        bottom, ncards, num_packs: integer;
        procedure Populate;
    public
        constructor Create(n: integer);
        destructor Destroy; override;
        function GetSize: integer;
        function GetMaxSize: integer;
        procedure Shuffle;
        function Deal: TCard;
        procedure ReturnCard(card: TCard);
    end;

implementation

constructor TPack.Create(n: integer);
begin
    bottom := 0;
    ncards := 52 * n;
    num_packs := n;
    setlength(cards, ncards);
    setlength(all_cards, ncards);
    Populate;
    Shuffle;
end;

destructor TPack.Destroy;
var
    i: integer;
begin
    for i := 0 to 51 do
        all_cards[i].free;
end;

function TPack.GetSize: integer;
begin
    result := ncards;
end;

function TPack.GetMaxSize: integer;
begin
    result := length(cards);
end;

procedure TPack.Populate;
var
    i, j: integer;
begin
    for j := 0 to num_packs - 1 do
        for i := 0 to 51 do begin
            cards[j * 52 + i] := TCard.create(i mod 13, i div 13);
            all_cards[j * 52 + i] := cards[j * 52 + i];
        end;
end;

procedure TPack.Shuffle;
var
    i, ind_a, ind_b: integer;
    temp: TCard;
begin
    for i := ncards - 1 downto 1 do begin
        ind_a := proper_mod(random(i) + bottom, length(cards));
        ind_b := proper_mod(i, length(cards));
        temp := cards[ind_b];
        cards[ind_b] := cards[ind_a];
        cards[ind_a] := temp;
    end;
end;

function TPack.Deal: TCard;
begin
    result := cards[proper_mod(bottom + ncards - 1, length(cards))];
    dec(ncards);
end;

procedure TPack.ReturnCard(card: TCard);
begin
    cards[bottom] := card;
    bottom := proper_mod(bottom - 1, length(cards));
    inc(ncards)
end;

initialization

begin
    randomize;
end;

end.
