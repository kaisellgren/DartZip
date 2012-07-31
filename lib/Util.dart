#library('Util');

/**
 * Converts the byte sequence to a numeric representation.
 */
bytesToValue(List<int> bytes) {
  var value = 0;

  for (var i = 0, length = bytes.length; i < length; i++) {
    value += bytes[i] * Math.pow(256, i);
  }

  return value;
}

/**
* Returns true if the two given lists are equal.
*/
bool listsAreEqual(List one, List two) {
  var i = -1;
  return one.every((element) {
    i++;

    return two[i] == element;
  });
}