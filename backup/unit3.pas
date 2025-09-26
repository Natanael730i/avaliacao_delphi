unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, PQConnection, SQLDB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DateTimePicker;

type

  { TMortalidade }

  TMortalidade = class(TForm)
    BtnLancar: TButton;
    BtnCancelar: TButton;
    Data: TDateTimePicker;
    LblLote: TLabel;
    LblObservacoes: TLabel;
    Observacoes: TMemo;
    PQConnection1: TPQConnection;
    QtdMortos: TEdit;
    LblQtdMortos: TLabel;
    LblData: TLabel;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnLancarClick(Sender: TObject);
  private
    F_IDLote: Integer;
    F_Conexao: TPQConnection;
    F_Transacao: TSQLTransaction;
  public
    procedure CarregarMortalidade(ID: Integer; Conexao: TPQConnection; Transacao: TSQLTransaction);
  end;

var
  Mortalidade: TMortalidade;

implementation

{$R *.lfm}

{ TMortalidade }

// Recebe o lote selecionado e a conexão
procedure TMortalidade.CarregarMortalidade(ID: Integer; Conexao: TPQConnection; Transacao: TSQLTransaction);
begin
  F_IDLote := ID;
  F_Conexao := Conexao;
  F_Transacao := Transacao;
  LblLote.Caption := 'ID do Lote: ' + IntToStr(F_IDLote);
end;

// Botão Cancelar → apenas volta
procedure TMortalidade.BtnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

// Botão Lançar → valida, insere no banco e confirma
procedure TMortalidade.BtnLancarClick(Sender: TObject);
var
  QryExec, QryCheck: TSQLQuery;
  Qtd, QuantidadeInicial, QuantidadeTotal: Integer;
begin
  // Validação
  if Trim(QtdMortos.Text) = '' then
  begin
    ShowMessage('Informe a quantidade de aves mortas.');
    Exit;
  end;

  Qtd := StrToIntDef(QtdMortos.Text, 0);
  if Qtd <= 0 then
  begin
    ShowMessage('A quantidade deve ser maior que zero.');
    Exit;
  end;

  if Data.DateTime > Now then
     begin
         ShowMessage('Não é possível salvar com data Futura.');
         Exit;
     end;
  // Inserção no banco
  QryExec := TSQLQuery.Create(nil);
  try
    QryExec.DataBase := F_Conexao;
    QryExec.Transaction := F_Transacao;
    QryCheck := TSQLQuery.Create(nil);
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

      QryCheck.SQL.Text := 'SELECT COALESCE(SUM(quantidade_morta),0) AS total FROM tab_mortalidade WHERE id_lote_fk = :id';
      QryCheck.Params.ParamByName('id').AsInteger := F_IDLote;
      QryCheck.Open;
      QuantidadeTotal := QryCheck.FieldByName('total').AsInteger;
      QryCheck.Close;

      if QuantidadeTotal + StrToInt(QtdMortos.Text)  > QuantidadeInicial then
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
        'INSERT INTO tab_mortalidade (id_lote_fk, data_mortalidade, quantidade_morta, observacao) ' +
        'VALUES (:id_lote, :data_morte, :qtd, :obs)';

      QryExec.Params.ParamByName('id_lote').AsInteger := F_IDLote;
      QryExec.Params.ParamByName('data_morte').AsDate := Data.Date;
      QryExec.Params.ParamByName('qtd').AsInteger := Qtd;
      QryExec.Params.ParamByName('obs').AsString := Observacoes.Text;

      QryExec.ExecSQL;
      F_Transacao.Commit;

      ShowMessage('Mortalidade registrada com sucesso!');
      ModalResult := mrOk; // fecha e volta
    except
      on E: Exception do
      begin
        F_Transacao.Rollback;
        ShowMessage('ERRO AO SALVAR MORTALIDADE: ' + E.Message);
      end;
    end;
  finally
    QryExec.Free;
  end;
end;

end.

