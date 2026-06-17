# ✅ CHECKLIST PRÉ-DEPLOYMENT NETLIFY

## 🔍 VERIFICAÇÕES ANTES DE PUBLICAR

### ✅ Código
- [ ] Sem erros de compilação (`flutter analyze`)
- [ ] Home page corrigida e testada
- [ ] Todos os imports funcionando
- [ ] Sem warnings críticos

### ✅ Build Web
- [ ] `flutter build web --release` executa com sucesso
- [ ] Arquivos gerados em `build/web`
- [ ] Tamanho do build aceitável (< 50MB total)

### ✅ Configuração
- [ ] `netlify.toml` criado e correto
- [ ] `_redirects` existe (SPA routing)
- [ ] `manifest.json` configurado
- [ ] `index.html` válido

### ✅ Supabase
- [ ] Credenciais de Supabase estão corretas
- [ ] URLs de API acessíveis
- [ ] Permissões de CORS configuradas
- [ ] Tabelas existem no banco

### ✅ Assets
- [ ] Logo aparece corretamente
- [ ] Ícones carregam bem
- [ ] Fontes aparecem normalmente
- [ ] Imagens otimizadas

### ✅ Responsividade
- [ ] Testa em Desktop (1920x1080)
- [ ] Testa em Tablet (768x1024)
- [ ] Testa em Mobile (375x667)
- [ ] Todos os layouts funcionam

### ✅ Performance
- [ ] Carregamento rápido (< 3s)
- [ ] Sem lag ao navegar
- [ ] Gráficos renderizam bem
- [ ] API calls completam rápido

### ✅ Funcionalidades
- [ ] Login funciona
- [ ] Dashboard carrega dados
- [ ] Gráficos aparecem
- [ ] Navegação funciona
- [ ] Botões respondem

---

## 🚀 CHECKLIST DURANTE NETLIFY

### ✅ GitHub
- [ ] Repositório criado
- [ ] Todos arquivos fizeram push
- [ ] Branch main está atualizado

### ✅ Netlify Setup
- [ ] Conta criada
- [ ] Site conectado ao GitHub
- [ ] Build settings corretos
- [ ] Deploy iniciado

### ✅ Domínio
- [ ] Domínio configurado
- [ ] DNS apontando corretamente
- [ ] HTTPS habilitado
- [ ] Certificado válido

### ✅ Testes Online
- [ ] Site abre sem erros
- [ ] Dados carregam do Supabase
- [ ] Funcionalidades básicas funcionam
- [ ] Responsivo em mobile

---

## 📋 INFORMAÇÕES NECESSÁRIAS

Antes de começar, reúna:

1. **GitHub**
   - [ ] Conta GitHub criada
   - [ ] Chave SSH configurada (opcional)

2. **Netlify**
   - [ ] Email para cadastro

3. **Domínio**
   - [ ] Domínio registrado
   - [ ] Acesso ao painel DNS
   - [ ] Nenhuma configuração anterior

4. **Supabase**
   - [ ] URL da API
   - [ ] Chave pública (ANON)
   - [ ] Banco de dados criado

---

## 📊 RESUMO RÁPIDO

```
PASSO 1: Git + GitHub (5 min)
PASSO 2: Netlify Setup (10 min)
PASSO 3: Build Automático (5 min)
PASSO 4: Domínio (5 min + 24-48h DNS)
PASSO 5: Testes (15 min)

TOTAL: ~40 minutos (excluindo propagação DNS)
```

---

## 🎯 PRÓXIMAS FASES

Depois de Web rodando:
1. [ ] Testar com diferentes usuários
2. [ ] Coletar feedback
3. [ ] Build APK para Android
4. [ ] Publicar na Play Store
5. [ ] Build iOS (se precisar)

---

**VOCÊ ESTÁ PRONTO? 🚀**

Siga os passos do guia NETLIFY_DEPLOY_GUIDE.md!
