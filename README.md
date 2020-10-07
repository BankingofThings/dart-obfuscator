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
