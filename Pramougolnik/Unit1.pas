unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, ExtCtrls, GDIPAPI, GDIPOBJ;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    RectangleTimer: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RectangleTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  glX1,glX2,glY1,glY2,glColor, glHowLong:Integer;
  glColorR,glColorG,glColorB, glWidth:Integer;
  glFileName:String;
  CountTimer,MaxCountTimer:Integer;
  glFirstShow:Boolean;
  glgraphics : TGPGraphics;
  glPN: TGPPen;
  glOldX1,glOldX2,glOldY1,glOldY2:integer;

implementation

{$R *.dfm}

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


procedure DrawRectangle(Canvas: TCanvas; X1,Y1,X2,Y2: Integer; LW: Extended);
begin
   glgraphics.DrawRectangle(glPN, X1,Y1, X2-X1,Y2-Y1);
end;

procedure DrawArrowTimer();
begin
  CountTimer:=0;
  MaxCountTimer:=300;
  Form1.RectangleTimer.Enabled:=True;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
 Form1.Canvas.Pen.Color:=clGreen;
 Form1.Canvas.Brush.Color:=clGreen;
 Form1.Canvas.Pen.Width:=10;

 DrawRectangle(Form1.Canvas,10,200,800,400,10);
end;

procedure TForm1.FormCreate(Sender: TObject);
  var
    i: integer;
begin
  Application.ShowMainForm:=false;
  glgraphics := TGPGraphics.Create(Form1.Canvas.Handle);
  glPN := TGPPen.Create(MakeColor(255, 0, 0, 0));

  glgraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  glgraphics.SetCompositingQuality(CompositingQualityAssumeLinear);
  glgraphics.SetInterpolationMode(InterpolationModeHighQualityBilinear);

  Form1.Visible:=false;
 {
  if ParamCount = 0 then
  begin
    Form1.Close;
    ExitProcess(0);
  end;
 }

 //X1, Y1, X2, Y2, ????, ????????????,{??? ???? ?????(??????????????)}
 //???? ?? ????? ???? ???? ????, ?????? ???? ??????? exit

 glFirstShow:=True;

 glX1 := 100;
 glY1 := 300;
 glX2 := 1800;
 glY2 := 350;
 glHowLong:=30000;
 glColor := 255;
 glFileName:='';
 glWidth := 3;

 for i := 1 to ParamCount do
    begin
      if i=1 then
        glX1:=StrToInt(ParamStr(i));
      if i=2 then
        glY1:=StrToInt(ParamStr(i));
      if i=3 then
        glX2:=StrToInt(ParamStr(i));
      if i=4 then
        glY2:=StrToInt(ParamStr(i));
      if i=5 then
        glColorR:=StrToInt(ParamStr(i));
      if i=6 then
        glColorG:=StrToInt(ParamStr(i));
      if i=7 then
        glColorB:=StrToInt(ParamStr(i));
      if i=8 then
        glHowLong:=StrToInt(ParamStr(i));
      if i=9 then
        glWidth:=StrToInt(ParamStr(i));

      if LeftStr(ParamStr(i),13) = 'stopfilename=' then
      begin
        glFileName:=RightStr(ParamStr(i),Length(ParamStr(i))-13);
      end;

    end;

  DrawArrowTimer();

end;

procedure TForm1.RectangleTimerTimer(Sender: TObject);
  var
    OffsetX,OffsetY : integer;
    ResX,ResY : integer;
    Border:integer;
    Angle: Extended;
begin
  CountTimer:=CountTimer + Round(RectangleTimer.Interval);

  if glFileName <> '' then
  begin
    if FileExists(glFileName) then
    begin
      RectangleTimer.Enabled:=False;
      ExitProcess(0);
    end;

  end;


  if CountTimer >= glHowLong then
  begin
    //RectangleTimerTimer.Enabled:=False;
    ExitProcess(0);
  end;

  if CountTimer > MaxCountTimer then
  begin
    //ExitProcess(0);
    Exit;
  end;

  Border:=10;


  if glFirstShow then
  begin

    glFirstShow:=False;

    Form1.TransparentColorValue := TColor(1);
    Form1.Color := TColor(1);
    Form1.transparentcolor := true;

    Form1.BorderStyle := bsNone;
    Form1.Left:=1;
    Form1.Top:=1;
    Form1.Width:= Max(glX1,glX2)+Border*2;
    Form1.Height:=Max(glY1,glY2)+Border*2;


    Image1.Left:=0;
    Image1.Top:=0;
    Image1.Width:=Form1.Width;
    Image1.Height:=Form1.Height;


    Form1.Show;

    SetWindowPos(Form1.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
    SetWindowLong(Form1.Handle, GWL_EXSTYLE, GetWindowLong(Form1.Handle, GWL_EXSTYLE) or WS_EX_TRANSPARENT );
  end;



if (CountTimer + Round(RectangleTimer.Interval)) > MaxCountTimer then
  begin
   Form1.Refresh;
end;



  glgraphics := TGPGraphics.Create(Form1.Canvas.Handle);
  glPN := TGPPen.Create(MakeColor(255, glColorR, glColorG, glColorB));

  glgraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  glgraphics.SetCompositingQuality(CompositingQualityAssumeLinear);
  glgraphics.SetInterpolationMode(InterpolationModeHighQualityBilinear);

  glPN.SetWidth(glWidth);


  ResX:=glX1+OffsetX;
  ResY:=glY1+OffsetY;

  DrawRectangle(Form1.Canvas,glX1,glY1,glX2,glY2,10);

  glOldX1:=glX1;
  glOldY1:=glY1;
  glOldX2:=ResX;
  glOldY2:=ResY;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

end.
