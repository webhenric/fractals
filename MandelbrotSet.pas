{*******************************************************}
{                                                       }
{       Fractals                                        }
{                                                       }
{       Copyright (C) 2018 webhenric consulting         }
{                                                       }
{*******************************************************}

unit MandelbrotSet;

interface

uses
  System.VarCmplx, System.Generics.Collections;

type
  TPoints = record
    X, Y, N: Integer;
    Z: Variant;
  end;

  TPointsRecordPointer = ^TPoints;

  TPointsArray = array [1..2] of TList<TPointsRecordPointer>;

  TMandelbrotSet = class
  private
    NumberOfIterations, MaxXValue, MaxYValue: Integer;
    StepX, StepY: Double;
    ListOfPointsInSet, ListOfPointsNotInSet: TList<TPointsRecordPointer>;
    const
      StartValueZ_Real: Double = 0.0;
      StartValueZ_Imag: Double = 0.0;
      MaxRealValue: Double = 2.0;
      MaxImagValue: Double = 2.0;
      MinRealValue: Double = -2.0;
      MinImagValue: Double = -2.0;
      ClosedDiskRadius: Double = 2.0;
  protected
    procedure ClearPoints;
    procedure OnPointsInSetRemove(Sender: TObject; const Item: TPointsRecordPointer; Action: TCollectionNotification);
    procedure OnPointsNotInSetRemove(Sender: TObject; const Item: TPointsRecordPointer; Action: TCollectionNotification);
  public
    constructor Create(Iterations, Max_X, Max_Y: Integer);
    function CalculatePoints: TPointsArray;
    function GetPointCount: Integer;
    destructor Destroy; override;
  end;

implementation

{ TMandelbrotSet }

function TMandelbrotSet.CalculatePoints: TPointsArray;
var
  CurrentReal, CurrentImag: Double;
  X, Y, N: Integer;
  C, Z, CurrentValueZ: Variant;
  PointsPointer: TPointsRecordPointer;
  PointsArray: TPointsArray;
begin
  ClearPoints;
  CurrentReal := MaxRealValue;
  for X := MaxXValue downto 0 do
  begin
    CurrentImag := MaxImagValue;
    for Y := MaxYValue downto 0 do
    begin
      C := VarComplexCreate(CurrentReal, CurrentImag);
      CurrentValueZ := VarComplexCreate(StartValueZ_Real, StartValueZ_Imag);
      for N := 1 to NumberOfIterations do
      begin
        Z := CurrentValueZ;
        CurrentValueZ := VarComplexSqr(Z) + C;
        if Abs(Z) > ClosedDiskRadius then
        begin
          New(PointsPointer);
          PointsPointer^.X := X;
          PointsPointer^.Y := Y;
          PointsPointer^.N := N;
          PointsPointer^.Z := Z;
          ListOfPointsNotInSet.Add(PointsPointer);
          Break;
        end;
        if N = NumberOfIterations then
        begin
          New(PointsPointer);
          PointsPointer^.X := X;
          PointsPointer^.Y := Y;
          PointsPointer^.N := N;
          PointsPointer^.Z := Z;
          ListOfPointsInSet.Add(PointsPointer);
        end;
      end;
      CurrentImag := CurrentImag - StepY;
    end;
    CurrentReal := CurrentReal - StepX;
  end;
  PointsArray[1] := ListOfPointsInSet;
  PointsArray[2] := ListOfPointsNotInSet;
  CalculatePoints := PointsArray;
end;

procedure TMandelbrotSet.ClearPoints;
begin
  ListOfPointsInSet.Clear;
  ListOfPointsNotInSet.Clear;
end;

constructor TMandelbrotSet.Create(Iterations, Max_X, Max_Y: Integer);
begin
  NumberOfIterations := Iterations;
  MaxXValue := Max_X;
  MaxYValue := Max_Y;

  StepX := (Abs(MaxRealValue) + Abs(MinRealValue)) / MaxXValue;
  StepY := (Abs(MaxImagValue) + Abs(MinImagValue)) / MaxYValue;

  ListOfPointsInSet := TList<TPointsRecordPointer>.Create;
  ListOfPointsNotInSet := TList<TPointsRecordPointer>.Create;
  ListOfPointsInSet.OnNotify := OnPointsInSetRemove;
  ListOfPointsNotInSet.OnNotify := OnPointsNotInSetRemove;
end;

destructor TMandelbrotSet.Destroy;
begin
  ClearPoints;
  inherited;
end;

function TMandelbrotSet.GetPointCount: Integer;
begin
  GetPointCount := ListOfPointsInSet.Count + ListOfPointsNotInSet.Count;
end;

procedure TMandelbrotSet.OnPointsInSetRemove(Sender: TObject; const Item: TPointsRecordPointer; Action: TCollectionNotification);
begin
  if Action = cnRemoved then
  begin
    Dispose(Item);
  end;
end;

procedure TMandelbrotSet.OnPointsNotInSetRemove(Sender: TObject; const Item: TPointsRecordPointer; Action: TCollectionNotification);
begin
  if Action = cnRemoved then
  begin
    Dispose(Item);
  end;
end;

end.
