unit TJ.LibQDAC;

interface

uses
  System.Classes,
  TJ.Lib,
  qjson;

type
  
  TLibQDAC = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TQJson;
    function fGetName: string;
  end;

implementation

procedure TLibQDAC.AfterConstruction;
begin
  inherited AfterConstruction;
  fName := 'QDAC';
  fJson      := TQJson.Create;
  fJsonClone := TQJson.Create;
end;

destructor TLibQDAC.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibQDAC.Add(const aKey, aValue: string);
begin
  fJson.Add(aKey).AsString := aValue;
end;

function TLibQDAC.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibQDAC.Save(const aFileName: string);
begin
  fJson.SaveToFile(aFileName);
end;

procedure TLibQDAC.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibQDAC.Load(const aFileName: string);
begin
  fJson.LoadFromFile(aFileName);
end;

function TLibQDAC.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.ValueByName(aKey, 'notfound') = aValue);
end;

procedure TLibQDAC.Parse;
begin
  fJsonClone.AsJSON := fJson.AsJSON;
end;

function TLibQDAC.Check(const aCode: string): Boolean;
begin
  Result := fJson.TryParse(aCode);
end;

function TLibQDAC.ToString: string;
begin
  Result := fJson.AsJson;
end;

function TLibQDAC.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('QDAC', TLibQDAC);
end.
