# 🚀 FrotaCheck - Guia de Implementação

Bem-vindo ao **FrotaCheck**, um sistema completo de gestão de frota para Flutter/Supabase!

## 📋 Progresso da Implementação

### ✅ Concluído (Fase 1)

#### Autenticação & Dashboard
- ✅ Login com Supabase Auth
- ✅ Dashboard principal com KPIs
- ✅ Menu lateral recolhível
- ✅ Tema Material Design 3

#### Módulos Implementados
- ✅ **Gestão de Veículos** - CRUD completo
- ✅ **Gestão de Motoristas** - CRUD completo
- ✅ **Abastecimentos** - Registro com foto
- ✅ **Histórico de Abastecimentos** - Listagem e busca
- ✅ **Manutenções** - Planejamento
- ✅ **Troca de Óleo** - Especializado
- ✅ **Ocorrências** - Registro e listagem
- ✅ **Relatórios Básicos** - Visão geral

#### 🆕 Novas Funcionalidades Implementadas (Fase 2)
- ✅ **Checklist Operacional** - Saída e Retorno
  - 5 fotos obrigatórias (Frente, Traseira, Lateral Esq, Lateral Dir, Painel)
  - 10 itens de verificação
  - Validação automática
  
- ✅ **Gestão de Multas**
  - Registro de multas por veículo
  - Status: Aberta, Paga, Contestada
  - Associação com motorista
  - Upload de foto
  
- ✅ **Gestão de Documentos**
  - Upload de documentos (CRLV, Licenciamento, Seguro, CNH)
  - Alertas de vencimento (30 dias)
  - Filtros: Vencidos, Vencer em 30 dias, Ativos
  
- ✅ **Timeline do Veículo**
  - Histórico cronológico de eventos
  - Abastecimentos, Manutenções, Checklists, Multas
  - Formato visual intuitivo
  
- ✅ **Controle de Viagens**
  - Registro de origem/destino
  - Quilometragem inicial e final
  - Status: Em Progresso, Concluída, Cancelada
  - Cálculo automático de KM percorrido
  
- ✅ **Relatórios Avançados**
  - Gráficos de consumo mensal
  - Distribuição de gastos (Pie Chart)
  - Ocorrências por tipo (Bar Chart)

### 🔧 Em Progresso (Fase 3)

- ⏳ Notificações Push (Firebase Cloud Messaging)
- ⏳ Níveis de Acesso (Admin, Gestor, Motorista)
- ⏳ Exportação PDF/Excel
- ⏳ Modo Escuro

### ⏩ Próximas Fases

- ❌ Sincronização offline
- ❌ Aplicativo dedicado para motoristas
- ❌ Integração com GPS em tempo real
- ❌ Analytics avançada

---

## 📦 Instalação e Setup

### Pré-requisitos
- Flutter 3.41.1 (ou superior)
- Dart SDK 3.11.0
- Android SDK (para compilação Android)
- Conta Supabase ativa

### 1️⃣ Clonar/Preparar o Projeto

```bash
cd /path/to/frotacheck
flutter pub get
flutter clean
```

### 2️⃣ Configurar Supabase

#### A. Criar as tabelas no Supabase SQL Editor

Execute os scripts SQL na seguinte ordem:

**1. Script Principal** (Tabelas básicas - se ainda não existem)
```bash
docs/MIGRATION_CHECKLISTS_MULTAS_DOCS.sql
```

**2. Script de Viagens**
```bash
docs/MIGRATION_VIAGENS.sql
```

#### B. Criar Storage Buckets

No Supabase Dashboard → Storage, crie os buckets (se não existirem):
- `checklists` (público)
- `multas` (público)
- `documentos` (público)
- `viagens` (público)

#### C. Verificar Configuração de RLS

Certifique-se de que o RLS está habilitado nas tabelas (geralmente feito nos scripts SQL).

### 3️⃣ Atualizar Config do Supabase

Arquivo: `lib/core/config/supabase_config.dart`

```dart
class SupabaseConfig {
  // ⚠️ Mantenha estes valores confidenciais!
  static const String url = 'https://rseefinwtlrjhzosvmgt.supabase.co';
  static const String publishableKey = 'sb_publishable_nX6Q8wyti_TP_ImjCUXyXg_Knlko9CZ';
}
```

