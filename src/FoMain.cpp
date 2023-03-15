//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include "FoMain.h"

#include "McJSON.hpp"
#include "uLkJSON.hpp"
#include "System.JSON.hpp"
#include "JsonDataObjects.hpp"
#include "superobject.hpp"
#include "JsonTools.hpp"
#include "Jsons.hpp"

#include "myJSON.hpp"
#include "uJSON.hpp"

#include "McUtils.hpp"
#include "System.IOUtils.hpp"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TFormMain *FormMain;
//---------------------------------------------------------------------------
AnsiString C_PRESET_FILE = "..\\..\\preset.json";
AnsiString C_PRESET_LIST = "List";
AnsiString C_PRESET_SEL  = "Selected";
//---------------------------------------------------------------------------
// shortners macros
#define C_MC(p) static_cast<TMcJsonItem*>(p)
#define C_LK(p) static_cast<TlkJSONobject*>(p)
#define C_SJ(p) static_cast<System::Json::TJSONObject*>(p)
#define C_JD(p) static_cast<Jsondataobjects::TJsonObject*>(p)
#define C_SO(p) static_cast<TSuperObject*>(p)
#define C_JT(p) static_cast<TJsonNode*>(p)
#define C_JS(p) static_cast<Jsons::TJson*>(p)

