unit TJ.LibVSoftYAML;

interface

uses
  System.Classes,
  TJ.Lib,
  VSoft.YAML;

type
  TLibVSoftYAML = class (TInterfacedObject, ILib)
  public
    procedure AfterConstruction; override;
    destructor  Destroy; override;
    procedure Add(const aKey, aValue: string);overload;
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
    FYAML: IYAMLDocument;
    function fGetName: string;
  end;


implementation

uses
  System.IOUtils,
  System.SysUtils;

{ TLibVSoftYAML }

procedure TLibVSoftYAML.Add(const aKey, aValue: string);
begin
  FYAML.AsMapping.AddOrSetValue(aKey, aValue);
end;

procedure TLibVSoftYAML.AfterConstruction;
begin
  inherited;
  fName := 'VSoft.YAML';
  TYAML.DefaultParserOptions.DuplicateKeyBehavior := TYAMLDuplicateKeyBehavior.dkError;
  TYAML.DefaultParserOptions.JSONMode := true;

  TYAML.DefaultWriterOptions.PrettyPrint := false;
  TYAML.DefaultWriterOptions.Encoding := TEncoding.UTF8;

  FYAML      := TYAML.CreateMapping;
end;

function TLibVSoftYAML.Check(const aCode: string): Boolean;
var
  tmpDoc : IYAMLDocument;
begin
  Result := true;
  tmpDoc   := TYAML.LoadFromString(aCode);
end;

procedure TLibVSoftYAML.Clear;
begin
  FYAML.Root.AsMapping.Clear;
end;

function TLibVSoftYAML.Count: Integer;
begin
  result := FYAML.AsMapping.Count;
end;

destructor TLibVSoftYAML.Destroy;
begin
  FYAML := nil;
  inherited;
end;

function TLibVSoftYAML.fGetName: string;
begin
  result := fName;
end;

function TLibVSoftYAML.Find(const aKey, aValue: string): Boolean;
begin
   Result := FYAML.AsMapping.S[aKey] = aValue;
end;

procedure TLibVSoftYAML.Load(const aFileName: string);
begin
  FYAML := TYAML.LoadFromFile(aFileName);
//  FYAML := TYAML.LoadFromString(TFile.ReadAllText(aFileName)).AsMapping;
end;


procedure TLibVSoftYAML.Parse;
var
  tmpDoc : IYAMLDocument;
begin
  tmpDoc := TYAML.LoadFromString(TYAML.WriteToJSONString(FYAML));
end;

procedure TLibVSoftYAML.Save(const aFileName: string);
begin
//  TYAML.DefaultWriterOptions.Encoding := TEncoding.UTF8;
  TYAML.WriteToJSONFile(FYAML, aFileName);
//  TFile.WriteAllText(aFileName, TYAML.WriteToJSONString(FYAML), TEncoding.UTF8);
//  TFile.WriteAllBytes(aFileName, TEncoding.UTF8.GetBytes(TYAML.WriteToJSONString(FYAML)));
end;

function TLibVSoftYAML.ToString: string;
begin
  FYAML.Options.PrettyPrint := false;
  result := TYAML.WriteToJSONString(FYAML);
end;

initialization
  RegisterTJLib('VSoft.YAML', TLibVSoftYAML);

end.
