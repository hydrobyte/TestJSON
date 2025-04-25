unit TJ.LibJsonDoc;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  TJ.Lib,
  jsonDoc;

type

  TLibJsonDoc = class (TInterfacedObject, ILib)
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
    fJson, fJsonClone: IJSONDocument;
    function fGetName: string;
  end;

implementation

constructor TLibJsonDoc.Create;
begin
  inherited Create;
  fName := 'jsonDoc';
  fJson      := JSON;
  fJsonClone := JSON;
end;

destructor TLibJsonDoc.Destroy;
begin
  inherited Destroy;
end;

procedure TLibJsonDoc.Add(const aKey, aValue: string);
begin
  fJson[aKey]:=aValue;
end;

function TLibJsonDoc.Count: Integer;
var
  e:IJSONEnumerator;
begin
  Result:=0;
  e:=JSONEnum(fJson);
  while e.Next do inc(Result);
end;

procedure TLibJsonDoc.Save(const aFileName: string);
var
  e:TEncoding;
begin
  e:=TUTF8Encoding.Create(true);
  try
    TFile.WriteAllText(aFileName,fJson.AsString,e);
  finally
    e.Free;
  end;
end;

procedure TLibJsonDoc.Clear;
begin
  fJson.Clear;
  fJsonClone.Clear;
end;

procedure TLibJsonDoc.Load(const aFileName: string);
begin
  fJson.Parse(TFile.ReadAllText(aFileName));
end;

function TLibJsonDoc.Find(const aKey, aValue: string): Boolean;
begin
  Result := (fJson[aKey] = aValue);
end;

procedure TLibJsonDoc.Parse;
begin
  fJsonClone.Parse(fJson.AsString);
end;

function TLibJsonDoc.Check(const aCode: string): Boolean;
var
  jTmp: IJSONDocument;
begin
  Result := False;
  try
    jTmp   := JSON(aCode);
    Result := True;
  except
    Result := False;
  end;
end;

function TLibJsonDoc.ToString: string;
begin
  Result := fJson.AsString;
end;

function TLibJsonDoc.fGetName: string;
begin
  Result := fName;
end;

end.
