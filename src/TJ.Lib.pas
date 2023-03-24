unit TJ.Lib;

interface

uses
  System.Classes;

type
  TLibType = (ljMcJSON, ljLkJSON, ljSystemJSON, ljJdoJSON, ljSuperObject,
              ljXSuperObject, ljJsonTools, ljJson4Delphi, ljGrijjyBson,
              ljNeslibJson, ljDwsJSON, ljChimeraJson);

  ILib = interface
  ['{BC59958C-81A8-4C5B-9847-2E51C3C6BCF2}']
    function fGetName: string;

    procedure Add(const aKey, aValue: string);
    function  Count: Integer;
    procedure Clear;
    procedure Save(const aFileName: string);
    procedure Load(const aFileName: string);
    function  Find(const aKey, aValue: string): Boolean;
    procedure Parse;
    function  Check(const aCode: string): Boolean;
    function  ToString: string;

    property Name: string read fGetName;
  end;

  TLibFactory = class
    class function CreateLib(aType: TLibType): ILib;
  end;

implementation

uses
  TJ.LibMcJSON, TJ.LibLkJSON, TJ.LibSystemJSON, TJ.LibJDO, TJ.LibSuperObject,
  TJ.LibXSuperObject, TJ.LibJsonTools, TJ.LibJson4Delphi, TJ.LibGrijjyBson,
  TJ.LibNeslibJson, TJ.LibDwsJSON, TJ.LibChimeraJson;

class function TLibFactory.CreateLib(aType: TLibType): ILib;
begin
  if      (aType = ljMcJSON      ) then Result := TLibMcJSON.Create()
  else if (aType = ljLkJSON      ) then Result := TLibLkJSON.Create()
  else if (aType = ljSystemJSON  ) then Result := TLibSystemJSON.Create()
  else if (aType = ljJdoJSON     ) then Result := TLibJDO.Create()
  else if (aType = ljSuperObject ) then Result := TLibSuperObject.Create()
  else if (aType = ljXSuperObject) then Result := TLibXSuperObject.Create()
  else if (aType = ljJsonTools   ) then Result := TLibJsonTools.Create()
  else if (aType = ljJson4Delphi ) then Result := TLibJson4Delphi.Create()
  else if (aType = ljGrijjyBson  ) then Result := TLibGrijjyBson.Create()
  else if (aType = ljNeslibJson  ) then Result := TLibNeslibJson.Create()
  else if (aType = ljDwsJSON     ) then Result := TLibDwsJSON.Create()
  else if (aType = ljChimeraJson ) then Result := TLibChimeraJson.Create()
  else                                  Result := nil;
end;

end.
