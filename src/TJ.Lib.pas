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
  C_LIB_REGISTRY_MAX = 20;

var
  TJLibRegistryCount: Integer;
  TJLibRegistry: array[0..C_LIB_REGISTRY_MAX-1] of record
    Name   : string;
    Factory: TLibFactory;
  end;

procedure RegisterTJLib(const aLibName: string; aLibFactory: TLibFactory);

implementation

uses
  System.SysUtils;

procedure RegisterTJLib(const aLibName: string; aLibFactory: TLibFactory);
begin
  if (TJLibRegistryCount = C_LIB_REGISTRY_MAX) then
    raise Exception.Create('Too many TJLib, raise C_LIB_REGISTRY_MAX');
  // See TJ.Lib<name> initialization section.
  TJLibRegistry[TJLibRegistryCount].Name   := aLibName;
  TJLibRegistry[TJLibRegistryCount].Factory:= aLibFactory;
  Inc(TJLibRegistryCount);
end;

initialization
  TJLibRegistryCount := 0;
end.
