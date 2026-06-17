# 🚀 GUIA COMPLETO: DEPLOY NETLIFY + DOMÍNIO PRÓPRIO

## ✅ STATUS ATUAL
- ✅ Build Web gerado em: `c:\frotacheck\build\web`
- ✅ arquivo `netlify.toml` configurado
- ✅ Arquivo `_redirects` já existe (SPA routing)
- ✅ App pronto para produção

## 📋 PASSO A PASSO COMPLETO

### PASSO 1: Criar Conta GitHub e Fazer Push do Código
```bash
# 1.1 Inicializar git (se ainda não fez)
cd c:\frotacheck
git init
git config user.email "seu.email@example.com"
git config user.name "Seu Nome"

# 1.2 Adicionar todos os arquivos
git add .

# 1.3 Fazer primeiro commit
git commit -m "Initial commit - FrotaCheck v1.0"

# 1.4 Criar repositório no GitHub
# Acesse: https://github.com/new
# Nome: frotacheck
# Descrição: Fleet management system
# Deixe público (para facilitar)
# Não inicialize com README (já temos)
```

### PASSO 2: Conectar Repositório Local ao GitHub
```bash
# Copie este comando do seu repositório no GitHub:
git remote add origin https://github.com/SEU_USUARIO/frotacheck.git
git branch -M main
git push -u origin main

# Aguarde completar o push (pode levar alguns minutos)
```

### PASSO 3: Cadastro no Netlify
```
1. Acesse: https://app.netlify.com/
2. Clique em "Sign up" 
3. Escolha "Sign up with GitHub"
4. Autorize a conexão com GitHub
5. Confirme email se solicitado
```

### PASSO 4: Criar Novo Site no Netlify
```
1. Clique em "Add new site"
2. Escolha "Import an existing project"
3. Selecione "GitHub" como provedor
4. Procure por "frotacheck"
5. Clique em "Deploy site"
```

### PASSO 5: Configurar Build Settings
```
Na página de deploy, configure:

Build command:
flutter build web --release

Publish directory:
build/web

Deixe as outras opções padrão
Clique em "Deploy site"
```

### PASSO 6: Esperar Build Completar
```
- Netlify vai fazer build automaticamente
- Pode levar 2-5 minutos
- Você receberá um URL automático como:
  https://SEU-SITE-aleatorio.netlify.app

- Clique nele para testar a aplicação
```

### PASSO 7: Conectar Seu Domínio Próprio
```
1. No painel Netlify, vá para: "Site settings" > "Domain management"

2. Clique em "Add custom domain"

3. Digite seu domínio: exemplo.com.br

4. Clique "Verify"

5. Netlify vai mostrar as configurações de DNS:
   - Se seu domínio está em Namecheap, GoDaddy, etc
   - Acesse o painel de DNS do seu provedor
   - Copie os nameservers do Netlify
   - Substitua os nameservers do seu domínio
   
   OU se preferir usar CNAME:
   - Crie um CNAME: www -> seu-site.netlify.app
   - Crie um A record: 75.2.60.5

6. Aguarde 24-48h para propagação total de DNS

7. Pronto! Seu site estará em https://seu-dominio.com.br
```

### PASSO 8: Habilitar HTTPS
```
1. Netlify habilita HTTPS automaticamente
2. Vá em "Site settings" > "Domain management"
3. Confirme que tem certificado SSL/TLS
4. Tudo deve estar em verde ✅
```

## 🔄 PRÓXIMAS ATUALIZAÇÕES (CI/CD)

Sempre que você fizer push para GitHub:
```bash
git add .
git commit -m "Descrição da mudança"
git push origin main
```

Netlify vai:
1. Detectar o novo push
2. Fazer build automaticamente
3. Atualizar o site em live
4. Nenhuma ação manual necessária!

## 📱 ENVIAR PARA OUTROS TESTAREM

Depois que estiver no ar:
1. Copie a URL: https://seu-dominio.com.br
2. Envie para amigos/clientes testarem
3. Eles acessam direto no navegador
4. Sem necessidade de instalação

## ⚙️ VARIÁVEIS DE AMBIENTE (Se precisar)

Se sua app precisa de chaves de API:
1. Vá em "Site settings" > "Build & deploy" > "Environment"
2. Adicione as variáveis necessárias
3. Clique "Save"
4. Faça novo build/push

## 🐛 TROUBLESHOOTING

### Erro: "flutter command not found"
- Solução: Adicione flutter ao PATH no Netlify
- Ou mude para: `curl https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.x.x-stable.zip`

### Erro: "build/web não encontrado"
- Certifique-se que flutter build web foi executado
- Verifique que netlify.toml tem publish correto

### Site vai em branco
- Abra console do navegador (F12)
- Procure por erros
- Verifique se Supabase está configurado
- Confirme URLs de API corretas

## 📊 MONITORAR PERFORMANCE

1. Em Netlify, vá para "Deploys"
2. Veja histórico de builds
3. Veja tempo de build
4. Clique em deploy para ver logs

## ✨ PRONTO!

Seu app Flutter Web estará:
- ✅ Ao vivo na internet
- ✅ No seu domínio personalizado
- ✅ Com HTTPS seguro
- ✅ Atualizando automaticamente
- ✅ Pronto para compartilhar

Próximo: Teste no Android (APK/AAB)

---
Data: 2026-06-17
App: FrotaCheck v1.0
Status: Pronto para Deploy
