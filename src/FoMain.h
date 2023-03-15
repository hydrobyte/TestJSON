//---------------------------------------------------------------------------
#ifndef FoMainH
#define FoMainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <Vcl.Graphics.hpp>

#include "McJSON.hpp"
#include <Vcl.Buttons.hpp>

#include <vector>
//---------------------------------------------------------------------------
enum TLibType  {ltMc = 0, ltLk = 1, ltSj = 2, ltJd = 3, ltSo = 4,
                ltJt = 5, ltJs = 6, ltMy = 7, ltUj = 8};
enum TTestType {ttGene = 0, ttSave  = 1, ttParse = 2, ttClear = 3, ttLoad = 4,
                ttFind = 5, ttTotal = 6};
//---------------------------------------------------------------------------
class TFormMain : public TForm
{
__published:
  TButton *BtClose;
  TButton *BtRun;
  TPageControl *PageControl;
  TTabSheet *TabRun;
  TMemo *Memo;
  TTabSheet *TabConfig;
  TRadioGroup *RbgLib;
  TGroupBox *GbxTestConfig;
  TComboBox *CbxType;
  TLabel *LbType;
  TPageControl *PageControlTest;
  TTabSheet *TabSpeed;
  TTabSheet *TabValid;
  TCheckBox *ChbSpeedGen;
  TCheckBox *ChbSpeedLoad;
  TCheckBox *ChbSpeedParse;
  TCheckBox *ChbSpeedSave;
  TCheckBox *ChbSpeedFind;
  TEdit *EdSpeedFind;
  TEdit *EdSpeedSave;
  TEdit *EdSpeedLoad;
  TEdit *EdSpeedGen;
  TEdit *EdSpeedRep;
  TCheckBox *ChbSpeedProg;
  TLabel *LbValidFolder;
  TEdit *EdValidFolder;
  TCheckBox *ChbSpeedRep;
  TImage *ImgLogo;
  TLabel *LbTM;
  TLabel *LbVersion;
  TBevel *Bevel;
  TTabSheet *TabFOpen;
  TLabel *LbOpenFile;
  TEdit *EdFOpenFile;
  TCheckBox *ChbValidReport;
  TLabel *LbPreset;
  TComboBox *CbxPreset;
  TSpeedButton *SpeedButton1;
  TSpeedButton *BtDel;
  TCheckBox *ChbSpeedClear;
  void __fastcall BtCloseClick(TObject *Sender);
  void __fastcall BtRunClick(TObject *Sender);
  void __fastcall CbxTypeChange(TObject *Sender);
  void __fastcall FormDestroy(TObject *Sender);
  void __fastcall CbxPresetChange(TObject *Sender);
  void __fastcall BtPresetSaveClick(TObject *Sender);
  void __fastcall BtDelClick(TObject *Sender);
  void __fastcall SpeedChange(TObject *Sender);

public:
  __fastcall TFormMain(TComponent* Owner);

private:
  void* Json;
  void* JsonP;
  DWORD FdwStart, FdwLast;
  double FDtLast, FDtTotal;

  int FCountTest, FCountRepete;
  std::vector<double> FStat;
  TMcJsonItem* FPreset;
  bool FEventsFreezed;

  void DoStart();
  void DoFinish();
  void DoCreateMem();
  void DoDeleteMem();

  void DoTestSpeed();
  void DoSpeed();
  void DoSpeedAdd(const String& ASKey, const String& ASVal);
  void DoSpeedSave(const String& AFileName);
  void DoSpeedClear();
  void DoSpeedLoad(const String& AFileName);
  void DoSpeedCount(int& Count);
  bool DoSpeedFind(const String& ASKey, const String& ASVal);
  void DoSpeedParse();
  void DoSpeedStat();
  String GetSpeedAvg(const String& SPrfx, TTestType AType);
  int  CountSpeedSubtestSelected();

  void DoTestValid();
  void DoValid(const String& AFileName);
  TStringList* GetListJsonFiles(const String& ADir);

  void DoTestFOpen();
  void DoFOpen(const String& AFileName);
  void DoFOpenToStr(String& Str);

  void MyLog(const String& S);
  String GetMemAlc() const;

  void PresetLoadList();
  void PresetLoad(int aIndex);
  void PresetPersist();
  void PresetSave(const String& aName);
  void PresetDelete(const String& aName);
  bool PresetNameExists(const String& aName, int& Pos);
};
//---------------------------------------------------------------------------
extern PACKAGE TFormMain *FormMain;
//---------------------------------------------------------------------------
#endif
