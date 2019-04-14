object Form1: TForm1
  Left = 192
  Top = 124
  Width = 416
  Height = 326
  Caption = 'MouseClickEvent'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StartHook: TButton
    Left = 120
    Top = 48
    Width = 145
    Height = 57
    Caption = 'StartHook'
    TabOrder = 0
    Visible = False
    OnClick = StartHookClick
  end
  object StopHook: TButton
    Left = 280
    Top = 48
    Width = 185
    Height = 57
    Caption = 'StopHook'
    TabOrder = 1
    Visible = False
    OnClick = StopHookClick
  end
  object ListBox1: TListBox
    Left = 504
    Top = 56
    Width = 89
    Height = 73
    ItemHeight = 13
    TabOrder = 2
    Visible = False
    OnClick = ListBox1Click
  end
  object DrawCircle: TButton
    Left = 120
    Top = 120
    Width = 137
    Height = 65
    Caption = 'DrawCircle'
    TabOrder = 3
    Visible = False
    OnClick = DrawCircleClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 24
    Top = 56
  end
  object TimerStatus: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerStatusTimer
    Left = 56
    Top = 56
  end
end
