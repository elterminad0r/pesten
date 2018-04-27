{$MODE OBJFPC}

unit UUI;

interface

uses UGame, UUIQuerier, SysUtils, StrUtils;

type
    {User interface interface}
    IUI = interface(IUIQUerier)
        procedure DisplayText(txt: string);
        procedure ClearScreen;
        function AskPassword(msg: string): string;
    end;

    {Plain ansi terminal implementation of a UI}
    TTextUI = class(TInterfacedObject, IUI, IUIQuerier)
    public
        function GetInt(msg: string): integer;
        function GetString(msg: string): string;
        function GetBool(msg: string): boolean;
        function AskPassword(msg: string): string;
        procedure log(msg: string);
        procedure DisplayText(txt: string);
        procedure ClearScreen;
    end;

implementation

function TTextUI.GetInt(msg: string): integer;
var
    response: string;
begin
    writeln(msg);
    write('Enter integer > '); readln(response);
    try
        result := strtoint(response);
    except
        on E: EConvertError do
            result := GetInt(msg);
    end;
end;

function TTextUI.GetString(msg: string): string;
var
    response: string;
begin
    writeln(msg);
    write('Enter text > '); readln(response);
    result := response;
end;

function TTextUI.GetBool(msg: string): boolean;
var
    response: string;
begin
    writeln(msg);
    write('Enter message containing ''y'' to confirm > '); readln(response);
    result := AnsiContainsStr(LowerCase(response), 'y');
end;

procedure TTextUI.log(msg: string);
begin
    writeln('(game engine) ' + msg);
end;

procedure TTextUI.DisplayText(txt: string);
begin
    writeln(txt);
end;

procedure TTextUI.ClearScreen;
begin
    {Ansi escape code to clear terminal}
    write(#27 + '[1;1H');
end;

function TTextUI.AskPassword(msg: string): string;
begin
    writeln(msg);
    write('Enter password > '); readln(result);
end;

end.
