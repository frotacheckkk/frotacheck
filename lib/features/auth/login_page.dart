import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home_page.dart';
import 'register_page.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _backgroundAsset = 'assets/images/login_bg.jpg';

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgotEmailController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('Login error: $e');
      debugPrint('$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    forgotEmailController.text = emailController.text;
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar senha'),
          content: TextField(
            controller: forgotEmailController,
            decoration: const InputDecoration(labelText: 'E-mail'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (shouldSend != true) return;
    final email = forgotEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe um email')));
      return;
    }

    try {
      // Use dynamic call to support multiple supabase versions
      await (Supabase.instance.client.auth as dynamic).resetPasswordForEmail(
        email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de recuperação enviado')),
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível enviar o email. Contate o administrador.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          if (isMobile) {
            // Mobile: imagem como fundo + formulário em primeiro plano
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _backgroundAsset,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppColors.background),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.background.withOpacity(0.85),
                          AppColors.background.withOpacity(0.90),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _buildFormPanel(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Desktop: layout lado a lado
            return Row(
              children: [
                // Lado esquerdo: Imagem com logo e descrição
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          _backgroundAsset,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: AppColors.background),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.35),
                                Colors.black.withOpacity(0.45),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLeftPanel(),
                              _buildFeaturesSection(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lado direito: Formulário de login
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 30,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: _buildFormPanel(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: const [
            AppLogo(compact: false, iconSize: 40),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FROTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'CHECK',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Gestão completa da sua frota\nna palma da sua mão.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildFeatureItem(Icons.shield, 'Seguro'),
        _buildFeatureItem(Icons.insights, 'Inteligente'),
        _buildFeatureItem(Icons.wifi, 'Conectado'),
        _buildFeatureItem(Icons.speed, 'Eficiente'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.secondary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0B172D).withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.16),
            blurRadius: 48,
            spreadRadius: 1,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.55),
                width: 1.2,
              ),
            ),
            child: const Text(
              'LOGIN WEB',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.6,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bem-vindo de volta!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Faça login para acessar sua conta',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          _buildLoginForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF10233B),
              labelText: 'E-mail',
              prefixIcon: const Icon(Icons.email, color: AppColors.secondary),
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.secondary.withOpacity(0.18),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.secondary.withOpacity(0.18),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.secondary.withOpacity(0.85),
                  width: 1.8,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe seu email';
              }
              if (!value.contains('@')) {
                return 'Digite um email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF10233B),
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock, color: AppColors.secondary),
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.secondary.withOpacity(0.18),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.secondary.withOpacity(0.18),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.secondary.withOpacity(0.85),
                  width: 1.8,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe sua senha';
              }
              if (value.length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Esqueceu sua senha?'),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF39A6FF), Color(0xFF0E66D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF39A6FF).withOpacity(0.35),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Entrar na conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.textSecondary.withOpacity(0.32),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'ou continue com',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.textSecondary.withOpacity(0.32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  label: const Text('Google'),
                  style:
                      OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: AppColors.secondary.withOpacity(0.30),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          AppColors.secondary.withOpacity(0.12),
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.window, color: Colors.white),
                  label: const Text('Microsoft'),
                  style:
                      OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: AppColors.secondary.withOpacity(0.30),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          AppColors.secondary.withOpacity(0.12),
                        ),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Não tem uma conta? ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
