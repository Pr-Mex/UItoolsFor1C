unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    StartHook: TButton;
    StopHook: TButton;
    ListBox1: TListBox;
    DrawCircle: TButton;
    Timer1: TTimer;
    TimerStatus: TTimer;
    procedure StartHookClick(Sender: TObject);
    procedure StopHookClick(Sender: TObject);
    procedure DrawCircleClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerStatusTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure WMin (var b : TMessage); message $0401; 
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  glStartX,glStartY:integer;
  glCount,glMaxCount:integer;
  glColor:TColor;
  MaxR:integer;
  glFileName:string;
  procedure sethook;external 'MouseClickDLL.dll';
  procedure removehook;external 'MouseClickDLL.dll';

implementation

{$R *.dfm}

procedure HideForm();
begin
  Form1.TransparentColorValue := TColor(1);
  Form1.Color := TColor(1);
  Form1.transparentcolor := true;
  Form1.BorderStyle := bsNone;

end;


procedure TForm1.StartHookClick(Sender: TObject);
begin
 sethook();
end;

procedure TForm1.StopHookClick(Sender: TObject);
begin
  removehook;
end;

procedure TForm1.DrawCircleClick(Sender: TObject);
var
  Point: TPoint;
begin
  GetCursorPos(Point);
  glStartX:=Point.X;
  glStartY:=Point.Y;

  glCount:=0;
  glMaxCount:=24;
  MaxR:=20;

  HideForm();


  Form1.Left:=glStartX-100;
  Form1.Top:=glStartY-100;


  Form1.Canvas.Pen.Color:=TColor(glColor);
  Form1.Canvas.Brush.Color:=TColor(glColor);
  Form1.Canvas.Pen.Width:=10;



  Timer1.Enabled:=True;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
    Form1.DrawCircleClick(nil);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
  var
    x1,y1,x2,y2,R:integer;
begin
  Form1.Refresh;
  glCount:=glCount + 1;
  if glCount >= glMaxCount then
  begin
    Timer1.Enabled:=False;
    exit;
  end;

  SetWindowPos(Form1.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
  SetWindowLong(Form1.Handle, GWL_EXSTYLE, GetWindowLong(Form1.Handle, GWL_EXSTYLE) or WS_EX_TRANSPARENT );


  R:=round(glCount/glMaxCount*MaxR);
  x1:=glStartX - round(r/2) - Form1.Left;
  y1:=glStartY - round(r/2) - Form1.Top;
  x2:=glStartX + round(r/2) - Form1.Left;
  y2:=glStartY + round(r/2) - Form1.Top;


  Form1.Canvas.Ellipse(x1, y1, x2, y2);
end;

function LeftStr(S:String; Kol:Integer):String;
  var
    Res:String;
begin

  Res:=S;
  Delete(Res,Kol+1,Length(Res));

  LeftStr:=Res;
end;

function RightStr(S:String; Kol:Integer):String;
  var
    Res:String;
begin

  Res:=S;
  Delete(Res,1,Length(Res)-Kol);

  RightStr:=Res;
end;


procedure TForm1.FormCreate(Sender: TObject);
  var
    i:integer;
begin
  Form1.StartHookClick(nil);
  HideForm;
  glFileName:='';
  for i := 1 to ParamCount do
    begin
      if LeftStr(ParamStr(i),13) = 'stopfilename=' then
      begin
        glFileName:=RightStr(ParamStr(i),Length(ParamStr(i))-13);
      end;

    end;
end;

procedure TForm1.TimerStatusTimer(Sender: TObject);
  var lClick,rClick:boolean;
begin
  if glFileName <> '' then
  begin
    if FileExists(glFileName) then
    begin
      TimerStatus.Enabled:=False;
      ExitProcess(0);
    end;

  end;


  lClick:=False;
  rClick:=False;

  if lClick then
  begin
    glColor:=clLime;
  end;

  if rClick then
  begin
    glColor:=clNavy;
  end;


  if lClick or rClick then
  begin
    Form1.DrawCircleClick(nil);
  end;


end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
  Form1.Caption:=Form1.Caption + 'App';
end;

procedure TForm1.WMin(var b: TMessage);
begin

  if b.WParam = 1 then
  //left click
  begin
    glColor:=clLime;
    Form1.DrawCircleClick(nil);
  end;

  if b.WParam = 2 then
  //right click
  begin
    glColor:=clNavy;
    Form1.DrawCircleClick(nil);
  end;


end;

end.
