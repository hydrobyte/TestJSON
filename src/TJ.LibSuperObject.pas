unit TJ.LibSuperObject;

interface

uses
  System.Classes, System.IOUtils,
  TJ.Lib,
  SuperObject;

type
  
  TLibSuperObject = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: ISuperObject;
    function fGetName: string;
  end;

implementation

procedure TLibSuperObject.AfterConstruction;
begin
  inherited;
  fName := 'SuperObject';
  fJson      := SO;
  fJsonClone := SO;
//  fJson      := TSuperObject.Create;
//  fJsonClone := TSuperObject.Create;
end;

destructor TLibSuperObject.Destroy;
begin
//  fJson.Free;
//  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibSuperObject.Add(const aKey, aValue: string);
begin
  fJson.S[aKey] := aValue;
end;

function TLibSuperObject.Count: Integer;
begin
  Result := fJson.AsObject.count;
end;

procedure TLibSuperObject.Save(const aFileName: string);
begin
  fJson.SaveTo(aFileName);
end;

procedure TLibSuperObject.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibSuperObject.Load(const aFileName: string);
begin
//  fJson.ParseFile(aFileName,true);
  fJson := SO(TFile.ReadAllText(aFileName));
end;

function TLibSuperObject.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.S[aKey] = aValue);
end;

procedure TLibSuperObject.Parse;
begin
//  fJsonClone.ParseString(PChar(fJson.AsJSon), True);
  fJsonClone := SO(fJson.AsJSON);
end;

function TLibSuperObject.Check(const aCode: string): Boolean;
begin
  Result := Assigned(TSuperObject.ParseString(PChar(aCode), True));
//  Result := fJson.Validate( Check(aCode);
end;

function TLibSuperObject.ToString: string;
begin
  Result := fJson.AsJSon;
end;

function TLibSuperObject.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('SuperObject', TLibSuperObject);
end.
