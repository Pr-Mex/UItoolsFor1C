unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,Unit2;

type
  TForm1 = class(TForm)
    TimerMouseMove: TTimer;
    TimerShowControl: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TimerMouseMoveTimer(Sender: TObject);
    procedure TimerShowControlTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  CountTimer,MaxCountTimer:Integer;
  HandleOfClotrol:HWND;
  glStartX,glStartY:integer;
  glFirstShow:Boolean;
  gltimeshowframe:integer;
  tektimeshowframe:integer;


implementation

uses Math;

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




function GetFocusedWindow: HWND;
var 
CurrThID, ThID: DWORD; 
begin 
  result := GetForegroundWindow;
  if result <> 0 then
    begin
      CurrThID := GetCurrentThreadId;
      ThID := GetWindowThreadProcessId(result, // handle to window
      nil // process identifier
      );
      result := 0;
      if CurrThID = ThId then
      result := GetFocus
    else
      begin
        if AttachThreadInput(CurrThID, ThID, True) then
          begin
            result := GetFocus;
            AttachThreadInput(CurrThID, ThID, False);
          end;
      end;
    end;
end;



procedure DoMoveMouseToActiveControl(mousespeed:integer);
  var
    h:HWND;
    POINT:TPoint;
begin
  h:=GetFocusedWindow();
  if h > 0 then
  begin
    HandleOfClotrol:=h;


    GetCursorPos(POINT);
    glStartX:=POINT.X;
    glStartY:=POINT.Y;

    CountTimer:=0;
    MaxCountTimer:=mousespeed;
    Form1.TimerMouseMove.Enabled:=True;
    Exit;
  end;


  //ShowMessage('DoMoveMouseToActiveControl=' + IntToHex(h,8));


  ExitProcess(0);
end;


procedure DoShowFrameOfActiveControl(timeshowframe:integer);
 var
    h:HWND;
begin
  //Form1.TimerShowControl.Enabled:=True;
  h:=GetFocusedWindow();
  gltimeshowframe:=timeshowframe;
  tektimeshowframe:=0;

  //ShowMessage('h=' + IntToHex(h,8));

  if h > 0 then
  begin
    HandleOfClotrol:=h;
    Form1.TimerShowControl.Enabled:=True;
 end;

  if h = 0 then
    ExitProcess(0);


end;


procedure TForm1.FormCreate(Sender: TObject);
  var
    i:integer;
    NeedDoExitProcess:Boolean;
    showframeofactivecontrol:boolean;
    timeshowframe:integer;
begin

  if ParamCount = 0 then
  begin
    Form1.Close;
    ExitProcess(0);
  end;

  glFirstShow:=False;
  showframeofactivecontrol:=false;
  NeedDoExitProcess:=True;
  timeshowframe:=2000;//2 секунды




  for i := 1 to ParamCount do
    begin
      //ShowMessage('Параметр '+IntToStr(i)+' = '+ParamStr(i));
      if ParamStr(i) = '-showframeofactivecontrol' then
        begin
          showframeofactivecontrol:=true;
          NeedDoExitProcess:=False;
        end;

      if LeftStr(ParamStr(i),14) = 'timeshowframe=' then
      begin
        //ShowMessage(''+RightStr(ParamStr(i),Length(ParamStr(i))-11));
        timeshowframe:=StrToInt(RightStr(ParamStr(i),Length(ParamStr(i))-14));
      end;


    end;


    
  if NeedDoExitProcess then
    ExitProcess(0);



  if showframeofactivecontrol then
  begin
    DoShowFrameOfActiveControl(timeshowframe);
  end;



end;

procedure TForm1.TimerMouseMoveTimer(Sender: TObject);
  var
    Rect:TRect;
    Proc:Double;
    x,y:integer;
    //POINT:TPoint;
begin
  CountTimer:=CountTimer + Round(TimerMouseMove.Interval);

  if CountTimer >= MaxCountTimer then
  begin
    TimerMouseMove.Enabled:=False;

    GetWindowRect(HandleOfClotrol,Rect);
    SetCursorPos(Rect.Left,Rect.Bottom);

    ExitProcess(0);
  end;


  GetWindowRect(HandleOfClotrol,Rect);


  Proc:=RoundTo(CountTimer/MaxCountTimer,-2);

  //GetCursorPos(POINT);

  x:=glStartX + Round((Rect.Left   - glStartX)*Proc);
  y:=glStartY + Round((Rect.Bottom - glStartY)*Proc);

  SetCursorPos(x,y);

end;

procedure TForm1.TimerShowControlTimer(Sender: TObject);
  var
    Rect:TRect;
    Border:integer;
    PenWidth:integer;
begin
    tektimeshowframe:=tektimeshowframe + round(TimerShowControl.Interval);
    if tektimeshowframe >= gltimeshowframe then
    begin
      ExitProcess(0);
    end;



    Border:=100;
    GetWindowRect(HandleOfClotrol,Rect);
    Form2.Canvas.Pen.Color := clRed;
    Form2.Canvas.Pen.Width:=5;
    PenWidth:=Form2.Canvas.Pen.Width;

    if not glFirstShow then
    begin


      Form2.BorderStyle := bsNone;
      Form2.Left:=Rect.Left-Border;
      Form2.Top:=Rect.Top-Border;
      Form2.Width:=Rect.Right - Rect.Left + Border*2;
      Form2.Height:=Rect.Bottom - Rect.Top + Border*2;

      Form2.TransparentColorValue := clBlack;
      Form2.transparentcolor := true;
      Form2.Color := clBlack;

      glFirstShow:=True;
    end;

    SetWindowPos(Form2.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
    SetWindowLong(Form2.Handle, GWL_EXSTYLE, GetWindowLong(Form2.Handle, GWL_EXSTYLE) or WS_EX_TRANSPARENT );
    
    if not Form2.Visible then
      Form2.Visible:=True;




    //Form2.Canvas.Rectangle(Border-PenWidth,Border-PenWidth,Rect.Right - Rect.Left+Border + PenWidth,Rect.Bottom - Rect.Top+Border + PenWidth);
    Form2.Canvas.RoundRect(Border-PenWidth,Border-PenWidth,Rect.Right - Rect.Left+Border + PenWidth,Rect.Bottom - Rect.Top+Border + PenWidth,15,15);




end;

end.
