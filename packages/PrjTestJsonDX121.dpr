program PrjTestJsonDX121;

uses
  Vcl.Forms,
  FoMainDx in '..\src\FoMainDx.pas' {FormMain},
  JsonDataObjects in '..\src\pas\JsonDataObjects.pas',
  JsonTools in '..\src\pas\JsonTools.pas',
  McJSON in '..\src\pas\McJSON.pas',
  McUtils in '..\src\pas\McUtils.pas',
  uLkJSON in '..\src\pas\uLkJSON.pas',
  Mc.Param in '..\src\Mc.Param.pas',
  TJ.TestSpeedRun in '..\src\TJ.TestSpeedRun.pas',
  TJ.Test in '..\src\TJ.Test.pas',
  TJ.LibMcJSON in '..\src\TJ.LibMcJSON.pas',
  TJ.LibLkJSON in '..\src\TJ.LibLkJSON.pas',
  TJ.TestValid in '..\src\TJ.TestValid.pas',
  TJ.LibSystemJSON in '..\src\TJ.LibSystemJSON.pas',
  TJ.LibSuperObject in '..\src\TJ.LibSuperObject.pas',
  TJ.LibXSuperObject in '..\src\TJ.LibXSuperObject.pas',
  TJ.LibJsonTools in '..\src\TJ.LibJsonTools.pas',
  TJ.LibJson4Delphi in '..\src\TJ.LibJson4Delphi.pas',
  TJ.TestFOpen in '..\src\TJ.TestFOpen.pas',
  TJ.Lib in '..\src\TJ.Lib.pas',
  TJ.LibJDO in '..\src\TJ.LibJDO.pas',
  TJ.LibGrijjyBson in '..\src\TJ.LibGrijjyBson.pas',
  TJ.LibNeslibJson in '..\src\TJ.LibNeslibJson.pas',
  TJ.LibDwsJSON in '..\src\TJ.LibDwsJSON.pas',
  TJ.LibChimeraJson in '..\src\TJ.LibChimeraJson.pas',
  TJ.LibDynamicDataObjects in '..\src\TJ.LibDynamicDataObjects.pas',
  EasyJson in '..\src\pas\EasyJson.pas',
  TJ.LibEasyJson in '..\src\TJ.LibEasyJson.pas',
  DataObjects2 in '..\src\pas\DynamicDataObjects\DataObjects2.pas',
  DataObjects2JSON in '..\src\pas\DynamicDataObjects\DataObjects2JSON.pas',
  dwsJSON in '..\src\pas\DWScript\dwsJSON.pas',
  chimera.json in '..\src\pas\chimera\chimera.json.pas',
  Grijjy.Bson in '..\src\pas\Grijjy\Grijjy.Bson.pas',
  Neslib.Json in '..\src\pas\Neslib\Neslib.Json.pas',
  superobject in '..\src\pas\superobject\superobject.pas',
  XSuperObject in '..\src\pas\XSuperObject\XSuperObject.pas',
  Jsons in '..\src\pas\Json4Delphi\Jsons.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
