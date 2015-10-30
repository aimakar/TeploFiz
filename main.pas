﻿unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComObj, ActiveX, WinProcs, Math;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Edit7: TEdit;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Edit8: TEdit;
    Button1: TButton;
    Button2: TButton;
    StringGrid1: TStringGrid;
    ComboBox1: TComboBox;
    OD: TOpenDialog;
    Label22: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  aa =  array of array of string;

var
  Form1: TForm1;
  Fdata : OleVariant;
  MyExcel: OleVariant;
  Flag: boolean;
  Data, RData : aa;
const
  ExcelApp = 'Excel.Application';

implementation

{$R *.dfm}
function CheckExcelInstall : boolean;
var
  ClassId: TCLSID;
  Rez : HRESULT;
begin
  Rez:= CLSIDFromProgID(PWideChar(WideString(ExcelApp)),ClassID);
  if Rez = S_OK then Result:=True
                else Result:=False;
end;

function CheckExcelRun: boolean;
begin
  try
    MyExcel:=GetActiveOleObject(ExcelApp);
    Result:=True;
  except
    Result:=false;
  end;
end;

function RunExcel(DisableAlerts:boolean=true; Visible: boolean=false): boolean;
begin
  try
{проверяем установлен ли Excel}
    if CheckExcelInstall then
      begin
        MyExcel:=CreateOleObject(ExcelApp);
//показывать/не показывать системные сообщения Excel
        MyExcel.Application.DisplayAlerts:= false;//DisableAlerts;
        MyExcel.Visible:=Visible;
       // SetForegroundWindow(MyExcel.Hwnd);
        Result:=true;
      end
    else
      begin
        MessageBox(0,'Приложение MS Excel не установлено на этом компьютере','Ошибка',MB_OK+MB_ICONERROR);
        Result:=false;
      end;
  except
    Result:=false;
  end;
end;

function OpenBook(AutoRun:boolean=true; path: string=''):boolean; // открывает новую книгу
begin
  if CheckExcelRun then
    begin
      MyExcel.WorkBooks.Open[path, 0, True];
      Flag:= false;
      Result:=true;
    end
  else
   if AutoRun then
     begin
       RunExcel;
       MyExcel.WorkBooks.Open[path, 0, True];
       Flag:=True;
       Result:=true;
     end
   else
     Result:=false;
end;


function closebook: boolean;
begin
  if Flag then
  begin
    MyExcel.Application.Quit;
    MyExcel:=UnAssigned;
  end;
end;

procedure FilGrid(param : string='');
var i,j,s: integer;
begin
s:=0;
j:=length(data[1])-1;
for i := 1 to j do
      begin
        Form1.StringGrid1.Rows[i].Clear;
      end;

if param='    Все термопары' then
  Begin
    for i := 0 to j do
      begin
        Form1.StringGrid1.Cells[0,i+1]:=Data[0,i];
        Form1.StringGrid1.Cells[1,i+1]:=Data[1,i];
        Form1.StringGrid1.Cells[2,i+1]:=Data[2,i];
        Form1.StringGrid1.Cells[3,i+1]:=Data[3,i];
        Form1.StringGrid1.Cells[4,i+1]:=Data[4,i];
      end;
  End
else
  begin
    for i := 0 to j do
      if Data[0,i] = param then
         begin
          Form1.StringGrid1.Cells[0,s+1]:=Data[0,i];
          Form1.StringGrid1.Cells[1,s+1]:=Data[1,i];
          Form1.StringGrid1.Cells[2,s+1]:=Data[2,i];
          Form1.StringGrid1.Cells[3,s+1]:=Data[3,i];
          Form1.StringGrid1.Cells[4,s+1]:=Data[4,i];
          s:=s+1;
        end;
  end;
Form1.StringGrid1.Row:=1;
Form1.StringGrid1.SetFocus;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
od.Execute();
Edit8.Text:=od.FileName;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  r1,r2,t,y,q,R,Q1,Q2,a1,l,c,a : real;
  i, z: integer;
  k2: string;
begin
  r1:=strtofloat(trim(Edit1.Text));
  r2:=strtofloat(trim(Edit2.Text));
  t:=strtofloat(trim(Edit3.Text));
  y:=strtofloat(trim(Edit4.Text));
  q:=strtofloat(trim(Edit5.Text));
  R:=strtofloat(trim(Edit6.Text));
  Q1:=strtofloat(trim(Edit7.Text));
  OpenBook(true, Edit8.Text);
  z:=strtoint(MyExcel.ActiveSheet.UsedRange.rows.Count);
  k2:='E'+inttostr(z-1);
  Fdata:=MyExcel.Range['D4',k2].Value;
  StringGrid1.RowCount:=z-4;
  SetLength(Data,5,StringGrid1.RowCount);
  MyExcel.ActiveWorkbook.Close;
  CloseBook;
for i := 1 to StringGrid1.RowCount do
begin
  Q2:=FData[i,2];
  a1:=(sqr(r2) - sqr(r1))/(4*t);
  l:=((q*R)/(2*(Q2-Q1)))*(((sqr(r2)-sqr(r1)))/(sqr(R)));
  c:=l/(a1*y);
  a:=sqr((l*c*y*R)/q);
  Data[0,i-1]:=VarToStr(FData[i,1]);
  Data[1,i-1]:= floatToStr(RoundTo(strtofloat(VarToStr(FData[i,2])), -2));
  Data[2,i-1]:=floattostr(RoundTo(l, -2));
  Data[3,i-1]:=floattostr(RoundTo(c, -2));
  Data[4,i-1]:=floattostr(RoundTo(a, -2));
end;
for i:= 0 to (StringGrid1.RowCount-1) do
  begin
    if Data[0,i]='Термопара 1' then Data[0,i]:='                        n1';
    if Data[0,i]='Термопара 2' then Data[0,i]:='                        n2';
    if Data[0,i]='Термопара 3' then Data[0,i]:='                        n3';
    if Data[0,i]='Термопара 4' then Data[0,i]:='                        n4';
  end;


  Combobox1.Visible:=true;
  FilGrid('    Все термопары');
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  FilGrid(ComboBox1.Text);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
StringGrid1.Cells[0,0]:='                   Термопара';
StringGrid1.Cells[1,0]:='                          Θ2';
StringGrid1.Cells[2,0]:='                          λ';
StringGrid1.Cells[3,0]:='                          c';
StringGrid1.Cells[4,0]:='                          a';
end;

end.
