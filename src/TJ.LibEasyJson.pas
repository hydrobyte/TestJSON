unit TJ.LibEasyJson;

interface

uses
  System.Classes,
  TJ.Lib,
  EasyJson;

type

  TLibEasyJson = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TEasyJson;
    function fGetName: string;
  end;

implementation

procedure TLibEasyJson.AfterConstruction;
begin
  inherited;
  fName := 'EasyJson';
  fJson      := TEasyJson.Create;
  fJsonClone := TEasyJson.Create;
end;

destructor TLibEasyJson.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibEasyJson.Add(const aKey, aValue: string);
begin
  fJson.Add(aKey, aValue);
end;

function TLibEasyJson.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibEasyJson.Save(const aFileName: string);
begin
  fJson.SaveToFile(aFileName);
end;

procedure TLibEasyJson.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibEasyJson.Load(const aFileName: string);
begin
  fJson.LoadFromFile(aFileName);
end;

function TLibEasyJson.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.Items[aKey].AsString = aValue);
end;

procedure TLibEasyJson.Parse;
begin
  fJsonClone.Free;
  fJsonClone := TEasyJson.Create(fJson.ToString);
end;

function TLibEasyJson.Check(const aCode: string): Boolean;
var
  jTmp: TEasyJson;
begin
  Result := False;
  try
    jTmp := TEasyJson.Create(aCode);
    Result := ( Assigned(jTmp) and (jTmp.Count > 0) );
  finally
    jTmp.Free;
  end;
end;

function TLibEasyJson.ToString: string;
begin
  Result := fJson.ToString();
end;

function TLibEasyJson.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('EasyJson', TLibEasyJson);
end.
