object LobbyForm: TLobbyForm
  Left = 0
  Top = 0
  Caption = 'Lobby'
  ClientHeight = 374
  ClientWidth = 347
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnDochazka: TButton
    Left = 96
    Top = 56
    Width = 145
    Height = 57
    Caption = 'Doch'#225'zka'
    TabOrder = 0
    OnClick = btnDochazkaClick
  end
  object btnHerbareni: TButton
    Left = 96
    Top = 144
    Width = 145
    Height = 57
    Caption = 'Herba'#345'en'#237
    TabOrder = 1
    OnClick = btnHerbareniClick
  end
  object btnEventy: TButton
    Left = 96
    Top = 240
    Width = 145
    Height = 57
    Caption = 'Eventy'
    TabOrder = 2
    OnClick = btnEventyClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 336
    Width = 347
    Height = 38
    Align = alBottom
    Caption = 'Copyright '#169' Hajp 2026. V'#353'echna pr'#225'va vyhrazena'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
end
