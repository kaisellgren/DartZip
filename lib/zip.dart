/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

library zip;

import 'dart:io';
import 'end_of_central_directory_record.dart';
import 'central_directory.dart';
import 'central_directory_file_header.dart';
import 'local_file_header.dart';
import 'util.dart';
import 'package:crc32/crc32.dart';

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

  EndOfCentralDirectoryRecord _endOfCentralDirectoryRecord = new EndOfCentralDirectoryRecord();
  CentralDirectory _centralDirectory = new CentralDirectory();

  Zip(path) {
    if (path is String)
      _filePath = new Path(path);
    else
      _filePath = path;
  }

  /**
   * Saves the Zip archive.
   */
  void save() {
    _file = new File.fromPath(this._filePath);

    _file.create().then((File file) {
      file.open(FileMode.WRITE).then((RandomAccessFile raf) {

        // Start by writing Local File Headers.
        _centralDirectory.fileHeaders.forEach((CentralDirectoryFileHeader cdfh) {

          // Save the current position on the Central Directory File Header.
          cdfh.localHeaderOffset = raf.positionSync();

          // Save the header and write it to the file.
          final buffer = cdfh.localFileHeader.save();
          raf.writeListSync(buffer, 0, buffer.length);
        });

        // We are now at the location of the Central Directory.
        final centralDirectoryOffset = raf.positionSync();

        // Continue with the Central Directory Record.
        _centralDirectory.fileHeaders.forEach((CentralDirectoryFileHeader cdfh) {

          // Save the header and write it to the file.
          final buffer = cdfh.save();
          raf.writeListSync(buffer, 0, buffer.length);
        });

        // Last, write the End of Central Directory Record.
        _endOfCentralDirectoryRecord.centralDirectoryOffset = centralDirectoryOffset;
        _endOfCentralDirectoryRecord.centralDirectorySize = raf.positionSync() - centralDirectoryOffset;

        final buffer = _endOfCentralDirectoryRecord.save();
        raf.writeListSync(buffer, 0, buffer.length);

        // TODO: Done saving, do something.
      });
    });
  }

  /**
   * Open the Zip file for reading.
   */
  Future<Exception> open() {
    final completer = new Completer();

    _file = new File.fromPath(this._filePath);

    _file.readAsBytes().then((bytes) {
      try {
        final position = _getEndOfCentralDirectoryRecordPosition(bytes);

        _endOfCentralDirectoryRecord = new EndOfCentralDirectoryRecord.fromData(bytes.getRange(position, bytes.length - position));

        // Create Central Directory object.
        final centralDirectoryOffset = _endOfCentralDirectoryRecord.centralDirectoryOffset;
        final centralDirectorySize = _endOfCentralDirectoryRecord.centralDirectorySize;
        _centralDirectory = new CentralDirectory.fromData(bytes.getRange(centralDirectoryOffset, centralDirectorySize), bytes);

      } on Exception catch (e) {
        completer.completeException(e);
      }

      completer.complete(null);
    });

    return completer.future;
  }

  /**
   * Adds the data associated with the given filename to the Zip.
   */
  void addFileFromString(filename, String data) {
    final fh = new LocalFileHeader();
    fh.content = data.charCodes();
    fh.crc32 = CRC32.compute(fh.content);
    fh.uncompressedSize = data.length;
    fh.compressedSize = fh.uncompressedSize;
    fh.filename = filename;

    final cdfh = new CentralDirectoryFileHeader.fromLocalFileHeader(fh);

    _centralDirectory.fileHeaders.add(cdfh);
    _endOfCentralDirectoryRecord.totalCentralDirectoryEntries += 1;
  }

  /**
   * Extracts the entire archive to the given path.
   */
  Future<Exception> extractTo(path) {
    if (path is String)
      path = new Path(path);

    final completer = new Completer();

    // This method extracts every file. We will call this later.
    void extract() {

      // Create the target directory if needed.
      final directory = new Directory.fromPath(path);
      directory.create().then((directory) {

        // Extract every file.
        _centralDirectory.fileHeaders.forEach((CentralDirectoryFileHeader header) {
          final filename = header.localFileHeader.filename;
          final content = header.localFileHeader.content;

          final file = new File.fromPath(path.append(filename));

          // Open the file for writing.
          file.open(FileMode.WRITE).then((RandomAccessFile raf) {

            // Write all bytes and then close the file.
            raf.writeList(content, 0, content.length).then((trash) => raf.close());
          });
        });

        completer.complete(null);
      });
    }

    // If the Zip is not yet opened, open it first before we can extract it.
    if (_file == null) {
      open().then((error) {

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
   * Finds the position of the End of Central Directory.
   */
  int _getEndOfCentralDirectoryRecordPosition(bytes) {
    // I want to shoot the smart ass who had the great idea of having an arbitrary sized comment field in this header.
    final signatureSize = Zip.END_OF_CENTRAL_DIRECTORY_RECORD_SIGNATURE.length;
    final signatureCodes = Zip.END_OF_CENTRAL_DIRECTORY_RECORD_SIGNATURE.charCodes();
    final maxScanLength = 65536;
    final length = bytes.length;
    var position = length - signatureSize;

    // Start looping from the end of the data sequence.
    for (; position > length - maxScanLength && position > 0; position--) {
      // If we found the end of central directory record signature, return the current position.
      if (listsAreEqual(signatureCodes, bytes.getRange(position, signatureSize))) {
        return position;
      }
    }

    throw new Exception('The Zip file seems to be corrupted. Could not find End of Central Directory Record location.');
  }
}