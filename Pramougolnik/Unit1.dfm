object Form1: TForm1
  Left = -8
  Top = -8
  Width = 1936
  Height = 1056
  Caption = 'Form1'
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
  object Image1: TImage
    Left = 128
    Top = 128
    Width = 441
    Height = 249
  end
  object Button1: TButton
    Left = 72
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    Visible = False
    OnClick = Button1Click
  end
  object RectangleTimer: TTimer
    Interval = 10
    OnTimer = RectangleTimerTimer
    Left = 176
    Top = 24
  end
end
