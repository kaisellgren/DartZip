#import('../lib/Zip.dart');
#import('dart:io');

void main() {
  var zip = new Zip(new Path('test.zip'));

  zip.extractTo(new Path("${new Directory.current()}/test-extraction/"));

  //print(zip.files); // It's null, as long as we haven't opened the Zip or modified it.

  /*
  zip.open().then((error) {
    // An error can occur when you open a corrupted Zip file, for example.
    if (error) {
      throw error;
    }

    print(zip.files);
  });*/
}