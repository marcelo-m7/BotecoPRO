// lib/presentation/pages/signup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// TODO: Descomentar quando implementar autenticação
// import '../../core/providers/auth_provider.dart';
// import 'package:provider/provider.dart';

/// SignupPage - Tela de cadastro do aplicativo
///
/// IMPLEMENTAÇÃO ATUAL:
/// - Interface de cadastro com nome, email e senha (não funcional)
/// - Botão "Cadastrar" volta para tela de login
/// - Validação básica de formulário
/// - Design responsivo e animado
///
/// TODO: IMPLEMENTAÇÕES FUTURAS
/// 
/// 1. Integrar com AuthProvider:
///    ```dart
///    final authProvider = context.read<AuthProvider>();
///    await authProvider.registerWithEmail(name, email, password);
///    ```
///
/// 2. Adicionar confirmação de senha
/// 3. Implementar validação de senha forte
/// 4. Adicionar termos de uso e política de privacidade
/// 5. Implementar feedback de erro/sucesso
/// 6. Adicionar loading durante cadastro
/// 7. Redirecionar automaticamente após cadastro bem-sucedido
///
/// OBSERVAÇÃO: Atualmente apenas mostra interface para desenvolvimento
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // TODO: Implementar cadastro real com AuthProvider
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você deve aceitar os termos de uso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Substituir por lógica real de cadastro
    // Exemplo:
    // try {
    //   final authProvider = context.read<AuthProvider>();
    //   await authProvider.registerWithEmail(
    //     name: _nameController.text.trim(),
    //     email: _emailController.text.trim(),
    //     password: _passwordController.text,
    //   );
    //   
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Cadastro realizado com sucesso!'),
    //         backgroundColor: Colors.green,
    //       ),
    //     );
    //     Navigator.of(context).pop();
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Erro ao cadastrar: $e')),
    //     );
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }

    // TEMPORÁRIO: Simulação de cadastro para desenvolvimento
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro será implementado em breve!'),
          backgroundColor: Colors.blue,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                      'Criar Conta',
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
                      'Comece a gerenciar seu bar agora',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                          ),
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 400)),
                    
                    const SizedBox(height: 32),
                    
                    // Campo Nome
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nome completo',
                        hintText: 'João Silva',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        if (value.length < 3) {
                          return 'Nome deve ter pelo menos 3 caracteres';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 500))
                        .moveX(begin: -30, delay: const Duration(milliseconds: 500)),
                    
                    const SizedBox(height: 16),
                    
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
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 600))
                        .moveX(begin: -30, delay: const Duration(milliseconds: 600)),
                    
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
                        .fadeIn(delay: const Duration(milliseconds: 700))
                        .moveX(begin: -30, delay: const Duration(milliseconds: 700)),
                    
                    const SizedBox(height: 16),
                    
                    // Campo Confirmar Senha
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar senha',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme sua senha';
                        }
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 800))
                        .moveX(begin: -30, delay: const Duration(milliseconds: 800)),
                    
                    const SizedBox(height: 16),
                    
                    // Checkbox Termos
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: Text(
                              'Aceito os termos de uso e política de privacidade',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botão Cadastrar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
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
                              'Cadastrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 900))
                        .scale(delay: const Duration(milliseconds: 900)),
                    
                    const SizedBox(height: 24),
                    
                    // Link para Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já tem uma conta? ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Faça login',
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
