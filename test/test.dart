import '../lib/zip.dart';
import 'dart:io';

void main() {
  final zip = new Zip('test.zip');
  zip.addFileFromString('something.txt', 'content goes here');
  zip.save();

  //zip.extractTo(new Path.fromNative("${new Directory.current().path}/test-extraction/"));

  /*
  zip.open().then((error) {
    // An error can occur when you open a corrupted Zip file, for example.
    if (error) {
      throw error;
    }

    print(zip.files);
  });*/
}