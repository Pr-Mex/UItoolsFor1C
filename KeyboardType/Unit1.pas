unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ClipBrd, ExtCtrls, StrUtils, Registry;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  CNT_LAYOUT = 2; // количество известных раскладок
  ENGLISH = $409;
  RUSSIAN = $419;

  Alphabet: array[0..32] of Char = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя';

  TKbdValue : array [1..CNT_LAYOUT] of LongWord =
                ( ENGLISH,
                  RUSSIAN
                );
  TKbdDisplayNames : array [1..CNT_LAYOUT] of string =
                ('English',
                 'Русский'
                );


type
    TMyClipboard = class(TClipboard);

type TArrOfChar = array of Char;

var
  Form1: TForm1;
  glArrOfChar:TArrOfChar;
  glID:integer;
  glTekLan:string;
  gltypespeed:integer;
  switchLangAltShift: boolean;

implementation

{$R *.dfm}


function ItsRussianLetter(S:String):boolean;
  var
    SmallChar:Char;
    SmallS:String;
    i:integer;
begin
   SmallS:=AnsiLowerCase(S);
   SmallChar:=SmallS[1];

  result:=false;
  for i := 0 to 32 do
  begin
     if SmallChar = Alphabet[i] then
     begin
       result:=true;
       exit;
     end;

  end;

end;

function ItsSwitchLangAltShift():boolean;
var
   Reestr: TRegistry;
   Param: String;
begin
     result:=false;
     Reestr:=TRegistry.Create;
     Reestr.RootKey:=HKEY_CURRENT_USER;
     If Reestr.OpenKey('\Keyboard Layout\Toggle', False)  Then
        Begin
            Param := Reestr.ReadString('Hotkey');
            If Param = '1' Then
                result:=true
            Else
                result:=false;

             Reestr.CloseKey;
        End;
  
   Reestr.Free;

end;

procedure DoAltShift();
begin
    keybd_event(VK_MENU, 0, 0, 0);
    keybd_event(VK_LSHIFT, 0, 0, 0);
    sleep(10);
    keybd_event(VK_LSHIFT, 0, KEYEVENTF_KEYUP, 0);
    keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0);
    sleep(100);
end;

procedure DoCtrlShift();
begin
    keybd_event(VK_LCONTROL, 0, 0, 0);
    keybd_event(VK_LSHIFT, 0, 0, 0);
    sleep(10);
    keybd_event(VK_LSHIFT, 0, KEYEVENTF_KEYUP, 0);
    keybd_event(VK_LCONTROL, 0, KEYEVENTF_KEYUP, 0);
    sleep(100);
end;


procedure DoSwitchLang();

begin
       If switchLangAltShift Then
            DoAltShift
       Else
           DoCtrlShift;

end;

procedure FullSwitchEng();
begin
   LoadKeyboardLayout(PChar('00000409'), KLF_ACTIVATE);
   DoSwitchLang;
   glTekLan:='en';
end;


procedure FullSwitchRus();
begin
   LoadKeyboardLayout(PChar('00000419'), KLF_ACTIVATE);
   DoSwitchLang;
   glTekLan:='ru';
end;



procedure SimulateKeyDown(Key : byte);
begin
    keybd_event(Key, 0, 0, 0);
    sleep(100);
end;

procedure SimulateKeyUp(Key : byte);
begin
    keybd_event(Key, 0, KEYEVENTF_KEYUP, 0);
    sleep(100);
end;

procedure SimulateKeystroke(Key : byte; extra : DWORD);
begin
    keybd_event(Key,extra,0,0);
    keybd_event(Key,extra,KEYEVENTF_KEYUP,0);
    sleep(10);
end;


procedure SendKeysHome();
var
    i : integer;
    flag : bool;
    w : word;
    s:string;
