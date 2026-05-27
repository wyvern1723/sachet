import 'package:flutter/material.dart';
import 'package:sachet/models/enums/app_update_channel.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class AppUpdateChannelDropdownMenu extends StatelessWidget {
  const AppUpdateChannelDropdownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String appUpdateChannel = context.select<SettingsProvider, String>(
        (settngsProvider) => SettingsProvider.appUpdateChannel);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DropdownMenu<String>(
      width: 180,
      initialSelection: appUpdateChannel,
      requestFocusOnTap: false,
      textStyle: textTheme.labelMedium,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
          return switch ((
            Theme.of(context).brightness,
            states.contains(WidgetState.disabled)
          )) {
            (Brightness.dark, true) => const Color(0x0DFFFFFF), //  5% white
            (Brightness.dark, false) => const Color(0x1AFFFFFF), // 10% white
            (Brightness.light, true) => const Color(0x05000000), //  2% black
            (Brightness.light, false) => const Color(0x0A000000), //  4% black
          };
        }),
        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      ),
      onSelected: (String? value) {
        if (value != null) {
          context.read<SettingsProvider>().setAppUpdateChannel(value);
        }
      },
      dropdownMenuEntries: AppUpdateChannel.values
          .map(
            (e) => DropdownMenuEntry<String>(
              value: e.host,
              label: e.host,
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(textTheme.labelSmall),
                padding:
                    WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
              ),
            ),
          )
          .toList(),
    );
  }
}
