unit UClasses;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, PQConnection, SQLDB;

type
  { TModelBase }
  TModelBase = class
  private
    FDataRegistro: TDateTime;
  public
    property DataRegistro: TDateTime read FDataRegistro write FDataRegistro;
  end;

  { TLote }
  TLote = class(TModelBase)
  private
    FIDLote: Integer;
    FDescricao: string;
    FQuantidadeInicial: Integer;
  public
    property IDLote: Integer read FIDLote write FIDLote;
    property Descricao: string read FDescricao write FDescricao;
    property QuantidadeInicial: Integer read FQuantidadeInicial write FQuantidadeInicial;
    function CreationTable():TSQLQuery;
  end;

  { TPesagem }
  TPesagem = class(TModelBase)
  private
    FIDPesagem: Integer;
    FIDLoteFK: Integer;
    FPesoMedio: Real;
    FQuantidadePesada: Integer;
  public
    property IDPesagem: Integer read FIDPesagem write FIDPesagem;
    property IDLoteFK: Integer read FIDLoteFK write FIDLoteFK;
    property PesoMedio: Real read FPesoMedio write FPesoMedio;
    property QuantidadePesada: Integer read FQuantidadePesada write FQuantidadePesada;
  end;

  { TMortalidade }
  TMortalidade = class(TModelBase)
  private
    FIDMortalidade: Integer;
    FIDLoteFK: Integer;
    FQuantidadeMorta: Integer;
    FObservacao: string;
  public
    property IDMortalidade: Integer read FIDMortalidade write FIDMortalidade;
    property IDLoteFK: Integer read FIDLoteFK write FIDLoteFK;
    property QuantidadeMorta: Integer read FQuantidadeMorta write FQuantidadeMorta;
    property Observacao: string read FObservacao write FObservacao;
  end;

implementation

end.
