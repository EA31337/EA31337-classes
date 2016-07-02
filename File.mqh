//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
    Note:
    For security reasons, work with files is strictly controlled in the MQL language.
    Files with which file operations are conducted means cannot be outside the file sandbox.
*/

/**
 * Class to provide a group of functions for working with files.
 */
class File {
public:

    /**
     * Read file and return its content.
     */
    static string ReadContent(string file_name, int open_flags = FILE_TXT, short delimiter=';', bool verbose = TRUE) {
        int file_handle = FileOpen(file_name, open_flags, delimiter);
        int str_size;
        string str;
        if (file_handle < 0) {
            if (verbose) {
                PrintFormat("%s: Error: Failed to open %s file: %s", __FUNCTION__, file_name, GetLastError());
            }
            return "";
        }
        ResetLastError();
        while (!FileIsEnding(file_handle)) {
            // Find out how many symbols are used for writing the time.
            str_size = FileReadInteger(file_handle, INT_VALUE);
            // Read the string.
            str += FileReadString(file_handle, str_size);
        }
        FileClose(file_handle);
        return str;
    }

    static bool FileIsExist(string file_name, int common_flag = 0) {
        return ::FileIsExist(file_name, common_flag);
    }

};
