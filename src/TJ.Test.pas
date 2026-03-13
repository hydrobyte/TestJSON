unit TJ.Test;

interface

uses
  Winapi.Windows,
  System.Classes, System.SysUtils,
  TJ.Lib,
  McUtils;

type
  TTestType = (ttSpeedRun, ttValidation, ttFileOpen);

  TMyLog = procedure(IsON: Boolean; const S: string) of object;

  TTest = class
  protected
    fName         : string ;
    fLib          : ILib   ;
    fCountRepeat  : Integer;
    fIsRepeatOn,
    fVerbose      : Boolean;
    fMyLog        : TMyLog ;

    function IsOKToGo: Boolean; virtual;

  public
    property Name       : string  read fName;
    property Lib        : ILib    read fLib;
    property CountRepeat: Integer read fCountRepeat write fCountRepeat;
    property IsRepeatOn : Boolean read fIsRepeatOn  write fIsRepeatOn;
    property Verbose    : Boolean read fVerbose     write fVerbose;
    property MyLog      : TMyLog  read fMyLog;

    constructor Create(aLib: ILib; aMyLog: TMyLog); virtual;

    procedure Header;
    procedure Start ; virtual; abstract;
    procedure Run   ; virtual; abstract;
    procedure Finish; virtual;

    function GetMemAlcStr: string;
    function GetMemAlcRealInKib: Real;

  end;

  TTestFactory = class
    class function CreateTest(aType: TTestType; aLib: ILib; aMyLog: TMyLog): TTest;
  end;

  TTestList = class
  private
    fList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(aItem: TObject);
  end;

  TTestClock = class
  protected
    fStartTick, fLastTick,
    fDeltaLast, fDeltaTotal: Cardinal;
  public
    property StartTick : Cardinal read fStartTick ;
    property LastTick  : Cardinal read fLastTick  ;
    property DeltaLast : Cardinal read fDeltaLast ;
    property DeltaTotal: Cardinal read fDeltaTotal;
    procedure Start;
    procedure Now;
  end;

var
  TestClock: TTestClock;

implementation

uses
  TJ.TestSpeedRun, TJ.TestValid, TJ.TestFOpen;

function TTest.IsOKToGo: Boolean;
begin
  Result := Assigned(fLib);
end;

constructor TTest.Create(aLib: ILib; aMyLog: TMyLog);
begin
  fLib   := aLib;
  fMyLog := aMyLog;
  fIsRepeatOn := false;
  fVerbose    := false;
end;

procedure TTest.Header;
begin
  fMyLog(true, 'Starting test');
  fMyLog(true, '  Test   : ' + fName);
  fMyLog(true, '  Library: ' + fLib.Name);
end;

procedure TTest.Finish;
begin
  fMyLog(true, 'Test finished');
end;

function TTest.GetMemAlcStr: string;
var
  k, M, G: Integer;
  Mem: Real;
begin
  Result := '';
  k := 1024;
  M := 1024*1024;
  G := 1024*1024*1024;
  // calc memory allocated by memory manager
  Mem := GetFastMMAllocated;
  // return memory alloc label
  if      (Mem < k) then Result := Format('%.0f', [Mem  ]) + ' Bytes'
  else if (Mem < M) then Result := Format('%.2f', [Mem/k]) + ' kiB'
  else if (Mem < G) then Result := Format('%.2f', [Mem/M]) + ' MiB'
  else                   Result := Format('%.2f', [Mem/G]) + ' GiB'  ;
end;

function TTest.GetMemAlcRealInKib: Real;
var
  Mem: Real;
begin
  Result := 0.0;
  // calc memory allocated by memory manager
  Mem := GetFastMMAllocated;
  // return memory alloc in kib
  Result := Mem / 1024;
end;

{ class TTestFactory }

class function TTestFactory.CreateTest(aType: TTestType; aLib: ILib;
  aMyLog: TMyLog): TTest;
begin
  if      (aType = ttSpeedRun  ) then Result := TTestSpeedRun.Create(aLib, aMyLog)
  else if (aType = ttValidation) then Result := TTestValid.Create(aLib, aMyLog)
  else if (aType = ttFileOpen  ) then Result := TTestFOpen.Create(aLib, aMyLog)
  else                                Result := nil;
end;

{ class TTestList }

constructor TTestList.Create;
begin
  fList := TList.Create;
end;

destructor TTestList.Destroy;
begin
  fList.Free;
  inherited Destroy;
end;

procedure TTestList.Add(aItem: TObject);
begin
  fList.Add(aItem);
end;

{ class TTestClock }

procedure TTestClock.Start;
begin
  fStartTick := GetTickCount;
  fLastTick  := fStartTick;
end;

procedure TTestClock.Now;
var
  nowTick: Cardinal;
begin
  nowTick := GetTickCount;
  fDeltaTotal := nowTick - fStartTick;
  fDeltaLast  := nowTick - fLastTick;
  fLastTick   := nowTick;
end;

end.
