unit TJ.LibChimeraJson;

interface

uses
  System.Classes, System.IOUtils,
  TJ.Lib,
  chimera.json;

type
  
  TLibChimeraJson = class (TInterfacedObject, ILib)
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
    function ToString: string; override;
  protected
    fName: string;
    fJson, fJsonClone: IJSONObject;
    function fGetName: string;
  end;

implementation

procedure TLibChimeraJson.AfterConstruction;
begin
  inherited;
  fName := 'chimera.json';
  fJson      := TJSON.New;
  fJsonClone := TJSON.New;
end;

destructor TLibChimeraJson.Destroy;
begin
  inherited Destroy;
end;

procedure TLibChimeraJson.Add(const aKey, aValue: string);
begin
  fJson.Strings[aKey] := aValue;
end;

function TLibChimeraJson.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibChimeraJson.Save(const aFileName: string);
begin
  fJson.SaveToFile(aFileName);
end;

procedure TLibChimeraJson.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibChimeraJson.Load(const aFileName: string);
begin
  fJson.LoadFromFile(aFileName);
end;

function TLibChimeraJson.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.Strings[aKey] = aValue);
end;

procedure TLibChimeraJson.Parse;
begin
  fJsonClone := TJSON.From(fJson.AsJSON);
end;

function TLibChimeraJson.Check(const aCode: string): Boolean;
var
 jTmp: IJSONObject;
begin
  Result := False;
  try
    jTmp   := TJSON.From(aCode);
    Result := Assigned(jTmp);
  finally
    ;
  end;
end;

function TLibChimeraJson.ToString: string;
begin
  Result := fJson.AsJSON;
end;

function TLibChimeraJson.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('chimera.json', TLibChimeraJson);
end.
