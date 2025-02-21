program Az_Compiler;

uses
  Vcl.Forms,
  UiClassic in 'UiClassic.pas' {FormClassic},
  SyntaxLine in 'SyntaxLine.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormClassic, FormClassic);
  Application.Run;
end.
