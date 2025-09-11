import 'package:flutter/material.dart';
import 'package:nestra/l10n/app_localizations.dart';

class AppEditResult {
  AppEditResult({required this.name, required this.url, this.iconPath});
  final String name;
  final Uri url;
  final String? iconPath;
}

Future<AppEditResult?> showAppEditDialog(
  BuildContext context, {
  String? initialName,
  Uri? initialUrl,
  String? initialIcon,
  bool isEdit = false,
}) async {
  final nameController = TextEditingController(text: initialName ?? '');
  final urlController = TextEditingController(
    text: initialUrl?.toString() ?? '',
  );
  final iconController = TextEditingController(text: initialIcon ?? '');
  final formKey = GlobalKey<FormState>();
  return showDialog<AppEditResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        isEdit
            ? AppLocalizations.of(ctx).dialogEditTitle
            : AppLocalizations.of(ctx).dialogAddTitle,
      ),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).fieldName,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppLocalizations.of(ctx).validateName
                    : null,
                autofocus: true,
              ),
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).fieldUrl,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return AppLocalizations.of(ctx).validateUrl;
                  final parsed = Uri.tryParse(v);
                  if (parsed == null ||
                      !(parsed.isScheme('http') || parsed.isScheme('https'))) {
                    return AppLocalizations.of(ctx).validateUrlInvalid;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: iconController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).fieldIconOptional,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(AppLocalizations.of(ctx).actionCancel),
        ),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            final uri = Uri.parse(urlController.text.trim());
            Navigator.of(ctx).pop(
              AppEditResult(
                name: nameController.text.trim(),
                url: uri,
                iconPath: iconController.text.trim().isEmpty
                    ? null
                    : iconController.text.trim(),
              ),
            );
          },
          child: Text(
            isEdit
                ? AppLocalizations.of(ctx).actionSave
                : AppLocalizations.of(ctx).actionAdd,
          ),
        ),
      ],
    ),
  );
}
