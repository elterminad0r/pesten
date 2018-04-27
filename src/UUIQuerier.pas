{$MODE OBJFPC}

unit UUIQuerier;

interface

type
    IUIQuerier = interface
        function GetInt(msg: string): integer;
        function GetString(msg: string): string;
        function GetBool(msg: string): boolean;
        procedure log(msg: string);
    end;

implementation

end.
