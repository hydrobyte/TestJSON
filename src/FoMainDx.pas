unit FoMainDx;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.ComCtrls,

  McJson, McUtils, Mc.Param,
  TJ.Test, TJ.TestSpeedRun, TJ.TestValid, TJ.TestFOpen,
  TJ.Lib;

type
  TFormMain = class(TForm)
    PageControl: TPageControl;
    TabConfig: TTabSheet;
    RbgLib: TRadioGroup;
    GbxTestConfig: TGroupBox;
    LbType: TLabel;
    LbPreset: TLabel;
    BtPresetSave: TSpeedButton;
    BtPresetDel: TSpeedButton;
    CbxType: TComboBox;
    PageControlTest: TPageControl;
    TabSpeed: TTabSheet;
    Bevel: TBevel;
    ChbSpeedGen: TCheckBox;
    ChbSpeedLoad: TCheckBox;
    ChbSpeedParse: TCheckBox;
    ChbSpeedSave: TCheckBox;
    ChbSpeedFind: TCheckBox;
    EdSpeedFind: TEdit;
    EdSpeedSave: TEdit;
    EdSpeedLoad: TEdit;
    EdSpeedGen: TEdit;
    EdSpeedRep: TEdit;
    ChbSpeedProg: TCheckBox;
    ChbSpeedRepeat: TCheckBox;
    ChbSpeedClear: TCheckBox;
    TabValid: TTabSheet;
    LbValidFolder: TLabel;
    EdValidFolder: TEdit;
    ChbValidReport: TCheckBox;
    TabFOpen: TTabSheet;
    LbOpenFile: TLabel;
    EdFOpenFile: TEdit;
    CbxPreset: TComboBox;
    TabRun: TTabSheet;
    Memo: TMemo;
    ImgLogo: TImage;
    LbVersion: TLabel;
    LbTM: TLabel;
    BtRun: TButton;
    BtClose: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtCloseClick(Sender: TObject);
    procedure CbxTypeChange(Sender: TObject);
    procedure CbxPresetChange(Sender: TObject);
    procedure BtPresetSaveClick(Sender: TObject);
    procedure BtPresetDelClick(Sender: TObject);
    procedure BtRunClick(Sender: TObject);
    procedure CtrlChange(Sender: TObject);

  private
    FMcParam: TMcParam;
    FEventsFreezed: Boolean;

    procedure RunTest;
    procedure SetupTest(aTest: TTest);

    function GetLib: ILib;
    function GetTest(aLib: ILib; aMyLog: TMyLog): TTest;

    procedure LoadPreset(aIndex: Integer);
    procedure SavePreset(aName: string);
    procedure DeletePreset(aName: string);

    procedure MyLog(const S: string);

  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}
const
  C_PRESET_FILE = '..\\..\\preset.json';

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // version
  LbVersion.Caption := 'Test JSON 0.9.4 - Delphi 11.3 Alexandria (CE)';
  FEventsFreezed := false;
  // statistics clock
  TestClock := TTestClock.Create;
  // libraries.
  RbgLib.Items.Clear;
  RbgLib.Items.Add('McJSON'         );
  RbgLib.Items.Add('LkJSON'         );
  RbgLib.Items.Add('System.JSON'    );
  RbgLib.Items.Add('JsonDataObjects');
  RbgLib.Items.Add('SuperObject'    );
  RbgLib.Items.Add('X-SuperObject'  );
  RbgLib.Items.Add('JsonTools'      );
  RbgLib.Items.Add('Json4Delphi'    );
  RbgLib.Items.Add('Grijjy.Bson'    );
  RbgLib.Items.Add('Neslib.Json'    );
  RbgLib.Items.Add('dwsJSON'        );
  RbgLib.Items.Add('chimera.json'   );
  // tabs
  PageControl.ActivePageIndex := 0;
  RbgLib.ItemIndex := 0;
  // hide tests config tabs
  TabSpeed.TabVisible := false;
  TabValid.TabVisible := false;
  TabFOpen.TabVisible := false;
  // default: show performance test.
  CbxType.ItemIndex := 0;
  CbxTypeChange(nil);
  // default: check all validation test options
  ChbSpeedGen.Checked   := true;
  ChbSpeedSave.Checked  := true;
  ChbSpeedParse.Checked := true;
  ChbSpeedLoad.Checked  := true;
  ChbSpeedFind.Checked  := true;
  // presets
  FMcParam := TMcParam.Create(C_PRESET_FILE);
  FMcParam.LoadList(CbxPreset);
  // show selected
  CbxPreset.ItemIndex := CbxPreset.Items.IndexOf(FMcParam.Selected);
  CbxPresetChange(nil);
  //
  ReportMemoryLeaksOnShutdown := True;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  if (CbxPreset.ItemIndex >= 0) then
  begin
    // persist selected preset
    FMcParam.Selected := CbxPreset.Text;
    FMcParam.Persist;
  end;
  FMcParam.Free;
  TestClock.Free;
end;

