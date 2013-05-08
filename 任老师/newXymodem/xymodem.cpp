//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
//download by http://www.codefans.net
#include "xymodem.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btn1Click(TObject *Sender)
{
	dlgOpen1->Execute();
	edt1->Text = dlgOpen1->FileName;
	lbl4->Caption = "无";
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btn2Click(TObject *Sender)
{
	if(envicheck())
	{
		MessageBox(NULL, L"请设置选项，设置完成后再次点击传输键", L"警告", MB_OK);
		return;
	}
	mysendthread = new TSendThread(this, false);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::chk1Click(TObject *Sender)
{
	if(chk1->Checked == false)
	{
		if(mysendthread)
		{
			::TerminateThread((HANDLE)mysendthread->Handle,0);
			delete mysendthread;
			mysendthread = NULL;
		}
		if(mymonitorthread)
		{
			::TerminateThread((HANDLE)mymonitorthread->Handle,0);
			delete mymonitorthread;
			mymonitorthread = NULL;
		}
		btn2->Enabled = true;
	}
	else
	{
		if(envicheck())
		{
			MessageBox(NULL, L"请设置选项，设置完成后再次点击自动传输", L"警告", MB_OK);
			chk1->Checked = false;
			return;
		}
		btn2->Enabled = false;
		if(mysendthread)
		{
			::TerminateThread((HANDLE)mysendthread->Handle,0);
			delete mysendthread;
			mysendthread = NULL;
		}
		if(mymonitorthread)
		{
			::TerminateThread((HANDLE)mymonitorthread->Handle,0);
			delete mymonitorthread;
			mymonitorthread = NULL;
		}
		mymonitorthread = new TMonitorThread(this, false);
		//mysendthread = new TSendThread(this, false);
	}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btn3Click(TObject *Sender)
{
	chk1->Checked = false;
	if(mysendthread)
	{
		::TerminateThread((HANDLE)mysendthread->Handle,0);
		delete mysendthread;
		mysendthread = NULL;
	}
	if(mymonitorthread)
	{
		::TerminateThread((HANDLE)mymonitorthread->Handle,0);
		delete mymonitorthread;
		mymonitorthread = NULL;
	}
	btn2->Enabled = true;
	pb1->Position = 0;
	lbl4->Caption = "无！";
}
//---------------------------------------------------------------------------
int __fastcall TForm1::envicheck()
{
	//---- Place thread code here ----
	//检查选项是否选择
	if(cbb1->Text==""||cbb2->Text==""||rg1->ItemIndex==-1)
	{
		return -1;
	}
	//检查文件能否打开
	int ifilehandle;
	ifilehandle = FileOpen(edt1->Text.w_str(), fmOpenRead);
	if(ifilehandle == -1)
	{
		FileClose(ifilehandle);
		return -1;
	}
	FileClose(ifilehandle);
	return 0;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
	chk1->Checked = false;
	UnicodeString path;
    path = ExtractFilePath(Application->ExeName) + "yxmodemconfig.ini";
	TIniFile *Ini = new TIniFile(path);
    try
    {
        edt1->Text = Ini->ReadString("file", "name", "");
        mymd5 = Ini->ReadString("file", "md5", "");
        cbb1->ItemIndex = Ini->ReadInteger("com", "port", -1);
        cbb2->ItemIndex = Ini->ReadInteger("com", "baud", -1);
        //rg1->ItemIndex = Ini->ReadInteger("com", "modem", -1);
    }
    __finally
    {
        delete Ini;
	}
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
	if(mysendthread)
	{
		::TerminateThread((HANDLE)mysendthread->Handle,0);
		delete mysendthread;
		mysendthread = NULL;
	}
	if(mymonitorthread)
	{
		::TerminateThread((HANDLE)mymonitorthread->Handle,0);
		delete mymonitorthread;
		mymonitorthread = NULL;
	}
	UnicodeString path;
    path = ExtractFilePath(Application->ExeName) + "yxmodemconfig.ini";
    TIniFile *Ini = new TIniFile(path);
    try
    {
        Ini->WriteString("file", "name", edt1->Text);
        Ini->WriteString("file", "md5", mymd5);
        Ini->WriteInteger("com", "port", cbb1->ItemIndex);
        Ini->WriteInteger("com", "baud", cbb2->ItemIndex);
		//Ini->WriteInteger("com", "modem", rg1->ItemIndex);
    }
    __finally
    {
        delete Ini;
	}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::WndProc(TMessage &Message)
{
	switch(Message.Msg)
    {
		case WM_CONTINUEMYMESSAGE:
			mymd5 = mygetmd5main();
			if(mymonitorthread)
			{
				::TerminateThread((HANDLE)mymonitorthread->Handle,0);
				delete mymonitorthread;
				mymonitorthread = NULL;
			}
			mymonitorthread = new TMonitorThread(this, false);
			break;
		case WM_STOPMYMESSAGE:
			mymd5 = mygetmd5main();
			break;
		case WM_MONITORMESSAGE:
			mymd5 = mygetmd5main();
			if(mysendthread)
			{
				::TerminateThread((HANDLE)mysendthread->Handle,0);
				delete mysendthread;
				mysendthread = NULL;
			}
			mysendthread = new TSendThread(this, false);
			break;
        default:
        	break;
    }
    TForm::WndProc(Message);
}
//---------------------------------------------------------------------------
UnicodeString __fastcall TForm1::mygetmd5main()
{
    int ifilehandle, ifilelength;
	ifilehandle = FileOpen(edt1->Text.w_str(), fmOpenRead);
    if(ifilehandle == -1)
	{
        FileClose(ifilehandle);;
        return "error";
    }
	ifilelength = FileSeek(ifilehandle, 0, 2);
    FileSeek(ifilehandle, 0, 0);
    char *filedata;
    char digest[16];
    char tempmd5[32];
    filedata = new char[ifilelength + 1];
    memset(filedata, 0, ifilelength + 1);
    FileRead(ifilehandle, filedata, ifilelength);
	hashmd5main.MD5Update(filedata, ifilelength);
	hashmd5main.MD5Final(digest);
	Str2Hexmain(digest, tempmd5);
	//UnicodeString lastmd5;
	//lastmd5.SetLength(32);
	//memcpy(lastmd5.w_str(),tempmd5, 32);
	FileClose(ifilehandle);
	delete[] filedata;
	filedata = NULL;
	return tempmd5;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Str2Hexmain(unsigned char* strIndata, char* strOutdata)
{
	int i;
    char szHex[3]="";
    int len = strlen(strIndata);
    char tempHexStr[101]="";
    for(i=0; i<16; i++)
    {
        if((strIndata[i]/16) >= 0 && (strIndata[i]/16) <= 9)
		{
            szHex[0] = '0' + (strIndata[i]/16);
        }
        else
        {
            szHex[0] = 'a' + (strIndata[i]/16) - 10;
		}

        if((strIndata[i]%16) >= 0 && (strIndata[i]%16) <= 9)
		{
            szHex[1] = '0' + (strIndata[i]%16);
        }
        else
        {
            szHex[1] = 'a' + (strIndata[i]%16) - 10;
        }
		szHex[2] = 0;
		strcat(tempHexStr, szHex);
	}
	tempHexStr[len * 2] = 0;
	strcpy(strOutdata, tempHexStr);
}
