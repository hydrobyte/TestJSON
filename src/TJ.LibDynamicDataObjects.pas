unit TJ.LibDynamicDataObjects;

interface

uses
  System.Classes, System.SysUtils, System.IOUtils,
  TJ.Lib,
  DataObjects2, DataObjects2JSON;

type
  
  TLibDynamicDataObjects = class (TInterfacedObject, ILib)
  public
    procedure AfterConstruction; override;
    destructor  Destroy; override;
    procedure Add(const aKey, aValue: string);
    function  Count: Integer;
    procedure Clear;
    procedure Save(const aFileName: string);
    procedure Load(const aFileName: string);
    function  Find(const aKey, aValue: string): Boolean;
    procedure Parse;
    function  Check(const aCode: string): Boolean;
    function  ToString: string; override;
  protected
    fName: string;
    fJson, fJsonClone: TDataObj;
    function fGetName: string;
  end;

implementation

procedure TLibDynamicDataObjects.AfterConstruction;
begin
  inherited AfterConstruction;
  fName := 'DynamicDataObjects';
  fJson      := TDataObj.Create;
  fJsonClone := TDataObj.Create;
end;

destructor TLibDynamicDataObjects.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibDynamicDataObjects.Add(const aKey, aValue: string);
begin
  fJson[aKey].AsString := aValue;
end;

function TLibDynamicDataObjects.Count: Integer;
begin
  Result := fJson.AsFrame.Count;
end;

procedure TLibDynamicDataObjects.Save(const aFileName: string);
begin
  fJson.WriteToFile(aFileName);
end;

procedure TLibDynamicDataObjects.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibDynamicDataObjects.Load(const aFileName: string);
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create();
  try
    strStream.LoadFromFile(aFileName);
    TJsonStreamer.JsonToDataObj(strStream.DataString, fJson);
  finally
    strStream.Free;
  end;
end;

function TLibDynamicDataObjects.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson[aKey].AsString = aValue);
end;

procedure TLibDynamicDataObjects.Parse;
begin
  TJsonStreamer.JsonToDataObj(fJson.JSON, fJsonClone);
end;

function TLibDynamicDataObjects.Check(const aCode: string): Boolean;
var
  lStreamer: TJsonStreamer;
begin
  Result := False;
  lStreamer := TJsonStreamer.create;
  try
    lStreamer.AllowParsingSymbols           := False;
    lStreamer.AllowParsingExtendedTypes     := False;
    lStreamer.AllowSingleQuoteStrings       := False;
    lStreamer.AllowOverwritingExistingSlots := False;
    lStreamer.SlotnameIsCaseSensitive       := True;
    lStreamer.AllowParsingLeadingZeros      := False;
    lStreamer.JSON := aCode;
    lStreamer.Decode(fJson);
    Result := True;
  finally
    lStreamer.free;
  end;
end;

function TLibDynamicDataObjects.ToString: string;
begin
  Result := fJson.JSON;
end;

function TLibDynamicDataObjects.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('DynamicDataObjects', TLibDynamicDataObjects);
end.