### 4️⃣ Compilar e Executar

#### Android
```bash
flutter run
```

Ou específico para um device:
```bash
flutter devices  # Listar devices
flutter run -d <device_id>
```

#### Limpeza de cache (se houver problemas)
```bash
flutter clean
flutter pub get
flutter run --no-fast-start
```

---

## 📱 Funcionalidades por Página

### 🏠 Dashboard
- KPIs de veículos, motoristas, abastecimentos
- Últimos abastecimentos
- Ações rápidas (cards de navegação)

### 🚗 Veículos
- Listar todos os veículos
- Adicionar novo veículo
- Editar informações
- Deletar veículo
- Acessar timeline

### 👨‍✈️ Motoristas
- CRUD completo
- Gerenciar motoristas ativo/inativo

### ⛽ Abastecimentos
- Registrar novo abastecimento com foto
- Listar histórico
- Filtrar por veículo

### ✅ Checklist
- Checklist de Saída (início da jornada)
- Checklist de Retorno (fim da jornada)
- 5 fotos obrigatórias
- 10 itens de verificação

### 🚨 Multas
- Registrar nova multa
- Marcar como paga
- Visualizar foto da multa
- Filtrar por status

### 📄 Documentos
- Upload de documentos
- Alertas de vencimento
- Filtrar por status

### 🗺️ Viagens
- Iniciar nova viagem
- Registrar origem/destino
- Concluir viagem com KM final
- Histórico de viagens

### 📊 Relatórios
- Consumo mensal (Bar Chart)
- Distribuição de gastos (Pie Chart)
- Ocorrências por tipo
- Cards de resumo

---

## 🔐 Variáveis de Ambiente

Crie um arquivo `.env` (opcional) com:
```
SUPABASE_URL=https://rseefinwtlrjhzosvmgt.supabase.co
SUPABASE_ANON_KEY=sb_publishable_nX6Q8wyti_TP_ImjCUXyXg_Knlko9CZ
```

Depois, use no código:
```dart
// lib/main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
```

---

## 🐛 Troubleshooting

### Erro: "AuthRetryableFetchException - Failed host lookup"

**Solução:**
1. Verificar internet do device
2. Limpar cache: `flutter clean && flutter pub get`
3. Rebuildar: `flutter run --no-fast-start`
4. No Android Manifest, confirmar permissão de internet

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
```

### Erro: "file_picker not found"

**Solução:**
```bash
flutter pub get
flutter pub upgrade
```

### Erro ao fazer upload de arquivo

**Solução:**
- Verificar se bucket existe no Supabase Storage
- Confirmar RLS policies permitem upload
- Verificar permissões de storage no app

---

## 🎨 Temas e Customização

Arquivo: `lib/core/theme/app_theme.dart`

```dart
class AppColors {
  static const Color primary = Color(0xFF0A2A57);      // Azul escuro
  static const Color secondary = Color(0xFF1E90FF);    // Azul brilhante
  static const Color background = Color(0xFFFAFAFA);   // Cinza muito claro
  // ... mais cores
}
```

---

## 📤 Deploy (Futuros)

### Google Play Store
```bash
flutter build appbundle
# Upload no console.cloud.google.com
```

### App Store (iOS)
```bash
flutter build ipa
# Upload no app.apple.com
```

---

## 🔄 Próximas Atualizações

- [ ] Firebase Messaging para notificações push
- [ ] Níveis de acesso por usuário
- [ ] Exportação de relatórios em PDF/Excel
- [ ] Sincronização offline com drift
- [ ] App dedicada para motorista
- [ ] Integração de câmera com ML Kit
- [ ] Dark mode completo

---

## 📞 Suporte

Em caso de dúvidas:
1. Verificar logs: `flutter run -v`
2. Consultar documentação Supabase: https://supabase.com/docs
3. Documentação Flutter: https://flutter.dev/docs

---

## 📄 Licença

Propriedade privada - Uso exclusivo para o projeto FrotaCheck.

---

**Versão Atual:** 1.0.0 | **Última Atualização:** 2026-06-17
