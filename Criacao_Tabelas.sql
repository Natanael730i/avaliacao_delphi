-- =====================================================
-- 1️⃣ Criação das tabelas
-- =====================================================

CREATE TABLE public.tab_lote_aves (
    id_lote integer NOT NULL,
    descricao character varying(100) NOT NULL,
    data_entrada date NOT NULL,
    quantidade_inicial numeric NOT NULL
);

CREATE TABLE public.tab_mortalidade (
    id_mortalidade integer NOT NULL,
    id_lote_fk integer NOT NULL,
    data_mortalidade date NOT NULL,
    quantidade_morta numeric NOT NULL,
    observacao character varying(255)
);

CREATE TABLE public.tab_pesagem (
    id_pesagem integer NOT NULL,
    id_lote_fk integer NOT NULL,
    data_pesagem date NOT NULL,
    peso_medio numeric(10,2) NOT NULL,
    quantidade_pesada numeric NOT NULL
);

-- =====================================================
-- 2️⃣ Criação das sequências
-- =====================================================

CREATE SEQUENCE public.tab_lote_aves_id_lote_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

CREATE SEQUENCE public.tab_mortalidade_id_mortalidade_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

CREATE SEQUENCE public.tab_pesagem_id_pesagem_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

-- =====================================================
-- 3️⃣ Vincular sequências como DEFAULT
-- =====================================================

ALTER TABLE ONLY public.tab_lote_aves ALTER COLUMN id_lote
SET DEFAULT nextval('public.tab_lote_aves_id_lote_seq'::regclass);

ALTER TABLE ONLY public.tab_mortalidade ALTER COLUMN id_mortalidade
SET DEFAULT nextval('public.tab_mortalidade_id_mortalidade_seq'::regclass);

ALTER TABLE ONLY public.tab_pesagem ALTER COLUMN id_pesagem
SET DEFAULT nextval('public.tab_pesagem_id_pesagem_seq'::regclass);

-- =====================================================
-- 4️⃣ Chaves primárias e estrangeiras
-- =====================================================

ALTER TABLE ONLY public.tab_lote_aves
    ADD CONSTRAINT tab_lote_aves_pkey PRIMARY KEY (id_lote);

ALTER TABLE ONLY public.tab_mortalidade
    ADD CONSTRAINT tab_mortalidade_pkey PRIMARY KEY (id_mortalidade);

ALTER TABLE ONLY public.tab_pesagem
    ADD CONSTRAINT tab_pesagem_pkey PRIMARY KEY (id_pesagem);

ALTER TABLE ONLY public.tab_mortalidade
    ADD CONSTRAINT tab_mortalidade_id_lote_fk_fkey FOREIGN KEY (id_lote_fk) REFERENCES public.tab_lote_aves(id_lote);

ALTER TABLE ONLY public.tab_pesagem
    ADD CONSTRAINT tab_pesagem_id_lote_fk_fkey FOREIGN KEY (id_lote_fk) REFERENCES public.tab_lote_aves(id_lote);

-- =====================================================
-- 5️⃣ Funções
-- =====================================================

CREATE FUNCTION public.fn_inserir_mortalidade(
    p_id_lote_fk integer, 
    p_data_mortalidade date, 
    p_quantidade_morta numeric, 
    p_observacao character varying
) RETURNS numeric
LANGUAGE plpgsql AS $$
DECLARE
    v_qtd_inicial       NUMERIC;
    v_mortalidade_acum  NUMERIC;
    v_percentual_mortal NUMERIC;
BEGIN
    SELECT QUANTIDADE_INICIAL INTO v_qtd_inicial
    FROM TAB_LOTE_AVES
    WHERE ID_LOTE = p_id_lote_fk;

    SELECT COALESCE(SUM(QUANTIDADE_MORTA), 0) INTO v_mortalidade_acum
    FROM TAB_MORTALIDADE
    WHERE ID_LOTE_FK = p_id_lote_fk;

    IF (v_mortalidade_acum + p_quantidade_morta) > v_qtd_inicial THEN
        RAISE EXCEPTION 'VAL-MORT-001' 
            USING MESSAGE = 'A quantidade total de aves mortas (%) excede a quantidade inicial do lote.';
    END IF;

    INSERT INTO TAB_MORTALIDADE (ID_LOTE_FK, DATA_MORTALIDADE, QUANTIDADE_MORTA, OBSERVACAO)
    VALUES (p_id_lote_fk, p_data_mortalidade, p_quantidade_morta, p_observacao);

    v_mortalidade_acum := v_mortalidade_acum + p_quantidade_morta;
    v_percentual_mortal := (v_mortalidade_acum * 100.0) / v_qtd_inicial;

    RETURN v_percentual_mortal;
END;
$$;

CREATE FUNCTION public.fn_inserir_pesagem(
    p_id_lote_fk integer, 
    p_data_pesagem date, 
    p_peso_medio numeric, 
    p_quantidade_pesada numeric
) RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO TAB_PESAGEM (ID_LOTE_FK, DATA_PESAGEM, PESO_MEDIO, QUANTIDADE_PESADA)
    VALUES (p_id_lote_fk, p_data_pesagem, p_peso_medio, p_quantidade_pesada);
    RETURN TRUE;
END;
$$;

