unit chimera.json.path.generators;

interface

uses
  System.SysUtils,
  System.Classes,
  chimera.json;

type
  IGenerator = interface
    function AST : string;
    function &Type : string;
    function Next : IGenerator;
    function ToString : string;
    function Process(Value : TMultiValues) : TMultiValues;
  end;

  TBaseGenerator = class(TInterfacedObject, IGenerator)
  private
    FNext : IGenerator;
  protected
    FType : string;
    function ProcessNext(Value : TMultiValues) : TMultiValues;
  public
    function AST : string;
    function &Type : string;
    function Next : IGenerator;
    function Process(Value : TMultiValues) : TMultiValues; virtual; abstract;

    constructor Create(const Next : IGenerator); reintroduce; virtual;
    function ToString: string; virtual;
  end;

  TRootGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TLengthGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TIndexGenerator = class(TBaseGenerator)
  private
    FIndexes : TArray<integer>;
  public
    constructor Create(const Indexes : TArray<integer>; const Next : IGenerator); reintroduce; virtual;
    function ToString: string; override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TFromIndexGenerator = class(TBaseGenerator)
  private
    FFromIndex : integer;
  public
    constructor Create(FromIndex : integer; const Next : IGenerator); reintroduce; virtual;
    function ToString: string; override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TToIndexGenerator = class(TBaseGenerator)
  private
    FToIndex : integer;
  public
    constructor Create(ToIndex : integer; const Next : IGenerator); reintroduce; virtual;
    function ToString: string; override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TFilterGenerator = class(TBaseGenerator)
  private
    FExpression : string;
  public
    constructor Create(const Expression : String; const Next : IGenerator); reintroduce; virtual;
    function ToString: string; override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TPropertyGenerator = class(TBaseGenerator)
  private
    FProperty : string;
  public
    constructor Create(Prop : string; const Next : IGenerator); reintroduce; virtual;
    function ToString: string; override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TDeepGenerator = class(TPropertyGenerator)
  private
    procedure CheckObject(var Result: TMultiValues; Obj: IJSONObject);
  public
    constructor Create(Prop : string; const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TAllPropertiesGenerator = class(TBaseGenerator)
  private
    FDeep : boolean;
    procedure CheckObject(var Result: TMultiValues; Obj: IJSONObject);
  public
    constructor Create(const Next : IGenerator; Deep : boolean); reintroduce; virtual;
    function ToString: string; override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TAllIndexesGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function ToString: string; override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TSliceGenerator = class(TBaseGenerator)
  private
    FFromIndex: Integer;
    FToIndex: Integer;
  public
    constructor Create(FromIndex, ToIndex : integer; const Next : IGenerator); reintroduce; virtual;
    function ToString: string; override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TKeysGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TMinGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TMaxGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TAvgGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TSumGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TStdDevGenerator = class(TBaseGenerator)
  public
    constructor Create(const Next : IGenerator); override;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TConcatGenerator = class(TBaseGenerator)
  private
    FValue : string;
  public
    constructor Create(const Value : string; const Next : IGenerator); reintroduce; virtual;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

  TAppendGenerator = class(TBaseGenerator)
  private
    FValue : string;
  public
    constructor Create(const Value : string; const Next : IGenerator); reintroduce; virtual;
    function Process(Value : TMultiValues) : TMultiValues; override;
  end;

implementation

uses
  System.Math;

{ TBaseGenerator }

function TBaseGenerator.AST: string;
begin
  Result := ToString;
  if Assigned(FNext) then
    Result := Result+#13#10'  > '+FNext.AST;
end;

constructor TBaseGenerator.Create(const Next : IGenerator);
begin
  inherited Create;
  FType := '';
  FNext := Next;
end;

function TBaseGenerator.ToString: string;
begin
  Result := FType;
end;

function TBaseGenerator.&Type: string;
begin
  Result := FType;
end;

function TBaseGenerator.Next: IGenerator;
begin
  Result := FNext;
end;

function TBaseGenerator.ProcessNext(Value: TMultiValues): TMultiValues;
begin
  if Assigned(FNext) then
    Result := FNext.Process(Value)
  else
    Result := Value;
end;

{ TRootGenerator }

constructor TRootGenerator.Create(const Next: IGenerator);
begin
  inherited Create(Next);
  FType := 'ROOT';
end;

function TRootGenerator.Process(Value: TMultiValues): TMultiValues;
begin
  Result := Value;
  Result := ProcessNext(Result);
end;

{ TIndexGenerator }

constructor TIndexGenerator.Create(const Indexes: TArray<integer>;
  const Next: IGenerator);
begin
  inherited Create(Next);
  FType := 'INDEX';
  FIndexes := Indexes;
end;

function TIndexGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen : integer;
begin
  SetLength(Result, 0);

  iLen := Length(Value);
  for var i := 0 to iLen-1 do
  begin
    case Value[i].ValueType of
      TJSONValueType.array:
      begin
        for var idx in FIndexes do
        begin
          if (idx >= 0) and (idx <= Value[i].ArrayValue.Count-1) then
          begin
            SetLength(Result, length(Result)+1);
            case Value[i].ArrayValue.Types[idx] of
              TJSONValueType.string:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Strings[idx]);
              TJSONValueType.number:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Numbers[idx]);
              TJSONValueType.object:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Objects[idx]);
              TJSONValueType.array:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Arrays[idx]);
              TJSONValueType.boolean:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Booleans[idx]);
              TJSONValueType.null:
                Result[Length(Result)-1] := TMultiValue.InitializeNull;
              TJSONValueType.code:
                Result[Length(Result)-1] := TMultiValue.InitializeCode(Value[i].ArrayValue.Values[idx].StringValue);
            end;
          end else if (idx < 0) and (Value[i].ArrayValue.Count+idx >= 0) then
          begin
            SetLength(Result, length(Result)+1);
            case Value[i].ArrayValue.Types[Value[i].ArrayValue.Count + idx] of
              TJSONValueType.string:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Strings[Value[i].ArrayValue.Count + idx]);
              TJSONValueType.number:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Numbers[Value[i].ArrayValue.Count + idx]);
              TJSONValueType.object:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Objects[Value[i].ArrayValue.Count + idx]);
              TJSONValueType.array:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Arrays[Value[i].ArrayValue.Count + idx]);
              TJSONValueType.boolean:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Booleans[Value[i].ArrayValue.Count + idx]);
              TJSONValueType.null:
                Result[Length(Result)-1] := TMultiValue.InitializeNull;
              TJSONValueType.code:
                Result[Length(Result)-1] := TMultiValue.InitializeCode(Value[i].ArrayValue.Values[Value[i].ArrayValue.Count + idx].StringValue);
            end;
          end;

        end;
      end;

      TJSONValueType.string,
      TJSONValueType.number,
      TJSONValueType.object,
      TJSONValueType.boolean,
      TJSONValueType.null,
      TJSONValueType.code:;
    end;
  end;
  Result := ProcessNext(Result);
