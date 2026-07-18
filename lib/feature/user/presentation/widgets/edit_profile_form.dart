import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/providers/user_provider.dart';

class EditProfileForm extends ConsumerStatefulWidget {
  const EditProfileForm({super.key, this.initialProfile});

  final UserProfile? initialProfile;

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.initialProfile?.name,
  );
  late final _ageController = TextEditingController(
    text: widget.initialProfile?.age.toString(),
  );
  late final _countryController = TextEditingController(
    text: widget.initialProfile?.country,
  );
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final profile = UserProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      country: _countryController.text.trim(),
    );

    final success = await ref
        .read(userProfileProvider.notifier)
        .saveProfile(profile);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      AppSnackBar.show(
        context,
        type: SnackBarType.error,
        message: 'No se pudo guardar tu perfil',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppInputText(
            label: 'Nombre',
            textEditingController: _nameController,
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El campo no puede estar vacío';
              }
              return null;
            },
          ),
          SizedBox(height: tokens.spacing.smallMedium),
          AppInputText(
            label: 'Edad',
            textEditingController: _ageController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.cake_outlined),
            validator: (value) {
              final age = int.tryParse(value?.trim() ?? '');
              if (age == null || age <= 0) return 'Edad inválida';
              return null;
            },
          ),
          SizedBox(height: tokens.spacing.smallMedium),
          AppInputText(
            label: 'País',
            textEditingController: _countryController,
            prefixIcon: const Icon(Icons.public_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El campo no puede estar vacío';
              }
              return null;
            },
          ),
          SizedBox(height: tokens.spacing.large),
          Row(
            children: [
              Expanded(
                child: AppButtons(
                  type: ButtonType.primaryTextButton,
                  title: const Text('Cancelar'),
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(width: tokens.spacing.xSmall),
              Expanded(
                child: AppButtons(
                  type: ButtonType.primaryFillButton,
                  title: const Text('Guardar'),
                  isLoading: _isSaving,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
