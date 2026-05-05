import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nestra/l10n/app_localizations.dart';
import 'package:nestra/src/core/desktop/icon_helper.dart';
import 'package:nestra/src/core/desktop/linux_desktop_entry.dart';
import 'package:nestra/src/presentation/cubit/apps/apps_cubit.dart';
import 'package:nestra/src/presentation/screens/browser/app_browser_screen.dart';
import 'package:nestra/src/presentation/widgets/app_edit_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: BlocBuilder<AppsCubit, AppsState>(
        builder: (context, state) {
          if (state is AppsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AppsReady) {
            if (state.apps.isEmpty) {
              return Center(child: Text(l10n.homeNoApps));
            }
            return ListView.builder(
              itemCount: state.apps.length,
              itemBuilder: (context, index) {
                final app = state.apps[index];
                Widget? leading;
                final iconPath = app.iconPath;
                if (iconPath != null && iconPath.isNotEmpty) {
                  final lower = iconPath.toLowerCase();
                  if (lower.endsWith('.svg')) {
                    leading = SvgPicture.file(
                      File(iconPath),
                      width: 32,
                      height: 32,
                    );
                  } else {
                    leading = Image.file(
                      File(iconPath),
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox(width: 32, height: 32),
                    );
                  }
                }
                return ListTile(
                  leading: leading,
                  title: Text(app.name),
                  subtitle: Text(
                    (app.description != null &&
                            app.description!.trim().isNotEmpty)
                        ? app.description!.trim()
                        : app.url.toString(),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AppBrowserScreen(app: app),
                      ),
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final cubit = context.read<AppsCubit>();
                      if (value == 'edit') {
                        final result = await showAppEditDialog(
                          context,
                          initialName: app.name,
                          initialUrl: app.url,
                          initialIcon: app.iconPath,
                          isEdit: true,
                        );
                        if (result != null) {
                          await cubit.editApp(
                            id: app.id,
                            name: result.name,
                            url: result.url,
                            iconPath: result.iconPath,
                            description: result.description,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.snackbarUpdated)),
                            );
                          }
                        }
                      } else if (value == 'clear-cache') {
                        final ok = await clearAppCache(app.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? l10n.snackbarCacheCleared
                                    : l10n.snackbarCacheClearFailed,
                              ),
                            ),
                          );
                        }
                      } else if (value == 'create-launcher') {
                        await installAppDesktopEntry(app);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.snackbarLauncherCreated),
                            ),
                          );
                        }
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.confirmDeleteTitle),
                            content: Text(l10n.confirmDeleteMessage(app.name)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(l10n.actionCancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(l10n.actionDelete),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await cubit.deleteApp(app.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.snackbarDeleted)),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.popupEdit)),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'clear-cache',
                        child: Text(l10n.popupClearCache),
                      ),
                      PopupMenuItem(
                        value: 'create-launcher',
                        child: Text(l10n.popupCreateLauncher),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.popupDelete),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          if (state is AppsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showAppEditDialog(context);
          if (result != null) {
            await context
                .read<AppsCubit>()
                .addApp(
                  name: result.name,
                  url: result.url,
                  iconPath: result.iconPath,
                  description: result.description,
                )
                .then((_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.snackbarAdded)));
                  }
                });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
