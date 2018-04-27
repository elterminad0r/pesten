{$MODE OBJFPC}

unit UGameHandler;

interface

uses UUI, UGame;

type
    TGameHandler = class
    protected
        UI: IUI;
        game_engine: IGame;
    public
        constructor Create(ui_var: IUI; game_var: IGame);
        procedure Play;
    end;

implementation

constructor TGameHandler.Create(ui_var: IUI; game_var: IGame);
begin
    UI := ui_var;
    game_engine := game_var;
end;

procedure TGameHandler.Play;
begin
    while True do begin
        UI.ClearScreen;
        UI.DisplayText(game_engine.GetHelp);
        UI.DisplayText(game_engine.GetGlobalState);
        UI.DisplayText(game_engine.GetPrivateState);
        game_engine.HandleTurn(UI);
    end;
end;

end.
