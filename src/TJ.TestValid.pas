unit TJ.TestValid;

interface

uses
  System.Classes, System.SysUtils, System.IOUtils, System.Types,
  TJ.Test,
  TJ.Lib;

type
  
  TTestValid = class (TTest)
  protected
    fIsReportJSON: Boolean;
    fPathFolder: string;
    function IsOKToGo: Boolean; override;
  private
    procedure DoTest(const aFileName: string);
  public
    property PathFolder  : string  read fPathFolder   write fPathFolder  ;
    property IsReportJSON: Boolean read fIsReportJSON write fIsReportJSON;

    constructor Create(aLib: ILib; aMyLog: TMyLog); override;

    procedure Header;
    procedure Start ; override;
    procedure Run   ; override;
    procedure Finish; override;

  end;

implementation

procedure TTestValid.DoTest(const aFileName: string);
var
  StrL: TStringList;
  sComment, sJson, sMsg, sExc: string;
  isOK: Boolean;
  i: Integer;
begin
  StrL := TStringList.Create;
  try
    try
      StrL.LoadFromFile(aFileName);
      sComment := StrL[0];
      sJson    := StrL[1];
      // amend other lines
      for i := 2 to StrL.Count-1 do
        sJson := sJson + #13 + StrL[i];
      isOK := False;
      try
        isOK := fLib.Check(sJson);
      except on e: Exception do
        sExc := e.Message;
      end;
      //[0000/0000]: PASS/FAIL = file00.json = comment = json
      if (isOK)
        then sMsg := 'PASS'
        else sMsg := 'FAIL';
      sMsg := sMsg + ' = ' + ExtractFileName(aFileName);
      sMsg := sMsg + ' = ' + sComment;
      if (IsReportJSON) then
        sMsg := sMsg + ' = ' + sComment;
      if (sExc <> '') then
        sMsg := sMsg + ' = [Exception] = ' + sExc;
      // log
      fMyLog(fVerbose, sMsg);
    except on e: Exception do
      fMyLog(true, '  Validation exception: ' + e.Message);
    end;
  finally
    StrL.Free;
  end;
end;

function TTestValid.IsOKToGo: Boolean;
begin
  Result := inherited IsOKToGo;
  Result := Result and DirectoryExists(fPathFolder);
end;

constructor TTestValid.Create(aLib: ILib; aMyLog: TMyLog);
begin
  inherited Create(aLib, aMyLog);
  fName := 'Validation';
end;

procedure TTestValid.Header;
begin
  fMyLog(true, 'Starting test');
  fMyLog(true, '  Test   : ' + fName);
  fMyLog(true, '  Library: ' + fLib.Name);
end;

procedure TTestValid.Start;
begin
end;

procedure TTestValid.Run;
var
  aFileName: string;
begin
  Start;
  fMyLog(true, '');
  for aFileName in TDirectory.GetFiles(fPathFolder) do
  begin
    DoTest(aFileName);
  end;
  Finish;
end;

procedure TTestValid.Finish;
begin
  fMyLog(true, 'Test finished');
end;

end.
