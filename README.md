# dart_obfuscator

# About
This is a plane Dart script, that is obfuscating dart projects, including flutter

## Usecase
Obfuscator will go under /lib directory and obfuscate all files except exported once.
It's dedicated for libraries, packages and SDKs that should be distributed without revealing source code to the client.

### High level overview off the algorithm:

1. Determine which files should not be obfuscated (the once under lib and once mentioned in export notation) and which should - the rest.  
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
