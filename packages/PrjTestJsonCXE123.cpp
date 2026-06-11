//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include <tchar.h>

USEFORMNS("..\src\FoMainDx.pas", Fomaindx, FormMain);

//Error in CX 12.3: looses the line above when adding .pas files. Backup:
//USEFORMNS("..\src\FoMainDx.pas", Fomaindx, FormMain);
//---------------------------------------------------------------------------
#pragma link "IndySystem.bpi"
#pragma link "IndyCore.bpi"
#pragma link "dbrtl.bpi"
//#pragma link "rtl.bpi"
//---------------------------------------------------------------------------
int WINAPI _tWinMain(HINSTANCE, HINSTANCE, LPTSTR, int)
{
  try
  {
     Application->Initialize();
     Application->MainFormOnTaskBar = true;
     Application->CreateForm(__classid(TFormMain), &FormMain);
     Application->Run();
  }
  catch (Exception &exception)
  {
     Application->ShowException(&exception);
  }
  catch (...)
  {
     try
     {
       throw Exception("");
     }
     catch (Exception &exception)
     {
       Application->ShowException(&exception);
     }
  }
  return 0;
}
//---------------------------------------------------------------------------
