object FormEventy: TFormEventy
  Left = 0
  Top = 0
  Caption = 'Eventy'
  ClientHeight = 406
  ClientWidth = 493
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 387
    Width = 487
    Height = 16
    Align = alBottom
    Alignment = taCenter
    BiDiMode = bdLeftToRight
    Caption = 
      #169' 2026 Hajp | V'#353'echna pr'#225'va vyhrazena                           ' +
      '                     Stellaria'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
    ExplicitWidth = 473
  end
  object dny: TComboBox
    Left = 152
    Top = 35
    Width = 193
    Height = 22
    Style = csOwnerDrawVariable
    Ctl3D = True
    ParentCtl3D = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
    TextHint = 'Vyber den'
    OnChange = dnyChange
    Items.Strings = (
      'Pond'#283'l'#237
      #218'ter'#253
      'St'#345'eda'
      #268'tvrtek'
      'P'#225'tek'
      'Sobota'
      'Ned'#283'le')
  end
  object ListBox1: TListBox
    Left = 8
    Top = 88
    Width = 477
    Height = 297
    Style = lbOwnerDrawFixed
    ItemHeight = 22
    TabOrder = 1
    OnDrawItem = ListBox1DrawItem
  end
  object Timer1: TTimer
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 64
    Top = 32
  end
end
