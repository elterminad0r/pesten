{$MODE OBJFPC}

unit UPack;

interface

uses SysUtils, UCard;

type
    TPack = class
        private
            cards: TCardArray;
            all_cards: TCardArray;
            bottom, ncards: integer;
            procedure Populate;
        public
            constructor Create;
            destructor Free;
            function GetSize: integer;
            procedure Shuffle;
            function Deal: TCard;
            procedure ReturnCard(card: TCard);
    end;

implementation

constructor TPack.Create;
begin
    bottom := 0;
    ncards := 52;
    Populate;
    Shuffle;
end;

destructor TPack.Free;
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

procedure TPack.Populate;
var
    i: integer;
begin
    for i := 0 to 51 do begin
        cards[i] := TCard.create(i mod 13, i div 13);
        all_cards[i] := cards[i];
    end;
end;

procedure TPack.Shuffle;
var
    i, ind_a, ind_b: integer;
    temp: TCard;
begin
    for i := ncards - 1 downto 1 do begin
        ind_a := proper_mod(random(i) + bottom, 52);
        ind_b := proper_mod(i, 52);
        temp := cards[ind_b];
        cards[ind_b] := cards[ind_a];
        cards[ind_a] := temp;
    end;
end;

function TPack.Deal: TCard;
begin
    if ncards = 0 then
        raise ECardError.create('can''t deal card as pack is empty')
    else begin
        result := cards[proper_mod(bottom + ncards, 52)];    
        dec(ncards);
    end;
end;

procedure TPack.ReturnCard(card: TCard);
begin
    if ncards = 52 then
        raise ECardError.create('can''t return card as pack is full')
    else begin
        cards[bottom] := card;
        bottom := proper_mod(bottom - 1, 52);
        inc(ncards)
    end;
end;

initialization

begin
    randomize;
end;

end.
