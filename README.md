# op_obfuscator

# About
The OnePub obfuscator is designed to obfuscate Dart libraries.

The action that OnePub obfuscator takes are:
* remove all comments
* rename variable and class names with short non-contextual names e.g. 'aa'.
* private delcarations that start with '_' are retained as private.
* any libraries that are exported will remain non-obfuscated.

## Non-actions
* all platform specific code (java, swfit...) is left untouched
* example code is left untouched.
* unit tests are not carried across 

TODO: review unit tests
Users may want to run unit tests after obfuscating code.
Perhaps we need to copy them across and treat them like a public interface
It is then the users job to delete them before publishing.
Unit tests don't get uploaded so seems ok.



## Usecase
For distributing source packages to customers.

## Non-use case
The flutter compiler has an --obfuscate flag which will obfuscate compiled code.
You should use the --obfucscate flag when compiling your release code.
In this case you don't need to use op-obfuscator

The op-obfuscator is only required when you are distributing source.


## Usage
Obtain a OnePub Customer Distribution License (CDL)
Email 'support@onepub.dev' asking fro access to the op-obfuscator
The support team will email the installation details.

Activate the op-obfuscator script via:
```
dart pub global activate op-obfuscator
```

To run the obfuscator:

```
cd mypackage
op-obfuscator --output /some/directory
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