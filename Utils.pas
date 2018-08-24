unit Utils;

interface

uses
  Variants,
  TypInfo,
  SysUtils;

type
  TEnum<T: record> = record
  public
    class function ToString(const Value: T): string; static;
    class function ToInteger(const Value: T): Integer; static;
    class function ToEnum(const Value: string): T; overload; static;
    class function ToEnum(const Value: Integer): T; overload; static;
  end;


implementation

{ TEnumConversor }

class function TEnum<T>.ToEnum(const Value: string): T;
var
  P: ^T;
  num: Integer;
begin
  try
    num := GetEnumValue(TypeInfo(T), Value);
    if num = -1 then
      abort;

    P := @num;
    result := P^;
  except
    raise EConvertError.Create('O Parâmetro "' + Value + '" passado não ' +
      sLineBreak + ' corresponde a um Tipo Enumerado ' + GetTypeName(TypeInfo(T)));
  end;
end;

class function TEnum<T>.ToEnum(const Value: Integer): T;
var
  P: ^T;
  num: Integer;
  tmp: string;
begin
  try
    tmp := GetEnumName(TypeInfo(T), Value);
    num := GetEnumValue(TypeInfo(T), tmp);
    if num = -1 then
      abort;

    P := @num;
    result := P^;
  except
    raise EConvertError.Create(Format('O Parâmetro %d passado não' + sLineBreak +
                                      'corresponde a um Tipo Enumerado %s',
                                      [Value,
                                       GetTypeName(TypeInfo(T))]));
  end;
end;

class function TEnum<T>.ToInteger(const Value: T): Integer;
type
  TGenerico = 0..255;

var
  P: PInteger;
  num: Integer;
begin

  try
    P := @Value;
    num := Ord(TGenerico((P^)));
    result := num;
  except
    raise EConvertError.Create('O Parâmetro passado não corresponde a ' +
      sLineBreak + 'Ou a um Tipo Enumerado ' + GetTypeName(TypeInfo(T)));
  end;
end;

class function TEnum<T>.ToString(const Value: T): string;
type
  TGenerico = 0..255;

var
  P: PInteger;
  num: Integer;
begin

  try
    P := @Value;
    num := Ord(TGenerico((P^)));
    result := GetEnumName(TypeInfo(T), num);
  except
    raise EConvertError.Create('O Parâmetro passado não corresponde a ' +
      sLineBreak + 'Ou a um Tipo Enumerado ' + GetTypeName(TypeInfo(T)));
  end;
end;

end.
