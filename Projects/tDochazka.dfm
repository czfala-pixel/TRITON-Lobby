object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'TRITON - Doch'#225'zka'
  ClientHeight = 564
  ClientWidth = 999
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 999
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 960
    DesignSize = (
      999
      50)
    object lblTyden: TLabel
      Left = 12
      Top = 17
      Width = 39
      Height = 14
      Caption = 'T'#253'den:'
    end
    object lblRezim: TLabel
      Left = 668
      Top = 17
      Width = 108
      Height = 15
      Caption = 'Re'#382'im: Jen ke '#269'ten'#237
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbTydny: TComboBox
      Left = 55
      Top = 14
      Width = 140
      Height = 22
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbTydnyChange
    end
    object btnNovyTyden: TButton
      Left = 201
      Top = 13
      Width = 92
      Height = 25
      Caption = '+ Nov'#253' t'#253'den'
      TabOrder = 1
      OnClick = btnNovyTydenClick
    end
    object btnSync: TButton
      Left = 299
      Top = 13
      Width = 105
      Height = 25
      Caption = 'Na'#269#237'st z cloudu'
      TabOrder = 2
      OnClick = btnSyncClick
    end
    object chkAutoSync: TCheckBox
      Left = 412
      Top = 17
      Width = 115
      Height = 17
      Caption = 'Auto-sync (5s)'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = chkAutoSyncClick
    end
    object btnOdemknout: TButton
      Left = 535
      Top = 13
      Width = 125
      Height = 25
      Caption = 'Odemknout '#250'pravy'
      TabOrder = 4
      OnClick = btnOdemknoutClick
    end
    object btnDiscord: TButton
      Left = 839
      Top = 13
      Width = 148
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Kopirovat pro Discord'
      TabOrder = 5
      OnClick = btnDiscordClick
      ExplicitLeft = 800
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 514
    Width = 999
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 510
    ExplicitWidth = 960
    object lblStav: TLabel
      Left = 450
      Top = 17
      Width = 89
      Height = 14
      Caption = 'Stav: P'#345'ipraveno'
    end
    object Label1: TLabel
      Left = 720
      Top = 24
      Width = 209
      Height = 14
      Caption = 'Aplikaci vytvo'#345'il Hajp pro cech TRITON'
    end
    object edtNovyClen: TEdit
      Left = 12
      Top = 14
      Width = 170
      Height = 22
      TabOrder = 0
      TextHint = 'Jm'#233'no nov'#233'ho '#269'lena...'
    end
    object btnPridatClena: TButton
      Left = 188
      Top = 13
      Width = 95
      Height = 25
      Caption = 'P'#345'idat '#269'lena'
      TabOrder = 1
      OnClick = btnPridatClenaClick
    end
    object btnSmazatClena: TButton
      Left = 289
      Top = 13
      Width = 105
      Height = 25
      Caption = 'Odebrat vybran'#233'ho'
      TabOrder = 2
      OnClick = btnSmazatClenaClick
    end
  end
  object GridDochazka: TStringGrid
    Left = 0
    Top = 50
    Width = 999
    Height = 464
    Align = alClient
    ColCount = 11
    DefaultRowHeight = 26
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 2
    OnDrawCell = GridDochazkaDrawCell
    OnMouseDown = GridDochazkaMouseDown
    ExplicitWidth = 960
    ExplicitHeight = 460
  end
  object TimerSync: TTimer
    Interval = 5000
    OnTimer = TimerSyncTimer
    Left = 508
    Top = 12
  end
end
