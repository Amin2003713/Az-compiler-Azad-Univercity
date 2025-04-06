(*
  Unit: UiClassic
  Description:
  This unit implements a classic user interface for a syntax analysis tool.
  It leverages the TSyntaxLine record (from the SyntaxLine unit) to process text
  files and perform various syntax tests (such as checking identifiers, integers,
  numbers, etc.). The design is inspired by classic programming editors and
  aims to provide an interactive, creative experience for users.

  Developer: mohhamad amin ahmadi
  Date: 2025-02-21
*)

unit UiClassic;

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
    procedure StrClicked(Sender: TObject);
    procedure IrregularClicked(Sender: TObject);
    procedure DecisionClicked(Sender: TObject);
    procedure ParserClicked(Sender: TObject);
    procedure DepthClicked(Sender: TObject);
    procedure CodeClicked(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormClassic: TFormClassic;

implementation

{$R *.dfm}

uses
  SyntaxLine, IOUtils;

var
  // Global instance of TSyntaxLine used to process the source text.
  Inp: TSyntaxLine;

  { TFormClassic }

procedure TFormClassic.OnActivation(Sender: TObject);
var
  i: Integer;
  Files: TArray<String>;
begin
  // On form activation, load all '.txt' files from the current directory
  // into the FileCombo combo box for user selection.
  Files := TDirectory.GetFiles(TDirectory.GetCurrentDirectory, '*.txt');
  for i := 0 to High(Files) do
    Files[i] := TPath.GetFileName(Files[i]);

  FileCombo.Items.Clear;
  FileCombo.Items.AddStrings(Files);
  if FileCombo.Items.Count > 0 then
    FileCombo.ItemIndex := 0;

  // Load the selected file's content into the input memo and TSyntaxLine processor.
  if FileCombo.Text <> '' then
  begin
    InputMemo.Lines.LoadFromFile(FileCombo.Text);
    Inp.LoadFromFile(FileCombo.Text);
  end;
end;

procedure TFormClassic.ChangeFile(Sender: TObject);
begin
  // When the file selection changes, update the input memo and reload the source text.
  InputMemo.Lines.LoadFromFile(FileCombo.Text);
  Inp.LoadFromFile(FileCombo.Text);
end;

procedure TFormClassic.Save(Sender: TObject);
begin
  // Save the content of the input memo back to the file.
  if FileCombo.Text = '' then
  begin
    ShowMessage('Please select a file.');
    Exit;
  end;

  try
    InputMemo.Lines.SaveToFile(FileCombo.Text);
    // Reload the updated file content into the TSyntaxLine instance.
    Inp.LoadFromFile(FileCombo.Text);
  except
    on E: Exception do
      ShowMessage('Error saving file: ' + E.Message);
  end;
end;

procedure TFormClassic.IdClicked(Sender: TObject);
begin
  // Process an identifier token.
  // Save changes first and then display the skipped identifier.

  OutputMemo.Lines.Text := Inp.SkipId;
end;

procedure TFormClassic.IntClicked(Sender: TObject);
begin
  // Process an integer token.

  OutputMemo.Lines.Text := Inp.SkipInt.ToString;
end;

procedure TFormClassic.IrregularClicked(Sender: TObject);
var
  S: String;
begin
  // for #id := #int to #int do
  S := Inp.Skip('$for');
  S := S + ' ' + Inp.Skip('#id');
  S := S + ' ' + Inp.Skip(':=');
  S := S + ' ' + Inp.Skip('#int');
  S := S + ' ' + Inp.Skip('$to');
  S := S + ' ' + Inp.Skip('#int');
  S := S + ' ' + Inp.Skip('$do');

  OutputMemo.Lines.Text := S;
end;

procedure TFormClassic.NumberClicked(Sender: TObject);
begin
  // Process a number token (could be an integer or a floating-point number).
  OutputMemo.Lines.Text := Inp.SkipNumber.ToString;
end;

procedure TFormClassic.CodeClicked(Sender: TObject);
begin
            OutputMemo.Lines.Clear;
  OutputMemo.Lines.Add('Codes =');
  OutputMemo.Lines.AddStrings(Inp.SkipCodes.ToLines);
end;

procedure TFormClassic.DecisionClicked(Sender: TObject);
var
  S: String;
begin
  case Inp.WhichIs(['$if', '$while', '$for', '#id']) of
    0:
      begin
        S := Inp.SkipKey('if');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep('=');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipKey('then');
      end;

    1:
      begin
        S := Inp.SkipKey('while');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep('=');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipKey('do');
      end;

    2:
      begin
        S := Inp.SkipKey('for');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep(':=');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep('to');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipKey('do');
      end;

    3:
      begin
        S := Inp.SkipId;
        S := S + ' ' + Inp.SkipSep(':=');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep('+');
        S := S + ' ' + Inp.SkipId;
      end;

  else
    Inp.ReportSyntaxError('if, while, for, id Expected');
  end;

  OutputMemo.Lines.Text := S;
end;

procedure TFormClassic.DepthClicked(Sender: TObject);
begin
      // OutputMemo.Lines.Text := 'Depth = ' + Inp.SkipDepth.ToString;
       OutputMemo.Lines.Text := 'Expression = ' + Inp.SkipExpVal.ToString;

end;

procedure TFormClassic.StrClicked(Sender: TObject);
begin
  // Process a string token.
  // The SkipStrQuot method (assumed to be implemented in TSyntaxLine) handles string syntax.
  OutputMemo.Lines.Text := Inp.SkipStrQuot;
end;

procedure TFormClassic.UnreadClicked(Sender: TObject);
begin
  OutputMemo.Lines.Text := Inp.SkipUnread;
end;

procedure TFormClassic.OnRun(Sender: TObject);
var
  SelectedFile: string;
begin
  // The OnRun event acts as the central command for running syntax tests.
  // It simulates a button click based on the currently selected file name.

  if FileCombo.Text = '' then
  begin
    ShowMessage('Please select a file.');
    Exit;
  end;

  SelectedFile := FileCombo.Text;

  // Determine which test to run by comparing the selected file name.
  // Each file corresponds to a specific syntax test button.
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
    ShowMessage('Invalid file selection!');
end;

procedure TFormClassic.ParserClicked(Sender: TObject);
begin
  OutputMemo.Lines.Text := Inp.SkipSXY;
  // OutputMemo.Lines.Text := Inp.SkipSPNV;
end;

end.