begin
    SimulateKeystroke(36, 0);
    exit;

    {Get the state of the caps lock key}
    flag := not GetKeyState(VK_CAPITAL) and 1 = 0;
    {If the caps lock key is on then turn it off}
    if flag then
        SimulateKeystroke(VK_CAPITAL, 0);
    for i := 1 to Length(s) do
        begin
            w := VkKeyScan(s[i]);
            {If there is not an error in the key translation}
            if ((HiByte(w) <> $FF) and (LoByte(w) <> $FF)) then
                begin
                    {If the key requires the shift key down - hold it down}
                    if HiByte(w) and 1 = 1 then
                        SimulateKeyDown(VK_SHIFT);
                        {Send the VK_KEY}
                    SimulateKeystroke(LoByte(w), 0);
                    {If the key required the shift key down - release it}
                    if HiByte(w) and 1 = 1 then
                        SimulateKeyUp(VK_SHIFT);
                end;
        end;
{if the caps lock key was on at start, turn it back on}
if flag then
    SimulateKeystroke(VK_CAPITAL, 0);
end;



procedure SendKeys(s : string);
var
    i : integer;
    flag : bool;
    w : word;
begin
    {Get the state of the caps lock key}
    flag := not GetKeyState(VK_CAPITAL) and 1 = 0;
    {If the caps lock key is on then turn it off}
    if flag then
        SimulateKeystroke(VK_CAPITAL, 0);
    for i := 1 to Length(s) do
        begin
            w := VkKeyScan(s[i]);
            {If there is not an error in the key translation}
            if ((HiByte(w) <> $FF) and (LoByte(w) <> $FF)) then
                begin
                    {If the key requires the shift key down - hold it down}
                    if HiByte(w) and 1 = 1 then
                        SimulateKeyDown(VK_SHIFT);
                        {Send the VK_KEY}
                    SimulateKeystroke(LoByte(w), 0);
                    {If the key required the shift key down - release it}
                    if HiByte(w) and 1 = 1 then
                        SimulateKeyUp(VK_SHIFT);
                end;
        end;
{if the caps lock key was on at start, turn it back on}
if flag then
    SimulateKeystroke(VK_CAPITAL, 0);
end;


procedure SendKeysMy(s : string);
var
    i : integer;
    flag : bool;
    w : word;
begin
    {Get the state of the caps lock key}
    flag := not GetKeyState(VK_CAPITAL) and 1 = 0;
    {If the caps lock key is on then turn it off}
    if flag then
        SimulateKeystroke(VK_CAPITAL, 0);
    for i := 1 to Length(s) do
        begin
            w := VkKeyScan(s[i]);
            {If there is not an error in the key translation}
            if ((HiByte(w) <> $FF) and (LoByte(w) <> $FF)) then
                begin
                    SimulateKeyDown(VK_CONTROL);
                    SimulateKeystroke(LoByte(w), 0);
                    SimulateKeyUp(VK_CONTROL);
                end;
        end;
{if the caps lock key was on at start, turn it back on}
if flag then
    SimulateKeystroke(VK_CAPITAL, 0);
end;



procedure PostKeyEx32(key: Word; const shift: TShiftState; specialkey: Boolean);
 {************************************************************
//????????? ??? ???????? ??????? ?????? ??????????
//????? ?????? http://delphiworld.narod.ru/base/keyboard_keys_down.html

* Procedure PostKeyEx32
*
* Parameters:
*  key    : virtual keycode of the key to send. For printable
*           keys this is simply the ANSI code (Ord(character)).
*  shift  : state of the modifier keys. This is a set, so you
*           can set several of these keys (shift, control, alt,
*           mouse buttons) in tandem. The TShiftState type is
*           declared in the Classes Unit.
*  specialkey: normally this should be False. Set it to True to
*           specify a key on the numeric keypad, for example.
* Description:
*  Uses keybd_event to manufacture a series of key events matching
*  the passed parameters. The events go to the control with focus.
*  Note that for characters key is always the upper-case version of
*  the character. Sending without any modifier keys will result in
*  a lower-case character, sending it with [ssShift] will result
*  in an upper-case character!
// Code by P. Below
************************************************************}
 type
   TShiftKeyInfo = record
     shift: Byte;
     vkey: Byte;
   end;
   byteset = set of 0..7;
 const
   shiftkeys: array [1..3] of TShiftKeyInfo =
     ((shift: Ord(ssCtrl); vkey: VK_CONTROL),
     (shift: Ord(ssShift); vkey: VK_SHIFT),
     (shift: Ord(ssAlt); vkey: VK_MENU));
 var
   flag: DWORD;
   bShift: ByteSet absolute shift;
   i: Integer;
