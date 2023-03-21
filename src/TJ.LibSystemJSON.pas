unit TJ.LibSystemJSON;

interface

uses
  System.Classes, System.IOUtils,
  TJ.Lib,
  System.JSON;

type
  
  TLibSystemJSON = class (TInterfacedObject, ILib)
  public
    constructor Create;
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
    fJson, fJsonClone: TJSONObject;
    function fGetName: string;
  end;

implementation

constructor TLibSystemJSON.Create;
begin
  inherited Create;
  fName := 'System.JSON';
  fJson      := TJSONObject.Create;
  fJsonClone := TJSONObject.Create;
end;

destructor TLibSystemJSON.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibSystemJSON.Add(const aKey, aValue: string);
begin
  fJson.AddPair(aKey, aValue);
end;

function TLibSystemJSON.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibSystemJSON.Save(const aFileName: string);
begin
  TFile.WriteAllText(aFileName, fJson.ToJSON);
end;

procedure TLibSystemJSON.Clear;
begin
  fJson.Free;
  fJsonClone.Free;
  fJson      := TJSONObject.Create;
  fJsonClone := TJSONObject.Create;
end;

procedure TLibSystemJSON.Load(const aFileName: string);
begin
  fJson.Free;
  fJson := fJson.ParseJSONValue(TFile.ReadAllText(aFileName)) as TJSONObject;
end;

function TLibSystemJSON.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.GetValue(aKey).Value = aValue);
end;

procedure TLibSystemJSON.Parse;
begin
  fJsonClone.Free;
  fJsonClone := fJson.ParseJSONValue(fJson.ToJSON) as TJSONObject;
end;

function TLibSystemJSON.Check(const aCode: string): Boolean;
var
 jTmp: TJSONValue;
begin
  Result := False;
  try
    jTmp   := fJson.ParseJSONValue(aCode);
    Result := Assigned(jTmp);
  finally
    jTmp.Free;
  end;
end;

function TLibSystemJSON.ToString: string;
begin
  Result := fJson.ToJSON;
end;

function TLibSystemJSON.fGetName: string;
begin
  Result := fName;
end;

end.