procedure TFormMain.BtCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.CbxTypeChange(Sender: TObject);
begin
  if (FEventsFreezed) then Exit;
  // show/hide tests config tabs
  PageControlTest.ActivePageIndex := CbxType.ItemIndex;
  if (Assigned(Sender)) then
    CtrlChange(Sender);
end;

procedure TFormMain.CbxPresetChange(Sender: TObject);
begin
  if (FEventsFreezed) then Exit;
  LoadPreset(CbxPreset.ItemIndex);
end;

procedure TFormMain.BtPresetSaveClick(Sender: TObject);
var
  ACpt, APmp, AName: string;
  IsToSave, IsNew: Boolean;
  Pos: Integer;
begin
  // input preset prompt.
  ACpt  := 'Seve Preset';
  APmp  := 'Preset name:';
  AName := InputBox(ACpt, APmp, CbxPreset.Text);
  // check is valid and if exists.
  IsToSave := (AName <> '');
  IsNew    := True;
  if ( FMcParam.ExistsByName(AName) ) then
  begin // confirm overwrite.
    IsToSave := ( MessageDlg('Overwrite "' + AName + '" ?',
                             mtConfirmation, mbYesNo, 0, mbYes) = mrYes );
    IsNew := False;
  end;
  if (IsToSave) then
  begin
    SavePreset(AName);
    // update preset combobox.
    FEventsFreezed := True;
    if (IsNew) then
      CbxPreset.Items.Add(AName);
    // select name.
    Pos := CbxPreset.Items.IndexOf(AName);
    if (Pos >= 0) then CbxPreset.ItemIndex := Pos;
    FEventsFreezed := False;
  end;
end;

procedure TFormMain.BtPresetDelClick(Sender: TObject);
var
  AName: string;
begin
  if (CbxPreset.ItemIndex >= 0) then
  begin
    AName := CbxPreset.Text;
    if ( MessageDlg('Delete "' + AName + '" ?',
                    mtConfirmation, mbYesNo, 0, mbYes) = mrYes ) then
    begin
      DeletePreset(AName);
      CbxPreset.DeleteSelected();
      // set no selected
      CbxPreset.ItemIndex := -1;
      FMcParam.Selected   := '';
      FMcParam.Persist;
    end;
  end;
end;

procedure TFormMain.CtrlChange(Sender: TObject);
begin
  if (FEventsFreezed) then Exit;
  // change, set no selected
  CbxPreset.ItemIndex := -1;
end;

procedure TFormMain.BtRunClick(Sender: TObject);
begin
  Memo.Clear;
  PageControl.ActivePage := TabRun;
  RunTest;
end;

//------------------------------------------------------------------------------
// Private
//------------------------------------------------------------------------------

procedure TFormMain.RunTest;
var
  ALib : ILib;
  ATest: TTest;
begin
  ALib  := GetLib;
  ATest := GetTest(ALib, MyLog);
  // validate
  if (not Assigned(ALib )) then Exit;
  if (not Assigned(ATest)) then Exit;
  SetupTest(ATest);
  try
    try
      TestClock.Start;
      ATest.Header;
      ATest.Run;
    except on e: Exception do
      MyLog('  Run test exception: ' + e.Message);
    end;
  finally
    ALib := nil;
    ATest.Free;
  end;
end;

procedure TFormMain.SetupTest(aTest: TTest);
begin
  if (aTest is TTestSpeedRun) then
  begin
    TTestSpeedRun(aTest).CountRepeat  := StrToInt(EdSpeedRep.Text);
    TTestSpeedRun(aTest).IsGenOn      := ChbSpeedGen.Checked;
    TTestSpeedRun(aTest).IsSaveOn     := ChbSpeedSave.Checked;
    TTestSpeedRun(aTest).IsClearOn    := ChbSpeedClear.Checked;
    TTestSpeedRun(aTest).IsLoadOn     := ChbSpeedLoad.Checked;
    TTestSpeedRun(aTest).IsFindOn     := ChbSpeedFind.Checked;
    TTestSpeedRun(aTest).IsParseOn    := ChbSpeedParse.Checked;
    TTestSpeedRun(aTest).IsRepeatOn   := ChbSpeedRepeat.Checked;
    TTestSpeedRun(aTest).CountGen     := StrToInt(EdSpeedGen.Text);
    TTestSpeedRun(aTest).CountFind    := StrToInt(EdSpeedFind.Text);
    TTestSpeedRun(aTest).SaveFileName := EdSpeedSave.Text;
    TTestSpeedRun(aTest).LoadFileName := EdSpeedLoad.Text;
  end
  else if (aTest is TTestValid) then
  begin
    TTestValid(aTest).PathFolder      := EdValidFolder.Text;
    TTestValid(aTest).IsReportJSON    := ChbValidReport.Checked;
  end
  else if (aTest is TTestFOpen) then
  begin
    TTestFOpen(aTest).PathFile        := EdFOpenFile.Text;
  end;
end;

