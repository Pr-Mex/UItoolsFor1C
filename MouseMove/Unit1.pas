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
  dolog:Boolean;
  logpath:String;

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
begin
  Form1.TimerShowControl.Enabled:=True;
end;


procedure TForm1.FormCreate(Sender: TObject);
  var
    i:integer;
    movemousetoactivecontrol:Boolean;
    NeedDoExitProcess:Boolean;
    //showframeofactivecontrol:boolean;
    mousespeed:integer;
    //timeshowframe:integer;
begin


  if ParamCount = 0 then
  begin
    Form1.Close;
    ExitProcess(0);
  end;

  
  movemousetoactivecontrol:=False;
  //showframeofactivecontrol:=false;
  NeedDoExitProcess:=True;
  mousespeed:=1000;//1 секунда
  //timeshowframe:=2000;//2 секунды


  dolog:=False;
  logpath:='';


  for i := 1 to ParamCount do
    begin
      //ShowMessage('Параметр '+IntToStr(i)+' = '+ParamStr(i));
      if ParamStr(i) = '-movemousetoactivecontrol' then
        begin
          movemousetoactivecontrol:=true;
          NeedDoExitProcess:=False;
        end;

      if LeftStr(ParamStr(i),11) = 'mousespeed=' then
      begin
        //ShowMessage(''+RightStr(ParamStr(i),Length(ParamStr(i))-11));
        mousespeed:=StrToInt(RightStr(ParamStr(i),Length(ParamStr(i))-11));
      end;

      if ParamStr(i) = '-dolog' then
        begin
          dolog:=true;
        end;

      if LeftStr(ParamStr(i),8) = 'logpath=' then
      begin
        //ShowMessage(''+RightStr(ParamStr(i),Length(ParamStr(i))-11));
        logpath:=RightStr(ParamStr(i),Length(ParamStr(i))-8);
      end;
    end;


    
  if NeedDoExitProcess then
    ExitProcess(0);


  if movemousetoactivecontrol then
  begin
    DoMoveMouseToActiveControl(mousespeed);
  end;

  {
  if showframeofactivecontrol then
  begin
    DoShowFrameOfActiveControl(timeshowframe);
  end;
  }



end;

procedure TForm1.TimerMouseMoveTimer(Sender: TObject);
  var
    Rect:TRect;
    Proc:Double;
    x,y:integer;
    //POINT:TPoint;
    f:TextFile;
    str:String;

    h:HWND;
    //POINT:TPoint;
begin

  h:=GetFocusedWindow();
  HandleOfClotrol:=h;
  //GetCursorPos(POINT);
  //glStartX:=POINT.X;
  //glStartY:=POINT.Y;

  CountTimer:=CountTimer + Round(TimerMouseMove.Interval);

  if CountTimer >= MaxCountTimer then
  begin
    TimerMouseMove.Enabled:=False;

    GetWindowRect(HandleOfClotrol,Rect);
    SetCursorPos(Rect.Left,Rect.Bottom);

    ExitProcess(0);
  end;


  GetWindowRect(HandleOfClotrol,Rect);

  if dolog then
  begin
    str:='Rect.Left=' + IntToStr(Rect.Left) + ', Rect.Bottom=' + IntToStr(Rect.Bottom) + ', Rect.Top=' + IntToStr(Rect.Top);
    AssignFile(f,logpath);
    Append(f);
    Writeln(f,str);
    Flush(f);
    CloseFile(f);
    dolog:=False;
  end;



  Proc:=RoundTo(CountTimer/MaxCountTimer,-2);

  //GetCursorPos(POINT);

  x:=glStartX + Round((Rect.Left   - glStartX)*Proc);
  y:=glStartY + Round((Rect.Bottom - glStartY)*Proc);

  SetCursorPos(x,y);

end;

procedure TForm1.TimerShowControlTimer(Sender: TObject);
begin
  Form2.Visible:=true;
end;

end.
