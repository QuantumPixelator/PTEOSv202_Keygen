program TEOS_Keygen;

{$MODE DELPHI}
{$APPTYPE GUI}

uses
  Windows;

const
  EDIT_SYSOP = 101;
  EDIT_BBS   = 102;
  BTN_GEN    = 103;
  EDIT_KEY   = 104;

  WND_W = 380;
  WND_H = 242;

function ComputeKey(const SysopName, BBSName: AnsiString): LongWord;
var
  Sysop, BBS : AnsiString;
  Seed       : Int64;
  i, c       : Integer;
begin
  { Uppercase both names — same as what PLANCFG.EXE does via 1174:1AC2 }
  SetLength(Sysop, Length(SysopName));
  for i := 1 to Length(SysopName) do
    if SysopName[i] in ['a'..'z'] then
      Sysop[i] := Chr(Ord(SysopName[i]) - 32)
    else
      Sysop[i] := SysopName[i];

  SetLength(BBS, Length(BBSName));
  for i := 1 to Length(BBSName) do
    if BBSName[i] in ['a'..'z'] then
      BBS[i] := Chr(Ord(BBSName[i]) - 32)
    else
      BBS[i] := BBSName[i];

  Seed := 4;

  { Loop 1 — Sysop name: always add char; at even index also add char div index }
  for i := 1 to Length(Sysop) do
  begin
    c := Ord(Sysop[i]);
    Inc(Seed, c);
    if (i mod 2 = 0) then
      Inc(Seed, c div i);
  end;

  { Loop 2 — BBS name: always add char; at odd index also add i then seed div i }
  for i := 1 to Length(BBS) do
  begin
    c := Ord(BBS[i]);
    Inc(Seed, c);
    if (i mod 2 = 1) then
    begin
      Inc(Seed, i);
      Inc(Seed, Seed div i);
    end;
  end;

  { Post-scale: bring small seeds up to a useful range }
  if Seed < 1000 then Seed := Seed * 17;
  if Seed < 3000 then Seed := Seed * 11;
  if Seed < 7000 then Seed := Seed * 4;

  Result := LongWord(Seed and $FFFFFFFF);
end;

procedure Generate(hWnd: HWND);
var
  SysopBuf, BBSBuf : array[0..255] of AnsiChar;
  Key    : LongWord;
  KeyStr : AnsiString;
