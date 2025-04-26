unit TJ.LibJDO;

interface

uses
  System.Classes,
  TJ.Lib,
  JsonDataObjects;

type

  TLibJDO = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TJsonObject;
    function fGetName: string;
  end;

implementation

procedure TLibJDO.AfterConstruction;
begin
  inherited Create;
  fName := 'JsonDataObjects';
  fJson      := TJsonObject.Create;
  fJsonClone := TJsonObject.Create;
end;

destructor TLibJDO.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibJDO.Add(const aKey, aValue: string);
begin
  fJson.S[aKey] := aValue;
end;

function TLibJDO.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibJDO.Save(const aFileName: string);
begin
  fJson.SaveToFile(aFileName);
end;

procedure TLibJDO.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibJDO.Load(const aFileName: string);
begin
  fJson.LoadFromFile(aFileName);
end;

function TLibJDO.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.S[aKey] = aValue);
end;

procedure TLibJDO.Parse;
begin
  fJsonClone.Free;
  fJsonClone := fJson.Parse(fJson.ToJSON) as TJsonObject;
end;

function TLibJDO.Check(const aCode: string): Boolean;
var
 jTmp: TJsonBaseObject;
begin
  Result := False;
  try
    jTmp   := fJson.Parse(aCode);
    Result := Assigned(jTmp);
  finally
    jTmp.Free;
  end;
end;

function TLibJDO.ToString: string;
begin
  Result := fJson.ToJSON;
end;

function TLibJDO.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('JsonDataObjects', TLibJDO);
end.