end;

function TIndexGenerator.ToString: string;
var
  s : string;
  i: integer;
begin
  s := '';
  for i in FIndexes do
  begin
    if s <> '' then
      s := s+', ';
    s := s+i.ToString;
  end;
  Result := inherited ToString+' ['+s+']';
end;

{ TFromIndexGenerator }

constructor TFromIndexGenerator.Create(FromIndex: integer;
  const Next: IGenerator);
begin
  inherited Create(Next);
  FType := 'INDEX';
  FFromIndex := FromIndex;
end;

function TFromIndexGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen, iFrom : integer;
begin
  SetLength(Result, 0);

  iLen := Length(Value);
  for var i := 0 to iLen-1 do
  begin
    case Value[i].ValueType of
      TJSONValueType.array:
      begin
        iFrom := FFromIndex;
        if iFrom < 0 then
          iFrom := Value[i].ArrayValue.Count + iFrom;
        if iFrom < 0 then
          iFrom := 0;

        for var idx := iFrom to Value[i].ArrayValue.Count-1 do
        begin
          if (idx >= 0) and (idx <= Value[i].ArrayValue.Count-1) then
          begin
            SetLength(Result, length(Result)+1);
            case Value[i].ArrayValue.Types[idx] of
              TJSONValueType.string:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Strings[idx]);
              TJSONValueType.number:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Numbers[idx]);
              TJSONValueType.object:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Objects[idx]);
              TJSONValueType.array:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Arrays[idx]);
              TJSONValueType.boolean:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Booleans[idx]);
              TJSONValueType.null:
                Result[Length(Result)-1] := TMultiValue.InitializeNull;
              TJSONValueType.code:
                Result[Length(Result)-1] := TMultiValue.InitializeCode(Value[i].ArrayValue.Values[idx].StringValue);
            end;
          end;
        end;
      end;

      TJSONValueType.string,
      TJSONValueType.number,
      TJSONValueType.object,
      TJSONValueType.boolean,
      TJSONValueType.null,
      TJSONValueType.code:;
    end;
  end;
  Result := ProcessNext(Result);
