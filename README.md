Zip
==
A Zib library written in [Dart](http://dartlang.org).

### Notes

This library is in progress, and can partially extract Zip files. To be more specific, it can extract non-compressed Zip files
such as Zip files containing small text files (they are rarely compressed).

### Installation

Add as a dependency to your ```pubspec.yaml```. For example:

```
dependencies:
  zip:
    git: git://github.com/kaisellgren/DartZip.git
```

In the future when http://pub.dartlang.org is launched, there will be a more direct way to do this.

### Examples

##### Extracting an archive

The following code extracts the `test.zip` file to the given target folder. It works as long as the Zip file does not contain compressed files.

```dart
import 'package:dart_zip/zip.dart';
import 'dart:io';

void main() {
  var currentPath = new Directory.current().path;
  var zip = new Zip('test.zip');

  zip.extractTo(new Path.fromNative("${currentPath}/test-extraction/"));
}
```

##### Creating an archive

This code demonstrates how to dynamically add files to an archive and save it. Support for other actions will arrive at some point.

```dart
import 'package:dart_zip/zip.dart';
import 'dart:io';

void main() {
  var zip = new Zip('test.zip');
  zip.addFileFromString('something.txt', 'content goes here');
  zip.save();
}
```

### TODO

- No support for compression yet. Zips are stored without compression, and existing archives that are compressed can't be decompressed.
- Encryption.
- Signatures.
- More API stuff.

### Notes

I'm kind of waiting to see if Dart gets an official support for compression algorithms as they would perform much better that way.

### License
The library is licensed under MIT. Feel free to use it for any purpose.
