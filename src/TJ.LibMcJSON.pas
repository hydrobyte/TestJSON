unit TJ.LibMcJSON;

interface

uses
  System.Classes,
  TJ.Lib,
  McJSON;

type
  
  TLibMcJSON = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TMcJsonItem;
    function fGetName: string;
  end;

implementation

constructor TLibMcJSON.Create;
begin
  inherited Create;
  fName := 'McJSON';
  fJson      := TMcJsonItem.Create;
  fJsonClone := TMcJsonItem.Create;
end;

destructor TLibMcJSON.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibMcJSON.Add(const aKey, aValue: string);
begin
  fJson.Add(aKey).AsString := aValue;
end;

function TLibMcJSON.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibMcJSON.Save(const aFileName: string);
begin
  fJson.SaveToFile(aFileName);
end;

procedure TLibMcJSON.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibMcJSON.Load(const aFileName: string);
begin
  fJson.LoadFromFile(aFileName);
end;

function TLibMcJSON.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.Values[aKey].AsString = aValue);
end;

procedure TLibMcJSON.Parse;
begin
  fJsonClone.AsJSON := fJson.AsJSON;
end;

function TLibMcJSON.Check(const aCode: string): Boolean;
begin
  Result := fJson.Check(aCode);
end;

function TLibMcJSON.ToString: string;
begin
  Result := fJson.ToString(False);
end;

function TLibMcJSON.fGetName: string;
begin
  Result := fName;
end;

end.