end;

function TFromIndexGenerator.ToString: string;
begin
  Result := inherited ToString+' From '+FFromIndex.ToString;
end;

{ TToIndexGenerator }

constructor TToIndexGenerator.Create(ToIndex: integer; const Next: IGenerator);
begin
  inherited Create(Next);
  FType := 'INDEX';
  FToIndex := ToIndex;
end;

function TToIndexGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen, iTo : integer;
begin
  SetLength(Result, 0);

  iLen := Length(Value);
  for var i := 0 to iLen-1 do
  begin
    case Value[i].ValueType of
      TJSONValueType.array:
      begin
        iTo := FToIndex;
        if iTo < 0 then
          iTo := Value[i].ArrayValue.Count + iTo;
        if iTo < 0 then
          iTo := 0;
        for var idx := 0 to iTo do
        begin
          if (idx >= 0) and (idx <= Value[i].ArrayValue.Count-1) then
          begin
            SetLength(Result, length(Result)+1);
            case Value[i].ArrayValue.Types[idx] of
              TJSONValueType.string:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Strings[idx]);
              TJSONValueType.number:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Numbers[idx]);
              TJSONValueType.object:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Objects[idx]);
              TJSONValueType.array:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Arrays[idx]);
              TJSONValueType.boolean:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Booleans[idx]);
              TJSONValueType.null:
                Result[Length(Result)-1] := TMultiValue.InitializeNull;
              TJSONValueType.code:
                Result[Length(Result)-1] := TMultiValue.InitializeCode(Value[i].ArrayValue.Values[idx].StringValue);
            end;
          end;
        end;
      end;

      TJSONValueType.string,
      TJSONValueType.number,
      TJSONValueType.object,
      TJSONValueType.boolean,
      TJSONValueType.null,
      TJSONValueType.code:;
    end;
  end;
  Result := ProcessNext(Result);
end;

function TToIndexGenerator.ToString: string;
begin
  Result := inherited ToString+' To '+FToIndex.ToString;
end;

{ TDeepGenerator }

constructor TDeepGenerator.Create(Prop : string; const Next : IGenerator);
begin
  inherited Create(Prop, Next);
  FType := 'DEEP';
end;

procedure TDeepGenerator.CheckObject(var Result : TMultiValues; Obj : IJSONObject);
begin
  var r := Result;
  Obj.Each(
    procedure(const Name : String; const Value : PMultiValue)
    begin
      if Value.ValueType = TJSONValueType.object then
        CheckObject(r, Value.ObjectValue);
    end
  );

  Result := r;

  if Obj.Has[FProperty] then
  begin
    SetLength(Result, length(Result)+1);
    case obj.Types[FProperty] of
      TJSONValueType.string:
        Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Strings[FProperty]);
      TJSONValueType.number:
        Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Numbers[FProperty]);
      TJSONValueType.object:
        Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Objects[FProperty]);
      TJSONValueType.array:
        Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Arrays[FProperty]);
      TJSONValueType.boolean:
        Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Booleans[FProperty]);
      TJSONValueType.null:
        Result[Length(Result)-1] := TMultiValue.InitializeNull;
      TJSONValueType.code:
        Result[Length(Result)-1] := TMultiValue.InitializeCode(Obj.Values[FProperty].StringValue);
    end;
  end;

end;

function TDeepGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen : integer;
begin
  SetLength(Result, 0);

  iLen := Length(Value);
  for var i := 0 to iLen-1 do
  begin
    case Value[i].ValueType of
      TJSONValueType.object:
      begin
        CheckObject(Result, Value[i].ObjectValue);
      end;

      TJSONValueType.string,
      TJSONValueType.number,
      TJSONValueType.array,
      TJSONValueType.boolean,
      TJSONValueType.null,
      TJSONValueType.code:;
    end;
  end;
  Result := ProcessNext(Result);
end;

{ TPropertyGenerator }

constructor TPropertyGenerator.Create(Prop: string; const Next: IGenerator);
begin
  inherited Create(Next);
  FType := 'PROPERTY';
  FProperty := Prop;
end;

function TPropertyGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen : integer;
begin
  SetLength(Result, 0);

  iLen := Length(Value);
  for var i := 0 to iLen-1 do
  begin
    case Value[i].ValueType of
      TJSONValueType.object:
      begin
        if Value[i].ObjectValue.Has[FProperty] then
        begin
          SetLength(Result, length(Result)+1);
          case Value[i].ObjectValue.Types[FProperty] of
            TJSONValueType.string:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Strings[FProperty]);
            TJSONValueType.number:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Numbers[FProperty]);
            TJSONValueType.object:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Objects[FProperty]);
            TJSONValueType.array:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Arrays[FProperty]);
            TJSONValueType.boolean:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Booleans[FProperty]);
            TJSONValueType.null:
              Result[Length(Result)-1] := TMultiValue.InitializeNull;
            TJSONValueType.code:
              Result[Length(Result)-1] := TMultiValue.InitializeCode(Value[i].ObjectValue.Values[FProperty].StringValue);
          end;
        end;
      end;

      TJSONValueType.string,
      TJSONValueType.number,
      TJSONValueType.array,
      TJSONValueType.boolean,
      TJSONValueType.null,
      TJSONValueType.code:;
    end;
  end;
  Result := ProcessNext(Result);
end;

function TPropertyGenerator.ToString: string;
begin
  Result := inherited ToString+' '+FProperty;
end;

{ TAllPropertiesGenerator }

procedure TAllPropertiesGenerator.CheckObject(var Result: TMultiValues;
  Obj: IJSONObject);
begin
  var r := Result;
  Obj.Each(
    procedure(const Name : String; const Value : PMultiValue)
    begin
      if Value.ValueType = TJSONValueType.object then
        CheckObject(r, Value.ObjectValue);
    end
  );

  Result := r;

  var mv : TMultiValue;
  for var j := 0 to Obj.Count-1 do
  begin
    var sProp := Obj.Names[j];

    if Obj.Has[sProp] then
    begin
      SetLength(Result, length(Result)+1);
      case obj.Types[sProp] of
        TJSONValueType.string:
          Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Strings[sProp]);
        TJSONValueType.number:
          Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Numbers[sProp]);
        TJSONValueType.object:
          Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Objects[sProp]);
        TJSONValueType.array:
          Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Arrays[sProp]);
        TJSONValueType.boolean:
          Result[Length(Result)-1] := TMultiValue.Initialize(Obj.Booleans[sProp]);
        TJSONValueType.null:
          Result[Length(Result)-1] := TMultiValue.InitializeNull;
        TJSONValueType.code:
          Result[Length(Result)-1] := TMultiValue.InitializeCode(Obj.Values[sProp].StringValue);
      end;
    end;
  end;
end;

constructor TAllPropertiesGenerator.Create(const Next: IGenerator; Deep : boolean);
begin
  inherited Create(Next);
  FType := 'ALL';
  FDeep := Deep;
end;

function TAllPropertiesGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen : integer;
begin
  SetLength(Result, 0);

  if FDeep then
  begin
    iLen := Length(Value);
    for var i := 0 to iLen-1 do
    begin
      case Value[i].ValueType of
        TJSONValueType.object:
        begin
          CheckObject(Result, Value[i].ObjectValue);
        end;

        TJSONValueType.string,
        TJSONValueType.number,
        TJSONValueType.array,
        TJSONValueType.boolean,
        TJSONValueType.null,
        TJSONValueType.code:;
      end;
    end;
  end else
  begin
    iLen := Length(Value);
    for var i := 0 to iLen-1 do
    begin
      case Value[i].ValueType of
        TJSONValueType.object:
        begin
          var mv : TMultiValue;
          for var j := 0 to Value[i].ObjectValue.Count-1 do
          begin
            var sProp := Value[i].ObjectValue.Names[i];

            SetLength(Result, length(Result)+1);
            case Value[i].ObjectValue.Types[sProp] of
              TJSONValueType.string:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Strings[sProp]);
              TJSONValueType.number:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Numbers[sProp]);
              TJSONValueType.object:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Objects[sProp]);
              TJSONValueType.array:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Arrays[sProp]);
              TJSONValueType.boolean:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ObjectValue.Booleans[sProp]);
              TJSONValueType.null:
                Result[Length(Result)-1] := TMultiValue.InitializeNull;
              TJSONValueType.code:
                Result[Length(Result)-1] := TMultiValue.InitializeCode(Value[i].ObjectValue.Values[sProp].StringValue);
            end;
          end;
        end;

        TJSONValueType.string,
        TJSONValueType.number,
        TJSONValueType.array,
        TJSONValueType.boolean,
        TJSONValueType.null,
        TJSONValueType.code:;
      end;
    end;
  end;
  Result := ProcessNext(Result);
