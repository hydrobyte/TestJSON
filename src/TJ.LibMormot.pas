unit TJ.LibMormot;

interface

uses
  System.Classes, System.IOUtils,
  TJ.Lib,
  mormot.core.variants,
  mormot.core.text;

type
  
  TLibMormotJson = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: Variant;
    function fGetName: string;
  end;

implementation

procedure TLibMormotJson.AfterConstruction;
begin
  inherited;
  fName := 'mORMot JSON';
  fJson      := _Json('');
  fJsonClone := _Json('');
end;

destructor TLibMormotJson.Destroy;
begin
  inherited Destroy;
end;

procedure TLibMormotJson.Add(const aKey, aValue: string);
begin
  //TDocVariantData(fJson)[aKey] := aValue;     // slow
  TDocVariantData(fJson).AddValue(aKey,aValue); // fast
end;

function TLibMormotJson.Count: Integer;
begin
  Result := fJson._Count;
end;

procedure TLibMormotJson.Save(const aFileName: string);
begin
  TDocVariantData(fJson).SaveToJsonFile(aFileName);
end;

procedure TLibMormotJson.Clear;
begin
  TDocVariantData(fJson).Clear;
  TDocVariantData(fJsonClone).Clear;
end;

procedure TLibMormotJson.Load(const aFileName: string);
begin
   fJson := _Json(TFile.ReadAllText(aFileName));
end;

function TLibMormotJson.Find(const aKey, aValue: string): Boolean;
begin
  Result := (TDocVariantData(fJson)[aKey] = aValue);
end;

procedure TLibMormotJson.Parse;
begin
  fJsonClone := _Json(TDocVariantData(fJson).ToJson);
end;

function TLibMormotJson.Check(const aCode: string): Boolean;
var
 jTmp: Variant;
begin
  Result := False;
  try
    jTmp := _Json(aCode);
    Result := (jTmp._Count > 0);
  finally
    ;
  end;
end;

function TLibMormotJson.ToString: string;
begin
  Result := fJson.AsJSON;
end;

function TLibMormotJson.fGetName: string;
begin
  Result := fName;
end;

initialization
  RegisterTJLib('mORMot JSON', TLibMormotJson);
end.