#define C_MY(p) static_cast<myJSONItem*>(p)
#define C_UJ(p) static_cast<Ujson::TJSONObject*>(p)
//---------------------------------------------------------------------------
__fastcall TFormMain::TFormMain(TComponent* Owner)
  : TForm(Owner)
{
  // version
  LbVersion->Caption = "Test JSON 0.9.0 - C++Buider 10.2";
  FEventsFreezed = false;
  // libraries.
  RbgLib->Items->Clear();
  RbgLib->Items->Add("McJSON"         ); //ltMc
  RbgLib->Items->Add("LkJSON"         ); //ltLk
  RbgLib->Items->Add("System.JSON"    ); //ltSj
  RbgLib->Items->Add("JsonDataObjects"); //ltJd
  RbgLib->Items->Add("SuperObject"    ); //ltSo
  RbgLib->Items->Add("JsonTools"      ); //ltJt
  RbgLib->Items->Add("Json4Delphi"    ); //ltJs
  //RbgLib->Items->Add("myJSON"         ); //ltMy
  //RbgLib->Items->Add("uJSON"          ); //ltUj
  // tabs
  PageControl->ActivePageIndex = 0;
  RbgLib->ItemIndex = 0;
  // hide tests config tabs
  TabSpeed->TabVisible = false;
  TabValid->TabVisible = false;
  TabFOpen->TabVisible = false;
  // default: show performance test.
  CbxType->ItemIndex = 0;
  CbxTypeChange(NULL);
  // default: check all validation test options
  ChbSpeedGen->Checked   = true;
  ChbSpeedSave->Checked  = true;
  ChbSpeedParse->Checked = true;
  ChbSpeedLoad->Checked  = true;
  ChbSpeedFind->Checked  = true;
  // presets
  FPreset = new TMcJsonItem;
  PresetLoadList();
  // show selected
  CbxPreset->ItemIndex = CbxPreset->Items->IndexOf(FPreset->S[C_PRESET_SEL]);
  CbxPresetChange(NULL);
}
//---------------------------------------------------------------------------
void __fastcall
TFormMain::FormDestroy(TObject *Sender)
{
  if (CbxPreset->ItemIndex >= 0)
  { // persist selected preset
    FPreset->S[C_PRESET_SEL] = CbxPreset->Text;
    PresetPersist();
  }
  if (FPreset) delete (FPreset);
}
//---------------------------------------------------------------------------
void __fastcall
TFormMain::BtCloseClick(TObject *Sender)
{
  Close();
}
//---------------------------------------------------------------------------
void __fastcall
TFormMain::CbxTypeChange(TObject *Sender)
{
  if (FEventsFreezed) return;
  // show/hide tests config tabs
  PageControlTest->ActivePageIndex = CbxType->ItemIndex;
}
//---------------------------------------------------------------------------
void __fastcall
TFormMain::CbxPresetChange(TObject *Sender)
{
  if (FEventsFreezed) return;
  PresetLoad(CbxPreset->ItemIndex);
}
//---------------------------------------------------------------------------
void __fastcall
TFormMain::BtPresetSaveClick(TObject *Sender)
{
  if (!FPreset) return;
  // input preset prompt.
  AnsiString ACpt  = "Seve Preset";
  AnsiString APmp  = "Preset name:";
  AnsiString AName = InputBox(ACpt, APmp, CbxPreset->Text);
  // check is valid and if exists.
  bool IsToSave = (AName != "");
  bool IsNew = true;
  int Pos;
  if ( PresetNameExists(AName, Pos) )
  { // confirm overwrite.
    IsToSave = ( MessageDlg("Overwrite \"" + AName + "\" ?",
                            mtConfirmation, mbYesNo, 0, mbYes) == mrYes );
    IsNew = false;
  }
  if (IsToSave)
  {
    PresetSave(AName);
    // update preset combobox.
    FEventsFreezed = true;
    if (IsNew)
      CbxPreset->Items->Add(AName);
    // select name.
    int Pos = CbxPreset->Items->IndexOf(AName);
    if (Pos >= 0) CbxPreset->ItemIndex = Pos;
    FEventsFreezed = false;
  }
}
//---------------------------------------------------------------------------
void __fastcall
TFormMain::BtDelClick(TObject *Sender)
{
  if (CbxPreset->ItemIndex >= 0)
  {
    String AName = CbxPreset->Text;
    if ( MessageDlg("Delete \"" + AName + "\" ?",
                    mtConfirmation, mbYesNo, 0, mbYes) == mrYes )
    {
      PresetDelete(AName);
      CbxPreset->DeleteSelected();
      // set no selected
      CbxPreset->ItemIndex = -1;
      FPreset->S[C_PRESET_SEL] = "";
      PresetPersist();
    }
  }
}
//---------------------------------------------------------------------------
void __fastcall
TFormMain::SpeedChange(TObject *Sender)
{
  if (FEventsFreezed) return;
  // change, set no selected
  CbxPreset->ItemIndex = -1;
}
//---------------------------------------------------------------------------
void __fastcall
TFormMain::BtRunClick(TObject *Sender)
{
  // tab focus
  PageControl->ActivePageIndex = TabRun->PageIndex;
  Memo->Clear();
  Application->ProcessMessages();
  // run tests.
  if      (CbxType->ItemIndex == 0) DoTestSpeed();
  else if (CbxType->ItemIndex == 1) DoTestValid();
  else if (CbxType->ItemIndex == 2) DoTestFOpen();
}
//---------------------------------------------------------------------------
// Private
//---------------------------------------------------------------------------
void
TFormMain::DoStart()
{
  Memo->Lines->Add("Starting tests");
  Memo->Lines->Add("  Test   : " + CbxType->Text);
  Memo->Lines->Add("  Library: " + RbgLib->Items->Strings[RbgLib->ItemIndex]);
}
//---------------------------------------------------------------------------
void
TFormMain::DoFinish()
{
  Memo->Lines->Add("Tests finished");
}
//---------------------------------------------------------------------------
void
TFormMain::DoCreateMem()
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: Json  = new TMcJsonItem();
               JsonP = new TMcJsonItem();                  break;
    case ltLk: Json  = new TlkJSONobject(true);
               JsonP = new TlkJSONobject(true);            break;
    case ltSj: Json  = new System::Json::TJSONObject();
               JsonP = new System::Json::TJSONObject();    break;
    case ltJd: Json  = new Jsondataobjects::TJsonObject();
               JsonP = new Jsondataobjects::TJsonObject(); break;
    case ltSo: Json  = new TSuperObject("");
               JsonP = new TSuperObject("");               break;
    case ltJt: Json  = new TJsonNode();
               JsonP = new TJsonNode();                    break;
    case ltJs: Json  = new Jsons::TJson();
               JsonP = new Jsons::TJson();                 break;

    case ltMy: Json  = new myJSONItem();
               JsonP = new myJSONItem();                   break;
    case ltUj: Json  = new Ujson::TJSONObject();
               JsonP = new Ujson::TJSONObject();           break;
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoDeleteMem()
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: if (C_MC(Json )) delete (C_MC(Json ));
               if (C_MC(JsonP)) delete (C_MC(JsonP)); break;
    case ltLk: if (C_LK(Json )) delete (C_LK(Json ));
               if (C_LK(JsonP)) delete (C_LK(JsonP)); break;
    case ltSj: if (C_SJ(Json )) C_SJ(Json )->Free() ;
               if (C_SJ(JsonP)) C_SJ(JsonP)->Free() ; break;
    case ltJd: if (C_JD(Json )) delete (C_JD(Json ));
               if (C_JD(JsonP)) delete (C_JD(JsonP)); break;
    case ltSo: if (C_SO(Json )) delete (C_SO(Json ));
               if (C_SO(JsonP)) delete (C_SO(JsonP)); break;
    case ltJt: if (C_JT(Json )) delete (C_JT(Json ));
               if (C_JT(JsonP)) delete (C_JT(JsonP)); break;
    case ltJs: if (C_JS(Json )) delete (C_JS(Json ));
               if (C_JS(JsonP)) delete (C_JS(JsonP)); break;

    case ltMy: if (C_MY(Json )) delete (C_MY(Json ));
               if (C_MY(JsonP)) delete (C_MY(JsonP)); break;
    case ltUj: if (C_UJ(Json )) delete (C_UJ(Json ));
               if (C_UJ(JsonP)) delete (C_UJ(JsonP)); break;
  }
}
//---------------------------------------------------------------------------
// Speed Test
//---------------------------------------------------------------------------
void
TFormMain::DoTestSpeed()
{
  // tab focus
  PageControl->ActivePageIndex = TabRun->PageIndex;

  Memo->Clear();
  // statistics
  FStat.clear();
  FStat.resize(ttTotal+1, 0.0);
  // number of selected tests
  FCountTest = CountSpeedSubtestSelected();
  // number of repetitions
  FCountRepete = (ChbSpeedRep->Checked) ? StrToInt(EdSpeedRep->Text) : 1;
  // same random seed for all tests
  RandSeed = 1010;
  // header
  DoStart();
  // run tests
  for (int i=0; i<FCountRepete; i++)
  {
    Memo->Lines->Add("");
    Memo->Lines->Add("Test #" + IntToStr(i));
    DoSpeed();
  }
  DoFinish();
  // show statistics
  DoSpeedStat();
}
//---------------------------------------------------------------------------
void
TFormMain::DoSpeed()
{
  AnsiString SKey, SVal;
  FdwStart = FdwLast = GetTickCount();
  // alloc
  MyLog("Memory: " + GetMemAlc());
  MyLog("Creating objects...");
  DoCreateMem();
  MyLog("  Done: " + GetMemAlc());
  // aux
  int CountLoad;
  // run selected tests
  try
  { try
    {
      if (ChbSpeedGen->Checked)
      { // number of items to generate
        int CountGen = StrToInt(EdSpeedGen->Text);
        MyLog("Generating " + EdSpeedGen->Text + " items...");
        for (int i=0; i < CountGen; i++)
        {
          SKey = "key"   + IntToStr(i+1);
          SVal = "value" + IntToStr(i+1);
          DoSpeedAdd(SKey, SVal);
        }
        DoSpeedCount(CountLoad);
        MyLog("  Done " + IntToStr(CountLoad) + " items: " + GetMemAlc());
        FStat[ttGene] += FDtLast;
      }

      if (ChbSpeedSave->Checked)
      {
        MyLog("Save to file...");
        DoSpeedSave(EdSpeedSave->Text);
        MyLog("  Done: " + GetMemAlc());
        FStat[ttSave] += FDtLast;
      }

      if (ChbSpeedClear->Checked)
      {
        MyLog("Cleaning...");
        DoSpeedClear();
        MyLog("  Done: " + GetMemAlc());
        FStat[ttClear] += FDtLast;
      }

      if (ChbSpeedLoad->Checked)
      {
        MyLog("Load from file...");
        DoSpeedLoad(EdSpeedLoad->Text);
        DoSpeedCount(CountLoad);
        MyLog("  Done " + IntToStr(CountLoad) + " items: " + GetMemAlc());
        FStat[ttLoad] += FDtLast;
      }

      if (ChbSpeedFind->Checked)
      { // number of items to find
        int CountFind  = StrToInt(EdSpeedFind->Text);
        int CountRange = StrToInt(EdSpeedGen->Text );
        MyLog("Finding " + EdSpeedFind->Text + " items...");
        int Id;
        bool IsOK = true;
        for (int i=0; i < CountFind; i++)
        {
          Id = Random(CountRange) + 1;
          SKey = "key"   + IntToStr(Id);
          SVal = "value" + IntToStr(Id);
          IsOK = IsOK && DoSpeedFind(SKey, SVal);
        }
        if (IsOK) MyLog("  Done all found: "    + GetMemAlc());
        else      MyLog("  Done with problem: " + GetMemAlc());
        FStat[ttFind] += FDtLast;
      }

      if (ChbSpeedParse->Checked)
      {
        MyLog("Clone/Parsing...");
        DoSpeedParse();
        MyLog("  Done: " + GetMemAlc());
        FStat[ttParse] += FDtLast;
      }
    }
    catch (Exception& E)
    {
      MyLog("Error: " + E.Message);
    }
  }
  __finally
  {
    FStat[ttTotal] += FDtTotal;
    // free memory
    MyLog("Deleting objects...");
    DoDeleteMem();
    MyLog("  Done: " + GetMemAlc());
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoSpeedAdd(const String& ASKey, const String& ASVal)
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: C_MC(Json)->Add(ASKey)->AsString = ASVal; break;
    case ltLk: C_LK(Json)->Add(ASKey, ASVal);            break;
    case ltSj: C_SJ(Json)->AddPair(ASKey, ASVal);        break;
    case ltJd: C_JD(Json)->S[ASKey] = ASVal;             break;
    case ltSo: C_SO(Json)->S[ASKey] = ASVal;             break;
    case ltJt: C_JT(Json)->Add(ASKey, ASVal);            break;
    case ltJs: C_JS(Json)->Put(ASKey, ASVal);            break;

    case ltMy: C_MY(Json)->Item[ASKey]->setStr(ASVal);   break;
    case ltUj: C_UJ(Json)->put(ASKey, ASVal);            break;
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoSpeedSave(const String& AFileName)
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: C_MC(Json)->SaveToFile(AFileName, false);                break;
    case ltLk: TlkJSONstreamed::SaveToFile(C_LK(Json), AFileName);      break;
    case ltSj: TFile::WriteAllText(AFileName, C_SJ(Json)->ToJSON());    break;
    case ltJd: C_JD(Json)->SaveToFile(AFileName);                       break;
    case ltSo: C_SO(Json)->SaveTo(AFileName);                           break;
    case ltJt: C_JT(Json)->SaveToFile(AFileName);                       break;
    case ltJs: TFile::WriteAllText(AFileName, C_JS(Json)->Stringify()); break;

    case ltMy: C_MY(Json)->SaveToFile(AFileName);                       break;
    case ltUj: C_UJ(Json)->SaveToFile(AFileName);                       break;
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoSpeedClear()
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: C_MC(Json)->Clear();                      break;
    case ltLk: { if (C_LK(Json)) delete (C_LK(Json));
                 Json = new TlkJSONobject(true);
               }                                         break;
    case ltSj: { if (C_SJ(Json)) C_SJ(Json)->Free();
                 Json = new System::Json::TJSONObject();
               }                                         break;
    case ltJd: C_JD(Json)->Clear();                      break;
    case ltSo: C_SO(Json)->Clear();                      break;
    case ltJt: C_JT(Json)->Clear();                      break;
    case ltJs: C_JS(Json)->Clear();                      break;

    case ltMy: C_MY(Json)->Clear();                      break;
    case ltUj: C_UJ(Json)->clean();                      break;
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoSpeedLoad(const String& AFileName)
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: C_MC(Json)->LoadFromFile(AFileName, false);            break;
    case ltLk: Json = C_LK(TlkJSONstreamed::LoadFromFile(AFileName)); break;
    case ltSj: Json = C_SJ(Json)->ParseJSONValue(
                                    TFile::ReadAllText(AFileName));   break;
    case ltJd: C_JD(Json)->LoadFromFile(AFileName);                   break;
    case ltSo: C_SO(Json)->ParseFile(AFileName,true);                 break;
    case ltJt: C_JT(Json)->LoadFromFile(AFileName);                   break;
    case ltJs: C_JS(Json)->Parse(
                             TFile::ReadAllText(AFileName));          break;

    case ltMy: C_MY(Json)->LoadFromFile(AFileName);                   break;
    case ltUj: C_UJ(Json)->LoadFromFile(AFileName);                   break;
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoSpeedCount(int& Count)
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: Count = C_MC(Json)->Count     ; break;
    case ltLk: Count = C_LK(Json)->Count     ; break;
    case ltSj: Count = C_SJ(Json)->Count     ; break;
    case ltJd: Count = C_JD(Json)->Count     ; break;
    case ltSo: Count = C_SO(Json)->CalcSize(); break;
    case ltJt: Count = C_JT(Json)->Count     ; break;
    case ltJs: Count = C_JS(Json)->Count     ; break;

    case ltMy: Count = C_MY(Json)->Count()   ; break;
    case ltUj: Count = C_UJ(Json)->length()  ; break;
  }
}
//---------------------------------------------------------------------------

