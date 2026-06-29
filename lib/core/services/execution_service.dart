import '../network/api_client.dart';

class ExecutionResult {
  final String output;
  final String stderr;
  final int exitCode;
  final double execTime;
  final bool isError;

  const ExecutionResult({
    required this.output,
    required this.stderr,
    required this.exitCode,
    required this.execTime,
    required this.isError,
  });
}

class ExecutionService {
  ExecutionService._();

  static const _langMap = {
    'Python':     'python',
    'JavaScript': 'javascript',
    'Java':       'java',
    'C++':        'cpp',
    'Dart':       'dart',
  };

  static Future<ExecutionResult> execute({
    required String language,
    required String code,
    String stdin = '',
  }) async {
    final lang = _langMap[language] ?? language.toLowerCase();

    try {
      final response = await ApiClient.instance.post(
        '/api/execute',
        data: {
          'language': lang,
          'code': code,
          'stdin': stdin,
        },
      );

      final data = response.data;
      final exitCode = data['exitCode'] ?? 0;

      return ExecutionResult(
        output: data['output'] ?? '',
        stderr: data['stderr'] ?? '',
        exitCode: exitCode,
        execTime: (data['execTime'] ?? 0).toDouble(),
        isError: exitCode != 0,
      );
    } catch (e) {
      return const ExecutionResult(
        output: 'Failed to connect to execution service.',
        stderr: '',
        exitCode: 1,
        execTime: 0,
        isError: true,
      );
    }
  }
}