end;

function TAllPropertiesGenerator.ToString: string;
begin
  Result := inherited ToString+' Properties';
end;

{ TAllIndexesGenerator }

constructor TAllIndexesGenerator.Create(const Next: IGenerator);
begin
  inherited;
  FType := 'ALL';
end;

function TAllIndexesGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen : integer;
begin
  SetLength(Result, 0);

  iLen := Length(Value);
  for var i := 0 to iLen-1 do
  begin
    case Value[i].ValueType of
      TJSONValueType.array:
      begin
        for var idx := 0 to Value[i].ArrayValue.Count-1 do
        begin
          SetLength(Result, length(Result)+1);
          case Value[i].ArrayValue.Types[idx] of
            TJSONValueType.string:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Strings[idx]);
            TJSONValueType.number:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Numbers[idx]);
            TJSONValueType.object:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Objects[idx]);
            TJSONValueType.array:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Arrays[idx]);
            TJSONValueType.boolean:
              Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Booleans[idx]);
            TJSONValueType.null:
              Result[Length(Result)-1] := TMultiValue.InitializeNull;
            TJSONValueType.code:
              Result[Length(Result)-1] := TMultiValue.InitializeCode(Value[i].ArrayValue.Values[idx].StringValue);
          end;
        end;
      end;

      TJSONValueType.string,
      TJSONValueType.number,
      TJSONValueType.object,
      TJSONValueType.boolean,
      TJSONValueType.null,
      TJSONValueType.code:;
    end;
  end;
  Result := ProcessNext(Result);
end;

function TAllIndexesGenerator.ToString: string;
begin
  Result := inherited ToString+' Indexes';
end;

{ TSliceGenerator }

constructor TSliceGenerator.Create(FromIndex, ToIndex: integer;
  const Next: IGenerator);
begin
  inherited Create(Next);
  FType := 'INDEX';
  FFromIndex := FromIndex;
  FToIndex := ToIndex;
end;

function TSliceGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen, iFrom, iTo : integer;
begin
  SetLength(Result, 0);

  iLen := Length(Value);
  for var i := 0 to iLen-1 do
  begin
    case Value[i].ValueType of
      TJSONValueType.array:
      begin
        iTo := FToIndex;
        if iTo < 0 then
          iTo := Value[i].ArrayValue.Count + iTo;
        if iTo < 0 then
          iTo := 0;
        iFrom := FFromIndex;
        if iFrom < 0 then
          iFrom := Value[i].ArrayValue.Count + iFrom;
        if iFrom < 0 then
          iFrom := 0;
        for var idx := iFrom to iTo do
        begin
          if (idx >= 0) and (idx <= Value[i].ArrayValue.Count-1) then
          begin
            SetLength(Result, length(Result)+1);
            case Value[i].ArrayValue.Types[idx] of
              TJSONValueType.string:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Strings[idx]);
              TJSONValueType.number:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Numbers[idx]);
              TJSONValueType.object:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Objects[idx]);
              TJSONValueType.array:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Arrays[idx]);
              TJSONValueType.boolean:
                Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Booleans[idx]);
              TJSONValueType.null:
                Result[Length(Result)-1] := TMultiValue.InitializeNull;
              TJSONValueType.code:
                Result[Length(Result)-1] := TMultiValue.InitializeCode(Value[i].ArrayValue.Values[idx].StringValue);
            end;
          end;
        end;
      end;

      TJSONValueType.string,
      TJSONValueType.number,
      TJSONValueType.object,
      TJSONValueType.boolean,
      TJSONValueType.null,
      TJSONValueType.code:;
    end;
  end;
  Result := ProcessNext(Result);
end;

function TSliceGenerator.ToString: string;
begin
  Result := inherited ToString+' From '+FFromIndex.ToString+' To '+FToIndex.ToString;
end;

{ TLengthGenerator }

constructor TLengthGenerator.Create(const Next: IGenerator);
begin
  inherited;
  FType := 'LENGTH';
end;

function TLengthGenerator.Process(Value: TMultiValues): TMultiValues;
var
  iLen : integer;
