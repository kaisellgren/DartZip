/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

#library('Zip');

#import('dart:io');
#import('EndOfCentralDirectoryRecord.dart');
#import('CentralDirectory.dart');
#import('Util.dart');

/**
 * This class represents a Zip file.
 */
class Zip {
  static final LOCAL_FILE_HEADER_SIGNATURE = "\x50\x4b\x03\x04";
  static final DATA_DESCRIPTOR_SIGNATURE = "\x50\x4b\x07\x08";
  static final CENTRAL_DIRECTORY_FILE_HEADER_SIGNATURE = "\x50\x4b\x01\x02";
  static final END_OF_CENTRAL_DIRECTORY_RECORD_SIGNATURE = "\x50\x4b\x05\x06";
  static final CENTRAL_DIRECTORY_DIGITAL_SIGNATURE_SIGNATURE = "\x50\x4b\x05\x05";

  Path _filePath;
  File _file;
  List<int> _data;

  EndOfCentralDirectoryRecord _endOfCentralDirectoryRecord;
  CentralDirectory _centralDirectory;
  List files;

  Zip(Path this._filePath);

  /**
   * Open the Zip file for reading.
   *
   * Returns a future which gives a string containing an error message, if such ever occurred.
   */
  Future<Exception> open() {
    var completer = new Completer();

    this._file = new File.fromPath(this._filePath);

    this._file.readAsBytes().then((bytes) {
      this._data = bytes;

      try {
        this._process();
      } catch (Exception e) {
        completer.completeException(e);
      }

      completer.complete(null);
    });

    return completer.future;
  }

  /**
   * Extracts the entire archive to the given path.
   */
  Future<Exception> extractTo(Path path) {
    var completer = new Completer();

    void extract() {
      // Extract every file.
      this.files.forEach((CentralDirectoryFileHeader header) {
        //print(new String.fromCharCodes(header));
        print(header.localFileHeader.filename);
        print(header.localFileHeader.content);
      });

      completer.complete(null);
    }

    // If the Zip is not yet opened, open it first before we can extract it.
    if (this._centralDirectory == null) {
      this.open().then((error) {

        // Check for potential errors.
        if (error) {
          completer.completeException(error);
        } else {
          extract();
        }
      });
    } else {
      extract();
    }

    return completer.future;
  }

  /**
   * Processes the Zip file contents.
   */
  void _process() {
    var position = this._getEndOfCentralDirectoryRecordPosition();
    if (position == false) {
      throw new Exception('Could not locate the End of Central Directory Record. The archive seems to be a corrupted Zip archive.');
    }

    this._endOfCentralDirectoryRecord = new EndOfCentralDirectoryRecord(this._data.getRange(position, this._data.length - position));

    // Create Central Directory object.
    var centralDirectoryOffset = this._endOfCentralDirectoryRecord.centralDirectoryOffset;
    var centralDirectorySize = this._endOfCentralDirectoryRecord.centralDirectorySize;
    this._centralDirectory = new CentralDirectory(this._data.getRange(centralDirectoryOffset, centralDirectorySize), this._data);

    // Let the user access file headers.
    this.files = this._centralDirectory.fileHeaders;
  }

  /**
   * Finds the position of the End of Central Directory.
   */
  int _getEndOfCentralDirectoryRecordPosition() {
    // I want to shoot the smart ass who had the great idea of having an arbitrary sized comment field in this header.
    var signatureSize = Zip.END_OF_CENTRAL_DIRECTORY_RECORD_SIGNATURE.length;
    var signatureCodes = Zip.END_OF_CENTRAL_DIRECTORY_RECORD_SIGNATURE.charCodes();
    var maxScanLength = 65536;
    var length = this._data.length;
    var position = length - signatureSize;

    // Start looping from the end of the data sequence.
    for (; position > length - maxScanLength && position > 0; position--) {
      // If we found the end of central directory record signature, return the current position.
      if (listsAreEqual(signatureCodes, this._data.getRange(position, signatureSize))) {
        return position;
      }
    }

    return false;
  }
}