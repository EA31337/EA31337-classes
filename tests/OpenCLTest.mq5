//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of OpenCL class.
 */

// Includes.
#include "../Math/Matrix.h"
#include "../Math/OpenCL.h"

/**
 * Implements initialization function.
 */
int OnInit() {
  Ref<OpenCLProgram> program =
      OpenCL::Compile("#pragma OPENCL EXTENSION cl_khr_fp64 : enable" NL
                      "__kernel void test(__global double *data) {" NL "  data[0] = 5;" NL "}" NL,

                      "test");

  double result[] = {0};

  Ref<OpenCLBuffer> buffer = OpenCL::Alloc(1 /* 1 double */, CL_MEM_READ_WRITE);

  program REF_DEREF SetArg(0, buffer.Ptr(), ULONG_MAX);

  if (!program REF_DEREF Run()) {
    Alert("Error running program!");
  }

  buffer REF_DEREF Read(result);

  Print("Output: ", result[0]);

  Matrix<double> *in1, *in2, *out;
  in1 = Matrix<double>::CreateFromString("[[1,2,3], [4,5,6]]");  // 2 x 3
  Print("in1 shape: ", in1 PTR_DEREF GetRange(0), " x ", in1 PTR_DEREF GetRange(1));
  in2 = Matrix<double>::CreateFromString("[[7,8,9,10,11], [11,12,13,14,16], [15,16,17,18,19]]");  // 3 x 5
  Print("in2 shape: ", in2 PTR_DEREF GetRange(0), " x ", in2 PTR_DEREF GetRange(1));
  out = in1 PTR_DEREF MatMul(in2);
  Print("out shape: ", out PTR_DEREF GetRange(0), " x ", out PTR_DEREF GetRange(1));
  Print("out data: ", out PTR_DEREF ToString());

  delete in1;
  delete in2;
  delete out;

  ExpertRemove();
  return (INIT_SUCCEEDED);
}
