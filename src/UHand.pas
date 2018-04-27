{$MODE OBJFPC}

unit UHand;

interface

uses SysUtils, UCard;

type
    TKeyArray = array of integer;

    type THand = class
        protected
            cards: TCardArray;
            size: integer;
            procedure Sort(cardbuf: TCardArray; keybuf, keys: TKeyArray; lower, upper: integer);
            procedure Merge(cardbuf: TCardArray; keybuf, keys: TKeyArray; lower, mid, upper: integer);
        public
            constructor Create(max_pack_size: integer);
            function GetSize: integer;
            function Display: string;
            procedure PushCard(card: TCard);
            procedure InsertCard(card: TCard; i: integer);
            function RemoveCard(i: integer): TCard;
            function FindCard(cardscore: integer): integer;
            function FindCard(cardname: string): integer;
            function PopCard: TCard;
            function PopCard(cardscore: integer): TCard;
            function PopCard(cardstring: string): TCard;
            procedure ClearHand;
            function ViewCard(i: integer): TCard;
            function ViewCard(cardname: string): TCard;
            function TopCard: TCard;
            procedure SwapCards(i, j: integer);
            procedure Sort(keyfunc: TCardKeyFunc);
            procedure SortByRank;
            procedure SortBySuit;
    end;

implementation

constructor THand.Create(max_pack_size: integer);
begin
    size := 0;
    setlength(cards, max_pack_size);
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
    cards[size] := card;
    inc(size);
end;

function THand.PopCard: TCard;
begin
    result := cards[size - 1];
    dec(size);
end;

function THand.FindCard(cardscore: integer): integer;
var
    i: integer;
begin
    result := -1;
    for i := 0 to size - 1 do
        if cards[i].GetScore = cardscore then
            result := 1;
end;

function THand.FindCard(cardname: string): integer;
var
    i: integer;
begin
    result := -1;
    for i := 0 to size - 1 do
        if cards[i].GetShortName = cardname then
            result := 1;
end;

function THand.PopCard(cardscore: integer): TCard;
begin
    result := RemoveCard(FindCard(cardscore));
end;

function THand.PopCard(cardstring: string): TCard;
begin
    result := RemoveCard(FindCard(cardstring));
end;

procedure THand.ClearHand;
begin
    size := 0;
end;

procedure THand.InsertCard(card: TCard; i: integer);
var
    j: integer;
begin
    for j := size downto i + 1 do
        cards[j] := cards[j - 1];
    cards[i] := card;
    inc(size);
end;

function THand.RemoveCard(i: integer): TCard;
begin
    result := cards[i];
    for i := i to size - 2 do
        cards[i] := cards[i + 1];
    dec(size);
end;

function THand.ViewCard(i: integer): TCard;
begin
    result := cards[i];
end;

function THand.ViewCard(cardname: string): TCard;
begin
    result := cards[FindCard(cardname)];
end;

function THand.TopCard: TCard;
begin
    result := ViewCard(size - 1);
end;

procedure THand.SwapCards(i, j: integer);
var
    tmp_card: TCard;
begin
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
    setlength(keys, length(cards));
    setlength(keybuf, length(cards));
    setlength(cardbuf, length(cards));
    for i := 0 to length(cards) - 1 do
        keys[i] := keyfunc(cards[i]);
    Sort(cardbuf, keybuf, keys, 0, length(cards));
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
