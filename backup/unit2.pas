unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, PQConnection, SQLDB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DateTimePicker;

type

  { TPesagens }

  TPesagens = class(TForm)
    BtnLancaPesagem: TButton;
    BtnCancelar: TButton;
    DtPesagem: TDateTimePicker;
    LblLote: TLabel;
    LblPsMedio: TLabel;
    PQConnection1: TPQConnection;
    PsMedio: TEdit;
    LblDtPesagem: TLabel;
    QtdPesada: TEdit;
    LblQtdPesada: TLabel;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnLancaPesagemClick(Sender: TObject);
  private
    F_IDLote: Integer;
    F_Conexao: TPQConnection;
    F_Transacao: TSQLTransaction;
  public
    procedure CarregarPesagem(ID: Integer; Conexao: TPQConnection; Transacao: TSQLTransaction);
  end;

var
  Pesagens: TPesagens;

implementation

{$R *.lfm}

{ TPesagens }

// Carrega os dados de conexão e lote selecionado
procedure TPesagens.CarregarPesagem(ID: Integer; Conexao: TPQConnection; Transacao: TSQLTransaction);
begin
  F_IDLote := ID;
  F_Conexao := Conexao;
  F_Transacao := Transacao;
  LblLote.Caption := 'ID do Lote: ' + IntToStr(F_IDLote);
end;

// Botão Cancelar → apenas fecha e volta
procedure TPesagens.BtnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

// Botão Lançar → valida, insere no banco e volta
procedure TPesagens.BtnLancaPesagemClick(Sender: TObject);
var
  QryExec, QryCheck: TSQLQuery;
  QuantidadeInicial, QuantidadeTotal, QtdAtual: Integer;
begin
  // Validações simples
  if Trim(PsMedio.Text) = '' then
  begin
    ShowMessage('Informe o peso médio.');
    Exit;
  end;

  if Trim(QtdPesada.Text) = '' then
  begin
    ShowMessage('Informe a quantidade pesada.');
    Exit;
  end;

    if DtPesagem.DateTime > Now then
     begin
         ShowMessage('Não é possível salvar com data Futura.');
         Exit;
     end;

  QryExec := TSQLQuery.Create(nil);
  try
    QryExec.DataBase := F_Conexao;
    QryExec.Transaction := F_Transacao;
    try
      QryCheck.DataBase := F_Conexao;
      QryCheck.Transaction := F_Transacao;
      QryCheck.SQL.Text := 'SELECT quantidade_inicial FROM tab_lote_aves WHERE id_lote = :id';
      QryCheck.Params.ParamByName('id').AsInteger := F_IDLote;
      QryCheck.Open;
      if QryCheck.RecordCount = 0 then
      begin
        ShowMessage('Lote não encontrado.');
        Exit;
      end;
      QuantidadeInicial := QryCheck.FieldByName('quantidade_inicial').AsInteger;
      QryCheck.Close;

      QryCheck.SQL.Text := 'SELECT COALESCE(SUM(quantidade_pesada),0) AS total FROM tab_pesagem WHERE id_lote_fk = :id';
      QryCheck.Params.ParamByName('id').AsInteger := F_IDLote;
      QryCheck.Open;
      QuantidadeTotal := QryCheck.FieldByName('total').AsInteger;
      QryCheck.Close;

      if QuantidadeTotal + QtdAtual > QuantidadeInicial then
      begin
        ShowMessage('Erro: A quantidade total pesagem ultrapassa a quantidade inicial do lote (' +
          IntToStr(QuantidadeInicial) + ').');
        Exit;
      end;
    finally
      QryCheck.Free;
    end;

    try
      QryExec.SQL.Text :=
        'INSERT INTO tab_pesagem (id_lote_fk, data_pesagem, peso_medio, quantidade_pesada) ' +
        'VALUES (:id_lote, :data_pesagem, :peso_medio, :qtd_pesada)';

      QryExec.Params.ParamByName('id_lote').AsInteger := F_IDLote;
      QryExec.Params.ParamByName('data_pesagem').AsDate := DtPesagem.Date;
      QryExec.Params.ParamByName('peso_medio').AsFloat := StrToFloat(PsMedio.Text);
      QryExec.Params.ParamByName('qtd_pesada').AsInteger := StrToInt(QtdPesada.Text);

      QryExec.ExecSQL;
      F_Transacao.Commit;

      ShowMessage('Pesagem registrada com sucesso!');
      ModalResult := mrOk; // fecha a tela e volta pro form inicial
    except
      on E: Exception do
      begin
        F_Transacao.Rollback;
        ShowMessage('ERRO AO SALVAR PESAGEM: ' + E.Message);
      end;
    end;
  finally
    QryExec.Free;
  end;
end;

end.

