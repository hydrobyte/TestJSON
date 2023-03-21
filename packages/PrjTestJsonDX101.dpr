program PrjTestJsonDX101;

uses
  Vcl.Forms,
  FoMainDx in '..\src\FoMainDx.pas' {FormMain},
  JsonDataObjects in '..\src\pas\JsonDataObjects.pas',
  Jsons in '..\src\pas\Jsons.pas',
  JsonTools in '..\src\pas\JsonTools.pas',
  McJSON in '..\src\pas\McJSON.pas',
  McUtils in '..\src\pas\McUtils.pas',
  superobject in '..\src\pas\superobject.pas',
  uLkJSON in '..\src\pas\uLkJSON.pas',
  Mc.Param in '..\src\Mc.Param.pas',
  TJ.TestSpeedRun in '..\src\TJ.TestSpeedRun.pas',
  TJ.Test in '..\src\TJ.Test.pas',
  TJ.LibMcJSON in '..\src\TJ.LibMcJSON.pas',
  TJ.LibLkJSON in '..\src\TJ.LibLkJSON.pas',
  TJ.TestValid in '..\src\TJ.TestValid.pas',
  TJ.LibSystemJSON in '..\src\TJ.LibSystemJSON.pas',
  TJ.LibSuperObject in '..\src\TJ.LibSuperObject.pas',
  XSuperObject in '..\src\pas\XSuperObject.pas',
  TJ.LibXSuperObject in '..\src\TJ.LibXSuperObject.pas',
  TJ.LibJsonTools in '..\src\TJ.LibJsonTools.pas',
  TJ.LibJson4Delphi in '..\src\TJ.LibJson4Delphi.pas',
  TJ.TestFOpen in '..\src\TJ.TestFOpen.pas',
  TJ.Lib in '..\src\TJ.Lib.pas',
  TJ.LibJDO in '..\src\TJ.LibJDO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
