//+----------------
//| MD5 in MQL    |
//| File: MD5.mqh |
//+----------------

/*

  License: New BSD License

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/*
  MD5 algorithm is very simple, if you want to understand the relevant algorithms refer to: RFC 1321.
  The efficiency of the algorithm simply test it, it probably is the original version of the speed C 1/10.
  The MD5 algorithm is only for optimized string, the string can support MQL4 longest string.
  If the large file MD5 encryption, see a little improvement to this algorithm, when I was in design,
  also made consideration, you can quickly convert over.
  Problems may occur, but the repair method is also very simple, it is the first 16 bits are added, then after 16 are summed. Note that the first 16-bit carry:
  var lsw = (x & 0xFFFF) + (y & 0xFFFF);    var msw = (x >> 16) + (y >> 16) + (lsw >> 16);    (msw << 16) | (lsw & 0xFFFF);
  If you're using the algorithm, but also pay attention to test the accuracy of the Chinese case, the algorithm does not take a lot of Chinese.
  Some dictionaries now online MD5 crack site, in fact, do not be afraid of them, you put the initial algorithm a, b, c, d change it, it becomes a new encryption algorithm of.
  @see: http://www.cnblogs.com/niniwzw/archive/2009/12/05/1617685.html
*/


// Includes.
#include "Array.mqh"
#include "Convert.mqh"

/**
 * Class to provide implementation of MD5 algorithm.
 * Based on the code published at: https://code.google.com/archive/p/md5-in-mql4/
 */
class MD5 {

  public:

    /**
     * Calculate MD5 checksum.
     */
    static string MD5Sum(string str) {
      int len = StringLen(str);
      int index = len % 64; //mod 64
      int count = (len - index) / 64;

      long a = 0x67452301, b = 0xEFCDAB89, c = 0x98BADCFE, d = 0x10325476;
      int buff[16], last[16], i, k = 0, last_char[4], last_index;
      string item;
      for (i = 0; i < count; i++)
      {
        item = StringSubstr(str, i * 64, 64);
        Convert::String4ToIntArray(buff, item);
        MD5Transform(a, b, c, d, buff);
      }
      ArrayInitialize(last, 0);
      ArrayInitialize(last_char, 0);
      last_index = 0;
      if (index > 0) {
        int last_num = index % 4;
        count = index - last_num;
        if (count > 0) {
          item = StringSubstr(str, i * 64, count);
          last_index = Convert::String4ToIntArray(last, item);
        }
        for (k = 0; k < last_num; k++)
        {
          last_char[k] = StringGetCharacter(str, i * 64 + count + k);
        }
      }
      last_char[k] = 0x80;
      last[last_index] = Convert::CharToInt(last_char);
      if (index >= 56) {
        MD5Transform(a, b, c, d, last);
        ArrayInitialize(last, 0);
      }
      last[14] =  len << 3;
      last[15] =  ((len >> 1) & 0x7fffffff) >> 28;
      MD5Transform(a, b, c, d, last);
      string result = StringFormat("%s%s%s%s",
        Convert::IntToHex(a), Convert::IntToHex(b), Convert::IntToHex(c),  Convert::IntToHex(d));
      return result;
    }

    static long F(long x, long y, long z) {
      return ((x & y) | ((~x) & z));
    }

    static long G(long x, long y, long z) {
      return ((x & z) | (y & (~z)));
    }

    static long H(long x, long y, long z) {
      return ((x ^ y ^ z));
    }

    static long I(long x, long y, long z) {
      return ((y ^ (x | (~z))));
    }

    static long AddUnsigned(long a, long b) {
      long c = a + b;
      return (c);
    }

