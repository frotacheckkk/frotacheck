-- Tabela de Usuários com Roles
CREATE TABLE IF NOT EXISTS public.usuarios (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'motorista' CHECK (role IN ('admin', 'gestor', 'motorista')),
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para email e role
CREATE INDEX idx_usuarios_email ON public.usuarios(email);
CREATE INDEX idx_usuarios_role ON public.usuarios(role);

-- Políticas de RLS para Usuários
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;

-- Policy: Usuários podem ver seus próprios dados
CREATE POLICY "Usuários podem ver seus próprios dados"
    ON public.usuarios FOR SELECT
    USING (auth.uid() = id);

-- Policy: Admins podem ver todos os usuários
CREATE POLICY "Admins podem ver todos os usuários"
    ON public.usuarios FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Policy: Admins podem atualizar usuários
CREATE POLICY "Admins podem atualizar usuários"
    ON public.usuarios FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Policy: Admins podem criar usuários
CREATE POLICY "Admins podem criar usuários"
    ON public.usuarios FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND role = 'admin'
        ) OR
        auth.uid() = id
    );

-- Views com base em permissões

-- VIEW: Veículos que motorista pode acessar
CREATE OR REPLACE VIEW public.veiculos_do_motorista AS
SELECT v.* FROM public.veiculos v
WHERE v.motorista_id = auth.uid()
   OR EXISTS (
       SELECT 1 FROM public.usuarios
       WHERE id = auth.uid() AND role IN ('admin', 'gestor')
   );

-- VIEW: Checklists que motorista pode acessar
CREATE OR REPLACE VIEW public.checklists_do_motorista AS
SELECT c.* FROM public.checklists c
WHERE c.motorista_id = auth.uid()
   OR EXISTS (
       SELECT 1 FROM public.usuarios
       WHERE id = auth.uid() AND role IN ('admin', 'gestor')
   );

-- VIEW: Viagens que motorista pode acessar
CREATE OR REPLACE VIEW public.viagens_do_motorista AS
SELECT v.* FROM public.viagens v
WHERE v.motorista_id = auth.uid()
   OR EXISTS (
       SELECT 1 FROM public.usuarios
       WHERE id = auth.uid() AND role IN ('admin', 'gestor')
   );

-- Trigger para atualizar timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_usuarios_updated_at
BEFORE UPDATE ON public.usuarios
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Inserir usuários de exemplo (opcional)
-- Substitua os emails e senhas com valores reais
-- INSERT INTO public.usuarios (id, email, nome, role, ativo)
-- VALUES
--     ('00000000-0000-0000-0000-000000000001', 'admin@frotacheck.com', 'Administrador', 'admin', true),
--     ('00000000-0000-0000-0000-000000000002', 'gestor@frotacheck.com', 'Gerente de Frota', 'gestor', true),
--     ('00000000-0000-0000-0000-000000000003', 'motorista@frotacheck.com', 'João Motorista', 'motorista', true);