begin
  SetLength(Result, 0);

  iLen := Length(Value);
  for var i := 0 to iLen-1 do
  begin
    SetLength(Result, length(Result)+1);
    case Value[i].ValueType of
      TJSONValueType.array:
      begin
        Result[Length(Result)-1] := TMultiValue.Initialize(Value[i].ArrayValue.Count);
      end;

      TJSONValueType.string,
      TJSONValueType.number,
      TJSONValueType.object,
      TJSONValueType.boolean,
      TJSONValueType.null,
      TJSONValueType.code:;
    end;
  end;
  Result := ProcessNext(Result);
end;

{ TFilterGenerator }

constructor TFilterGenerator.Create(const Expression: String;
  const Next: IGenerator);
begin
  inherited Create(Next);
  FExpression := Expression;
end;

function TFilterGenerator.Process(Value: TMultiValues): TMultiValues;
begin
  Result := Value;
end;

function TFilterGenerator.ToString: string;
begin
  Result := inherited ToString+' ('+FExpression+')';
end;

{ TKeysGenerator }

constructor TKeysGenerator.Create(const Next: IGenerator);
begin
  inherited;
  FType := 'KEYS()';
end;

function TKeysGenerator.Process(Value: TMultiValues): TMultiValues;
var
  r : TMultiValues;
begin
  SetLength(r,0);
  for var mv in Value do
  begin
    if mv.ValueType = TJSONValueType.object then
    begin
      mv.ObjectValue.Each(
        procedure(const Name : string; const Value : PMultiValue)
        begin
          SetLength(r, Length(r)+1);
          r[Length(r)-1] := TMultiValue.Initialize(Name);
        end
      );
    end;
  end;
  Result := r;
end;

function CompareArrays(const L, R : IJSONArray) : integer;
begin
  Result := R.Count - L.Count;
end;
function CompareObjects(const L, R : IJSONObject) : integer;
begin
  Result := L.AsSHA1.CompareTo(R.AsSHA1);
end;
function CompareMV(const L, R : TMultiValue) : integer;
begin
  result := 0;
  if L.ValueType <> R.ValueType then
  begin
    case L.ValueType of
      TJSONValueType.string:
        if R.ValueType in [TJSONValueType.code] then
          Result := L.StringValue.CompareTo(R.StringValue)
        else
          Result := -1;
      TJSONValueType.number:
        if R.ValueType = TJSONValueType.Boolean then
          if R.NumberValue - L.NumberValue < 0 then
            Result := -1
          else if R.NumberValue - L.NumberValue > 0 then
            Result := 1
          else
            Result := 0
        else
          Result := 1;
      TJSONValueType.array:
        if R.ValueType <> TJSONValueType.Object then
          Result := 1
        else
          Result := -1;
      TJSONValueType.object:
        Result := 1;
      TJSONValueType.boolean:
        if R.ValueType in [TJSONValueType.number] then
          if R.NumberValue - L.NumberValue < 0 then
            Result := -1
          else if R.NumberValue - L.NumberValue > 0 then
            Result := 1
          else
            Result := 0
        else
          Result := -1;
      TJSONValueType.null:
        Result := -1;
      TJSONValueType.code:
        if R.ValueType in [TJSONValueType.string] then
          Result := L.StringValue.CompareTo(R.StringValue)
        else
          Result := -1;
    end;
  end else
  begin
    case L.ValueType of
      TJSONValueType.string:
        Result := L.StringValue.CompareTo(R.StringValue);
      TJSONValueType.number:
        if R.NumberValue - L.NumberValue < 0 then
          Result := -1
        else if R.NumberValue - L.NumberValue > 0 then
          Result := 1
        else
          Result := 0;
      TJSONValueType.array:
        Result := CompareArrays(L.ArrayValue, R.ArrayValue);
      TJSONValueType.object:
        Result := CompareObjects(L.ObjectValue, R.ObjectValue);
      TJSONValueType.boolean:
        if R.NumberValue - L.NumberValue < 0 then
          Result := -1
        else if R.NumberValue - L.NumberValue > 0 then
          Result := 1
        else
          Result := 0;
      TJSONValueType.null:
        Result := 0;
      TJSONValueType.code:
        Result := L.StringValue.CompareTo(R.StringValue);
    end;
  end;
end;


{ TMinGenerator }

constructor TMinGenerator.Create(const Next: IGenerator);
begin
  inherited;
  FType := 'MIN()';
end;

