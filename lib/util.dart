library Util;

import 'dart:math';

/**
 * Converts the byte sequence to a numeric representation.
 */
int bytesToValue(List<int> bytes) {
  var value = 0;

  for (var i = 0, length = bytes.length; i < length; i++) {
    value += bytes[i] * pow(256, i);
  }

  return value;
}

/**
 * Converts the given value to a byte sequence.
 *
 * The parameter [minByteCount] specifies how many bytes should be returned at least.
 */
List<int> valueToBytes(int value, [int minByteCount = 0]) {
  var bytes = [0x00, 0x00, 0x00, 0x00];

  if (value == null) value = 0;

  var i = 0;
  var actualByteCount = 0;
  do {
    bytes[i++] = value & (255);
    value = value >> 8;
    actualByteCount += 1;

    if (value == 0)
      break;
  } while (i < 4);

  return bytes.getRange(0, max(minByteCount, actualByteCount));
}

/**
 * Returns true if the two given lists are equal.
 */
bool listsAreEqual(final List one, final List two) {
  var i = -1;
  return one.every((element) {
    i++;

    return two[i] == element;
  });
}