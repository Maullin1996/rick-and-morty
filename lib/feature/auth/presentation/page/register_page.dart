import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(isLoggedInProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted && ref.read(isLoggedInProvider)) context.pop();
    } on AuthException catch (e) {
      if (mounted) {
        AppSnackBar.show(context, type: SnackBarType.error, message: e.message);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.spacing.small),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: tokens.spacing.large),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 350, maxHeight: 250),
                    child: Image.asset(
                      'assets/images/Rick-and-Morty.png',

                      cacheWidth: 460,
                    ),
                  ),
                  AppCard(
                    color: colors.border,
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spacing.small),
                      child: Column(
                        children: [
                          AppInputText(
                            label: 'Correo electrónico',
                            textEditingController: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El campo no puede estar vacío';
                              }
                              if (!value.contains('@')) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: tokens.spacing.smallMedium),
                          AppInputText(
                            label: 'Contraseña',
                            textEditingController: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: AppButtons(
                              type: ButtonType.primaryIconButton,
                              icon: _obscurePassword
                                  ? AppIcons.showPassword
                                  : AppIcons.obscurePassword,
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo no puede estar vacío';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: tokens.spacing.smallMedium),
                          AppInputText(
                            label: 'Confirmar contraseña',
                            textEditingController: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: AppButtons(
                              type: ButtonType.primaryIconButton,
                              icon: _obscureConfirmPassword
                                  ? AppIcons.showPassword
                                  : AppIcons.obscurePassword,
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo no puede estar vacío';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: tokens.spacing.large),
                          SizedBox(
                            width: double.infinity,
                            child: AppButtons(
                              type: ButtonType.primaryFillButton,
                              title: const Text('Crear cuenta'),
                              isLoading: _isSubmitting,
                              onPressed: _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.spacing.small),

                  SizedBox(height: tokens.spacing.large),
                  AppButtons(
                    type: ButtonType.primaryTextButton,
                    title: AppText.body(
                      '¿Ya tienes cuenta? Inicia sesión',
                      color: colors.primary,
                    ),
                    onPressed: _isSubmitting ? null : () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