begin
  GetWindowTextA(GetDlgItem(hWnd, EDIT_SYSOP), SysopBuf, 255);
  GetWindowTextA(GetDlgItem(hWnd, EDIT_BBS),   BBSBuf,   255);

  if (SysopBuf[0] = #0) or (BBSBuf[0] = #0) then
  begin
    MessageBoxA(hWnd,
      'Please enter both Sysop Real Name and BBS Name.',
      'Input Required',
      MB_OK or MB_ICONWARNING);
    Exit;
  end;

  Key := ComputeKey(AnsiString(SysopBuf), AnsiString(BBSBuf));
  Str(Key, KeyStr);
  SetWindowTextA(GetDlgItem(hWnd, EDIT_KEY), PAnsiChar(KeyStr));
end;

{ ── Layout constants ────────────────────────────── }
const
  LBL_X = 12;   LBL_W = 136;  LBL_H = 18;
  EDT_X = 152;  EDT_W = 212;  EDT_H = 22;
  PAD   = 34;   TOP   = 14;

{ ── Control helpers (module-level, take hParent) ── }

procedure MakeLabel(hParent: HWND; const Caption: PAnsiChar; X, Y, W, H: Integer);
var
  hCtl: HWND;
begin
  hCtl := CreateWindowExA(0, 'STATIC', Caption, WS_CHILD or WS_VISIBLE,
    X, Y, W, H, hParent, HMENU(0), HInstance, nil);
  SendMessageA(hCtl, WM_SETFONT, GetStockObject(DEFAULT_GUI_FONT), 1);
end;

procedure MakeEdit(hParent: HWND; ID, X, Y, W, H: Integer;
                   const Def: PAnsiChar; Flags: DWORD);
var
  hCtl: HWND;
begin
  hCtl := CreateWindowExA(WS_EX_CLIENTEDGE, 'EDIT', Def,
    WS_CHILD or WS_VISIBLE or WS_TABSTOP or ES_AUTOHSCROLL or Flags,
    X, Y, W, H, hParent, HMENU(ID), HInstance, nil);
  SendMessageA(hCtl, WM_SETFONT, GetStockObject(DEFAULT_GUI_FONT), 1);
end;

procedure MakeLabelCentered(hParent: HWND; const Caption: PAnsiChar; Y, H: Integer);
var
  hCtl: HWND;
begin
  hCtl := CreateWindowExA(0, 'STATIC', Caption,
    WS_CHILD or WS_VISIBLE or SS_CENTER,
    0, Y, WND_W, H, hParent, HMENU(0), HInstance, nil);
  SendMessageA(hCtl, WM_SETFONT, GetStockObject(DEFAULT_GUI_FONT), 1);
end;

procedure MakeButton(hParent: HWND; const Caption: PAnsiChar;
                     ID, X, Y, W, H: Integer);
var
  hCtl: HWND;
begin
  hCtl := CreateWindowExA(0, 'BUTTON', Caption,
    WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_DEFPUSHBUTTON,
    X, Y, W, H, hParent, HMENU(ID), HInstance, nil);
  SendMessageA(hCtl, WM_SETFONT, GetStockObject(DEFAULT_GUI_FONT), 1);
end;

function WndProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := 0;
  case Msg of

    WM_CREATE:
    begin
      MakeLabel(hWnd, 'Sysop Real Name:',  LBL_X, TOP,           LBL_W, LBL_H);
      MakeEdit (hWnd, EDIT_SYSOP, EDT_X, TOP - 2, EDT_W, EDT_H, '', 0);

      MakeLabel(hWnd, 'BBS Name:',         LBL_X, TOP + PAD,     LBL_W, LBL_H);
      MakeEdit (hWnd, EDIT_BBS, EDT_X, TOP + PAD - 2, EDT_W, EDT_H, '', 0);

      MakeButton(hWnd, 'Generate Key', BTN_GEN,
                 LBL_X, TOP + PAD*2 + 4, EDT_X + EDT_W - LBL_X, 28);

      MakeLabel(hWnd, 'Registration  #:',  LBL_X, TOP + PAD*3 + 8, LBL_W, LBL_H);
      MakeEdit (hWnd, EDIT_KEY, EDT_X, TOP + PAD*3 + 6, EDT_W, EDT_H, '',
                ES_READONLY or ES_CENTER);

      MakeLabel(hWnd, '(names are case-insensitive)',
                LBL_X, TOP + PAD*4 + 10, EDT_X + EDT_W - LBL_X, 16);

      MakeLabelCentered(hWnd, '>>>  Quantum Pixelator  <<<', TOP + PAD*5 + 8, 16);
    end;

    WM_COMMAND:
      if LOWORD(wParam) = BTN_GEN then
        Generate(hWnd);

    WM_DESTROY:
      PostQuitMessage(0);

  else
    Result := DefWindowProcA(hWnd, Msg, wParam, lParam);
  end;
end;

var
  WC     : TWndClassA;
  Msg    : TMsg;
  MainWnd: HWND;
  WR     : TRect;
  X, Y   : Integer;

begin
  ZeroMemory(@WC, SizeOf(WC));
  WC.style         := CS_HREDRAW or CS_VREDRAW;
  WC.lpfnWndProc   := @WndProc;
  WC.hInstance     := HInstance;
  WC.hIcon         := LoadIconA(0, IDI_APPLICATION);
  WC.hCursor       := LoadCursorA(0, IDC_ARROW);
  WC.hbrBackground := HBRUSH(COLOR_BTNFACE + 1);
  WC.lpszClassName := 'TeosKeygen';
  RegisterClassA(WC);

  { Centre on the work area (avoids the taskbar) }
  SystemParametersInfoA(SPI_GETWORKAREA, 0, @WR, 0);
  X := WR.Left + (WR.Right  - WR.Left - WND_W) div 2;
  Y := WR.Top  + (WR.Bottom - WR.Top  - WND_H) div 2;

  MainWnd := CreateWindowExA(
    0,
    'TeosKeygen',
    'Planets:TEOS v2.02  -  Registration Keygen',
    WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,
    X, Y, WND_W, WND_H,
    0, 0, HInstance, nil);

  ShowWindow(MainWnd, SW_SHOWNORMAL);
  UpdateWindow(MainWnd);

  while GetMessageA(@Msg, 0, 0, 0) do
  begin
    if not IsDialogMessage(MainWnd, @Msg) then
    begin
      TranslateMessage(@Msg);
      DispatchMessageA(@Msg);
    end;
  end;
end.
