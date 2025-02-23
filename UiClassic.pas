﻿unit UiClassic;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;




type
  TFormClassic = class(TForm)
    TopPanel: TPanel;
    LeftPanel: TPanel;
    ClientPanel: TPanel;
    OutputMemo: TMemo;
    InputMemo: TMemo;
    RunBtn: TButton;
    FileCombo: TComboBox;
    SaveBtn: TButton;
    CodeBtn: TButton;
    TranslatorBtn: TButton;
    ParserBtn: TButton;
    DecisionBtn: TButton;
    IrregularBtn: TButton;
    NumBtn: TButton;
    IntBtn: TButton;
    IdBtn: TButton;
    UnreadBtn: TButton;
    StrBtn: TButton;
    procedure OnActivation(Sender: TObject);
    procedure Save(Sender: TObject);
    procedure ChangeFile(Sender: TObject);
    procedure OnRun(Sender: TObject);
    procedure UnreadClicked(Sender: TObject);
    procedure IdClicked(Sender: TObject);
    procedure IntClicked(Sender: TObject);
     procedure NumberClicked(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormClassic: TFormClassic;

implementation

{$R *.dfm}

uses SyntaxLine, IOUtils;

var
  Inp: TSyntaxLine;

procedure TFormClassic.ChangeFile(Sender: TObject);
begin
  InputMemo.Lines.LoadFromFile(FileCombo.Text);
  Inp.LoadFromFile(FileCombo.Text);
end;

procedure TFormClassic.IdClicked(Sender: TObject);
begin
  Save(Sender);
  OutputMemo.Lines.Text := Inp.SkipId;
end;

procedure TFormClassic.IntClicked(Sender: TObject);
begin
  Save(Sender);
  OutputMemo.Lines.Text := Inp.SkipInt.ToString;
end;

procedure TFormClassic.NumberClicked(Sender: TObject);
begin
  Save(Sender);
  OutputMemo.Lines.Text := Inp.SkipNumber;
end;

procedure TFormClassic.OnActivation(Sender: TObject);
var
  i: Integer;
  F: TArray<String>;
begin
  F := TDirectory.GetFiles(TDirectory.GetCurrentDirectory, '*.txt');
  for i := 0 to High(F) do
    F[i] := TPath.GetFileName(F[i]);

  FileCombo.Items.Clear;
  FileCombo.Items.AddStrings(F);
  FileCombo.ItemIndex := 0;

  InputMemo.Lines.LoadFromFile(FileCombo.Text);
  Inp.LoadFromFile(FileCombo.Text);
end;

procedure TFormClassic.OnRun(Sender: TObject);
var
  SelectedFile: string;
begin
  // بررسی اینکه آیا فایلی انتخاب شده است
  if FileCombo.Text = '' then
  begin
    ShowMessage('لطفاً یک فایل را انتخاب کنید.');
    Exit;
  end;

  SelectedFile := FileCombo.Text;

  Save(Sender);

  if SelectedFile = 'Unread.txt' then
    UnreadBtn.Click
  else if SelectedFile = 'Id.txt' then
    IdBtn.Click
  else if SelectedFile = 'Int.txt' then
    IntBtn.Click
  else if SelectedFile = 'Num.txt' then
    NumBtn.Click
  else if SelectedFile = 'Str.txt' then
    StrBtn.Click
  else if SelectedFile = 'Irregular.txt' then
    IrregularBtn.Click
  else if SelectedFile = 'Decision.txt' then
    DecisionBtn.Click
  else if SelectedFile = 'Parser.txt' then
    ParserBtn.Click
  else if SelectedFile = 'Translator.txt' then
    TranslatorBtn.Click
  else if SelectedFile = 'Code.txt' then
    CodeBtn.Click
  else
    ShowMessage('دکمه نامعتبر!');
end;

procedure TFormClassic.Save(Sender: TObject);
begin
  if FileCombo.Text = '' then
  begin
    ShowMessage('لطفاً یک فایل را انتخاب کنید.');
    Exit;
  end;

  try
    InputMemo.Lines.SaveToFile(FileCombo.Text);
    Inp.LoadFromFile(FileCombo.Text);
  except
    on E: Exception do
      ShowMessage('خطا در ذخیره فایل: ' + E.Message);
  end;
end;

procedure TFormClassic.UnreadClicked(Sender: TObject);
begin
  Save(Sender);
  OutputMemo.Lines.Text := Inp.SkipUnread;
end;

end.