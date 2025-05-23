object FormClassic: TFormClassic
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Classic Syntaxes'
  ClientHeight = 936
  ClientWidth = 1392
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Consolas'
  Font.Pitch = fpVariable
  Font.Style = []
  Position = poScreenCenter
  OnActivate = OnActivation
  TextHeight = 18
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 1392
    Height = 51
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 994
    object RunBtn: TButton
      AlignWithMargins = True
      Left = 276
      Top = 4
      Width = 130
      Height = 43
      Align = alLeft
      Caption = 'Run'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      OnClick = OnRun
    end
    object FileCombo: TComboBox
      AlignWithMargins = True
      Left = 140
      Top = 4
      Width = 130
      Height = 26
      Align = alLeft
      TabOrder = 1
      Text = 'FileCombo'
      OnChange = ChangeFile
    end
    object SaveBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 130
      Height = 43
      Align = alLeft
      Caption = 'Save'
      TabOrder = 2
      OnClick = Save
    end
  end
  object LeftPanel: TPanel
    Left = 0
    Top = 51
    Width = 137
    Height = 885
    Align = alLeft
    TabOrder = 1
    ExplicitHeight = 613
    object CodeBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 445
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Code'
      TabOrder = 0
      OnClick = CodeClicked
    end
    object TranslatorBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 396
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Translator'
      TabOrder = 1
      OnClick = DepthClicked
    end
    object ParserBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 347
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Parser'
      TabOrder = 2
      OnClick = ParserClicked
    end
    object DecisionBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 298
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Decision'
      TabOrder = 3
      OnClick = DecisionClicked
    end
    object IrregularBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 249
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Irregular'
      TabOrder = 4
      OnClick = IrregularClicked
    end
    object NumBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 151
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Num'
      TabOrder = 5
      OnClick = NumberClicked
    end
    object IntBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 102
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Int'
      TabOrder = 6
      OnClick = IntClicked
    end
    object IdBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 53
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Id'
      TabOrder = 7
      OnClick = IdClicked
    end
    object UnreadBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Unread'
      TabOrder = 8
      OnClick = UnreadClicked
    end
    object StrBtn: TButton
      AlignWithMargins = True
      Left = 4
      Top = 200
      Width = 129
      Height = 43
      Align = alTop
      Caption = 'Str'
      TabOrder = 9
      OnClick = StrClicked
    end
  end
  object ClientPanel: TPanel
    Left = 137
    Top = 51
    Width = 1255
    Height = 885
    Align = alClient
    TabOrder = 2
    ExplicitWidth = 857
    ExplicitHeight = 613
    object OutputMemo: TMemo
      Left = 593
      Top = 1
      Width = 661
      Height = 883
      Align = alClient
      Color = clMoneyGreen
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Fira Code'
      Font.Pitch = fpVariable
      Font.Style = []
      Lines.Strings = (
        'OutputMemo')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
      ExplicitLeft = 401
      ExplicitWidth = 455
      ExplicitHeight = 611
    end
    object InputMemo: TMemo
      Left = 1
      Top = 1
      Width = 592
      Height = 883
      Align = alLeft
      Color = clSkyBlue
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Fira Code'
      Font.Pitch = fpVariable
      Font.Style = []
      Lines.Strings = (
        'Memo1')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 1
      WordWrap = False
    end
  end
end