function TFormMain.GetLib: ILib;
begin
  Result := TLibFactory.CreateLib(TLibType(RbgLib.ItemIndex));
end;

function TFormMain.GetTest(aLib: ILib; aMyLog: TMyLog): TTest;
var
  testType: TTestType;
begin
  testType := TTestType(CbxType.ItemIndex);
  Result   := TTestFactory.CreateTest(testType, aLib, aMyLog);
end;

procedure TFormMain.LoadPreset(aIndex: Integer);
var
  PrsItem: TMcJsonItem;
begin
  if (aIndex < 0) then Exit;
  FEventsFreezed := True;
  try
    PrsItem := FMcParam.GetByIndex(aIndex);
    // get preset properties.
    CbxType.ItemIndex      := PrsItem.I['TestType'     ];
    RbgLib.ItemIndex       := PrsItem.I['LibType'      ];
    // speed run
    ChbSpeedGen.Checked    := PrsItem.B['SpeedGenOn'   ];
    ChbSpeedSave.Checked   := PrsItem.B['SpeedSaveOn'  ];
    ChbSpeedClear.Checked  := PrsItem.B['SpeedClearOn' ];
    ChbSpeedLoad.Checked   := PrsItem.B['SpeedLoadOn'  ];
    ChbSpeedFind.Checked   := PrsItem.B['SpeedFindOn'  ];
    ChbSpeedParse.Checked  := PrsItem.B['SpeedParseOn' ];
    EdSpeedGen.Text        := PrsItem.S['SpeedGen'     ];
    EdSpeedSave.Text       := McJsonUnEscapeString(PrsItem.S['SpeedSave']);
    EdSpeedLoad.Text       := McJsonUnEscapeString(PrsItem.S['SpeedLoad']);
    EdSpeedFind.Text       := PrsItem.S['SpeedFind'    ];
    ChbSpeedRepeat.Checked := PrsItem.B['SpeedRepeatOn'];
    ChbSpeedProg.Checked   := PrsItem.B['SpeedProgOn'  ];
    EdSpeedRep.Text        := PrsItem.S['SpeedRep'     ];
    // validation
    EdValidFolder.Text     := McJsonUnEscapeString(PrsItem.S['ValidFolder']);
    // file open
    EdFOpenFile.Text       := McJsonUnEscapeString(PrsItem.S['FOpenFile'  ]);
  finally
    FEventsFreezed := False;
    CbxTypeChange(nil);
  end;
end;

procedure TFormMain.SavePreset(aName: string);
var
  PrsItem: TMcJsonItem;
begin
  if (aName = '') then Exit;
  try
  begin
    PrsItem := FMcParam.GetOrCreateByName(aName);
    // set preset properties
    PrsItem.I['TestType'     ] := CbxType.ItemIndex;
    PrsItem.I['LibType'      ] := RbgLib.ItemIndex;
    // speed run
    PrsItem.B['SpeedGenOn'   ] := ChbSpeedGen.Checked;
    PrsItem.B['SpeedSaveOn'  ] := ChbSpeedSave.Checked;
    PrsItem.B['SpeedClearOn' ] := ChbSpeedClear.Checked;
    PrsItem.B['SpeedLoadOn'  ] := ChbSpeedLoad.Checked;
    PrsItem.B['SpeedFindOn'  ] := ChbSpeedFind.Checked;
    PrsItem.B['SpeedParseOn' ] := ChbSpeedParse.Checked;
    PrsItem.S['SpeedGen'     ] := EdSpeedGen.Text;
    PrsItem.S['SpeedSave'    ] := McJsonEscapeString(EdSpeedSave.Text);
    PrsItem.S['SpeedLoad'    ] := McJsonEscapeString(EdSpeedLoad.Text);
    PrsItem.S['SpeedFind'    ] := EdSpeedFind.Text;
    PrsItem.B['SpeedRepeatOn'] := ChbSpeedRepeat.Checked;
    PrsItem.B['SpeedProgOn'  ] := ChbSpeedProg.Checked;
    PrsItem.S['SpeedRep'     ] := EdSpeedRep.Text;
    // validation
    PrsItem.S['ValidFolder'  ] := McJsonEscapeString(EdValidFolder.Text);
    // file open
    PrsItem.S['FOpenFile'    ] := McJsonEscapeString(EdFOpenFile.Text);

    // set selected preset
    FMcParam.Selected := aName;

    // persist changes
    FMcParam.Persist;
  end;
  except
  end;
end;

procedure TFormMain.DeletePreset(aName: string);
begin
  if (aName = '') then Exit;
  try
  begin
    FMcParam.DeleteByName(aName);
    FMcParam.Persist;
  end;
  except
  end;
end;

procedure TFormMain.MyLog(const S: string);
var
  STag: string;
begin
  TestClock.Now;
  STag   := Format('[%6d/%4d]', [TestClock.DeltaTotal, TestClock.DeltaLast]);
  if (ChbSpeedProg.Checked) then
    Memo.Lines.Add(STag + ': ' + S);
end;

end.