bool
TFormMain::DoSpeedFind(const String& ASKey, const String& ASVal)
{
  bool Ans = false;
  switch (RbgLib->ItemIndex)
  {
    case ltMc: Ans = ( C_MC(Json)->Values[ASKey]->AsString  == ASVal ); break;
    case ltLk: Ans = ( C_LK(Json)->getStringFromName(ASKey) == ASVal ); break;
    case ltSj: Ans = ( C_SJ(Json)->GetValue(ASKey)->Value() == ASVal ); break;
    case ltJd: Ans = ( C_JD(Json)->S[ASKey]                 == ASVal ); break;
    case ltSo: Ans = ( C_SO(Json)->S[ASKey]                 == ASVal ); break;
    case ltJt: Ans = ( C_JT(Json)->Child(ASKey)->AsString   == ASVal ); break;
    case ltJs: Ans = ( C_JS(Json)->Values[ASKey]->AsString  == ASVal ); break;

    case ltMy: Ans = ( C_MY(Json)->Item[ASKey]->getStr()    == ASVal ); break;
    case ltUj: Ans = ( C_UJ(Json)->getString(ASKey)         == ASVal ); break;
  }
  return (Ans);
}
//---------------------------------------------------------------------------
void
TFormMain::DoSpeedParse()
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: C_MC(JsonP)->AsJSON = C_MC(Json)->AsJSON;           break;
    case ltLk: JsonP = C_LK(TlkJSON::ParseText(
                                       TlkJSON::GenerateText(
                                         C_LK(Json))));            break;
    case ltSj: JsonP = C_SJ(Json)->ParseJSONValue(
                                     C_SJ(Json)->ToJSON());        break;
    case ltJd: JsonP = C_JD(Json)->ParseUtf8(
                                     C_JD(Json)->ToJSON());        break;
    case ltSo: C_SO(JsonP)->ParseString(
                              C_SO(Json)->AsJSon().c_str(), true); break;
    case ltJt: C_JT(JsonP)->Value  = C_JT(Json)->AsJson;           break;
    case ltJs: C_JS(JsonP)->Parse(C_JS(Json)->Stringify());        break;

    case ltMy: C_MY(JsonP)->Code   = C_MY(Json)->getJSON();        break;
    case ltUj: C_UJ(JsonP)->Parse(C_UJ(Json)->toString());         break;
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoSpeedStat()
{
  Memo->Lines->Add("");
  Memo->Lines->Add("Speed Statistics for " + RbgLib->Items->Strings[RbgLib->ItemIndex]);
  Memo->Lines->Add("Average of " + IntToStr(FCountRepete) + " repetitions (in ms)");

  if (FCountTest > 0)
  {
    if (ChbSpeedGen->Checked  ) Memo->Lines->Add(GetSpeedAvg("  Generate", ttGene ));
    if (ChbSpeedSave->Checked ) Memo->Lines->Add(GetSpeedAvg("  Save    ", ttSave ));
    if (ChbSpeedClear->Checked) Memo->Lines->Add(GetSpeedAvg("  Clear   ", ttClear));
    if (ChbSpeedLoad->Checked ) Memo->Lines->Add(GetSpeedAvg("  Load    ", ttLoad ));
    if (ChbSpeedFind->Checked ) Memo->Lines->Add(GetSpeedAvg("  Find    ", ttFind ));
    if (ChbSpeedParse->Checked) Memo->Lines->Add(GetSpeedAvg("  Parse   ", ttParse));
                                Memo->Lines->Add(GetSpeedAvg("  Total   ", ttTotal));
  }
}
//---------------------------------------------------------------------------
String
TFormMain::GetSpeedAvg(const String& SPrfx, TTestType AType)
{
  // calc avg from test type
  double Avg = 0.0;
  if (FCountRepete > 0)
    Avg = FStat[AType]/FCountRepete;
  // format
  TVarRec args[1] = {Avg};
  // return stat label
  return ( SPrfx + ": " + Format("%8.2f", args, 1) );
}
//---------------------------------------------------------------------------
int
TFormMain::CountSpeedSubtestSelected()
{
  int Count = 0;
  if (ChbSpeedGen->Checked  ) Count++;
  if (ChbSpeedSave->Checked ) Count++;
  if (ChbSpeedParse->Checked) Count++;
  if (ChbSpeedLoad->Checked ) Count++;
  if (ChbSpeedFind->Checked ) Count++;
  return (Count);
}
//---------------------------------------------------------------------------
// Validation Test
//---------------------------------------------------------------------------
void
TFormMain::DoTestValid()
{
  FdwStart = FdwLast = GetTickCount();
  // tab focus
  PageControl->ActivePageIndex = TabRun->PageIndex;
  Memo->Clear();
  // header
  DoStart();

  TStringList* StrL = GetListJsonFiles(EdValidFolder->Text);
  try
  {
    for (int i=0; i<StrL->Count; i++)
    { // avoid corruption allocating/freeying memory to each test
      DoCreateMem();
      try
      { try
        {
          DoValid(StrL->Strings[i]);
        }
        catch (Exception& E)
        {
          MyLog("Unhandled exception: " + E.Message);
        }
      }
      __finally
      { // free memory
        DoDeleteMem();
      }
    }
  }
  __finally
  {
    delete (StrL);
    DoFinish();
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoValid(const String& AFileName)
{
  TStringList* StrL = new TStringList();
  if ( StrL )
  {
    StrL->LoadFromFile(AFileName);
    if (StrL->Count > 1)
    {
      String ACmnt, ACode;
      ACmnt = StrL->Strings[0];
      ACode = StrL->Strings[1];
      // amend other lines
      for (int i=2; i<StrL->Count; i++)
        ACode = ACode + '\n' + StrL->Strings[i];
      // check
      bool IsOK;
      String SExc = "";
      try
      {
        switch (RbgLib->ItemIndex)
        {
          case ltMc: IsOK = C_MC(Json)->Check(ACode);           break;
          case ltLk: IsOK = C_LK(TlkJSON::ParseText(ACode));    break;
          case ltSj: IsOK = C_SJ(Json)->ParseJSONValue(ACode);  break;
          case ltJd: IsOK = C_JD(Json)->ParseUtf8(ACode);       break;
          case ltSo: IsOK = C_SO(Json)->ParseString(
                                         ACode.c_str(), true);  break;
          case ltJt: IsOK = C_JT(Json)->TryParse(ACode);        break;
          case ltJs: {       C_JS(Json)->Parse(ACode);
                      IsOK = C_JS(Json)->Stringify() == ACode;} break;

          case ltMy: {       C_MY(Json)->Code =  ACode;
                      IsOK = C_MY(Json)->Code == ACode;}        break;
          case ltUj: IsOK = C_UJ(Json)->TryParse(ACode);        break;
          default  : IsOK = false;
        }
      }
      catch (Exception& E)
      {
        IsOK = false;
        SExc = E.Message;
      }
      //[0000/0000]: PASS/FAIL = file00.json = comment = json
      String AMsg;
      AMsg = (IsOK) ? "PASS" : "FAIL";
      AMsg = AMsg + " = " + Sysutils::ExtractFileName(AFileName);
      AMsg = AMsg + " = " + ACmnt;
      if (ChbValidReport->Checked)
        AMsg = AMsg + " = " + ACode;
      if (SExc != "")
        AMsg = AMsg + " = [Exception] = " + SExc;
      // log
      MyLog(AMsg);
    }
    else
    {
      MyLog("Problem reading file: " + AFileName);
    }
    delete (StrL);
  }
}
//---------------------------------------------------------------------------
TStringList*
TFormMain::GetListJsonFiles(const String& ADir)
{
  TStringList* StrL = NULL;

  const String DirAux = ADir + "\\*.json";
  WIN32_FIND_DATA FindData;
  #if defined(UNICODE)
  HANDLE const HSearch = FindFirstFileW(DirAux.c_str(), &FindData);
  #else
  HANDLE const HSearch = FindFirstFile(AnsiString(DirAux).c_str(), &FindData);
  #endif
  if (HSearch == INVALID_HANDLE_VALUE)
  {
    FindClose(HSearch);
  }
  else
  {
    StrL = new TStringList();
    try
    {
      do
      { // list files: dir \ filename
        if (FindData.dwFileAttributes & FILE_ATTRIBUTE_ARCHIVE)
          StrL->Add( ADir + "\\" + FindData.cFileName );
      }
      while (FindNextFile(HSearch, &FindData));
    }
    __finally
    {
      FindClose(HSearch);
    }
  }
  return (StrL);
}
//---------------------------------------------------------------------------
// File Open Test
//---------------------------------------------------------------------------
void
TFormMain::DoTestFOpen()
{
  FdwStart = FdwLast = GetTickCount();
  // tab focus
  PageControl->ActivePageIndex = TabRun->PageIndex;
  Memo->Clear();
  // header
  DoStart();
  try
  {
    try
    {
      DoFOpen(EdFOpenFile->Text);
    }
    catch (Exception& E)
    {
      MyLog("Unhandled exception: " + E.Message);
    }
  }
  __finally
  {
    DoFinish();
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoFOpen(const String& AFileName)
{
  int CountLoad;
  try
  { try
    { // alloc
      MyLog("Memory: " + GetMemAlc());
      MyLog("Creating objects...");
      DoCreateMem();
      MyLog("  Done: " + GetMemAlc());

      MyLog("Loading JSON object...");
      DoSpeedLoad(AFileName);
      DoSpeedCount(CountLoad);
      MyLog("  Done " + IntToStr(CountLoad) + " items: " + GetMemAlc());

      MyLog("To string it here...");
      String S;
      DoFOpenToStr(S);
      MyLog(S);
      MyLog("  Done: " + GetMemAlc());
    }
    catch (Exception& E)
    {
      MyLog("Open JSON file exception: " + E.Message);
    }
  }
  __finally
  { // free memory
    MyLog("Deleting objects...");
    DoDeleteMem();
    MyLog("  Done: " + GetMemAlc());
  }
}
//---------------------------------------------------------------------------
void
TFormMain::DoFOpenToStr(String& Str)
{
  switch (RbgLib->ItemIndex)
  {
    case ltMc: Str = C_MC(Json)->ToString(false);       break;
    case ltLk: Str = TlkJSON::GenerateText(C_LK(Json)); break;
    case ltSj: Str = C_SJ(Json)->ToString();            break;
    case ltJd: Str = C_JD(Json)->ToString();            break;
    case ltSo: Str = C_SO(Json)->ToString();            break;
    case ltJt: Str = C_JT(Json)->ToString();            break;
    case ltJs: Str = C_JS(Json)->Stringify();           break;

    case ltMy: Str = C_MY(Json)->getJSON();             break;
    case ltUj: Str = C_UJ(Json)->toString();            break;
  }
}
//---------------------------------------------------------------------------
// General and helpers
//---------------------------------------------------------------------------
void
TFormMain::MyLog(const String& S)
{
  DWORD dwNow  = GetTickCount();
  int   dTotal = dwNow - FdwStart;
  int   dLast  = dwNow - FdwLast;
  TVarRec args[2] = {dTotal, dLast};
  String STag = Format("[%6d/%4d]", args, 1);
  if (ChbSpeedProg->Checked)
    Memo->Lines->Add(STag + ": " + S);
  // inform
  FDtLast  = dLast;
  FDtTotal = dTotal;
  // update
  FdwLast = dwNow;
}
//---------------------------------------------------------------------------
String
TFormMain::GetMemAlc() const
{
  String Ans = "";
  int k = 1024;
  int M = 1024*1024;
  int G = 1024*1024*1024;
  // calc memory allocated by memory manager
  double Mem = GetFastMMAllocated();
  // format
  TVarRec args[1] = {Mem};
  if      (Mem < k) {args[0] = Mem  ; Ans = Format("%.0f", args, 1) + " Bytes";}
  else if (Mem < M) {args[0] = Mem/k; Ans = Format("%.2f", args, 1) + " kiB"  ;}
  else if (Mem < G) {args[0] = Mem/M; Ans = Format("%.2f", args, 1) + " MiB"  ;}
  else              {args[0] = Mem/G; Ans = Format("%.2f", args, 1) + " GiB"  ;}
  // return memory alloc label
  return ( Ans );
}
//---------------------------------------------------------------------------
void
TFormMain::PresetLoadList()
{
  if (!FPreset) return;
  CbxPreset->Clear();
  try
  {
    MyLog(ExpandFileName(C_PRESET_FILE));
    FPreset->LoadFromFile(C_PRESET_FILE, false);
    TMcJsonItem* PrsList = FPreset->Values[C_PRESET_LIST];
    for (int i=0; i < PrsList->Count; i++)
    {
      CbxPreset->Items->Add( PrsList->Items[i]->Key );
    }
  }
  catch (...)
  {
  }
}
//---------------------------------------------------------------------------
void
TFormMain::PresetLoad(int aIndex)
{
  if (!FPreset  ) return;
  if (aIndex < 0) return;
  FEventsFreezed = true;
  try
  { try
    {
      TMcJsonItem* PrsItem = FPreset->Values[C_PRESET_LIST]->Items[aIndex];
      // get preset properties.
      // speed run
      ChbSpeedGen->Checked   = PrsItem->B["SpeedGenOn"  ];
      ChbSpeedSave->Checked  = PrsItem->B["SpeedSaveOn" ];
      ChbSpeedClear->Checked = PrsItem->B["SpeedClearOn"];
      ChbSpeedLoad->Checked  = PrsItem->B["SpeedLoadOn" ];
      ChbSpeedFind->Checked  = PrsItem->B["SpeedFindOn" ];
      ChbSpeedParse->Checked = PrsItem->B["SpeedParseOn"];
      EdSpeedGen->Text       = PrsItem->S["SpeedGen"    ];
      EdSpeedSave->Text      = McJsonUnEscapeString(PrsItem->S["SpeedSave"]);
      EdSpeedLoad->Text      = McJsonUnEscapeString(PrsItem->S["SpeedLoad"]);
      EdSpeedFind->Text      = PrsItem->S["SpeedFind"  ];
      ChbSpeedRep->Checked   = PrsItem->B["SpeedRepOn" ];
      ChbSpeedProg->Checked  = PrsItem->B["SpeedProgOn"];
      EdSpeedRep->Text       = PrsItem->S["SpeedRep"   ];
      // validation
      EdValidFolder->Text    = McJsonUnEscapeString(PrsItem->S["ValidFolder"]);
      // file open
      EdFOpenFile->Text      = McJsonUnEscapeString(PrsItem->S["FOpenFile"  ]);
    }
    catch (...)
    {
    }
  }
  __finally
  {
    FEventsFreezed = false;
  }
}
//---------------------------------------------------------------------------
void
TFormMain::PresetPersist()
{
  if (!FPreset) return;
  try
  { // save to file with human reading.
    FPreset->SaveToFile(C_PRESET_FILE, true);
  }
  catch (...)
  {
  }
}
//---------------------------------------------------------------------------
void
TFormMain::PresetSave(const String& aName)
{
  if (!FPreset   ) return;
  if (aName == "") return;
  try
  { // check list object
    if ( !FPreset->HasKey(C_PRESET_LIST) )
      FPreset->Add(C_PRESET_LIST, jitObject);

    TMcJsonItem* PrsList = FPreset->Values[C_PRESET_LIST];
    TMcJsonItem* PrsItem;
    int Pos;

    // if exists, get item or add a new one
    if ( PresetNameExists(aName, Pos) )
      PrsItem = PrsList->Items[Pos];
    else
      PrsItem = PrsList->Add(aName);

    // set preset properties
    // speed run
    PrsItem->B["SpeedGenOn"  ] = ChbSpeedGen->Checked;
    PrsItem->B["SpeedSaveOn" ] = ChbSpeedSave->Checked;
    PrsItem->B["SpeedClearOn"] = ChbSpeedClear->Checked;
    PrsItem->B["SpeedLoadOn" ] = ChbSpeedLoad->Checked;
    PrsItem->B["SpeedFindOn" ] = ChbSpeedFind->Checked;
    PrsItem->B["SpeedParseOn"] = ChbSpeedParse->Checked;
    PrsItem->S["SpeedGen"    ] = EdSpeedGen->Text;
    PrsItem->S["SpeedSave"   ] = McJsonEscapeString(EdSpeedSave->Text);
    PrsItem->S["SpeedLoad"   ] = McJsonEscapeString(EdSpeedLoad->Text);
    PrsItem->S["SpeedFind"   ] = EdSpeedFind->Text;
    PrsItem->B["SpeedRepOn"  ] = ChbSpeedRep->Checked;
    PrsItem->B["SpeedProgOn" ] = ChbSpeedProg->Checked;
    PrsItem->S["SpeedRep"    ] = EdSpeedRep->Text;
    // validation
    PrsItem->S["ValidFolder" ] = McJsonEscapeString(EdValidFolder->Text);
    // file open
    PrsItem->S["FOpenFile"   ] = McJsonEscapeString(EdFOpenFile->Text);

    // set selected preset
    FPreset->S[C_PRESET_SEL] = aName;

    // persist changes
    PresetPersist();
  }
  catch (...)
  {
  }
}
//---------------------------------------------------------------------------
void
TFormMain::PresetDelete(const String& aName)
{
  if (!FPreset   ) return;
  if (aName == "") return;
  try
  {
    TMcJsonItem* PrsList = FPreset->Values[C_PRESET_LIST];
    int Pos;
    if ( PresetNameExists(aName, Pos) )
      PrsList->Delete(Pos);
    PresetPersist();
  }
  catch (...)
  {
  }
}
//---------------------------------------------------------------------------
bool
TFormMain::PresetNameExists(const String& aName, int& Pos)
{
  Pos = -1;
  if ( FPreset->HasKey(C_PRESET_LIST) )
    Pos = FPreset->Values[C_PRESET_LIST]->IndexOf(aName);
  return (Pos >= 0);
}
//---------------------------------------------------------------------------
