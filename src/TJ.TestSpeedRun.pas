unit TJ.TestSpeedRun;

interface

uses
  System.Classes, System.SysUtils,
  TJ.Test,
  TJ.Lib;

type

  TSubTestType = (stGene = 0, stSave  = 1, stParse = 2, stClear = 3, stLoad = 4,
                  stFind = 5, stTotal = 6);

  TTestSpeedRun = class (TTest)
  protected
    fIsGenOn, fIsSaveOn, fIsClearOn, fIsLoadOn, fIsFindOn, fIsParseOn : Boolean;
    fCountGen, fCountFind: Integer;
    fSaveFileName: string;
    fLoadFileName: string;

    fStat: array[0..Integer(stTotal)] of Real;

  private
    procedure DoTest;
    procedure DoSubTestGen  ;
    procedure DoSubTestSave ;
    procedure DoSubTestClear;
    procedure DoSubTestLoad ;
    procedure DoSubTestFind ;
    procedure DoSubTestParse;

    procedure DoStat;
    procedure InitStat;
    function  CalcAvg(const SPrfx: string; aType: TSubTestType): string;
    procedure UpdateStat(aSTType: TSubTestType; aValue: Real);

  public
    property IsGenOn     : Boolean read fIsGenOn      write fIsGenOn     ;
    property IsSaveOn    : Boolean read fIsSaveOn     write fIsSaveOn    ;
    property IsClearOn   : Boolean read fIsClearOn    write fIsClearOn   ;
    property IsLoadOn    : Boolean read fIsLoadOn     write fIsLoadOn    ;
    property IsFindOn    : Boolean read fIsFindOn     write fIsFindOn    ;
    property IsParseOn   : Boolean read fIsParseOn    write fIsParseOn   ;
    property CountGen    : Integer read fCountGen     write fCountGen    ;
    property CountFind   : Integer read fCountFind    write fCountFind   ;
    property SaveFileName: string  read fSaveFileName write fSaveFileName;
    property LoadFileName: string  read fLoadFileName write fLoadFileName;

    constructor Create(aLib: ILib; aMyLog: TMyLog); override;
    procedure Start ; override;
    procedure Run   ; override;
    procedure Finish; override;

  end;

implementation

procedure TTestSpeedRun.DoTest;
begin
  try
    if (fIsGenOn  ) then DoSubTestGen  ;
    if (fIsSaveOn ) then DoSubTestSave ;
    if (fIsClearOn) then DoSubTestClear;
    if (fIsLoadOn ) then DoSubTestLoad ;
    if (fIsFindOn ) then DoSubTestFind ;
    if (fIsParseOn) then DoSubTestParse;
  except on e: Exception do
    fMyLog(true, '  Subtest exception: ' + e.Message);
  end;
end;

procedure TTestSpeedRun.DoSubTestGen;
var
  i, Count: Integer;
  SKey, SVal: string;
begin
  fMyLog(fVerbose, 'Generating ' + IntToStr(fCountGen) + ' items...');
  for i := 1 to fCountGen do
  begin
    SKey := 'key'   + IntToStr(i);
    SVal := 'value' + IntToStr(i);
    fLib.Add(SKey, SVal);
  end;
  Count := fLib.Count;
  fMyLog(fVerbose, '  Done ' + IntToStr(Count) + ' items: ' + GetMemAlcStr);
  UpdateStat(stGene, TestClock.DeltaLast);
end;

procedure TTestSpeedRun.DoSubTestSave;
begin
  fMyLog(fVerbose, 'Saving to file ' + IntToStr(fLib.Count) + ' items...');
  fLib.Save(fSaveFileName);
  fMyLog(fVerbose, '  Done: '  + GetMemAlcStr);
  UpdateStat(stSave, TestClock.DeltaLast);
end;

procedure TTestSpeedRun.DoSubTestClear;
begin
  fMyLog(fVerbose, 'Cleaning ' + IntToStr(fLib.Count) + ' items...');
  fLib.Clear;
  fMyLog(fVerbose, '  Done: '  + GetMemAlcStr);
  UpdateStat(stClear, TestClock.DeltaLast);
end;

