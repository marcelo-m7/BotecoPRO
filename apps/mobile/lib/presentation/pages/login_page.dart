// lib/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../main.dart';
// TODO: Descomentar quando implementar autenticação
// import '../../core/providers/auth_provider.dart';
// import 'package:provider/provider.dart';
import 'signup_page.dart';

/// LoginPage - Tela de login do aplicativo
///
/// IMPLEMENTAÇÃO ATUAL:
/// - Interface de login com email e senha (não funcional)
/// - Botão "Entrar" redireciona temporariamente direto para o app
/// - Link para tela de cadastro
/// - Design responsivo e animado
///
/// TODO: IMPLEMENTAÇÕES FUTURAS
/// 
/// 1. Integrar com AuthProvider:
///    ```dart
///    final authProvider = context.read<AuthProvider>();
///    await authProvider.signInWithEmail(email, password);
///    ```
///
/// 2. Adicionar validação de formulário
/// 3. Implementar feedback de erro/sucesso
/// 4. Adicionar loading durante autenticação
/// 5. Implementar "Lembrar-me"
/// 6. Adicionar login com Google
/// 7. Implementar recuperação de senha
///
/// OBSERVAÇÃO: Atualmente bypassa autenticação para desenvolvimento
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // TODO: Implementar login real com AuthProvider
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Substituir por lógica real de autenticação
    // Exemplo:
    // try {
    //   final authProvider = context.read<AuthProvider>();
    //   await authProvider.signInWithEmail(
    //     _emailController.text.trim(),
    //     _passwordController.text,
    //   );
    //   
    //   if (mounted) {
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    //     );
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Erro ao fazer login: $e')),
    //     );
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }

    // TEMPORÁRIO: Bypass de autenticação para desenvolvimento
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  // TODO: Implementar login com Google
  Future<void> _handleGoogleLogin() async {
    // Implementação futura
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Google será implementado em breve'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.sports_bar,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600))
                        .scale(delay: const Duration(milliseconds: 200)),
                    
                    const SizedBox(height: 24),
                    
                    // Título
                    Text(
                      'Boteco PRO',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 300)),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Gestão completa para seu bar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                          ),
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 400)),
                    
                    const SizedBox(height: 48),
                    
                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'seu@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        if (!value.contains('@')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 500))
                        .moveX(begin: -30, delay: const Duration(milliseconds: 500)),
                    
                    const SizedBox(height: 16),
                    
                    // Campo Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'Senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 600))
                        .moveX(begin: -30, delay: const Duration(milliseconds: 600)),
                    
                    const SizedBox(height: 8),
                    
                    // Link Esqueci a Senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implementar recuperação de senha
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recuperação de senha será implementada em breve'),
                            ),
                          );
                        },
                        child: Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botão Entrar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 700))
                        .scale(delay: const Duration(milliseconds: 700)),
                    
                    const SizedBox(height: 24),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botão Google
                    OutlinedButton.icon(
                      onPressed: _handleGoogleLogin,
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Continuar com Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 800)),
                    
                    const SizedBox(height: 32),
                    
                    // Link para Cadastro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Não tem uma conta? ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignupPage()),
                            );
                          },
                          child: Text(
                            'Cadastre-se',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
