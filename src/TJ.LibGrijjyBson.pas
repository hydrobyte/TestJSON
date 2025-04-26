unit TJ.LibGrijjyBson;

interface

uses
  System.Classes, System.IOUtils,
  TJ.Lib,
  Grijjy.Bson;

type
  
  TLibGrijjyBson = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TgoBsonDocument;
    function fGetName: string;
  end;

implementation

procedure TLibGrijjyBson.AfterConstruction;
begin
  inherited Create;
  fName := 'GrijjyBson';
  fJson      := TgoBsonDocument.Create;
  fJsonClone := TgoBsonDocument.Create;
end;

destructor TLibGrijjyBson.Destroy;
begin
  inherited Destroy;
end;

procedure TLibGrijjyBson.Add(const aKey, aValue: string);
begin
  fJson.Add(aKey, aValue);
end;

function TLibGrijjyBson.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibGrijjyBson.Save(const aFileName: string);
begin
  fJson.SaveToJsonFile(aFileName);
end;

procedure TLibGrijjyBson.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibGrijjyBson.Load(const aFileName: string);
begin
  fJson := TgoBsonDocument.Parse(TFile.ReadAllText(aFileName));
end;

function TLibGrijjyBson.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson[aKey] = aValue);
end;

procedure TLibGrijjyBson.Parse;
begin
  fJsonClone := TgoBsonDocument.Parse(fJson.ToJson);
end;

function TLibGrijjyBson.Check(const aCode: string): Boolean;
var
  jTmp: TgoBsonDocument;
begin
  Result := False;
  try
    jTmp   := TgoBsonDocument.Parse(aCode);
    Result := True;
  except
    Result := False;
  end;
end;

function TLibGrijjyBson.ToString: string;
begin
  Result := fJson.ToJson;
end;

function TLibGrijjyBson.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('GrijjyBson', TLibGrijjyBson);
end.
