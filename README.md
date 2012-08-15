DartZip
==
A Zib library written in [Dart](http://dartlang.org).

### Notes

This library is in progress, and can partially extract Zip files. To be more specific, it can extract non-compressed Zip files
such as Zip files containing small text files (they are rarely compressed).

### Installation

For now, until the Dart package manager is finished, just clone the repository.

### Examples

The following code extracts the `test.zip` file to the given target folder. It works as long as the Zip file does not contain compressed files.

```dart
#import('../lib/Zip.dart');
#import('dart:io');

void main() {
  var currentPath = new Directory.current().path;
  var zip = new Zip(new Path('test.zip'));

  zip.extractTo(new Path.fromNative("${currentPath}/test-extraction/"));
}
```

### TODO

Support for compressed files is the next priority. Even after that, there's still work to do regarding signatures, encryption and other minor things.

### License
The library is licensed under MIT. Feel free to use it for any purpose.