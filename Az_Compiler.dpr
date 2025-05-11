program Az_Compiler;

uses
  Vcl.Forms,
  UiClassic in 'UiClassic.pas' {FormClassic},
  SyntaxLine in 'SyntaxLine.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('CopperDark');
  Application.CreateForm(TFormClassic, FormClassic);
  Application.Run;
end.
