{*******************************************************}
{                                                       }
{       Fractals                                        }
{                                                       }
{       Copyright (C) 2018 webhenric consulting         }
{                                                       }
{*******************************************************}

unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, RzPanel, RzRadGrp, RzSpnEdt, Vcl.StdCtrls, Vcl.Mask, RzEdit, RzButton,
  MandelbrotSet, System.Generics.Collections, System.Threading, RzPrgres, System.Math;

type
  TForm1 = class(TForm)
    RzPanel1: TRzPanel;
    RzRadioGrp1: TRzRadioGroup;
    RzSpinEdit1: TRzSpinEdit;
    RzButton1: TRzButton;
    Image1: TImage;
    RzProgressBar1: TRzProgressBar;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure RzButton1Click(Sender: TObject);
  private
    Bitmap: TBitmap;
    NumberOfIterations: Integer;
    AMandelbrotSet: MandelbrotSet.TMandelbrotSet;
    CalculationTask: ITask;
    const
      BitmapWidth = 872;
      BitmapHeight = 800;
      NumberOfPixels: Integer = BitmapWidth * BitmapHeight;

      { Four positions in hexadecimal }
      BitsToShift = 16;

      { Windows uses byte-order BBGGRR for colours }
      PureBlue = $00FF0000;

      { To get visible differences in colour }
      MultiplicationConstant = 4;

      { One less than maximum colour value }
      MaxValueToSubtract = 254;
  protected
    procedure PaintOnCanvas(ACanvas: TCanvas; APointsArray: TPointsArray);
    procedure RenderMandelbrot(Sender: TObject);
    procedure StopRendering;
    procedure ResetAfterCalculation;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Bitmap := TBitmap.Create;
  Bitmap.Width := BitmapWidth;
  Bitmap.Height := BitmapHeight;
end;

procedure TForm1.PaintOnCanvas(ACanvas: TCanvas; APointsArray: TPointsArray);
var
  PointsRecordPointer: TPointsRecordPointer;
  PointsRecordPointerList: TList<TPointsRecordPointer>;
  ValueToSubtract: Integer;
begin
  { Points belonging to the Mandelbrot set }
  PointsRecordPointerList := APointsArray[1];

  for PointsRecordPointer in PointsRecordPointerList do
  begin
    ACanvas.Pixels[PointsRecordPointer^.X, PointsRecordPointer^.Y] := clBlack;
  end;

  { Points not belonging to the Mandelbrot set }
  PointsRecordPointerList := APointsArray[2];

  for PointsRecordPointer in PointsRecordPointerList do
  begin
    { We do not want the colour black for points not in the set. Also no wrap arounds. }
    ValueToSubtract := PointsRecordPointer^.N * MultiplicationConstant;

    if ValueToSubtract > MaxValueToSubtract then
      ValueToSubtract := MaxValueToSubtract;

    { Because of byte-order we have to do some bit-shifting in order to manipulate the blue part of the colour. }
    ACanvas.Pixels[PointsRecordPointer^.X, PointsRecordPointer^.Y] := ((PureBlue shr BitsToShift) - ValueToSubtract) shl BitsToShift;
  end;
end;

procedure TForm1.RzButton1Click(Sender: TObject);
begin
  if CalculationTask = nil then
  begin
    Bitmap.Canvas.Refresh;
    Image1.Picture.Graphic := nil;
    CalculationTask := TTask.Create(Self, RenderMandelbrot);
    CalculationTask.Start;
    Cursor := crHourGlass;
    Timer1.Enabled := True;
    RzButton1.Caption := 'Stop';
  end
  else
    StopRendering;
end;

procedure TForm1.RenderMandelbrot(Sender: TObject);
var APointsArray: TPointsArray;
begin
  NumberOfIterations := Floor(RzSpinEdit1.Value);
  AMandelbrotSet := TMandelbrotSet.Create(NumberOfIterations, BitmapWidth, BitmapHeight);
  APointsArray := AMandelbrotSet.CalculatePoints;
  { Thanks to Delphi Cookbook Second Edition by Daniele Teti, for pointing me in the right direction. }
  TThread.Queue(nil, procedure
    begin
      PaintOnCanvas(Bitmap.Canvas, APointsArray);
      Image1.Picture.Graphic := Bitmap;
      RzProgressBar1.Percent := 100;
      ResetAfterCalculation;
    end);
end;

procedure TForm1.ResetAfterCalculation;
begin
  Timer1.Enabled := False;
  Cursor := crDefault;
  AMandelbrotSet.Free;
  AMandelbrotSet := nil;
  CalculationTask := nil;
  RzButton1.Caption := 'Paint';
end;

procedure TForm1.StopRendering;
begin
  CalculationTask.Cancel;
  ResetAfterCalculation;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  RzProgressBar1.Percent := Floor((AMandelbrotSet.GetPointCount / NumberOfPixels) * 100);
end;

end.
