#import('../lib/Zip.dart');
#import('dart:io');

void main() {
  var zip = new Zip(new Path('test.zip'));

  zip.extractTo(new Path.fromNative("${new Directory.current().path}/test-extraction/"));

  /*
  zip.open().then((error) {
    // An error can occur when you open a corrupted Zip file, for example.
    if (error) {
      throw error;
    }

    print(zip.files);
  });*/
}