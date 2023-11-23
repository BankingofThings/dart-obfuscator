// ignore_for_file: file_names
// ignore_for_file: flutter_style_todos

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

class Args {
  Args(this._args);

  final List<String> _args;

  late String inputPath;
  late String pathToObfuscatedProject;
  late bool overwrite;
  late List<String> include;
  late List<String> exclude;

  void parse() {
    final parser = ArgParser()
      ..addOption('output',
          abbr: 'o',
          help: 'Path to store the obfuscated project',
          mandatory: true)
      ..addOption(
        'input',
        abbr: 'i',
        help:
            '''Path to the location of the project to obfuscate. Defaults to the current directory''',
      )
      ..addMultiOption(
        'includes',
        abbr: 'c',
        help: '''
Filter the set of files that will be processed in from the 'input' directory. 
The primary purpose is for testing.''',
        hide: true,
      )
      ..addMultiOption(
        'excludes',
        abbr: 'x',
        defaultsTo: [
          'example',
          'tool',
          'benchmark',
        ],
        help: '''
Excludes the passed paths from the obfuscation process.
By default we exclude the 'example' and 'tool' directory.
''',
        hide: true,
      )
      ..addFlag('overwrite', abbr: 'w', help: '''
If the output path exist then it will be overwritten. 
Basic checks are peformed to ensure that the target directory was created by
the obfuscator.''');

    try {
      final parsed = parser.parse(_args);
      pathToObfuscatedProject = truepath(parsed['output'] as String);
      inputPath = truepath(parsed['input'] as String? ?? pwd);
      exclude = parsed['exclude'] as List<String>;
      include = parsed['filter'] as List<String>;
      overwrite = parsed['overwrite'] as bool;
    } on FormatException catch (e) {
      printerr(e.message);
    }
  }
}
