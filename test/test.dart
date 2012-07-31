#import('../lib/Zip.dart');
#import('dart:io');

void main() {
  var zip = new Zip(new Path('test.zip'));

  zip.open().then((i) {
    print(zip.files);
  });
}