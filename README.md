# dart_obfuscator

# About
This is a plane Dart script, that is obfuscating dart projects, including flutter

## Usecase
Obfuscator will go under /lib directory and obfuscate all files except exported ones.
It's dedicated for libraries, packages and SDKs that should be distributed without revealing source code to the client.

### High level overview off the algorithm:

1. Determine which dart libraries (.dart files) should not be obfuscated 
(the libraries under lib and libraries exported in the packages barrel file) and which should - the rest.  
2. Move all source code to singe file and delete rest of files
3. Obfuscate resulting source code


## Usage
1. Make sure you can run dart scripts, see https://dart.dev/tutorials/server/get-started
2. Ensure you have all changes in your repository saved, script will delete all files ???
3. Make sure your project is compilable and runnable, all the generatable files are generated.
3. Run console command:
```text
dart lib/main.dart "path/to/your/flutter-project" -o "output_file_name" //todo
```


# Reference material

Discussion on refactoring

https://groups.google.com/a/dartlang.org/g/analyzer-discuss/c/7-B75W1MG5k


# the specficiation for the analysis servers api.

https://htmlpreview.github.io/?https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server/doc/api.html#type_RefactoringKind


# package that launches an analysis server
https://pub.dev/packages/analysis_server_lib

# package to build plugins that extends the analysis server.
https://pub.dev/packages/analyzer_plugin

# codemod a cli interactive to for doing refactoring.
https://pub.dev/packages/codemod


# attributions
Some code taken from:

https://github.com/Workiva/dart_codemod