function TMinGenerator.Process(Value: TMultiValues): TMultiValues;
begin
  SetLength(Result, 0);
  for var mv in Value do
  begin
    if Length(Result) = 0 then
    begin
      SetLength(Result,1);
      Result[0] := mv;
    end else
    begin
      if CompareMV(Result[0], mv) < 0 then
        Result[0] := mv;
    end;
  end;
end;

{ TMaxGenerator }

constructor TMaxGenerator.Create(const Next: IGenerator);
begin
  inherited;
  FType := 'MAX()';
end;

function TMaxGenerator.Process(Value: TMultiValues): TMultiValues;
begin
  SetLength(Result, 0);
  for var mv in Value do
  begin
    if Length(Result) = 0 then
    begin
      SetLength(Result,1);
      Result[0] := mv;
    end else
    begin
      if CompareMV(Result[0], mv) > 0 then
        Result[0] := mv;
    end;
  end;
end;

{ TAvgGenerator }

constructor TAvgGenerator.Create(const Next: IGenerator);
begin
  inherited;
  FType := 'AVG()';
end;

function TAvgGenerator.Process(Value: TMultiValues): TMultiValues;
var
  Val : Double;
begin
  Val := 0;

  for var mv in Value do
  begin
    case mv.ValueType of
      TJSONValueType.number,
      TJSONValueType.boolean:
        Val := Val+mv.NumberValue;
    end;
  end;
  SetLength(Result,1);
  Result[0] := TMultiValue.Initialize(Val / Length(Value));
end;

{ TSumGenerator }

constructor TSumGenerator.Create(const Next: IGenerator);
begin
  inherited;
  FType := 'SUM()';
end;

function TSumGenerator.Process(Value: TMultiValues): TMultiValues;
var
  Val : Double;
begin
  Val := 0;

  for var mv in Value do
  begin
    case mv.ValueType of
      TJSONValueType.number,
      TJSONValueType.boolean:
        Val := Val+mv.NumberValue;
    end;
  end;
  SetLength(Result,1);
  Result[0] := TMultiValue.Initialize(Val);
end;

{ TStdDevGenerator }

constructor TStdDevGenerator.Create(const Next: IGenerator);
begin
  inherited;
  FType := 'STDDEV()';
end;

function TStdDevGenerator.Process(Value: TMultiValues): TMultiValues;
var
  Val : TArray<Double>;
begin
  setLength(Val, Length(Value));

  for var i := 0 to Length(Value)-1 do
  begin
    case Value[i].ValueType of
      TJSONValueType.number,
      TJSONValueType.boolean:
        Val[i] := Value[i].NumberValue;
      else
        Val[i] := 0;
    end;
  end;
  SetLength(Result,1);
  Result[0] := TMultiValue.Initialize(StdDev(Val));
end;

{ TConcatGenerator }

constructor TConcatGenerator.Create(const Value: string;
  const Next: IGenerator);
begin
  inherited Create(Next);
  FType := 'CONCAT('+Value+')';
  FValue := Value;
end;

function TConcatGenerator.Process(Value: TMultiValues): TMultiValues;
var
  s : string;
begin
  SetLength(Result, 1);

  s := '';
  for var mv in Value do
  begin
    if s <> '' then
      s := s + FValue;

    case mv.ValueType of
      TJSONValueType.string:
        s := s + mv.StringValue;
      TJSONValueType.number:
        s := s + mv.NumberValue.ToString;
      TJSONValueType.array:
        s := s + mv.ArrayValue.AsJSON;
      TJSONValueType.object:
        s := s + mv.ObjectValue.AsJSON;
      TJSONValueType.boolean:
        s := s + mv.NumberValue.ToString;
      TJSONValueType.null:
        s := s + 'NULL';
      TJSONValueType.code:
        s := s + mv.StringValue;
    end;
  end;
  SetLength(Result,1);
  Result[0] := TMultiValue.Initialize(s);
end;

{ TAppendGenerator }

constructor TAppendGenerator.Create(const Value: string;
  const Next: IGenerator);
begin
  inherited Create(Next);
  FType := 'APPEND('+Value+')';
  FValue := Value;
end;

function TAppendGenerator.Process(Value: TMultiValues): TMultiValues;
var
  s : string;
begin
  Result := Value;
  SetLength(Result, Length(result)+1);
  Result[Length(Result)-1] := TMultiValue.Initialize(FValue);
end;

end.
