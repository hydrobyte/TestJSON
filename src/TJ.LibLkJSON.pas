unit TJ.LibLkJSON;

interface

uses
  System.Classes,
  TJ.Lib,
  uLkJSON;

type
  
  TLibLkJSON = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TlkJSONobject;
    function fGetName: string;
  end;

implementation

constructor TLibLkJSON.Create;
begin
  inherited Create;
  fName := 'uLkJSON';
  fJson := TlkJSONobject.Create;
end;

destructor TLibLkJSON.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibLkJSON.Add(const aKey, aValue: string);
begin
  fJson.Add(aKey, aValue);
end;

function TLibLkJSON.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibLkJSON.Save(const aFileName: string);
begin
  TlkJSONstreamed.SaveToFile(fJson, aFileName);
end;

procedure TLibLkJSON.Clear;
begin
  fJson.Free;
  fJsonClone.Free;
  fJson      := TlkJSONobject.Create;
  fJsonClone := TlkJSONobject.Create;
end;

procedure TLibLkJSON.Load(const aFileName: string);
begin
  fJson.Free;
  fJson := TlkJSONstreamed.LoadFromFile(aFileName) as TlkJSONobject;
end;

function TLibLkJSON.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.Field[aKey].Value = aValue);
end;

procedure TLibLkJSON.Parse;
begin
  fJsonClone.Free;
  fJsonClone := TlkJSON.ParseText(TlkJSON.GenerateText(fJson)) as TlkJSONobject;
end;

function TLibLkJSON.Check(const aCode: string): Boolean;
var
  jTmp: TlkJSONbase;
begin
  Result := False;
  try
    jTmp   := TlkJSON.ParseText(aCode);
    Result := Assigned(jTmp);
  finally
    jTmp.Free;
  end;
end;

function TLibLkJSON.ToString: string;
begin
  Result := TlkJSON.GenerateText(fJson);
end;

function TLibLkJSON.fGetName: string;
begin
  Result := fName;
end;

end.
