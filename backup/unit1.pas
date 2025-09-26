unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, PQConnection, SQLDB, Forms, Controls, Graphics,
  Dialogs, DB, DBGrids, UClasses, StdCtrls, ExtCtrls, Unit2, Unit3, Grids;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnLancarPesagem: TButton;
    BtnMortalidade: TButton;
    BtnPesagem: TButton;
    DBGrid1: TDBGrid;
    DsLotes: TDataSource;
    lblLotes: TLabel;
    PQConnection1: TPQConnection;
    QryLotes: TSQLQuery;
    SQLTransaction1: TSQLTransaction;

    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnLancarPesagemClick(Sender: TObject);
    procedure BtnLancarMortalidadeClick(Sender: TObject);

  private
    procedure CarregarLotes;
    function GetIDLoteSelecionado: Integer;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  try
    PQConnection1.Connected := True;
  except
    on E: Exception do
      ShowMessage('ERRO CRÍTICO DE CONEXÃO: ' + E.Message);
  end;
end;

procedure TForm1.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Percentual: Real;
  Texto: string;
begin
  // Verifique o nome EXATO do campo que contém o percentual de mortalidade
  if Column.FieldName = 'status' then
  begin
    // 1. Acesso Seguro ao Valor
    if QryLotes.Active then
      Percentual := QryLotes.FieldByName('status').AsFloat
    else
      Percentual := 0.0;

    // 2. Lógica de Pintura de Fundo e Texto (usando Percentual)
    if gdSelected in State then
      DBGrid1.Canvas.Brush.Color := clHighlight // Mantém seleção azul
    else if Percentual < 5.0 then
      DBGrid1.Canvas.Brush.Color := clGreen
    else if Percentual < 10.0 then
      DBGrid1.Canvas.Brush.Color := clYellow
    else
      DBGrid1.Canvas.Brush.Color := clRed;

    // Preenche o fundo da célula
    DBGrid1.Canvas.FillRect(Rect);

    // Ajusta cor do texto para CONTRASTE
    if (DBGrid1.Canvas.Brush.Color = clRed) or (DBGrid1.Canvas.Brush.Color = clGreen) then
      DBGrid1.Canvas.Font.Color := clWhite
    else if gdSelected in State then
      DBGrid1.Canvas.Font.Color := clHighlightText
    else
      DBGrid1.Canvas.Font.Color := clBlack;

    // 3. Desenha o texto do percentual (SEM CHAMAR DefaultDrawColumnCell)
    Texto := FormatFloat('0.00%', Percentual);
    DBGrid1.Canvas.TextOut(Rect.Left + 5, Rect.Top + 3, Texto);

    // **NÃO HÁ NADA AQUI** - O desenho para essa coluna termina neste ponto.
  end
  else
    // 4. Para todas as outras colunas, usa o desenho padrão
    DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;


procedure TForm1.FormShow(Sender: TObject);
begin
  CarregarLotes;
  DBGrid1.Columns[0].Width := 40;
  DBGrid1.Columns[1].Width := 300;
  DBGrid1.Columns[2].Width := 100;
  DBGrid1.Columns[3].Width := 100;
  DBGrid1.Columns[4].Width := 50;
end;

// Atualiza os dados da grid
procedure TForm1.CarregarLotes;
begin
  if not PQConnection1.Connected then Exit;

  if QryLotes.Active then
    QryLotes.Close;

  try
    QryLotes.Database := PQConnection1;
    QryLotes.SQL.Text :=
      'SELECT ' +
      '  l.id_lote as Lote, ' +
      '  l.descricao as Descricao, ' +
      '  l.data_entrada as Entrada, ' +
      '  l.quantidade_inicial as Inicial, ' +
      '  (SELECT (SUM(quantidade_morta) * 100.0 / l.quantidade_inicial) FROM tab_mortalidade m WHERE m.id_lote_fk = l.id_lote) AS Status ' +
      'FROM TAB_LOTE_AVES l ORDER BY l.ID_LOTE DESC';
    QryLotes.Open;
  except
    on E: Exception do
      ShowMessage('ERRO AO CARREGAR LOTES: ' + E.Message);
  end;
end;

// Recupera o ID_LOTE da linha selecionada
function TForm1.GetIDLoteSelecionado: Integer;
begin
  Result := -1;
  if not QryLotes.Active then Exit;
  if QryLotes.RecordCount = 0 then Exit;

  Result := QryLotes.FieldByName('Lote').AsInteger;
end;

// Botão: abre tela de Pesagem
procedure TForm1.BtnLancarPesagemClick(Sender: TObject);
var
  F: TPesagens;
  LoteID: Integer;
begin
  LoteID := GetIDLoteSelecionado;
  if LoteID = -1 then
  begin
    ShowMessage('Selecione um lote na tabela primeiro.');
    Exit;
  end;

  F := TPesagens.Create(nil);
  try
    F.CarregarPesagem(LoteID, PQConnection1, SQLTransaction1);
    if F.ShowModal = mrOk then
      CarregarLotes; // Atualiza grid se houve lançamento
  finally
    F.Free;
  end;
end;

// Botão: abre tela de Mortalidade
procedure TForm1.BtnLancarMortalidadeClick(Sender: TObject);
var
  F: TMortalidade;
  LoteID: Integer;
begin
  LoteID := GetIDLoteSelecionado;
  if LoteID = -1 then
  begin
    ShowMessage('Selecione um lote na tabela primeiro.');
    Exit;
  end;

  F := TMortalidade.Create(nil);
  try
    F.CarregarMortalidade(LoteID, PQConnection1, SQLTransaction1);
    if F.ShowModal = mrOk then
      CarregarLotes;
  finally
    F.Free;
  end;
end;

end.

