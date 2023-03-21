unit TJ.LibXSuperObject;

interface

uses
  System.Classes, System.IOUtils,
  TJ.Lib,
  XSuperObject;

type
  
  TLibXSuperObject = class (TInterfacedObject, ILib)
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
  protected
    fName: string;
    fJson, fJsonClone: ISuperObject;
    function fGetName: string;
  end;

implementation

constructor TLibXSuperObject.Create;
begin
  inherited Create;
  fName := 'X-SuperObject';
  fJson      := SO;
  fJsonClone := SO;
end;

destructor TLibXSuperObject.Destroy;
begin
//  fJson.Free;
//  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibXSuperObject.Add(const aKey, aValue: string);
begin
  fJson.S[aKey] := aValue;
end;

function TLibXSuperObject.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibXSuperObject.Save(const aFileName: string);
begin
  fJson.SaveTo(aFileName);
end;

procedure TLibXSuperObject.Clear;
begin
  fJson      := SO;
  fJsonClone := SO;
end;

procedure TLibXSuperObject.Load(const aFileName: string);
begin
  fJson := SO(TFile.ReadAllText(aFileName));
end;

function TLibXSuperObject.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.S[aKey] = aValue);
end;

procedure TLibXSuperObject.Parse;
begin
  fJsonClone := SO(fJson.AsJSON);
end;

function TLibXSuperObject.Check(const aCode: string): Boolean;
begin
  Result := fJson.Check(aCode);
end;

function TLibXSuperObject.fGetName: string;
begin
  Result := fName;
end;

end.
