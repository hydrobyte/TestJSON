unit TJ.LibDwsJSON;

interface

uses
  System.Classes, System.IOUtils,
  TJ.Lib,
  dwsJSON;

type
  
  TLibDwsJSON = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TdwsJSONObject;
    function fGetName: string;
  end;

implementation

procedure TLibDwsJSON.AfterConstruction;
begin
  inherited;
  fName := 'dwsJSON';
  fJson      := TdwsJSONObject.Create;
  fJsonClone := TdwsJSONObject.Create;
end;

destructor TLibDwsJSON.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibDwsJSON.Add(const aKey, aValue: string);
begin
  fJson.AddValue(aKey, aValue);
end;

function TLibDwsJSON.Count: Integer;
begin
  Result := fJson.ElementCount;
end;

procedure TLibDwsJSON.Save(const aFileName: string);
begin
  TFile.WriteAllText(aFileName, fJson.ToString);
end;

procedure TLibDwsJSON.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibDwsJSON.Load(const aFileName: string);
begin
  fJson.Free;
  fJson := fJson.ParseString(TFile.ReadAllText(aFileName)) as TdwsJSONObject;
end;

function TLibDwsJSON.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.Values[aKey].AsString = aValue);
end;

procedure TLibDwsJSON.Parse;
begin
  fJsonClone.Free;
  fJsonClone := fJson.ParseString(fJson.ToString) as TdwsJSONObject;
end;

function TLibDwsJSON.Check(const aCode: string): Boolean;
var
 jTmp: TdwsJSONValue;
begin
  Result := False;
  try
    jTmp   := fJson.ParseString(aCode);
    Result := Assigned(jTmp);
  finally
    jTmp.Free;
  end;
end;

function TLibDwsJSON.ToString: string;
begin
  Result := fJson.ToString;
end;

function TLibDwsJSON.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('dwsJSON', TLibDwsJSON);
end.
