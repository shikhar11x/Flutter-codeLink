import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/editor/screens/editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CodeLinkApp());
}

class CodeLinkApp extends StatelessWidget {
  const CodeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        final slug = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.first
            : null;

        if (slug != null && slug.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => EditorScreen(padSlug: slug),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      },
      initialRoute: Uri.base.path.isEmpty || Uri.base.path == '/'
          ? '/'
          : Uri.base.path,
    );
  }
}