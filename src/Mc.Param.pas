unit Mc.Param;

interface

uses
  System.SysUtils, Vcl.StdCtrls,
  McJSON;

type
  TMcParam = class
  private
    FFileName: string;
    FParam: TMcJsonItem;

    function  fGetSelected: string;
    procedure fSetSelected(aValue: string);

  public
    constructor Create(aFileName: string);
    destructor Destroy; override;

    procedure LoadList(aCbx: TComboBox);
    procedure Persist;

    function ExistsByName(aName: string): Boolean;
    function GetByName(aName: string): TMcJsonItem;
    function GetOrCreateByName(aName: string): TMcJsonItem;
    function GetByIndex(aIndex: Integer): TMcJsonItem;

    procedure DeleteByName(aName: string);

    property Prm: TMcJsonItem read FParam      write FParam;
    property Selected: string read fGetSelected write fSetSelected;
  end;

implementation

const
  C_Param_LIST = 'List';
  C_Param_SEL  = 'Selected';

function TMcParam.fGetSelected: string;
begin
  Result := FParam.S[C_Param_SEL];
end;

procedure TMcParam.fSetSelected(aValue: string);
begin
  FParam.S[C_Param_SEL] := aValue;
end;

constructor TMcParam.Create(aFileName: string);
begin
  FFileName := aFileName;
  // Params
  FParam := TMcJsonItem.Create;
end;

destructor TMcParam.Destroy;
begin
  FParam.Free;
  inherited Destroy;
end;

procedure TMcParam.LoadList(aCbx: TComboBox);
var
  PrsList: TMcJsonItem;
  i: integer;
begin
  if ( not Assigned(aCbx) ) then Exit;
  aCbx.Clear;
  try
  begin
    //MyLog(ExpandFileName(C_Param_FILE));
    if (not FileExists(FFileName)) then Exit;
    FParam.LoadFromFile(FFileName);
    PrsList := FParam.Values[C_Param_LIST];
    for i := 0 to (PrsList.Count - 1) do
      aCbx.Items.Add(PrsList.Items[i].Key);
  end;
  except
  end;
end;

procedure TMcParam.Persist;
begin
  // save to file with human reading.
  FParam.SaveToFile(FFileName, true);
end;

function TMcParam.ExistsByName(aName: string): Boolean;
var
  PrsList: TMcJsonItem;
begin
  PrsList := FParam.O[C_Param_LIST];
  Result := PrsList.HasKey(aName);
end;

function TMcParam.GetByName(aName: string): TMcJsonItem;
var
  PrsList: TMcJsonItem;
begin
  Result := nil;
  PrsList := FParam.O[C_Param_LIST];
  if ( PrsList.HasKey(aName) ) then
    Result := FParam.Values[C_Param_LIST][aName];
end;

function TMcParam.GetOrCreateByName(aName: string): TMcJsonItem;
var
  PrsList: TMcJsonItem;
begin
  PrsList := FParam.O[C_Param_LIST];
  Result  := PrsList.O[aName];
end;

function TMcParam.GetByIndex(aIndex: Integer): TMcJsonItem;
var
  PrsList: TMcJsonItem;
begin
  Result := nil;
  PrsList := FParam.O[C_Param_LIST];
  if ( (aIndex >= 0            ) and
       (aIndex <  PrsList.Count) ) then
    Result := PrsList.Items[aIndex];
end;

procedure TMcParam.DeleteByName(aName: string);
var
  PrsList: TMcJsonItem;
  Pos: Integer;
begin
  PrsList := FParam.O[C_Param_LIST];
  PrsList.Delete(aName);
end;

end.
