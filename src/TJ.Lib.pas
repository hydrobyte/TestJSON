unit TJ.Lib;

interface

uses
  System.Classes;

type
  ILib = interface
  ['{BC59958C-81A8-4C5B-9847-2E51C3C6BCF2}']
    function fGetName: string;

    procedure Add(const aKey, aValue: string);
    function  Count: Integer;
    procedure Clear;
    procedure Save(const aFileName: string);
    procedure Load(const aFileName: string);
    function  Find(const aKey, aValue: string): Boolean;
    procedure Parse;
    function  Check(const aCode: string): Boolean;
    function  ToString: string;

    property Name: string read fGetName;
  end;

  TLibFactory = class of TInterfacedObject;

const
  TJLibRegistryMax=20;
var
  TJLibRegistryCount:integer;
  TJLibRegistry: array[0..TJLibRegistryMax-1] of record
    Name: string;
    Factory: TLibFactory;
  end;

procedure RegisterTJLib(const LibName: string; LibFactory: TLibFactory);

implementation

uses
  System.SysUtils;

procedure RegisterTJLib(const LibName: string; LibFactory: TLibFactory);
begin
  if TJLibRegistryCount=TJLibRegistryMax then
    raise Exception.Create('Too many TJLib, raise TJLibRegistryMax');
  TJLibRegistry[TJLibRegistryCount].Name:=LibName;
  TJLibRegistry[TJLibRegistryCount].Factory:=LibFactory;
  inc(TJLibRegistryCount);
end;

initialization
  TJLibRegistryCount:=0;
end.
