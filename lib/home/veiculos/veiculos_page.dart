import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frotacheck/core/theme/app_theme.dart';

class VeiculosPage extends StatefulWidget {
  const VeiculosPage({super.key});

  @override
  State<VeiculosPage> createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {
  final _formKey = GlobalKey<FormState>();
  final searchController = TextEditingController();

  final placaController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final anoController = TextEditingController();
  final corController = TextEditingController();
  final kmController = TextEditingController();

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> motoristas = [];
  List<Map<String, dynamic>> veiculos = [];
  int? motoristaSelecionado;
  bool isSaving = false;
  bool carregandoVeiculos = true;
  bool erroVeiculos = false;
  String erroVeiculosMsg = '';
  int? editingId;

  @override
  void initState() {
    super.initState();
    carregarMotoristas();
    carregarVeiculos();
  }

  Future<void> carregarMotoristas() async {
    try {
      final response = await supabase.from('drivers').select().order('name');
      if (!mounted) return;
      setState(() {
        motoristas = List<Map<String, dynamic>>.from(
          (response as List<dynamic>).map(
            (item) => Map<String, dynamic>.from(item as Map),
          ),
        );
      });
    } catch (e) {
      debugPrint('Erro ao carregar motoristas: $e');
    }
  }

  Future<void> carregarVeiculos() async {
    setState(() {
      carregandoVeiculos = true;
    });
    try {
      debugPrint('Iniciando carregamento de veículos...');
      final response = await supabase
          .from('vehicles')
          .select('id, plate, brand, model, year, color, odometer, driver_id')
          .order('plate');

      debugPrint('Resposta recebida: $response');

      final parsed = List<Map<String, dynamic>>.from(
        (response as List<dynamic>).map(
          (item) => Map<String, dynamic>.from(item as Map<String, dynamic>),
        ),
      );

      if (!mounted) return;
      setState(() {
        veiculos = parsed;
        erroVeiculos = false;
        erroVeiculosMsg = '';
      });

      debugPrint('Veículos carregados com sucesso: ${veiculos.length}');
    } catch (e) {
      debugPrint('Erro ao carregar veículos: $e');
      if (mounted) {
        setState(() {
          erroVeiculos = true;
          erroVeiculosMsg = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          carregandoVeiculos = false;
        });
      }
    }
  }

  String _driverNameForVehicle(Map<String, dynamic> vehicle) {
    // Buscar nome do motorista na lista carregada
    final driverId = vehicle['driver_id'];
    if (driverId == null) return 'Sem motorista';

    try {
      final driver = motoristas.firstWhere(
        (d) => d['id'].toString() == driverId.toString(),
        orElse: () => {},
      );
      return driver['name']?.toString() ?? 'Sem motorista';
    } catch (e) {
      return 'Sem motorista';
    }
  }

  Future<void> salvarVeiculo() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      isSaving = true;
    });

    try {
      final payload = {
        'plate': placaController.text.trim(),
        'brand': marcaController.text.trim(),
        'model': modeloController.text.trim(),
        'year': int.tryParse(anoController.text),
        'color': corController.text.trim(),
        'odometer': int.tryParse(kmController.text) ?? 0,
        'driver_id': motoristaSelecionado,
      };

      if (editingId != null) {
        await supabase.from('vehicles').update(payload).eq('id', editingId!);
      } else {
        await supabase.from('vehicles').insert(payload);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo salvo com sucesso!')),
      );
      limparFormulario();
      editingId = null;
      await carregarVeiculos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void limparFormulario() {
    placaController.clear();
    marcaController.clear();
    modeloController.clear();
    anoController.clear();
    corController.clear();
    kmController.clear();
    setState(() {
      motoristaSelecionado = null;
      editingId = null;
    });
  }

  void editarVeiculo(Map<String, dynamic> v) {
    setState(() {
      editingId = v['id'] as int?;
      placaController.text = v['plate']?.toString() ?? '';
      marcaController.text = v['brand']?.toString() ?? '';
      modeloController.text = v['model']?.toString() ?? '';
      anoController.text = v['year']?.toString() ?? '';
      corController.text = v['color']?.toString() ?? '';
      kmController.text = v['odometer']?.toString() ?? '';
      motoristaSelecionado = v['driver_id'] is int
          ? v['driver_id'] as int
          : int.tryParse((v['driver_id'] ?? '').toString());
    });
    Scrollable.ensureVisible(_formKey.currentContext ?? context);
  }

  Future<void> deletarVeiculo(int id) async {
    final conf = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja excluir este veículo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || conf != true) return;
    try {
      await supabase.from('vehicles').delete().eq('id', id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veículo excluído')));
      await carregarVeiculos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  List<Map<String, dynamic>> get veiculosFiltrados {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) return veiculos;
    return veiculos.where((item) {
      final driverName = _driverNameForVehicle(item);
      final text =
          '${item['plate'] ?? ''} ${item['brand'] ?? ''} ${item['model'] ?? ''} $driverName'
              .toLowerCase();
      return text.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    placaController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    anoController.dispose();
    corController.dispose();
    kmController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget _statTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frota de Veículos'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: AppColors.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Gestão da frota',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Cadastre veículos, acompanhe atribuições e visualize a frota corporativa.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _statTile(
                  'Total de veículos',
                  veiculos.length.toString(),
                  AppColors.muted,
                ),
                const SizedBox(width: 12),
                _statTile(
                  'Veículos atribuídos',
                  veiculos
                      .where((v) => _driverNameForVehicle(v) != 'Sem motorista')
                      .length
                      .toString(),
                  AppColors.muted,
                ),
              ],
            ),
            const SizedBox(height: 22),
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
                      const Text(
                        'Registrar veículo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: placaController,
                        decoration: const InputDecoration(labelText: 'Placa'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a placa';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: marcaController,
                        decoration: const InputDecoration(labelText: 'Marca'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a marca';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: modeloController,
                        decoration: const InputDecoration(labelText: 'Modelo'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o modelo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: anoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Ano',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o ano';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: kmController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Km',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe a quilometragem';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: corController,
                        decoration: const InputDecoration(labelText: 'Cor'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a cor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        value: motoristaSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Motorista responsável',
                        ),
                        items: motoristas.map((motorista) {
                          final id = motorista['id'] is int
                              ? motorista['id'] as int
                              : int.tryParse(motorista['id'].toString());
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(motorista['name'] ?? ''),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um motorista';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            motoristaSelecionado = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : salvarVeiculo,
                                child: isSaving
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('Salvar veículo'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: limparFormulario,
                            child: const Text('Limpar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (erroVeiculos)
              Card(
                color: Colors.red.shade50,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Erro ao carregar veículos: $erroVeiculosMsg',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar veículos',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            carregandoVeiculos
                ? const Center(child: CircularProgressIndicator())
                : veiculosFiltrados.isEmpty
                ? const Center(child: Text('Nenhum veículo encontrado'))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: veiculosFiltrados.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final veiculo = veiculosFiltrados[index];
                      final driverName = _driverNameForVehicle(veiculo);
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          title: Text(
                            '${veiculo['plate'] ?? '--'} • ${veiculo['brand'] ?? '--'} ${veiculo['model'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('Motorista: $driverName'),
                              const SizedBox(height: 4),
                              Text(
                                'Ano: ${veiculo['year'] ?? '--'} • Km: ${veiculo['odometer'] ?? '--'}',
                              ),
                            ],
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: AppColors.secondary.withOpacity(
                              0.14,
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: AppColors.secondary,
                            ),
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
}
