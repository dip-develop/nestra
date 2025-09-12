import 'package:flutter/material.dart';
import 'package:nestra/l10n/app_localizations.dart';
import 'package:nestra/src/core/desktop/icon_helper.dart';
import 'package:nestra/src/domain/utils/app_id.dart';
import 'package:nestra/src/infrastructure/metadata/app_metadata_fetcher.dart';

class AppEditResult {
  AppEditResult({
    required this.name,
    required this.url,
    this.iconPath,
    this.description,
  });
  final String name;
  final Uri url;
  final String? iconPath;
  final String? description;
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
  final fetcher = AppMetadataFetcher();
  String? fetchedDescription;
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
                controller: urlController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).fieldUrl,
                  suffix: IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: () async {
                      // Allow fetching even if name is empty; only check URL minimally.
                      final v = urlController.text.trim();
                      final parsed = Uri.tryParse(v);
                      if (parsed == null ||
                          !(parsed.isScheme('http') ||
                              parsed.isScheme('https'))) {
                        return;
                      }
                      final meta = await _tryPrefill(
                        ctx,
                        urlController,
                        nameController,
                        iconController,
                        fetcher,
                      );
                      if (meta != null) {
                        fetchedDescription = meta.description;
                      }
                    },
                  ),
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
                autofocus: true,

                onEditingComplete: () async {
                  // Try auto-fetch metadata when URL is completed
                  final v = urlController.text.trim();
                  final parsed = Uri.tryParse(v);
                  if (parsed == null ||
                      !(parsed.isScheme('http') || parsed.isScheme('https'))) {
                    return;
                  }
                  final meta = await _tryPrefill(
                    ctx,
                    urlController,
                    nameController,
                    iconController,
                    fetcher,
                  );
                  if (meta != null) {
                    fetchedDescription = meta.description;
                  }
                },
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).fieldName,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppLocalizations.of(ctx).validateName
                    : null,
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
                description: fetchedDescription,
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

Future<AppMetadata?> _tryPrefill(
  BuildContext ctx,
  TextEditingController urlController,
  TextEditingController nameController,
  TextEditingController iconController,
  AppMetadataFetcher fetcher,
) async {
  final url = Uri.parse(urlController.text.trim());
  try {
    final meta = await fetcher.fetch(url);
    if ((nameController.text.trim().isEmpty) && meta.name != null) {
      nameController.text = meta.name!;
    }
    if (meta.iconUrl != null) {
      final saved = await downloadIconFromUrl(
        meta.iconUrl!,
        baseName: idFromUrl(url),
      );
      if (saved != null) {
        iconController.text = saved;
      }
    }
    return meta;
  } catch (_) {
    // Silent fail; user can fill fields manually
  }
  return null;
}
