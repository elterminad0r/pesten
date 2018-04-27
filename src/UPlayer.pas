{$MODE OBJFPC}

unit UPlayer;

interface

uses UHand, UPack, UCard;

type
    TPestenPlayer = class
    protected
        hand: THand;
    public
        constructor Create(card_pack: TPack);
        destructor Destroy; override;
        function GetState: string;
        function GetHand: THand;
        procedure Pickup(card_pack: TPack);
        procedure Pickup(card_pack: TPack; num: integer);
    end;

implementation

constructor TPestenPlayer.Create(card_pack: TPack);
begin
    hand := THand.Create(card_pack.GetMaxSize);
    Pickup(card_pack, 7);
end;

destructor TPestenPlayer.Destroy;
begin
    hand.Destroy;
end;

procedure TPestenPlayer.Pickup(card_pack: TPack);
begin
    hand.PushCard(card_pack.deal);
end;

procedure TPestenPlayer.Pickup(card_pack: TPack; num: integer);
var
    i: integer;
begin
    for i := 1 to num do
        pickup(card_pack);
end;

function TPestenPlayer.GetState: string;
begin
    result := 'Your hand is: ' + hand.Display;
end;

function TPestenPlayer.GetHand: THand;
begin
    result := hand;
end;

end.