begin
   for i := 1 to 3 do
   begin
     if shiftkeys[i].shift in bShift then
       keybd_event(shiftkeys[i].vkey, MapVirtualKey(shiftkeys[i].vkey, 0), 0, 0);
   end; { For }
   if specialkey then
     flag := KEYEVENTF_EXTENDEDKEY
   else
     flag := 0;

   keybd_event(key, MapvirtualKey(key, 0), flag, 0);
   flag := flag or KEYEVENTF_KEYUP;
   keybd_event(key, MapvirtualKey(key, 0), flag, 0);

   for i := 3 downto 1 do
   begin
     if shiftkeys[i].shift in bShift then
       keybd_event(shiftkeys[i].vkey, MapVirtualKey(shiftkeys[i].vkey, 0),
         KEYEVENTF_KEYUP, 0);
   end; { For }
end; { PostKeyEx32 }







const
 INVALIDKEY       = $FFFF;
 VKKEYSCANSHIFTON = $100;
 VKKEYSCANCTRLON  = $200;
 VKKEYSCANALTON   = $400;

procedure SendKeyDown(VKey: Byte; NumTimes: Word; GenUpMsg: Boolean);
var
 i: Integer;
 ScanCode: Byte;
begin
 ScanCode:= Lo(MapVirtualKey(VKey,0));
 for i:= 1 to NumTimes do begin
   keybd_event(VKey, ScanCode, 0, 0);
   if GenUpMsg then
     keybd_event(VKey, ScanCode, KEYEVENTF_KEYUP, 0);
 end;
end;

procedure SendKeyUp(VKey: Byte);
var
 ScanCode: Byte;
begin
 ScanCode:= Lo(MapVirtualKey(VKey,0));
 keybd_event(VKey, ScanCode, KEYEVENTF_KEYUP, 0);
end;



function PressChar(Ch: Char; NumTimes: Integer): Boolean;
var
 MKey: Word;
begin
 MKey:= Word(VkKeyScan(Ch));
 if MKey <> INVALIDKEY then begin
   if MKey and VKKEYSCANSHIFTON <> 0 then SendKeyDown(VK_SHIFT, 1, False);
   if MKey and VKKEYSCANCTRLON <> 0  then SendKeyDown(VK_CONTROL, 1, False);
   if MKey and VKKEYSCANALTON <> 0   then SendKeyDown(VK_MENU, 1, False);
   SendKeyDown(Lo(MKey), NumTimes, true);
   if MKey and VKKEYSCANSHIFTON <> 0 then SendKeyUp(VK_SHIFT);
   if MKey and VKKEYSCANCTRLON <> 0  then SendKeyUp(VK_CONTROL);
   if MKey and VKKEYSCANALTON <> 0   then SendKeyUp(VK_MENU);
   result:= true;
 end else
   result:= false;
end;

{
procedure TForm1.Memo1Click(Sender: TObject);
begin
 PressChar("Б", 1);
 PressChar("ю", 2);
end;
}



procedure BufferToClipboard(Buffer: WideString;var AllOk:Boolean);
var WideBuffer: WideString;
    BuffSize: Cardinal;
    Data: THandle;
    DataPtr: Pointer;
begin
  AllOk:=true;
  if Buffer <> '' then begin
    WideBuffer := Buffer;
    BuffSize := length(Buffer) * SizeOf(WideChar);
    Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE+GMEM_ZEROINIT, BuffSize + 2);
    try
      DataPtr := GlobalLock(Data);
      try
        Move(PWideChar(WideBuffer)^, Pointer(Cardinal(DataPtr))^, BuffSize);
      finally
        GlobalUnlock(Data);
      end;
      Clipboard.SetAsHandle(CF_UNICODETEXT, Data);
    except
      GlobalFree(Data);
      AllOk:=false;
      //raise;
    end;
  end;
end;








function NameKeyboardLayout(layout : LongWord) : string;
var
  i: integer;
begin
  Result:='';
  try
    for i:=1 to CNT_LAYOUT do
      if TKbdValue[i]=layout then Result:= TKbdDisplayNames[i];
  except
    Result:='';
  end;
