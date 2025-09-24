unit TJ.TestFOpen;

interface

uses
  System.Classes, System.SysUtils, System.IOUtils, System.Types,
  TJ.Test,
  TJ.Lib;

type

  TSubTestOpenType = (stoMemory = 0, stoLoadTime  = 1, stoTotal = 2);
  
  TTestFOpen = class (TTest)
  protected
    fPathFile: string;
    fStat: array[0..Integer(stoTotal)] of Real;
    function IsOKToGo: Boolean; override;

  private
    procedure DoTest(const aPathFile: string);

    procedure DoStat;
    procedure InitStat;
    function  CalcAvg(const SPrfx: string; aType: TSubTestOpenType): string;
    procedure UpdateStat(aSTType: TSubTestOpenType; aValue: Real);

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
  MemIni, MemDiff: Real;
begin
  try
    try
      MemIni := GetMemAlcRealInKib;
      // Load file.
      fMyLog(fVerbose, 'Memory: ' + GetMemAlcStr);
      fMyLog(fVerbose, 'Loading from file "' + aPathFile + '" ...');
      fLib.Load(aPathFile);
      CountLoad := fLib.Count;
      UpdateStat(stoLoadTime, TestClock.DeltaLast);
      fMyLog(fVerbose, '  Done ' + IntToStr(CountLoad) + ' items: ' + GetMemAlcStr);
       // Stat load time.
      UpdateStat(stoLoadTime, TestClock.DeltaLast);
      // Stat memory (diff) allocated.
      MemDiff := GetMemAlcRealInKib - MemIni;
      UpdateStat(stoMemory, MemDiff);
      // Show JSON number of chars.
      fMyLog(fVerbose, 'JSON to string here...'  );
      fMyLog(fVerbose, '  '       + fLib.ToString);
      fMyLog(fVerbose, '  Done: ' + GetMemAlcStr );
    except on e: Exception do
      fMyLog(true, '  Open JSON file exception: ' + e.Message);
    end;
  finally
    // Clear.
    fMyLog(fVerbose, 'Clear object...');
    fLib.Clear;
    fMyLog(fVerbose, '  Done: ' + GetMemAlcStr());
  end;
end;

procedure TTestFOpen.DoStat;
begin
  fMyLog(true, '');
  fMyLog(true, 'File Open Statistics for ' + fLib.Name);
  fMyLog(true, 'Average of ' + IntToStr(fCountRepeat) + ' repetitions');

  fMyLog(true, CalcAvg('  Memory', stoMemory  ) + ' kiB');
  fMyLog(true, CalcAvg('  Load  ', stoLoadTime) + ' ms' );
  fMyLog(true, CalcAvg('  Total ', stoTotal   ) + ' ms' );
end;

procedure TTestFOpen.InitStat;
var
  i: Integer;
begin
  for i := 0 to Integer(stoTotal) do
    fStat[i] := 0.0;
end;

function TTestFOpen.CalcAvg(const SPrfx: string; aType: TSubTestOpenType): string;
var
  avg: Real;
  i: Integer;
begin
  // calc avg from test type
  avg := 0.0;
  if (fCountRepeat > 0) then
  begin
    i := Integer(AType);
    avg := fStat[i]/fCountRepeat;
  end;
  // return stat label
  Result := SPrfx + ': ' + Format('%8.2f', [avg]);
end;


procedure TTestFOpen.UpdateStat(aSTType: TSubTestOpenType; aValue: Real);
var
  i: Integer;
begin
  i := Integer(aSTType);
  fStat[i] := fStat[i] + aValue;
end;

//------------------------------------------------------------------------------
// Public
//------------------------------------------------------------------------------

function TTestFOpen.IsOKToGo: Boolean;
begin
  Result := inherited IsOKToGo;
  Result := Result and FileExists(fPathFile);
end;

constructor TTestFOpen.Create(aLib: ILib; aMyLog: TMyLog);
begin
  inherited Create(aLib, aMyLog);
  fName := 'File Open';
end;

procedure TTestFOpen.Header;
begin
  fMyLog(true, 'Starting test');
  fMyLog(true, '  Test   : ' + fName);
  fMyLog(true, '  Library: ' + fLib.Name);
end;

procedure TTestFOpen.Start;
begin
end;

procedure TTestFOpen.Run;
var
  i, NRep: Integer;
begin
  inherited;
  if (not IsOKToGo) then Exit;
  InitStat;
  if (fIsRepeatOn)
    then NRep := fCountRepeat-1
    else NRep := 0;
  for i := 0 to NRep do
  begin
    Start;
    fMyLog(true, '');
    fMyLog(true, 'Test #' + IntToStr(i));
    DoTest(fPathFile);
    Finish;
  end;
  UpdateStat(stoTotal, TestClock.DeltaTotal);
  DoStat;
  fMyLog(true, '');
  fMyLog(true, 'All done: '+ GetMemAlcStr);
end;

procedure TTestFOpen.Finish;
begin
  fMyLog(true, 'Test finished');
end;

end.
