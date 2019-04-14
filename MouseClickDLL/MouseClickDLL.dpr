library MouseClickDLL;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  windows,messages,SysUtils,Dialogs;
var
  H : THandle;
  glRightClick:boolean;
  glLeftClick:boolean;


function hook(c0de, wParam, lParam : integer): Lresult; stdcall;
var
 h1: HWND;
begin
{Если c0de не меньше 0, все в порядке, продолжаем}
if c0de >= 0 then
begin
  case wParam of
  WM_RBUTTONUP :
    begin
      h1 := findwindow(nil, 'MouseClickEventApp');
      if h1 <> 0 then
      begin
        PostMessage(h1,$0401,2,0);
      end;
    end;

  WM_LBUTTONUP:
    begin
      h1 := findwindow(nil, 'MouseClickEventApp');
      if h1 <> 0 then
      begin
        PostMessage(h1,$0401,1,0);
      end;
    end;

  end;

end
 else
//Если c0de меньше 0
  begin
    result := CallNextHookEx(H, c0de, wParam, lParam);
    exit;
  end;
  result := CallNextHookEx(H, c0de, wParam, lParam);
end;

procedure sethook();
begin
glRightClick:=False;
glLeftClick:=False;
H:= SetWindowsHookEx(WH_MOUSE, @hook, hInstance, 0);
if H = 0 then
  messagebox(0,'No hook set.','ERROR',MB_ICONERROR);
end;

procedure removehook;
begin
  UnhookWindowsHookEx(H);
end;

procedure GetStatus(var lClick,rClick:boolean);
begin
  if glRightClick then
  begin
    rClick:=True;
    glRightClick:=False;
  end;

  if glLeftClick then
  begin
    lClick:=True;
    glLeftClick:=False;
  end;

end;


exports
sethook index 1  name 'sethook',
removehook index 2 name 'removehook';
end.


