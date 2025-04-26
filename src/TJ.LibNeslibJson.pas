unit TJ.LibNeslibJson;

interface

uses
  System.Classes,
  TJ.Lib,
  Neslib.Json;

type
  
  TLibNeslibJson = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: IJsonDocument;
    function fGetName: string;
  end;

implementation

procedure TLibNeslibJson.AfterConstruction;
begin
  inherited;
  fName := 'Neslib.Json';
  fJson      := TJsonDocument.CreateDictionary;
  fJsonClone := TJsonDocument.CreateDictionary;
end;

destructor TLibNeslibJson.Destroy;
begin
  inherited Destroy;
end;

procedure TLibNeslibJson.Add(const aKey, aValue: string);
begin
  fJson.Root.AddOrSetValue(aKey, aValue);
end;

function TLibNeslibJson.Count: Integer;
begin
  Result := fJson.Root.Count;
end;

procedure TLibNeslibJson.Save(const aFileName: string);
begin
  fJson.Save(aFileName);
end;

procedure TLibNeslibJson.Clear;
begin
  fJson.Root.Clear;
  fJsonClone.Root.Clear;
end;

procedure TLibNeslibJson.Load(const aFileName: string);
begin
  fJson := TJsonDocument.Load(aFileName);
end;

function TLibNeslibJson.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.Root.Values[aKey].ToString = aValue);
end;

procedure TLibNeslibJson.Parse;
begin
  fJsonClone := TJsonDocument.Parse(fJson.ToJson(False));
end;

function TLibNeslibJson.Check(const aCode: string): Boolean;
var
 jTmp: IJsonDocument;
begin
  Result := False;
  try
    jTmp   := TJsonDocument.Parse(aCode);
    Result := Assigned(jTmp);
  finally
    ;
  end;
end;

function TLibNeslibJson.ToString: string;
begin
  Result := fJson.ToJson(False);
end;

function TLibNeslibJson.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('Neslib.Json', TLibNeslibJson);
end.
