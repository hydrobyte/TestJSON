program PrjTestJsonDX121;

uses
  Vcl.Forms,
  FoMainDx in '..\src\FoMainDx.pas' {FormMain},
  Mc.Param in '..\src\Mc.Param.pas',
  TJ.Test in '..\src\TJ.Test.pas',
  TJ.TestSpeedRun in '..\src\TJ.TestSpeedRun.pas',
  TJ.TestValid in '..\src\TJ.TestValid.pas',
  TJ.TestFOpen in '..\src\TJ.TestFOpen.pas',
  TJ.Lib in '..\src\TJ.Lib.pas',
  TJ.LibMcJSON in '..\src\TJ.LibMcJSON.pas',
  TJ.LibLkJSON in '..\src\TJ.LibLkJSON.pas',
  TJ.LibSystemJSON in '..\src\TJ.LibSystemJSON.pas',
  TJ.LibJDO in '..\src\TJ.LibJDO.pas',
  TJ.LibSuperObject in '..\src\TJ.LibSuperObject.pas',
  TJ.LibXSuperObject in '..\src\TJ.LibXSuperObject.pas',
  TJ.LibJsonTools in '..\src\TJ.LibJsonTools.pas',
  TJ.LibJson4Delphi in '..\src\TJ.LibJson4Delphi.pas',
  TJ.LibGrijjyBson in '..\src\TJ.LibGrijjyBson.pas',
  TJ.LibNeslibJson in '..\src\TJ.LibNeslibJson.pas',
  TJ.LibDwsJSON in '..\src\TJ.LibDwsJSON.pas',
  TJ.LibChimeraJson in '..\src\TJ.LibChimeraJson.pas',
  TJ.LibDynamicDataObjects in '..\src\TJ.LibDynamicDataObjects.pas',
  TJ.LibEasyJson in '..\src\TJ.LibEasyJson.pas',
  TJ.LibJsonDoc in '..\src\TJ.LibJsonDoc.pas',
  McJSON in '..\src\pas\McJSON.pas',
  McUtils in '..\src\pas\McUtils.pas',
  uLkJSON in '..\src\pas\uLkJSON.pas',
  JsonDataObjects in '..\src\pas\JsonDataObjects.pas',
  superobject in '..\src\pas\superobject\superobject.pas',
  XSuperObject in '..\src\pas\XSuperObject\XSuperObject.pas',
  JsonTools in '..\src\pas\JsonTools.pas',
  Jsons in '..\src\pas\Json4Delphi\Jsons.pas',
  Grijjy.Bson in '..\src\pas\Grijjy\Grijjy.Bson.pas',
  Neslib.Json in '..\src\pas\Neslib\Neslib.Json.pas',
  dwsJSON in '..\src\pas\DWScript\dwsJSON.pas',
  chimera.json in '..\src\pas\chimera\chimera.json.pas',
  DataObjects2 in '..\src\pas\DynamicDataObjects\DataObjects2.pas',
  DataObjects2JSON in '..\src\pas\DynamicDataObjects\DataObjects2JSON.pas',
  EasyJson in '..\src\pas\EasyJson.pas',
  jsonDoc in '..\src\pas\jsonDoc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
