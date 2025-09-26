-- =====================================================
-- Dados iniciais
-- =====================================================

INSERT INTO public.tab_lote_aves (id_lote, descricao, data_entrada, quantidade_inicial) VALUES
(1, 'Lote 001 - Frangos', '2025-09-25', 5000),
(2, 'Lote Teste', '2025-09-25', 10000);

INSERT INTO public.tab_mortalidade (id_mortalidade, id_lote_fk, data_mortalidade, quantidade_morta, observacao) VALUES
(8, 2, '2025-09-25', 150, 'Mortos'),
(9, 2, '2025-09-25', 150, 'poste'),
(10, 2, '2025-10-25', 150, 'po'),
(11, 1, '2025-09-25', 125, '12312'),
(12, 2, '2025-09-25', 50000, '121');

INSERT INTO public.tab_pesagem (id_pesagem, id_lote_fk, data_pesagem, peso_medio, quantidade_pesada) VALUES
(1, 2, '2025-09-25', 150.00, 150);

-- Ajuste das sequências para não gerar conflito em novos inserts
SELECT pg_catalog.setval('public.tab_lote_aves_id_lote_seq', 2, true);
SELECT pg_catalog.setval('public.tab_mortalidade_id_mortalidade_seq', 12, true);
SELECT pg_catalog.setval('public.tab_pesagem_id_pesagem_seq', 1, true);
