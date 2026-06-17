import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AbastecimentosPage extends StatefulWidget {
  const AbastecimentosPage({super.key});

  @override
  State<AbastecimentosPage> createState() => _AbastecimentosPageState();
}

class _AbastecimentosPageState extends State<AbastecimentosPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  final ImagePicker picker = ImagePicker();

  XFile? odometroPhoto;
  XFile? pumpPhoto;
  XFile? receiptPhoto;

  final litrosController = TextEditingController();
  final valorController = TextEditingController();
  final odometroController = TextEditingController();
  final horarioController = TextEditingController();
  final stationController = TextEditingController();
  final unitPriceController = TextEditingController();

  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> drivers = [];

  String? selectedVehicle;
  String? selectedDriver;
  String? selectedFuelType;
  String? selectedPaymentMethod;

  final fuelTypes = ['Diesel', 'Gasolina', 'Etanol', 'GNV', 'Flex'];
  final paymentMethods = [
    'Cartão da Frota',
    'Vale Combustível',
    'PIX',
    'Boleto',
    'Espécie',
  ];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<XFile?> selecionarImagem() async {
    try {
      return await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
    } catch (_) {
      return await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
    }
  }

  Future<void> tirarFoto(String tipo) async {
    final foto = await selecionarImagem();
    if (foto == null) return;

    setState(() {
      if (tipo == 'odometro') {
        odometroPhoto = foto;
      } else if (tipo == 'bomba') {
        pumpPhoto = foto;
      } else if (tipo == 'cupom') {
        receiptPhoto = foto;
      }
    });
  }

  Future<String?> uploadImagem(XFile? imagem) async {
    if (imagem == null) return null;

    final nomeArquivo =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagem.path)}';
    final bytes = await imagem.readAsBytes();

    await supabase.storage
        .from('fuelings')
        .uploadBinary(
          nomeArquivo,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('fuelings').getPublicUrl(nomeArquivo);
  }

  Future<void> carregarDados() async {
    try {
      final veiculos = await supabase.from('vehicles').select().order('plate');
      final motoristas = await supabase.from('drivers').select().order('name');

      setState(() {
        vehicles = List<Map<String, dynamic>>.from(veiculos);
        drivers = List<Map<String, dynamic>>.from(motoristas);
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    }
  }

  Future<void> selecionarHorario() async {
    final TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horario != null) {
      horarioController.text =
          '${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}';
    }
  }

  double get precoPorLitro {
    final litros = double.tryParse(litrosController.text) ?? 0;
    final total = double.tryParse(valorController.text) ?? 0;
    if (litros <= 0 || total <= 0) return 0;
    return total / litros;
  }

  Future<void> salvarAbastecimento() async {
    if (_formKey.currentState?.validate() != true) return;

    if (selectedVehicle == null || selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione veículo e motorista.')),
      );
      return;
    }

    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a forma de pagamento.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final odometroUrl = await uploadImagem(odometroPhoto);
      final bombaUrl = await uploadImagem(pumpPhoto);
      final cupomUrl = await uploadImagem(receiptPhoto);

      await supabase.from('fuelings').insert({
        'vehicle_id': selectedVehicle,
        'driver_id': selectedDriver,
        'fuel_date': DateTime.now().toIso8601String(),
        'fuel_time': horarioController.text,
        'liters': double.tryParse(litrosController.text) ?? 0,
        'total_value': double.tryParse(valorController.text) ?? 0,
        'unit_price': precoPorLitro > 0
            ? precoPorLitro
            : double.tryParse(unitPriceController.text) ?? 0,
        'fuel_type': selectedFuelType,
        'payment_method': selectedPaymentMethod,
        'station': stationController.text.trim(),
        'odometer': int.tryParse(odometroController.text) ?? 0,
        'odometer_photo': odometroUrl,
        'pump_photo': bombaUrl,
        'receipt_photo': cupomUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abastecimento salvo com sucesso!')),
      );

      litrosController.clear();
      valorController.clear();
      odometroController.clear();
      horarioController.clear();
      stationController.clear();
      unitPriceController.clear();

      setState(() {
        selectedVehicle = null;
        selectedDriver = null;
        selectedFuelType = null;
        selectedPaymentMethod = null;
        odometroPhoto = null;
        pumpPhoto = null;
        receiptPhoto = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    litrosController.dispose();
    valorController.dispose();
    odometroController.dispose();
    horarioController.dispose();
    stationController.dispose();
    unitPriceController.dispose();
    super.dispose();
  }

  Widget _buildMetaCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.88))),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
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
      appBar: AppBar(title: const Text('Abastecimentos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registrar abastecimento',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preencha os dados do abastecimento e registre fotos de comprovação.',
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _buildMetaCard(
                          'Tipo combustível',
                          selectedFuelType ?? '--',
                          Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        _buildMetaCard(
                          'Forma de pagamento',
                          selectedPaymentMethod ?? '--',
                          Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                      DropdownButtonFormField<String>(
                        initialValue: selectedVehicle,
                        decoration: const InputDecoration(labelText: 'Veículo'),
                        items: vehicles.map((v) {
                          return DropdownMenuItem<String>(
                            value: v['id'].toString(),
                            child: Text('${v['plate']} — ${v['model']}'),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? 'Selecione um veículo' : null,
                        onChanged: (value) => setState(() {
                          selectedVehicle = value;
                        }),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDriver,
                        decoration: const InputDecoration(
                          labelText: 'Motorista',
                        ),
                        items: drivers.map((d) {
                          return DropdownMenuItem<String>(
                            value: d['id'].toString(),
                            child: Text(d['name'] ?? ''),
                          );
                        }).toList(),
                        validator: (value) =>
                            value == null ? 'Selecione um motorista' : null,
                        onChanged: (value) => setState(() {
                          selectedDriver = value;
                        }),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedFuelType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de combustível',
                        ),
                        items: fuelTypes.map((fuel) {
                          return DropdownMenuItem<String>(
                            value: fuel,
                            child: Text(fuel),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          selectedFuelType = value;
                        }),
                        validator: (value) => value == null
                            ? 'Selecione o tipo de combustível'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Formas de pagamento',
                        ),
                        items: paymentMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          selectedPaymentMethod = value;
                        }),
                        validator: (value) => value == null
                            ? 'Selecione a forma de pagamento'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: stationController,
                        decoration: const InputDecoration(
                          labelText: 'Posto de abastecimento',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o posto de abastecimento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: litrosController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Litros'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a quantidade de litros';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: valorController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Valor total',
                          prefixText: 'R\$ ',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o valor total';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: unitPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Preço por litro',
                          prefixText: 'R\$ ',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: odometroController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Odômetro',
                          suffixText: 'km',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o odômetro';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: horarioController,
                        readOnly: true,
                        onTap: selecionarHorario,
                        decoration: const InputDecoration(
                          labelText: 'Horário do abastecimento',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione o horário';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => tirarFoto('odometro'),
                              icon: const Icon(Icons.camera_alt),
                              label: Text(
                                odometroPhoto == null
                                    ? 'Foto do hodômetro'
                                    : '✓ Hodômetro',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => tirarFoto('bomba'),
                              icon: const Icon(Icons.local_gas_station),
                              label: Text(
                                pumpPhoto == null ? 'Foto da bomba' : '✓ Bomba',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => tirarFoto('cupom'),
                        icon: const Icon(Icons.receipt_long),
                        label: Text(
                          receiptPhoto == null ? 'Foto do cupom' : '✓ Cupom',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Preço por litro estimado'),
                            Text(
                              precoPorLitro > 0
                                  ? 'R\$ ${precoPorLitro.toStringAsFixed(2)}'
                                  : '--',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : salvarAbastecimento,
                          child: isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Salvar Abastecimento'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
