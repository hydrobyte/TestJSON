unit TJ.LibJsonTools;

interface

uses
  System.Classes,
  TJ.Lib,
  JsonTools;

type
  
  TLibJsonTools = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TJsonNode;
    function fGetName: string;
  end;

implementation

procedure TLibJsonTools.AfterConstruction;
begin
  inherited;
  fName := 'JsonTools';
  fJson      := TJsonNode.Create;
  fJsonClone := TJsonNode.Create;
end;

destructor TLibJsonTools.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibJsonTools.Add(const aKey, aValue: string);
begin
  fJson.Add(aKey).AsString := aValue;
end;

function TLibJsonTools.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibJsonTools.Save(const aFileName: string);
begin
  fJson.SaveToFile(aFileName);
end;

procedure TLibJsonTools.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibJsonTools.Load(const aFileName: string);
begin
  fJson.LoadFromFile(aFileName);
end;

function TLibJsonTools.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.Child(aKey).AsString = aValue);
end;

procedure TLibJsonTools.Parse;
begin
  fJsonClone.AsJSON := fJson.AsJSON;
end;

function TLibJsonTools.Check(const aCode: string): Boolean;
begin
  Result := fJson.TryParse(aCode);
end;

function TLibJsonTools.ToString: string;
begin
  Result := fJson.AsJSON;
end;

function TLibJsonTools.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('JsonTools', TLibJsonTools);
end.
