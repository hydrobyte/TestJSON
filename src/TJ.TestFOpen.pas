unit TJ.TestFOpen;

interface

uses
  System.Classes, System.SysUtils, System.IOUtils, System.Types,
  TJ.Test,
  TJ.Lib;

type
  
  TTestFOpen = class (TTest)
  protected
    fPathFile: string;
    function IsOKToGo: Boolean; override;
  private
    procedure DoTest(const aPathFile: string);
  public
    property PathFile: string read fPathFile write fPathFile;

    constructor Create(aLib: ILib; aMyLog: TMyLog); override;

    procedure Header;
    procedure Start ; override;
    procedure Run   ; override;
    procedure Finish; override;

  end;

implementation

procedure TTestFOpen.DoTest(const aPathFile: string);
var
  CountLoad: Integer;
begin
  try
    try
      fMyLog('Memory: ' + GetMemAlc());
      fMyLog('Loading from file "' + aPathFile + '" ...');
      fLib.Load(aPathFile);
      CountLoad := fLib.Count;
      fMyLog('  Done ' + IntToStr(CountLoad) + ' items: ' + GetMemAlc);

      fMyLog('To string it here...');
      fMyLog(fLib.ToString);
      fMyLog('  Done: ' + GetMemAlc());
    except on e: Exception do
      fMyLog('  Open JSON file exception: ' + e.Message);
    end;
  finally
    // free memory
    MyLog('Deleting objects...');
//    DoDeleteMem();
    MyLog('  Done: ' + GetMemAlc());
  end;
end;

function TTestFOpen.IsOKToGo: Boolean;
begin
  Result := inherited IsOKToGo;
  Result := Result and DirectoryExists(fPathFile);
end;

constructor TTestFOpen.Create(aLib: ILib; aMyLog: TMyLog);
begin
  inherited Create(aLib, aMyLog);
  fName := 'File Open';
end;

procedure TTestFOpen.Header;
begin
  fMyLog('Starting test');
  fMyLog('  Test   : ' + fName);
  fMyLog('  Library: ' + fLib.Name);
end;

procedure TTestFOpen.Start;
begin
end;

procedure TTestFOpen.Run;
begin
  Start;
  fMyLog('');
  DoTest(fPathFile);
  Finish;
end;

procedure TTestFOpen.Finish;
begin
  fMyLog('Test finished');
end;

end.
