//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Test functionality of Matrix class.
 */

// Includes.
#include "../Matrix.mqh"
#include "../Test.mqh"

/**
 * Implements Init event handler.
 */
int OnInit() {
  int a, b, c;

  Matrix<double> matrix(2, 3, 20);

  assertTrueOrFail(matrix.GetRange(0) == 2, "1st dimension's length is not valid!");
  assertTrueOrFail(matrix.GetRange(1) == 3, "2nd dimension's length iś not valid!");
  assertTrueOrFail(matrix.GetRange(2) == 20, "3rd dimension's length is not valid!");

  assertTrueOrFail(matrix.GetDimensions() == 3, "Number of matrix dimensions isn't valid!");

  matrix.Fill(1);

  for (a = 0; a < matrix.GetRange(0); ++a) {
    for (b = 0; b < matrix.GetRange(1); ++b) {
      for (c = 0; c < matrix.GetRange(2); ++c) {
        assertTrueOrFail(matrix[a][b][c].Val() == 1, "Fill() didn't fill the whole matrix!");
      }
    }
  }

  matrix.Add(2);

  for (a = 0; a < matrix.GetRange(0); ++a) {
    for (b = 0; b < matrix.GetRange(1); ++b) {
      for (c = 0; c < matrix.GetRange(2); ++c) {
        assertTrueOrFail(matrix[a][b][c].Val() == 3, "Add() didn't add value to the whole matrix!");
      }
    }
  }

  matrix.Sub(2);

  for (a = 0; a < matrix.GetRange(0); ++a) {
    for (b = 0; b < matrix.GetRange(1); ++b) {
      for (c = 0; c < matrix.GetRange(2); ++c) {
        assertTrueOrFail(matrix[a][b][c].Val() == 1, "Sub() didn't subtract value from the whole matrix!");
      }
    }
  }

  matrix.Mul(4);

  for (a = 0; a < matrix.GetRange(0); ++a) {
    for (b = 0; b < matrix.GetRange(1); ++b) {
      for (c = 0; c < matrix.GetRange(2); ++c) {
        assertTrueOrFail(matrix[a][b][c].Val() == 4, "Mul() didn't multiply value for the whole matrix!");
      }
    }
  }

  matrix.Div(4);

  for (a = 0; a < matrix.GetRange(0); ++a) {
    for (b = 0; b < matrix.GetRange(1); ++b) {
      for (c = 0; c < matrix.GetRange(2); ++c) {
        assertTrueOrFail(matrix[a][b][c].Val() == 1, "Div() didn't divide value for the whole matrix!");
      }
    }
  }

  assertTrueOrFail((int)matrix.Sum() == matrix.GetSize(), "Sum() didn't sum values for the whole matrix!");

  matrix.FillRandom();

  assertTrueOrFail((int)matrix.Sum() != matrix.GetSize(), "FillRandom() should replace 1's with another values!");

  matrix.FillRandom(-0.1, 0.1);

  for (a = 0; a < matrix.GetRange(0); ++a) {
    for (b = 0; b < matrix.GetRange(1); ++b) {
      for (c = 0; c < matrix.GetRange(2); ++c) {
        assertTrueOrFail(matrix[a][b][c].Val() >= -0.1 && matrix[a][b][c].Val() <= 0.1,
                         "FillRandom() didn't fill random values properly for the whole matrix!");
      }
    }
  }

  Matrix<double> matrix2(1, 5);

  matrix2[0][0] = 1;
  matrix2[0][1] = 2;
  matrix2[0][2] = 4;
  matrix2[0][3] = 7;
  matrix2[0][4] = 12;

  assertTrueOrFail(matrix2.Avg() == 5.2, "Avg() didn't calculate valid average for matrix values!");

  assertTrueOrFail(matrix2.Min() == 1, "Min() didn't find the lowest matrix value!");

  assertTrueOrFail(matrix2.Max() == 12, "Max() didn't find the highest matrix value!");

  assertTrueOrFail(matrix2.Med() == 4, "Med() didn't find median of the matrix values!");

  matrix2.SetShape(2, 5);

  assertTrueOrFail(matrix2[0][0].Val() == 1, "SetShape() didn't leave existing values after resize!");
  assertTrueOrFail(matrix2[0][1].Val() == 2, "SetShape() didn't leave existing values after resize!");
  assertTrueOrFail(matrix2[0][2].Val() == 4, "SetShape() didn't leave existing values after resize!");
  assertTrueOrFail(matrix2[0][3].Val() == 7, "SetShape() didn't leave existing values after resize!");
  assertTrueOrFail(matrix2[0][4].Val() == 12, "SetShape() didn't leave existing values after resize!");

  for (b = 0; b < matrix2.GetRange(1); ++b) {
    assertTrueOrFail(matrix2[1][b].Val() == 0, "SetShape() didn't initialize new values with 0 after resize!");
  }

  // Some additional operations to check for memory leakage.
  matrix2.SetShape(2);
  matrix2.SetShape(1, 1);
  matrix2.SetShape(5, 4, 3);
  matrix2.SetShape(2, 6, 2);
  matrix2.SetShape(9, 3);
  matrix2.SetShape(0);
  matrix2.SetShape(2, 3);
  matrix2.SetShape(2, 3, 4);

  Matrix<double> matrix3_labels(2, 2);
  matrix3_labels[0][0] = 1.0;
  matrix3_labels[0][1] = 2.0;
  matrix3_labels[1][0] = 2.0;
  matrix3_labels[1][1] = 3.0;

  Matrix<double> matrix4_prediction(2, 2);
  matrix4_prediction[0][0] = 4.0;
  matrix4_prediction[0][1] = 5.0;
  matrix4_prediction[1][0] = 6.0;
  matrix4_prediction[1][1] = 7.0;

  Matrix<double> matrix5_weights(2);
  matrix5_weights[0] = 1.3;
  matrix5_weights[1] = 0.15;

  // MeanAbsolute() / Weighted average.
  double mean1 = matrix3_labels.MeanAbsolute(MATRIX_OPERATION_AVG, &matrix4_prediction, &matrix5_weights);
  assertTrueOrFail(mean1 == 2.25, "Wrongly calculated MeanAbsoule!");

  Matrix<double> matrix6_weights(1);
  matrix6_weights[0] = 2;

  // MeanAbsolute() / Weighted average.
  double mean2 = matrix3_labels.MeanAbsolute(MATRIX_OPERATION_AVG, &matrix4_prediction, &matrix6_weights);
  assertTrueOrFail(mean2 == 7.0, "Wrongly calculated MeanAbsoule!");

  //  Matrix<double> matrix7_padded(4, 4);
  //  matrix7_padded[0][0] = 1.0; matrix7_padded[0][1] = 2.0; matrix7_padded[0][2] = 2.0; matrix7_padded[0][3] = 3.0;
  //  matrix7_padded[1][0] = 5.0; matrix7_padded[1][1] = 7.0; matrix7_padded[1][2] = 2.0; matrix7_padded[1][3] = 1.0;
  //  matrix7_padded[2][0] = 8.0; matrix7_padded[2][1] = 9.0; matrix7_padded[2][2] = 5.0; matrix7_padded[2][3] = 1.0;
  //  matrix7_padded[3][0] = 5.0; matrix7_padded[3][1] = 3.0; matrix7_padded[3][2] = 2.0; matrix7_padded[3][3] = 1.0;

  Matrix<double> matrix7_padded(4, 2, 2);
  matrix7_padded[0][0][0] = 1.0;
  matrix7_padded[0][0][1] = 2.0;
  matrix7_padded[0][1][0] = 2.0;
  matrix7_padded[0][1][1] = 3.0;

  matrix7_padded[1][0][0] = 5.0;
  matrix7_padded[1][0][1] = 7.0;
  matrix7_padded[1][1][0] = 2.0;
  matrix7_padded[1][1][1] = 1.0;

  matrix7_padded[2][0][0] = 8.0;
  matrix7_padded[2][0][1] = 9.0;
  matrix7_padded[2][1][0] = 5.0;
  matrix7_padded[2][1][1] = 1.0;

  matrix7_padded[3][0][0] = 5.0;
  matrix7_padded[3][0][1] = 3.0;
  matrix7_padded[3][1][0] = 2.0;
  matrix7_padded[3][1][1] = 1.0;

  // ToString().
  assertTrueOrFail(matrix7_padded.ToString(false, 1) ==
                       "[[[1.0,2.0],[2.0,3.0]],[[5.0,7.0],[2.0,1.0]],[[8.0,9.0],[5.0,1.0]],[[5.0,3.0],[2.0,1.0]]]",
                   "Matrix::ToString(): Invalid output!");

  Matrix<double>* ptr_matrix7_padded_result =
      matrix7_padded.GetPooled(MATRIX_OPERATION_AVG, MATRIX_PADDING_SAME, 1, 2, 1, 0, 0, 1, 1, 1);

  delete ptr_matrix7_padded_result;

  // Parse().
  Matrix<double>* ptr_matrix8 = Matrix<double>::Parse(
      "["
      " [[1.000, 2.000], [2.000, 3.000]],"
      " [[5.000, 7.000], [2.000, 1.000]],"
      " [[8.000, 9.000], [5.000, 1.000]],"
      " [[5.000, 3.000], [2.000, 1.000]],"
      "]");
  assertTrueOrFail(ptr_matrix8.ToString(false, 3) ==
                       "[[[1.000,2.000],[2.000,3.000]],[[5.000,7.000],[2.000,1.000]],[[8.000,9.000],[5.000,1.000]],[[5."
                       "000,3.000],[2.000,1.000]]]",
                   "Matrix::ToString(): Invalid output!");
  delete ptr_matrix8;

  // FillIdentity().
  Matrix<double> matrix9_identity(3, 3);
  matrix9_identity.FillIdentity(0.5);
  assertTrueOrFail(matrix9_identity.ToString(false, 1) == "[[0.5,0.0,0.0],[0.0,0.5,0.0],[0.0,0.0,0.5]]",
                   "Matrix::FillIdentity(): Invalid output!");

  return INIT_SUCCEEDED;
}
