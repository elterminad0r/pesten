{$MODE OBJFPC}

unit UCard;

interface

uses SysUtils;

const
    suits: array[0..3] of string = ('Spades', 'Clubs', 'Hearts', 'Diamonds');
    char_suits: array[0..3] of string = ('♠', '♣', '♥', '♦');
    ranks: array[0..12] of string =
                        ('Ace', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
                         'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King');
    char_ranks: array[0..12] of char = ('A', '2', '3', '4', '5', '6', '7',
                                        '8', '9', 'T', 'J', 'Q', 'K');

type
    ECardError = class(Exception);

    TCard = class
        private
            Rank, Suit: Integer;
        public
            constructor Create(r, s: integer);
            function GetRank: integer;
            function GetSuit: integer;
            function GetScore: integer;
            function GetAltScore: integer;
            function GetName: string;
            function GetShortName: string;
    end;

    TCardArray = array[0..51] of TCard;
    TCardKeyFunc = function(card: TCard): integer;

function proper_mod(a, b: integer): integer;

implementation

{global functions}

function proper_mod(a, b: integer): integer;
begin
    proper_mod := a mod b;
    if proper_mod < 0 then
        proper_mod := proper_mod + b;
end;

{methods}

constructor TCard.Create(r, s: integer);
begin
    Rank := r;
    Suit := s;
end;

function TCard.GetRank: integer;
begin
    result := Rank;
end;

function TCard.GetSuit: integer;
begin
    result := Suit;
end;

function TCard.GetScore: integer;
begin
    result := Rank * 4 + Suit;
end;

function TCard.GetAltScore: integer;
begin
    result := Suit * 4 + Rank;
end;

function TCard.GetName: string;
begin
    result := Format('%s of %s', [ranks[Rank], suits[Suit]]);
end;

function TCard.GetShortName: string;
begin
    result := Format('%s%s', [char_ranks[Rank], char_suits[Suit]]);
end;

end.