end;
//**************** end of NameKeyboardLayot ***************************
{активная раскладка в своей программе}
function GetActiveKbdLayout : LongWord;
begin
  result:= GetKeyboardLayout(0) shr $10;
end;
//***************** end of GetActiveKbdLayot ****************************
{активная раскладка в активном окне}
function GetActiveKbdLayoutWnd : LongWord;
var
  hWindow,idProcess : THandle;
begin
  // получить handle активного окна чужой программы
  hWindow := GetForegroundWindow;
  // Получить идентификатор чужого процесса
  idProcess := GetWindowThreadProcessId(hWindow,nil);
  // Получить текущую раскладку в чужой программе
  Result:=(GetKeyboardLayout(idProcess) shr $10);
end;



{установить раскладку в своей программе}
procedure SetKbdLayout(kbLayout : LongWord);
var
  Layout: HKL;
begin
  // Получить ссылку на раскладку
  Layout:=LoadKeyboardLayout(PChar(IntToStr(kbLayout)), 0);
  // Переключить раскладку на русскую
  ActivateKeyboardLayout(Layout,KLF_ACTIVATE);
end;
//****************** end of SetKbdLayot **********************************
{установить раскладку в активном окне}
procedure SetLayoutActiveWnd(kbLayout : LongWord);
var 
  Layout: HKL;
  hWindow{, idProcess} : THandle; // ION T: не используется
begin
  // получить handle активного окна чужой программы
  hWindow := GetForegroundWindow;
  // Получить ссылку на раскладку
  Layout:=LoadKeyboardLayout(PChar(IntToStr(kbLayout)), 0);
  // посылаем сообщение о смене раскладки
  sendMessage(hWindow,WM_INPUTLANGCHANGEREQUEST,1,Layout);
end;



procedure TForm1.Button1Click(Sender: TObject);
  var
    f:textFile;
    str:String;
    i:integer;
    //h:hwnd;
    //vLangID :LANGID;
    Kol,id:integer;
    AllOk:Boolean;
    TekRaskladka:String;
begin
  //TekLan:='en';

  sleep(2000);
  //LoadKeyboardLayout('00000409', KLF_ACTIVATE);


  {активная раскладка в активном окне}
    Memo1.Lines.Add(NameKeyboardLayout(GetActiveKbdLayoutWnd));
  {активная раскладка в своей программе}
  Memo1.Lines.Add(NameKeyboardLayout(GetActiveKbdLayout));

  {установить раскладку в своей программе}
    //SetKbdLayout(ENGLISH);
  {установить раскладку в активном окне}
    //SetLayoutActiveWnd(ENGLISH);

  TekRaskladka:=  NameKeyboardLayout(GetActiveKbdLayoutWnd);
  if TekRaskladka = 'Русский' then
  begin
    FullSwitchEng();
  end;

  glTekLan:='en';



  AssignFile(f, 'C:\Temp\Example01Header.feature');

  Kol:=0;
  Reset(f);
  while Not EOF(f) do
  begin
    readLn(f, str);
    Kol:=Kol+1 + Length(str);
  end;

  SetLength(glArrOfChar,Kol-1);

  id:=-1;
  Reset(f);
  while Not EOF(f) do
  begin
    readLn(f, str);
    for i := 1 to Length(str) do
    begin
      inc(id);
      glArrOfChar[id]:=str[i];
    end;

    if not EOF(f) then
    begin
      inc(id);
      glArrOfChar[id]:=chr(VK_RETURN);
    end;

  end;

  CloseFile(f);



  glID:=-1;
  timer1.Enabled:=true;
  exit;






  {
 PressChar('Б', 1);
 PressChar('ю', 2);
 exit;
   }
//   Memo1.Lines.Add(IntToStr(Ord('Б')));


  //SendKeys('Delphi Is RAD!');
  //exit;

  //Clipboard.Open;

   {
  BufferToClipboard('йцу');
  SendKeysMy('v');
  exit;
    }

  AssignFile(f, 'C:\Temp\key.txt');
  Reset(f);

