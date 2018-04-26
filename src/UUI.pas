{$MODE OBJFPC}

unit UUI;

uses UGame, UUIQuerier;

interface

type
    {User interface interface}
    IUI = interface(IUIQuerier)
        procedure DisplayText(txt: string);
        procedure ClearScreen;
        function AskPassword(msg: string): string;
    end;

    {Plain ansi terminal implementation of a UI}
    TTextUI = class(IUI)
    private
    public
        function GetInt(msg: string): integer;
        function GetString(msg: string): string;
        procedure log(msg: string);
        procedure DisplayText(txt: string);
        procedure ClearScreen;
        function AskPassword(msg: string): string;
    end;

implementation

function TTextUI.GetInt(txt: string): integer;
begin
    writeln(txt);
    write('Enter integer > '); readln(result);
end;

function TTextUI.GetString(txt: string): integer;
begin
    writeln(txt);
    write('Enter text > '), readln(result);
end;

procedure TTextUI.log(msg: string);
begin
    writeln('(game engine) ' + msg);
end;

procedure TTextUI.DisplayText(txt: string);
begin
    writeln(txt);
end;

procedure TTextUI.ClearScreen(txt: string);
begin
    {Ansi escape code to clear terminal}
    write(#27 + '[1;1H');
end;

procedure AskPassword(msg: string): string;
begin
    writeln(msg);
    write('Enter password > '); readln(result);
end;

end.
