unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, ExtCtrls, GDIPAPI, GDIPOBJ;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ArrowTimer: TTimer;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ArrowTimerTimer(Sender: TObject);
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


procedure DrawArrowHead(Canvas: TCanvas; X,Y: Integer; Angle,LW: Extended);
var
  A1,A2, coef,Beta: Extended;
  Arrow: array[0..3] of TPoint;
  OldWidth: Integer;
const
  LineLen=4.74;
  CentLen=3;
begin

  if glWidth < 10 then
    coef := glWidth/5;
  if glWidth >= 10 then
     coef := glWidth/10;

  Beta :=0.322 * coef;
  Angle:=Pi+Angle;
  Arrow[0]:=Point(X,Y);
  A1:=Angle-Beta;
  A2:=Angle+Beta;
  Arrow[1]:=Point(X+Round(LineLen*LW*Cos(A1)),Y-Round(LineLen*LW*Sin(A1)));
  Arrow[2]:=Point(X+Round(CentLen*LW*Cos(Angle)),Y-Round(CentLen*LW*Sin(Angle)));
  Arrow[3]:=Point(X+Round(LineLen*LW*Cos(A2)),Y-Round(LineLen*LW*Sin(A2)));
  OldWidth:=Canvas.Pen.Width;
  Canvas.Pen.Width:=1;
  Canvas.Polygon(Arrow);
  Canvas.Pen.Width:=OldWidth
end;

procedure DrawArrow(Canvas: TCanvas; X1,Y1,X2,Y2: Integer; LW: Extended);
var
  Angle: Extended;
begin
  Angle:=ArcTan2(Y1-Y2,X2-X1);
  //Canvas.MoveTo(X1,Y1);
  //Canvas.LineTo(X2-Round(2*LW*Cos(Angle)),Y2+Round(2*LW*Sin(Angle)));
  glgraphics.DrawLine(glPN, X1,Y1, X2-Round(2*LW*Cos(Angle)),Y2+Round(2*LW*Sin(Angle)));
  //glgraphics.DrawLine(glPN, 100, 330, 1800, 430);

  DrawArrowHead(Canvas,X2,Y2,Angle,LW);
end;

procedure DrawArrowTimer();
begin
  CountTimer:=0;
  MaxCountTimer:=300;
  Form1.ArrowTimer.Enabled:=True;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
 Form1.Canvas.Pen.Color:=clGreen;
 Form1.Canvas.Brush.Color:=clGreen;
 Form1.Canvas.Pen.Width:=10;

 DrawArrow(Form1.Canvas,10,200,800,400,10);
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

 //X1, Y1, X2, Y2, Цвет, Длительность,{Имя стоп файла(необязательный)}
 //если на диске есть стоп файл, значит надо сделать exit

 glFirstShow:=True;

 glX1 := 100;
 glY1 := 300;
 glX2 := 1800;
 glY2 := 350;
 glHowLong:=30000;
 glColor := 255;
 glFileName:='';
 glWidth := 10;

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

procedure CopyScreenToImage();
var
  bm: TBitMap;
  ms: TMemoryStream;
begin
    bm := TBitMap.Create;
    bm.Width := Form1.Width; // ширина холста
    bm.Height := Form1.Height; // длина холста
    BitBlt(bm.Canvas.Handle, 0, 0,  bm.Width, bm.Height,
    GetDC(0), Form1.Left, Form1.Top, SRCCOPY); // 0, 0,  bm.Width, bm.Height здесь это та часть экрана
    // которую нужно копировать

    ms := TMemoryStream.Create;
    bm.SaveToStream(ms);
    ms.Position := 0;
    Form1.Image1.Picture.Bitmap.LoadFromStream(ms);
    bm.Destroy;
    ms.Free;

end;


procedure TForm1.ArrowTimerTimer(Sender: TObject);
  var
    OffsetX,OffsetY : integer;
    ResX,ResY : integer;
    Border:integer;
    Angle: Extended;
begin
  CountTimer:=CountTimer + Round(ArrowTimer.Interval);

  if glFileName <> '' then
  begin
    if FileExists(glFileName) then
    begin
      ArrowTimer.Enabled:=False;
      ExitProcess(0);
    end;

  end;


  if CountTimer >= glHowLong then
  begin
    ArrowTimer.Enabled:=False;
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
    Form1.Width:= Max(glX1,glX2)+Border*3;
    Form1.Height:=Max(glY1,glY2)+Border*3;


    Image1.Left:=0;
    Image1.Top:=0;
    Image1.Width:=Form1.Width;
    Image1.Height:=Form1.Height;

    CopyScreenToImage();

    Form1.Show;
    
    SetWindowPos(Form1.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
    SetWindowLong(Form1.Handle, GWL_EXSTYLE, GetWindowLong(Form1.Handle, GWL_EXSTYLE) or WS_EX_TRANSPARENT );
  end
  else
  begin
    Form1.Canvas.Pen.Color:=TColor(1);
    Form1.Canvas.Brush.Color:=TColor(1);
    Form1.Canvas.Pen.Width:=10;

    Angle:=ArcTan2(glOldY1-glOldY2,glOldX2-glOldX1);
    DrawArrowHead(Form1.Canvas,glOldX2,glOldY2,Angle,10);
  end;



  Form1.Canvas.Pen.Color:=RGB(glColorR,glColorG,glColorB);
  Form1.Canvas.Brush.Color:=RGB(glColorR,glColorG,glColorB);
  Form1.Canvas.Pen.Width:=10;


  OffsetX:= Round((CountTimer/MaxCountTimer)*(glX2-glX1));
  OffsetY:= Round((CountTimer/MaxCountTimer)*(glY2-glY1));

  if (CountTimer + Round(ArrowTimer.Interval)) > MaxCountTimer then
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



  DrawArrow(Form1.Canvas,glX1,glY1,ResX,ResY,10);
  
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
