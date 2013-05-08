//---------------------------------------------------------------------------

#ifndef xymodemH
#define xymodemH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
#include "Inifiles.hpp"

#include "TSendThread.h"
#include "TMonitorThread.h"
#include "md5.h"

#define WM_STOPMYMESSAGE WM_USER+1
#define WM_CONTINUEMYMESSAGE WM_USER+2
#define WM_MONITORMESSAGE WM_USER+3

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TLabel *lbl1;
	TLabel *lbl2;
	TLabel *lbl3;
	TProgressBar *pb1;
	TLabel *lbl5;
	TEdit *edt1;
	TGroupBox *grp1;
	TComboBox *cbb1;
	TGroupBox *grp2;
	TComboBox *cbb2;
	TLabel *lbl4;
	TButton *btn1;
	TButton *btn2;
	TButton *btn3;
	TRadioGroup *rg1;
	TCheckBox *chk1;
	TOpenDialog *dlgOpen1;
	void __fastcall btn1Click(TObject *Sender);
	void __fastcall btn2Click(TObject *Sender);
	void __fastcall chk1Click(TObject *Sender);
	void __fastcall btn3Click(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	int __fastcall envicheck();
	virtual void __fastcall WndProc(TMessage &Message);
	UnicodeString __fastcall mygetmd5main();
	void __fastcall Str2Hexmain(unsigned char* strIndata, char* strOutdata);
	TSendThread *mysendthread;
	TMonitorThread *mymonitorthread;
	UnicodeString mymd5;
	MD5_CTX hashmd5main;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
