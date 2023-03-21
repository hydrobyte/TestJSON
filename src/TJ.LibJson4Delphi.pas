unit TJ.LibJson4Delphi;

interface

uses
  System.Classes, System.IOUtils, System.SysUtils,
  TJ.Lib,
  Jsons;

type
  
  TLibJson4Delphi = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: TJson;
    function fGetName: string;
  end;

implementation

constructor TLibJson4Delphi.Create;
begin
  inherited Create;
  fName := 'Json4Delphi';
  fJson      := TJson.Create;
  fJsonClone := TJson.Create;
end;

destructor TLibJson4Delphi.Destroy;
begin
  fJson.Free;
  fJsonClone.Free;
  inherited Destroy;
end;

procedure TLibJson4Delphi.Add(const aKey, aValue: string);
begin
  fJson.Put(aKey, aValue);
end;

function TLibJson4Delphi.Count: Integer;
begin
  Result := fJson.Count;
end;

procedure TLibJson4Delphi.Save(const aFileName: string);
begin
  TFile.WriteAllText(aFileName, fJson.Stringify);
end;

procedure TLibJson4Delphi.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibJson4Delphi.Load(const aFileName: string);
begin
  fJson.Parse(TFile.ReadAllText(aFileName));
end;

function TLibJson4Delphi.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson.Values[aKey].AsString = aValue);
end;

procedure TLibJson4Delphi.Parse;
begin
  fJsonClone.Parse(fJson.Stringify);
end;

function TLibJson4Delphi.Check(const aCode: string): Boolean;
begin
  fJson.Parse(aCode);
  Result := (fJson.Stringify = aCode);
end;

function TLibJson4Delphi.ToString: string;
begin
  Result := fJson.Stringify;
end;

function TLibJson4Delphi.fGetName: string;
begin
  Result := fName;
end;

end.
