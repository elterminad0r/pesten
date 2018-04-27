{$MODE OBJFPC}

program PPesten;

uses UGameHandler, UUI, UGame;

var
    UI: TTextUI;
    game: TPestenGame;
    handler: TGameHandler;
begin
    UI := TTextUI.Create;
    game := TPestenGame.UICreate(UI);
    handler := TGameHandler.Create(UI, game);
    handler.play;

    handler.destroy;
    UI.destroy;
    game.destroy;
end.
