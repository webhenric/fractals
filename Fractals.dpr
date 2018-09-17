program Fractals;



uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  MandelbrotSet in 'MandelbrotSet.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
