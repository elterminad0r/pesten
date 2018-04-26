unit UGameHandler;

uses UUI;

interface

type
    TGameHandler = class
    private
        UI: IUI;
        game_engine: IGame;
    public
        constructor Create(ui_var: IUI; game_var: IGame);
        procedure Play;
    end;

implementation


