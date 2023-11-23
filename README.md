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
* unit tests are carried across so you can run tests after obfuscating.




## Usecase
For distributing source packages to customers.

## Non-use case
The flutter compiler has an --obfuscate flag which will obfuscate compiled code.
You should use the --obfucscate flag when compiling your release code.
In this case you don't need to use op-obfuscator

The op-obfuscator is only required when you are distributing source.

## Pre-conditions
* Your code must be without syntax errors 
* overrides MUST be annotated with @override

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

### Command line switches

#### --output (abbreviation: -o)
The location to store the obfuscated code.

The output path must NOT overlap the input path otherwise
an error will be thrown.


#### --input (abbreviation: -i)
The location of the project to process.
If the --input switch isn't passed then the current working
directory will be used.

In either case, if a `pubspec.yaml` isn't found in the provided
directory, then we search up the directory tree looking for a 'pubpsec.yaml'. This allows you to launch the obfucscator from
any directory within the project.

#### --overwrite (abbreviation: -w)
If the 'output' directory exists then the obfuscation will terminate to avoid overwritting critical files.

You can pass the --overwrite to force the obfuscator to overwrite
the `output` directory.

USE THIS OPTION WITH CARE!
It will delete the entire directory tree under the output path.

#### --excludes (abbreviation: -x)
The obfuscator process all dart files that form part of the package
except for directories that are excluded.

```
op-obfuscate --output /tmp/myproj --exclude=specialdir,example,tool,benchmark.
```

By default we exclude the following directories:
* example
* tool
* benchmark

You can select the directories to exclude by passing the --exclude 
flag with one or more directories to exclude but then you must
pass the default excludes as well.

The excludes switch takes a list of globs with paths relative to the project root.


If you pass the --exclude switch and the --include switch then exclusions
are processed first.


#### --includes (abbreviation: -c)
Only obfuscate the directories or files passed to the --include switch

```
op-obfuscate --output /tmp/myproj --exclude=specialdir,example,tool,benchmark.
```

If the --include switch isn't passed then all .dart libraries are 
obfuscated except for those in the --exclude list.

Any explicit or default excludes are processed before the include list.

The includes switch takes a list of globs with paths relative to the project root.



# Reference material

Dart linter provides lots of examples:

https://github.com/dart-code-checker/dart-code-metrics/blob/master/lib/src/analyzers/lint_analyzer/rules/rules_list/format_comment/visitor.dart


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