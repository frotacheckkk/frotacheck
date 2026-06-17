-- Tabela de Viagens
CREATE TABLE IF NOT EXISTS public.viagens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    veiculo_id UUID NOT NULL REFERENCES public.veiculos(id) ON DELETE CASCADE,
    motorista_id UUID NOT NULL REFERENCES public.motoristas(id) ON DELETE CASCADE,
    data_inicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fim TIMESTAMP,
    origem VARCHAR(255) NOT NULL,
    destino VARCHAR(255) NOT NULL,
    quilometragem_inicio DECIMAL(10, 1) NOT NULL,
    quilometragem_fim DECIMAL(10, 1),
    status VARCHAR(20) NOT NULL DEFAULT 'em_progresso' CHECK (status IN ('em_progresso', 'concluida', 'cancelada')),
    fotos_rota TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    consumo_litros DECIMAL(10, 2),
    custo_total DECIMAL(10, 2),
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para Viagens
CREATE INDEX idx_viagens_veiculo_id ON public.viagens(veiculo_id);
CREATE INDEX idx_viagens_motorista_id ON public.viagens(motorista_id);
CREATE INDEX idx_viagens_status ON public.viagens(status);
CREATE INDEX idx_viagens_data_inicio ON public.viagens(data_inicio DESC);

-- Políticas de RLS para Viagens
ALTER TABLE public.viagens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Viagens são visíveis para todos os usuários autenticados"
    ON public.viagens FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Viagens podem ser criadas por usuários autenticados"
    ON public.viagens FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Viagens podem ser atualizadas por usuários autenticados"
    ON public.viagens FOR UPDATE
    USING (auth.role() = 'authenticated');