    static long FF(long a, long b, long c, long d, long x, int s, long ac) {
      a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));
      return (AddUnsigned(RotateLeft(a, s), b));
    }

    static long GG(long a, long b, long c, long d, long x, int s, long ac) {
      a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));
      return (AddUnsigned(RotateLeft(a, s), b));
    }

    static long HH(long a, long b, long c, long d, long x, int s, long ac) {
      a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));
      return (AddUnsigned(RotateLeft(a, s), b));
    }

    static long II(long a, long b, long c, long d, long x, int s, long ac) {
      a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));
      return (AddUnsigned(RotateLeft(a, s), b));
    }

    /**
     * Implementation of right shift operation for unsigned int.
     * See: http://www.cnblogs.com/niniwzw/archive/2009/12/04/1617130.html
     */
    static long RotateLeft(long lValue, int iShiftBits) {
      if (iShiftBits == 32) return (lValue);
      long result = (lValue << iShiftBits) | (((lValue >> 1) & 0x7fffffff) >> (31 - iShiftBits));
      return (result);
    }

    /**
     * Assume: ArraySize(x) == 16.
     */
    static void MD5Transform(long &a, long &b, long &c, long &d, int &x[]) {
      long AA, BB, CC, DD;
      int S11=7, S12=12, S13=17, S14=22;
      int S21=5, S22=9 , S23=14, S24=20;
      int S31=4, S32=11, S33=16, S34=23;
      int S41=6, S42=10, S43=15, S44=21;

      AA=a; BB=b; CC=c; DD=d;
      a=FF(a,b,c,d,x[0], S11, 0xD76AA478);
      d=FF(d,a,b,c,x[1], S12, 0xE8C7B756);
      c=FF(c,d,a,b,x[2], S13, 0x242070DB);
      b=FF(b,c,d,a,x[3], S14, 0xC1BDCEEE);
      a=FF(a,b,c,d,x[4], S11, 0xF57C0FAF);
      d=FF(d,a,b,c,x[5], S12, 0x4787C62A);
      c=FF(c,d,a,b,x[6], S13, 0xA8304613);
      b=FF(b,c,d,a,x[7], S14, 0xFD469501);
      a=FF(a,b,c,d,x[8], S11, 0x698098D8);
      d=FF(d,a,b,c,x[9], S12, 0x8B44F7AF);
      c=FF(c,d,a,b,x[10],S13, 0xFFFF5BB1);
      b=FF(b,c,d,a,x[11],S14, 0x895CD7BE);
      a=FF(a,b,c,d,x[12],S11, 0x6B901122);
      d=FF(d,a,b,c,x[13],S12, 0xFD987193);
      c=FF(c,d,a,b,x[14],S13, 0xA679438E);
      b=FF(b,c,d,a,x[15],S14, 0x49B40821);

      a=GG(a,b,c,d,x[1], S21, 0xF61E2562);
      d=GG(d,a,b,c,x[6], S22, 0xC040B340);
      c=GG(c,d,a,b,x[11],S23, 0x265E5A51);
      b=GG(b,c,d,a,x[0], S24, 0xE9B6C7AA);
      a=GG(a,b,c,d,x[5], S21, 0xD62F105D);
      d=GG(d,a,b,c,x[10],S22, 0x2441453);
      c=GG(c,d,a,b,x[15],S23, 0xD8A1E681);
      b=GG(b,c,d,a,x[4], S24, 0xE7D3FBC8);
      a=GG(a,b,c,d,x[9], S21, 0x21E1CDE6);
      d=GG(d,a,b,c,x[14],S22, 0xC33707D6);
      c=GG(c,d,a,b,x[3], S23, 0xF4D50D87);
      b=GG(b,c,d,a,x[8], S24, 0x455A14ED);
      a=GG(a,b,c,d,x[13],S21, 0xA9E3E905);
      d=GG(d,a,b,c,x[2], S22, 0xFCEFA3F8);
      c=GG(c,d,a,b,x[7], S23, 0x676F02D9);
      b=GG(b,c,d,a,x[12],S24, 0x8D2A4C8A);

      a=HH(a,b,c,d,x[5], S31, 0xFFFA3942);
      d=HH(d,a,b,c,x[8], S32, 0x8771F681);
      c=HH(c,d,a,b,x[11],S33, 0x6D9D6122);
      b=HH(b,c,d,a,x[14],S34, 0xFDE5380C);
      a=HH(a,b,c,d,x[1], S31, 0xA4BEEA44);
      d=HH(d,a,b,c,x[4], S32, 0x4BDECFA9);
      c=HH(c,d,a,b,x[7], S33, 0xF6BB4B60);
      b=HH(b,c,d,a,x[10],S34, 0xBEBFBC70);
      a=HH(a,b,c,d,x[13],S31, 0x289B7EC6);
      d=HH(d,a,b,c,x[0], S32, 0xEAA127FA);
      c=HH(c,d,a,b,x[3], S33, 0xD4EF3085);
      b=HH(b,c,d,a,x[6], S34, 0x4881D05);
      a=HH(a,b,c,d,x[9], S31, 0xD9D4D039);
      d=HH(d,a,b,c,x[12],S32, 0xE6DB99E5);
      c=HH(c,d,a,b,x[15],S33, 0x1FA27CF8);
      b=HH(b,c,d,a,x[2], S34, 0xC4AC5665);

      a=II(a,b,c,d,x[0], S41, 0xF4292244);
      d=II(d,a,b,c,x[7], S42, 0x432AFF97);
      c=II(c,d,a,b,x[14],S43, 0xAB9423A7);
      b=II(b,c,d,a,x[5], S44, 0xFC93A039);
      a=II(a,b,c,d,x[12],S41, 0x655B59C3);
      d=II(d,a,b,c,x[3], S42, 0x8F0CCC92);
      c=II(c,d,a,b,x[10],S43, 0xFFEFF47D);
      b=II(b,c,d,a,x[1], S44, 0x85845DD1);
      a=II(a,b,c,d,x[8], S41, 0x6FA87E4F);
      d=II(d,a,b,c,x[15],S42, 0xFE2CE6E0);
      c=II(c,d,a,b,x[6], S43, 0xA3014314);
      b=II(b,c,d,a,x[13],S44, 0x4E0811A1);
      a=II(a,b,c,d,x[4], S41, 0xF7537E82);
      d=II(d,a,b,c,x[11],S42, 0xBD3AF235);
      c=II(c,d,a,b,x[2], S43, 0x2AD7D2BB);
      b=II(b,c,d,a,x[9], S44, 0xEB86D391);

      a=AddUnsigned(a, AA); b=AddUnsigned(b, BB);
      c=AddUnsigned(c, CC); d=AddUnsigned(d, DD);
    }
};
