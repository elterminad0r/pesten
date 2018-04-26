{$MODE OBJFPC}

unit UUIQuerier;

interface

type
    IUIQuerier = interface
        function GetInt(msg: string): integer;
        function GetString(msg: string): string;
        procedure log(msg: string);
    end;

end.
