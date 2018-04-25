{$MODE OBJFPC}

unit UHand;

interface

uses SysUtils, UCard;

type
    TKeyArray = array[0..51] of integer;

    type THand = class
        protected 
            cards: TCardArray;
            size: integer;
            procedure Sort(cardbuf: TCardArray; keybuf, keys: TKeyArray; lower, upper: integer);
            procedure Merge(cardbuf: TCardArray; keybuf, keys: TKeyArray; lower, mid, upper: integer);
        public
            constructor Create;
            function GetSize: integer;
            function Display: string;
            procedure PushCard(card: TCard);
            procedure InsertCard(card: TCard; i: integer);
            function RemoveCard(i: integer): TCard;
            function PopCard: TCard;
            procedure ClearHand;
            function ViewCard(i: integer): TCard;
            function TopCard: TCard;
            procedure SwapCards(i, j: integer);
            procedure Sort(keyfunc: TCardKeyFunc);
            procedure SortByRank;
            procedure SortBySuit;
    end;

implementation

constructor THand.Create;
begin
    size := 0;
end;

function THand.GetSize: integer;
begin
    result := size;
end;

function THand.Display: string;
var
    i: integer;
begin
    result := 'Hand(';
    if size > 0 then
        result := result + cards[0].GetShortName;
    for i := 1 to size - 1 do
        result := result + ', ' + cards[i].GetShortName;
    result := result + ')';
end;

procedure THand.PushCard(card: TCard);
begin
    if size > 51 then
        raise ECardError.create('can''t add card to hand as it is full');
    cards[size] := card;
    inc(size);
end;

function THand.PopCard: TCard;
begin
    if size = 0 then
        raise ECardError.create('can''t discard as hand is empty')
    else begin
        result := cards[size - 1];
        dec(size);
    end;
end;

procedure THand.ClearHand;
begin
    size := 0;
end;

procedure THand.InsertCard(card: TCard; i: integer);
var
    j: integer;
begin
    if size > 51 then
        raise ECardError.create('can''t add card to hand as it is full');
    if (i < 0) or (i >= size) then
        raise ECardError.create('can''t add card, this is an invalid index');
    for j := size downto i + 1 do
        cards[j] := cards[j - 1];
    cards[i] := card;
    inc(size);
end;

function THand.RemoveCard(i: integer): TCard;
begin
    if size = 0 then
        raise ECardError.create('can''t remove card, this hand is empty');
    if (i < 0) or (i >= size) then
        raise ECardError.create('can''t add card, this is an invalid index');
    result := cards[i];
    for i := i to size - 2 do
        cards[i] := cards[i + 1];
    dec(size);
end;

function THand.ViewCard(i: integer): TCard;
begin
    if (i >= size) or (i < 0) then
        raise ECardError.create('can''t view card outside of range')
    else
        result := cards[i];
end;

function THand.TopCard: TCard;
begin
    result := ViewCard(size - 1);
end;

procedure THand.SwapCards(i, j: integer);
var
    tmp_card: TCard;
begin
    if (i >= size) or (j >= size) then
        raise ECardError.create('can''t swap card outside of range')
    else
        tmp_card := cards[i];
        cards[i] := cards[j];
        cards[j] := tmp_card;
end;

procedure THand.Sort(cardbuf: TCardArray; keybuf, keys: TKeyArray; lower, upper: integer);
var
    mid: integer;
begin
    if upper - lower > 1 then begin
        mid := (lower + upper) div 2;
        Sort(cardbuf, keybuf, keys, lower, mid);
        Sort(cardbuf, keybuf, keys, mid, upper);
        Merge(cardbuf, keybuf, keys, lower, mid, upper);
    end;
end;

procedure THand.Merge(cardbuf: TCardArray; keybuf, keys: TKeyArray; lower, mid, upper: integer);
var
    i, j, k: integer;

begin
    i := lower;
    j := mid;
    k := 0;
    while (i < mid) and (j < upper) do
        if keys[i] <= keys[j] then begin
            keybuf[k] := keys[i];
            cardbuf[k] := cards[i];
            inc(i);
            inc(k);
        end else begin
            keybuf[k] := keys[j];
            cardbuf[k] := cards[j];
            inc(j);
            inc(k);
        end;

    for i := i to mid - 1 do begin
        keybuf[k] := keys[i];
        cardbuf[k] := cards[i];
        inc(k);
    end;

    for j := j to upper - 1 do begin
        keybuf[k] := keys[j];
        cardbuf[k] := cards[j];
        inc(k);
    end;

    for i := 0 to k do begin
        keys[lower + i] := keybuf[i];
        cards[lower + i] := cardbuf[i];
    end;
end;

procedure THand.Sort(keyfunc: TCardKeyFunc);
var
    cardbuf: TCardArray;
    keybuf, keys: TKeyArray;
    i: integer;
begin
    for i := 0 to 51 do
        keys[i] := keyfunc(cards[i]);
    Sort(cardbuf, keybuf, keys, 0, 52);
end;

function _GetScore(card: TCard): integer;
begin
    result := card.GetScore;
end;

procedure THand.SortByRank;
begin
    Sort(@_GetScore);
end;

function _GetAltScore(card: TCard): integer;
begin
    result := card.GetAltScore;
end;

procedure THand.SortBySuit;
begin
    Sort(@_GetAltScore);
end;

end.