//with TMyClipboard(Clipboard) do begin
//  Open;

  LoadKeyboardLayout('00000409', KLF_ACTIVATE);

  while Not EOF(f) do
  begin
    readLn(f, str);
    for i := 1 to Length(str) do
    begin
      Memo1.Lines.Add(str[i]);

       BufferToClipboard(str[i],AllOk);
      //Clipboard.AsText := str[i];
      {
      h := Clipboard.GetAsHandle(CF_TEXT);
      SetClipboardData(CF_LOCALE, h);
       }

        {
        AsText := str[i];

        vLangID := GetUserDefaultLangID;
        SetBuffer(CF_LOCALE, vLangID, SizeOf(vLangID));
        }

        SendKeysMy('v');

      //PostKeyEx32(ord('c'),[ssCtrl],false);
      //PressChar(str[i],1);
      //Memo1.Lines.Add(IntToStr(Ord(Str[i])));
      sleep(400);
    end;

    SendKeys(Chr(VK_RETURN));
    SendKeys(Chr(VK_HOME));


  end;

  CloseFile(f);
  Clipboard.Close;
//end;
  //sleep(4000);
  //SendKeys('Delphi Is RAD!');
end;




procedure TForm1.Timer1Timer(Sender: TObject);
  var
    //AllOk:Boolean;
    //Ch:Char;
    //s:string;
    //Kbd: HKL;
   //Layout: array[0.. KL_NAMELENGTH] of char;
   ItsRussian:Boolean;
   KeyPressed:Boolean;
begin
  glID:=glID+1;

  KeyPressed:=False;





  if ord(glArrOfChar[glID]) = 13 then //enter
    begin
       SendKeys(glArrOfChar[glID]);
       SendKeysHome();
       KeyPressed:=True;
       sleep(1000);
    end;

    
   if not KeyPressed then
   begin
     if ord(glArrOfChar[glID]) = 32 then //пробел
     begin
       SendKeys(glArrOfChar[glID]);
       KeyPressed:=True;
     end;

   end;


   if not KeyPressed then
    begin
      ItsRussian:=ItsRussianLetter(glArrOfChar[glID]);
      if ItsRussian and (glTekLan = 'en') then
      begin
        FullSwitchRus;
      end;

      if (not ItsRussian) and (glTekLan = 'ru') then
      begin
        FullSwitchEng;
      end;

      SendKeys(glArrOfChar[glID]);
    end;



  if glID = (Length(glArrOfChar)-1) then
  begin
    Timer1.Enabled:=False;
    ExitProcess(0);
  end;


end;

procedure TForm1.FormCreate(Sender: TObject);
  var
    i:integer;
    filename:string;
    TekRaskladka:String;
    f:textFile;
    Kol,id:integer;
    str:string;
begin
  if ParamCount = 0 then
  begin
    Form1.Close;
    ExitProcess(0);
    //Exit;
  end;

  gltypespeed:=100;
  filename:='';
  switchLangAltShift:= ItsSwitchLangAltShift();

  for i := 1 to ParamCount do
    begin
      if LeftStr(ParamStr(i),10) = 'typespeed=' then
        begin
          gltypespeed:=StrToInt(RightStr(ParamStr(i),Length(ParamStr(i))-10));
          timer1.Interval:=gltypespeed;
        end;

      if LeftStr(ParamStr(i),9) = 'filename=' then
      begin
        filename:=RightStr(ParamStr(i),Length(ParamStr(i))-9);
      end;

    end;

   if filename = '' then
   begin
     Form1.Visible:=True;
     exit;
   end;






  TekRaskladka:=  NameKeyboardLayout(GetActiveKbdLayoutWnd);
  if TekRaskladka = 'Русский' then
  begin
    FullSwitchEng();
  end;

  glTekLan:='en';








  AssignFile(f, filename);

  Kol:=0;
  Reset(f);
  while Not EOF(f) do
  begin
    readLn(f, str);
    Kol:=Kol+1 + Length(str);
  end;

  SetLength(glArrOfChar,Kol-1);

  id:=-1;
  Reset(f);
  while Not EOF(f) do
  begin
    readLn(f, str);
    for i := 1 to Length(str) do
    begin
      inc(id);
      glArrOfChar[id]:=str[i];
    end;

    if not EOF(f) then
    begin
      inc(id);
      glArrOfChar[id]:=chr(VK_RETURN);
    end;

  end;

  CloseFile(f);



  glID:=-1;
  timer1.Enabled:=true;


end;

end.