procedure TTestSpeedRun.DoSubTestLoad;
var
  Count: Integer;
begin
  fMyLog(fVerbose, 'Loading from file "' + fLoadFileName + '" ...');
  fLib.Load(fSaveFileName);
  Count := fLib.Count;
  fMyLog(fVerbose, '  Done ' + IntToStr(Count) + ' items: ' + GetMemAlcStr);
  UpdateStat(stLoad, TestClock.DeltaLast);
end;

procedure TTestSpeedRun.DoSubTestFind;
var
  i, Id: Integer;
  sKey, sVal: string;
  isOK: Boolean;
begin
  isOK := True;
  // number of items to find
  fMyLog(fVerbose, 'Finding ' + IntToStr(fCountFind) + ' items...');
  for i :=0 to fCountFind-1 do
  begin
    Id   := Random(fCountGen) + 1;
    sKey := 'key'   + IntToStr(Id);
    sVal := 'value' + IntToStr(Id);
    isOK := isOK and fLib.Find(sKey, sVal);
  end;
  if (isOK) then fMyLog(fVerbose, '  Done all found: '     + GetMemAlcStr())
  else           fMyLog(fVerbose, '  Done NOT all found: ' + GetMemAlcStr());
  UpdateStat(stFind, TestClock.DeltaLast);
end;

procedure TTestSpeedRun.DoSubTestParse;
begin
  fMyLog(fVerbose, 'Clone/Parsing ' + IntToStr(fLib.Count) + ' items...');
  fLib.Parse;
  fMyLog(fVerbose, '  Done: ' + GetMemAlcStr);
  UpdateStat(stParse, TestClock.DeltaLast);
end;

procedure TTestSpeedRun.DoStat;
begin
  fMyLog(true, '');
  fMyLog(true, 'Speed Statistics for ' + fLib.Name);
  fMyLog(true, 'Average of ' + IntToStr(fCountRepeat) + ' repetitions (in ms)');

  if (fIsGenOn  ) then fMyLog(true, CalcAvg('  Generate', stGene ));
  if (fIsSaveOn ) then fMyLog(true, CalcAvg('  Save    ', stSave ));
  if (fIsClearOn) then fMyLog(true, CalcAvg('  Clear   ', stClear));
  if (fIsLoadOn ) then fMyLog(true, CalcAvg('  Load    ', stLoad ));
  if (fIsFindOn ) then fMyLog(true, CalcAvg('  Find    ', stFind ));
  if (fIsParseOn) then fMyLog(true, CalcAvg('  Parse   ', stParse));
  if (True      ) then fMyLog(true, CalcAvg('  Total   ', stTotal));
end;

procedure TTestSpeedRun.InitStat;
var
  i: Integer;
begin
  for i := 0 to Integer(stTotal) do
    fStat[i] := 0.0;
end;

function TTestSpeedRun.CalcAvg(const SPrfx: string; aType: TSubTestType): string;
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

procedure TTestSpeedRun.UpdateStat(aSTType: TSubTestType; aValue: Real);
var
  i: Integer;
begin
  i := Integer(aSTType);
  fStat[i] := fStat[i] + aValue;
end;

//------------------------------------------------------------------------------
// Public
//------------------------------------------------------------------------------

constructor TTestSpeedRun.Create(aLib: ILib; aMyLog: TMyLog);
begin
  inherited Create(aLib, aMyLog);
  fName := 'Speed Run';
end;

procedure TTestSpeedRun.Start;
begin
  inherited;
  // same random seed for all tests
  RandSeed := 1010;
end;

procedure TTestSpeedRun.Run;
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
    fMyLog(true, 'Memory: ' + GetMemAlcStr);
    DoTest();
    Finish;
  end;
  UpdateStat(stTotal, TestClock.DeltaTotal);
  DoStat;
  fMyLog(true, '');
  fMyLog(true, 'All done: '+ GetMemAlcStr);
end;

procedure TTestSpeedRun.Finish;
begin
  fMyLog(true, 'Cleaning library objects...');
  fLib.Clear;
  fMyLog(true, '  Done: ' + GetMemAlcStr);
  inherited;
end;

end.
