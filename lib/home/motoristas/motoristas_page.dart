import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frotacheck/core/theme/app_theme.dart';

class MotoristasPage extends StatefulWidget {
  const MotoristasPage({super.key});

  @override
  State<MotoristasPage> createState() => _MotoristasPageState();
}

class _MotoristasPageState extends State<MotoristasPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final searchController = TextEditingController();

  bool isSaving = false;
  bool isEditing = false;

  final nomeController = TextEditingController();
  final cnhController = TextEditingController();
  final validadeController = TextEditingController();

  List<Map<String, dynamic>> motoristas = [];
  String? motoristaEditando;

  @override
  void initState() {
    super.initState();
    carregarMotoristas();
  }

  Future<void> carregarMotoristas() async {
    try {
      final response = await supabase.from('drivers').select().order('name');
      setState(() {
        motoristas = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Erro ao carregar motoristas: $e');
    }
  }

  Future<void> salvarMotorista() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      isSaving = true;
    });

    try {
      final payload = {
        'name': nomeController.text.trim(),
        'cnh_number': cnhController.text.trim(),
        'cnh_expiration': validadeController.text.trim(),
      };

      if (motoristaEditando == null) {
        await supabase.from('drivers').insert(payload);
      } else {
        final editingId = motoristaEditando!;
        await supabase.from('drivers').update(payload).eq('id', editingId);
      }

      await carregarMotoristas();
      limparFormulario();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            motoristaEditando == null
                ? 'Motorista cadastrado com sucesso!'
                : 'Motorista atualizado com sucesso!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void editarMotorista(Map<String, dynamic> motorista) {
    nomeController.text = motorista['name'] ?? '';
    cnhController.text = motorista['cnh_number'] ?? '';
    validadeController.text = motorista['cnh_expiration']?.toString() ?? '';
    setState(() {
      motoristaEditando = motorista['id'].toString();
      isEditing = true;
    });
  }

  Future<void> excluirMotorista(String id) async {
    try {
      await supabase.from('drivers').delete().eq('id', id);
      await carregarMotoristas();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Motorista excluído com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  void limparFormulario() {
    nomeController.clear();
    cnhController.clear();
    validadeController.clear();
    searchController.clear();
    setState(() {
      motoristaEditando = null;
      isEditing = false;
    });
  }

  List<Map<String, dynamic>> get motoristaFiltrado {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) return motoristas;
    return motoristas.where((motorista) {
      final nome = motorista['name']?.toString().toLowerCase() ?? '';
      final cnh = motorista['cnh_number']?.toString().toLowerCase() ?? '';
      return nome.contains(query) || cnh.contains(query);
    }).toList();
  }

  int get expirationsCount {
    final agora = DateTime.now();
    return motoristas.where((motorista) {
      final data = DateTime.tryParse(
        motorista['cnh_expiration']?.toString() ?? '',
      );
      return data != null && data.isBefore(agora.add(const Duration(days: 30)));
    }).length;
  }

  @override
  void dispose() {
    nomeController.dispose();
    cnhController.dispose();
    validadeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motoristas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF00B8D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Gestão de motoristas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Centralize cadastro, validades de CNH e perfis de condução.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    'Total de motoristas',
                    '${motoristas.length}',
                    Colors.white,
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    'CNH próximo vencimento',
                    '$expirationsCount',
                    Colors.amber.shade700,
                    Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEditing ? 'Editar Motorista' : 'Novo Motorista',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: nomeController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome do motorista';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: cnhController,
                        decoration: const InputDecoration(
                          labelText: 'Número da CNH',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o número da CNH';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: validadeController,
                        decoration: const InputDecoration(
                          labelText: 'Validade da CNH',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a validade';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving ? null : salvarMotorista,
                              child: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isEditing
                                          ? 'Atualizar motorista'
                                          : 'Salvar motorista',
                                    ),
                            ),
                          ),
                          if (isEditing) ...[
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: limparFormulario,
                              child: const Text('Cancelar'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar motoristas',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: motoristaFiltrado.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final motorista = motoristaFiltrado[index];
                final expirationDate = DateTime.tryParse(
                  motorista['cnh_expiration']?.toString() ?? '',
                );
                final isExpired =
                    expirationDate != null &&
                    expirationDate.isBefore(DateTime.now());
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.18,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: Text(motorista['name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('CNH: ${motorista['cnh_number'] ?? ''}'),
                        const SizedBox(height: 4),
                        Text(
                          'Validade: ${motorista['cnh_expiration'] ?? ''}',
                          style: TextStyle(
                            color: isExpired ? Colors.red : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editarMotorista(motorista),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              excluirMotorista(motorista['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    String label,
    String value,
    Color background,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
