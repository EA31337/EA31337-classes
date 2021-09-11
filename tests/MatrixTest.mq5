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
 * Test functionality of Matrix class.
 */

// Defines.
#define USE_MQL_MATH_STAT

// Includes.
#include "../Matrix.mqh"
#include "../Test.mqh"

/**
 * Implements Init event handler.
 */
int OnInit() {
  int a, b, c;

  Matrix<double> _matrix(2, 3, 20);

  assertTrueOrFail(_matrix.GetRange(0) == 2, "1st dimension's length is not valid!");
  assertTrueOrFail(_matrix.GetRange(1) == 3, "2nd dimension's length is not valid!");
  assertTrueOrFail(_matrix.GetRange(2) == 20, "3rd dimension's length is not valid!");

  assertTrueOrFail(_matrix.GetDimensions() == 3, "Number of _matrix dimensions isn't valid!");

  _matrix.Fill(1);

  for (a = 0; a < _matrix.GetRange(0); ++a) {
    for (b = 0; b < _matrix.GetRange(1); ++b) {
      for (c = 0; c < _matrix.GetRange(2); ++c) {
        assertTrueOrFail(_matrix[a][b][c].Val() == 1, "Fill() didn't fill the whole _matrix!");
      }
    }
  }

  _matrix.Add(2);

  for (a = 0; a < _matrix.GetRange(0); ++a) {
    for (b = 0; b < _matrix.GetRange(1); ++b) {
      for (c = 0; c < _matrix.GetRange(2); ++c) {
        assertTrueOrFail(_matrix[a][b][c].Val() == 3, "Add() didn't add value to the whole _matrix!");
      }
    }
  }

  _matrix.Sub(2);

  for (a = 0; a < _matrix.GetRange(0); ++a) {
    for (b = 0; b < _matrix.GetRange(1); ++b) {
      for (c = 0; c < _matrix.GetRange(2); ++c) {
        assertTrueOrFail(_matrix[a][b][c].Val() == 1, "Sub() didn't subtract value from the whole _matrix!");
      }
    }
  }

  _matrix.Mul(4);

  for (a = 0; a < _matrix.GetRange(0); ++a) {
    for (b = 0; b < _matrix.GetRange(1); ++b) {
      for (c = 0; c < _matrix.GetRange(2); ++c) {
        assertTrueOrFail(_matrix[a][b][c].Val() == 4, "Mul() didn't multiply value for the whole _matrix!");
      }
    }
  }

  _matrix.Div(4);

  for (a = 0; a < _matrix.GetRange(0); ++a) {
    for (b = 0; b < _matrix.GetRange(1); ++b) {
      for (c = 0; c < _matrix.GetRange(2); ++c) {
        assertTrueOrFail(_matrix[a][b][c].Val() == 1, "Div() didn't divide value for the whole _matrix!");
      }
    }
  }

  assertTrueOrFail((int)_matrix.Sum() == _matrix.GetSize(), "Sum() didn't sum values for the whole _matrix!");

  _matrix.FillRandom();

  assertTrueOrFail((int)_matrix.Sum() != _matrix.GetSize(), "FillRandom() should replace 1's with another values!");

  _matrix.FillRandom(-0.1, 0.1);

  for (a = 0; a < _matrix.GetRange(0); ++a) {
    for (b = 0; b < _matrix.GetRange(1); ++b) {
      for (c = 0; c < _matrix.GetRange(2); ++c) {
        assertTrueOrFail(_matrix[a][b][c].Val() >= -0.1 && _matrix[a][b][c].Val() <= 0.1,
                         "FillRandom() didn't fill random values properly for the whole _matrix!");
      }
    }
  }

  Matrix<double> matrix2(1, 5);

  matrix2[0][0] = 1;
  matrix2[0][1] = 2;
  matrix2[0][2] = 4;
  matrix2[0][3] = 7;
  matrix2[0][4] = 12;

  assertTrueOrFail(matrix2.Avg() == 5.2, "Avg() didn't calculate valid average for _matrix values!");

  assertTrueOrFail(matrix2.Min() == 1, "Min() didn't find the lowest _matrix value!");

  assertTrueOrFail(matrix2.Max() == 12, "Max() didn't find the highest _matrix value!");

  assertTrueOrFail(matrix2.Med() == 4, "Med() didn't find median of the _matrix values!");

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

  Matrix<double> matrix7_prediction(4, 2, 2);
  matrix7_prediction[0][0][0] = 9.0;
  matrix7_prediction[0][0][1] = 8.0;
  matrix7_prediction[0][1][0] = 7.0;
  matrix7_prediction[0][1][1] = 6.0;

  matrix7_prediction[1][0][0] = 5.0;
  matrix7_prediction[1][0][1] = 4.0;
  matrix7_prediction[1][1][0] = 3.0;
  matrix7_prediction[1][1][1] = 2.0;

  matrix7_prediction[2][0][0] = 1.0;
  matrix7_prediction[2][0][1] = 2.0;
  matrix7_prediction[2][1][0] = 3.0;
  matrix7_prediction[2][1][1] = 4.0;

  matrix7_prediction[3][0][0] = 5.0;
  matrix7_prediction[3][0][1] = 6.0;
  matrix7_prediction[3][1][0] = 7.0;
  matrix7_prediction[3][1][1] = 8.0;

  Matrix<double> matrix7_weights(4);
  matrix7_weights[0] = 1.0;
  matrix7_weights[1] = 0.5;
  matrix7_weights[2] = 1.0;
  matrix7_weights[3] = 1.3;

  // ToString().
  assertTrueOrFail(matrix7_padded.ToString(false, 1) ==
                       "[[[1.0,2.0],[2.0,3.0]],[[5.0,7.0],[2.0,1.0]],[[8.0,9.0],[5.0,1.0]],[[5.0,3.0],[2.0,1.0]]]",
                   "Matrix::ToString(): Invalid output!");

  Matrix<double>* ptr_matrix7_padded_result =
      matrix7_padded.GetPooled(MATRIX_OPERATION_AVG, MATRIX_PADDING_SAME, 1, 2, 1, 0, 0, 1, 1, 1);

  delete ptr_matrix7_padded_result;

  // Parse().
  Matrix<double>* ptr_matrix8 = Matrix<double>::CreateFromString(
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

#ifdef __MQL5__
#ifdef USE_MQL_MATH_STAT
  Matrix<double> matrix_10_initializer_random_normal(4, 4);
  matrix_10_initializer_random_normal.FillRandomNormal(0.0, 1.0);
#endif
#endif

  Matrix<double>* _mean_squared_matrix =
      matrix7_padded.MeanSquared(&matrix7_prediction, MATRIX_OPERATION_AVG, &matrix7_weights);

  assertTrueOrFail(_mean_squared_matrix.ToString(false, 2) == "[[50.00,17.00],[2.25,0.50],[49.00,6.50],[5.85,48.10]]",
                   "Matrix::MeanSquared(): Invalid output!");
  delete _mean_squared_matrix;

  double _mean_squared = matrix7_padded.MeanSquared(MATRIX_OPERATION_SUM, &matrix7_prediction, &matrix7_weights);
  assertTrueOrFail(_mean_squared == 358.4, "Matrix::MeanSquared(): Invalid result!");

  Matrix<double> matrix_11_fill_pos_add(3, 5);
  matrix_11_fill_pos_add.FillPosAdd();
  assertTrueOrFail(matrix_11_fill_pos_add.ToString(false, 1) ==
                       "[[0.0,1.0,2.0,3.0,4.0],[1.0,2.0,3.0,4.0,5.0],[2.0,3.0,4.0,5.0,6.0]]",
                   "Matrix::FillPosAdd(): Invalid result!");

  Matrix<double> matrix_11_fill_pos_mul(3, 5);
  matrix_11_fill_pos_mul.FillPosMul();
  assertTrueOrFail(matrix_11_fill_pos_mul.ToString(false, 1) ==
                       "[[0.0,0.0,0.0,0.0,0.0],[0.0,1.0,2.0,3.0,4.0],[0.0,2.0,4.0,6.0,8.0]]",
                   "Matrix::FillPosMul(): Invalid result!");

  Matrix<double>* ptr_matrix_12_abs = Matrix<double>::CreateFromString("[[2, -5.3], [-1, 4]]");
  ptr_matrix_12_abs.Abs();
  assertTrueOrFail(ptr_matrix_12_abs.ToString(false, 1) == "[[2.0,5.3],[1.0,4.0]]", "Matrix::Abs(): Invalid result!");
  delete ptr_matrix_12_abs;

  Matrix<double>* ptr_matrix_13_poisson_true = Matrix<double>::CreateFromString("[[2, -5.3, 2.1], [-1, 4, 4.1]]");

  Matrix<double>* ptr_matrix_13_poisson_pred = Matrix<double>::CreateFromString("[[1, -5.2, 1.5], [-1.2, 4, 4.4]]");
  Matrix<double>* ptr_matrix_13_poisson_res = ptr_matrix_13_poisson_true.Poisson(ptr_matrix_13_poisson_pred);

  delete ptr_matrix_13_poisson_true;
  delete ptr_matrix_13_poisson_pred;
  delete ptr_matrix_13_poisson_res;

  Matrix<double>* ptr_matrix_14_cos_sim_a = Matrix<double>::CreateFromString(
      "["
      " [1.0, 0.5, 0.3],"
      " [0.5, 0.6, 0.2],"
      "]");

  Matrix<double>* ptr_matrix_14_cos_sim_b = Matrix<double>::CreateFromString(
      "["
      " [1.0, 0.4, 0.1],"
      " [0.7, 0.3, 0.5],"
      "]");

  Matrix<double>* ptr_matrix_14_cos_sim_result_0 = ptr_matrix_14_cos_sim_a.CosineSimilarity(ptr_matrix_14_cos_sim_b, 0);
  assertTrueOrFail(ptr_matrix_14_cos_sim_result_0.ToString(false, 4) == "[0.9892,0.9731,0.7071]",
                   "Matrix::CosineSimilarity(): Invalid result!");

  delete ptr_matrix_14_cos_sim_result_0;
  delete ptr_matrix_14_cos_sim_a;
  delete ptr_matrix_14_cos_sim_b;

  Matrix<double>* ptr_matrix_15_cos_sim_a = Matrix<double>::CreateFromString(
      "["
      " [1.0, 0.5, 0.3],"
      "]");

  Matrix<double>* ptr_matrix_15_cos_sim_b = Matrix<double>::CreateFromString(
      "["
      " [1.0, 0.4, 0.1],"
      "]");

  Matrix<double>* ptr_matrix_15_cos_sim_result_0 = ptr_matrix_15_cos_sim_a.CosineSimilarity(ptr_matrix_15_cos_sim_b, 0);
  assertTrueOrFail(ptr_matrix_15_cos_sim_result_0.ToString(false, 4) == "[1.0000,1.0000,1.0000]",
                   "Matrix::CosineSimilarity(): Invalid result!");

  delete ptr_matrix_15_cos_sim_result_0;
  delete ptr_matrix_15_cos_sim_a;
  delete ptr_matrix_15_cos_sim_b;

  Matrix<double>* ptr_matrix_16_cos_sim_a = Matrix<double>::CreateFromString(
      "["
      " [[1.0, 0.7], [0.5, 0.4], [0.5, 0.3]],"
      " [[0.1, 0.3], [0.2, 0.1], [0.6, 0.4]],"
      "]");

  Matrix<double>* ptr_matrix_16_cos_sim_b = Matrix<double>::CreateFromString(
      "["
      " [[0.8, 0.1], [0.5, 0.7], [0.2, 0.1]],"
      " [[0.3, 0.2], [0.6, 0.6], [0.1, 0.4]],"
      "]");

  Matrix<double>* ptr_matrix_16_cos_sim_result_0 = ptr_matrix_16_cos_sim_a.CosineSimilarity(ptr_matrix_16_cos_sim_b, 0);
  assertTrueOrFail(
      ptr_matrix_16_cos_sim_result_0.ToString(false, 4) == "[[0.9666,0.7634],[0.8797,0.8944],[0.9162,0.9216]]",
      "Matrix::CosineSimilarity(): Invalid result!");

  Matrix<double>* ptr_matrix_16_cos_sim_result_1 = ptr_matrix_16_cos_sim_a.CosineSimilarity(ptr_matrix_16_cos_sim_b, 1);
  assertTrueOrFail(ptr_matrix_16_cos_sim_result_1.ToString(false, 4) == "[[0.9737,0.6186],[0.4836,0.7338]]",
                   "Matrix::CosineSimilarity(): Invalid result!");

  Matrix<double>* ptr_matrix_16_cos_sim_result_2 = ptr_matrix_16_cos_sim_a.CosineSimilarity(ptr_matrix_16_cos_sim_b, 2);
  assertTrueOrFail(
      ptr_matrix_16_cos_sim_result_2.ToString(false, 4) == "[[0.8840,0.9622,0.9971],[0.7894,0.9487,0.7399]]",
      "Matrix::CosineSimilarity(): Invalid result!");

  delete ptr_matrix_16_cos_sim_result_0;
  delete ptr_matrix_16_cos_sim_result_1;
  delete ptr_matrix_16_cos_sim_result_2;
  delete ptr_matrix_16_cos_sim_a;
  delete ptr_matrix_16_cos_sim_b;

  Matrix<double>* ptr_matrix_17_cos_sim_a = Matrix<double>::CreateFromString(
      "["
      " ["
      "  [[1.0, 0.4], [0.7, 0.2]],"
      "  [[0.3, 0.6], [0.3, 0.5]],"
      "  [[1.0, 0.2], [0.4, 0.1]]"
      " ],"
      " ["
      "  [[0.1, 0.5], [0.7, 0.1]],"
      "  [[0.3, 0.3], [0.5, 0.3]],"
      "  [[1.0, 0.1], [0.4, 0.5]]"
      " ]"
      "]");

  Matrix<double>* ptr_matrix_17_cos_sim_b = Matrix<double>::CreateFromString(
      "["
      " ["
      "  [[1.0, 0.5], [0.2, 0.5]],"
      "  [[0.5, 0.6], [0.3, 0.2]],"
      "  [[0.1, 0.2], [0.2, 0.5]]"
      " ],"
      " ["
      "  [[0.1, 0.7], [0.5, 0.1]],"
      "  [[0.2, 0.6], [0.6, 0.2]],"
      "  [[0.6, 0.3], [0.8, 0.1]]"
      " ]"
      "]");

  Matrix<double>* ptr_matrix_17_cos_sim_result_0 = ptr_matrix_17_cos_sim_a.CosineSimilarity(ptr_matrix_17_cos_sim_b, 0);
  assertTrueOrFail(
      ptr_matrix_17_cos_sim_result_0.ToString(false, 4) ==
          "[[[1.0000,0.9985],[0.9191,0.9648]],[[0.9191,0.9487],[0.9971,0.9701]],[[0.8137,0.8682],[0.8575,0.3846]]]",
      "Matrix::CosineSimilarity(): Invalid result!");
  delete ptr_matrix_17_cos_sim_result_0;

  Matrix<double>* ptr_matrix_17_cos_sim_result_1 = ptr_matrix_17_cos_sim_a.CosineSimilarity(ptr_matrix_17_cos_sim_b, 1);
  assertTrueOrFail(ptr_matrix_17_cos_sim_result_1.ToString(false, 4) ==
                       "[[[0.7703,0.9945],[0.8740,0.6211]],[[0.9977,0.9763],[0.9145,0.8281]]]",
                   "Matrix::CosineSimilarity(): Invalid result!");
  delete ptr_matrix_17_cos_sim_result_1;

  Matrix<double>* ptr_matrix_17_cos_sim_result_2 = ptr_matrix_17_cos_sim_a.CosineSimilarity(ptr_matrix_17_cos_sim_b, 2);
  assertTrueOrFail(
      ptr_matrix_17_cos_sim_result_2.ToString(false, 4) ==
          "[[[0.9158,0.9487],[0.9701,0.9312],[0.7474,0.7474]],[[0.9985,0.9985],[0.9762,0.8944],[0.8542,0.4961]]]",
      "Matrix::CosineSimilarity(): Invalid result!");
  delete ptr_matrix_17_cos_sim_result_2;

  Matrix<double>* ptr_matrix_17_cos_sim_result_3 = ptr_matrix_17_cos_sim_a.CosineSimilarity(ptr_matrix_17_cos_sim_b, 3);
  assertTrueOrFail(
      ptr_matrix_17_cos_sim_result_3.ToString(false, 4) ==
          "[[[0.9965,0.6122],[0.9734,0.9037],[0.6139,0.5855]],[[0.9985,0.9985],[0.8944,0.9762],[0.9345,0.7167]]]",
      "Matrix::CosineSimilarity(): Invalid result!");
  delete ptr_matrix_17_cos_sim_result_3;

  delete ptr_matrix_17_cos_sim_a;
  delete ptr_matrix_17_cos_sim_b;

  Matrix<double>* ptr_matrix_18_hinge_a = Matrix<double>::CreateFromString(
      "["
      " [[1.0, 0.7], [0.5, 0.4], [0.5, 0.3]],"
      " [[0.1, 0.3], [0.2, 0.1], [0.6, 0.4]],"
      "]");

  Matrix<double>* ptr_matrix_18_hinge_b = Matrix<double>::CreateFromString(
      "["
      " [[0.8, 0.1], [0.5, 0.7], [0.2, 0.1]],"
      " [[0.3, 0.2], [0.6, 0.6], [0.1, 0.4]],"
      "]");

  Matrix<double>* ptr_matrix_18_hinge_result = ptr_matrix_18_hinge_a.HingeLoss(ptr_matrix_18_hinge_b);

  // Print(ptr_matrix_18_hinge_result.ToString(true, 4));

  assertTrueOrFail(ptr_matrix_18_hinge_result.ToString(false, 4) == "[[0.5650,0.7350,0.9350],[0.9550,0.9100,0.8900]]",
                   "Matrix::HingeLoss(): Invalid result!");

  delete ptr_matrix_18_hinge_result;
  delete ptr_matrix_18_hinge_a;
  delete ptr_matrix_18_hinge_b;

  Matrix<double>* ptr_matrix_19_hinge_a = Matrix<double>::CreateFromString(
      "["
      " ["
      "  [[1.0, 0.4], [0.7, 0.2]],"
      "  [[0.3, 0.6], [0.3, 0.5]],"
      "  [[1.0, 0.2], [0.4, 0.1]]"
      " ],"
      " ["
      "  [[0.1, 0.5], [0.7, 0.1]],"
      "  [[0.3, 0.3], [0.5, 0.3]],"
      "  [[1.0, 0.1], [0.4, 0.5]]"
      " ]"
      "]");

  Matrix<double>* ptr_matrix_19_hinge_b = Matrix<double>::CreateFromString(
      "["
      " ["
      "  [[1.0, 0.5], [0.2, 0.5]],"
      "  [[0.5, 0.6], [0.3, 0.2]],"
      "  [[0.1, 0.2], [0.2, 0.5]]"
      " ],"
      " ["
      "  [[0.1, 0.7], [0.5, 0.1]],"
      "  [[0.2, 0.6], [0.6, 0.2]],"
      "  [[0.6, 0.3], [0.8, 0.1]]"
      " ]"
      "]");

  Matrix<double>* ptr_matrix_19_hinge_result = ptr_matrix_19_hinge_a.HingeLoss(ptr_matrix_19_hinge_b);

  assertTrueOrFail(
      ptr_matrix_19_hinge_result.ToString(false, 4) ==
          "[[[0.4000,0.8800],[0.7450,0.9050],[0.9300,0.9350]],[[0.8200,0.8200],[0.8800,0.8200],[0.6850,0.8150]]]",
      "Matrix::HingeLoss(): Invalid result!");

  delete ptr_matrix_19_hinge_result;
  delete ptr_matrix_19_hinge_a;
  delete ptr_matrix_19_hinge_b;

  Matrix<double>* ptr_matrix_20_hinge_a = Matrix<double>::CreateFromString(
      "["
      " [0.50, 0.15],"
      " [0.75, 0.12],"
      " [0.25, 0.50],"
      "]");

  Matrix<double>* ptr_matrix_20_hinge_b = Matrix<double>::CreateFromString(
      "["
      " [0.25],"
      " [0.12],"
      " [0.15],"
      "]");

  Matrix<double>* ptr_matrix_20_hinge_result = ptr_matrix_20_hinge_a.HingeLoss(ptr_matrix_20_hinge_b);

  assertTrueOrFail(ptr_matrix_20_hinge_result.ToString(false, 4) == "[0.9188,0.9478,0.9438]",
                   "Matrix::HingeLoss(): Invalid result!");

  delete ptr_matrix_20_hinge_result;
  delete ptr_matrix_20_hinge_a;
  delete ptr_matrix_20_hinge_b;

  Matrix<double>* ptr_matrix_21_hinge_a = Matrix<double>::CreateFromString(
      "["
      " [0.50, 0.15],"
      " [0.75, 0.12],"
      " [0.25, 0.50],"
      "]");

  Matrix<double>* ptr_matrix_21_hinge_b = Matrix<double>::CreateFromString(
      "["
      " 0.25,"
      "]");

  Matrix<double>* ptr_matrix_21_hinge_result = ptr_matrix_21_hinge_a.HingeLoss(ptr_matrix_21_hinge_b);

  assertTrueOrFail(ptr_matrix_21_hinge_result.ToString(false, 4) == "[0.9188,0.8913,0.9063]",
                   "Matrix::HingeLoss(): Invalid result!");

  delete ptr_matrix_21_hinge_result;
  delete ptr_matrix_21_hinge_a;
  delete ptr_matrix_21_hinge_b;

  Matrix<double>* ptr_matrix_22_hinge_a = Matrix<double>::CreateFromString(
      "["
      " [[0.50, 0.30], [0.15, 0.35]],"
      " [[0.75, 0.12], [0.24, 0.34]],"
      " [[0.25, 0.50], [0.23, 0.66]],"
      " [[0.55, 0.20], [0.10, 0.14]],"
      "]");

  Matrix<double>* ptr_matrix_22_hinge_b = Matrix<double>::CreateFromString(
      "["
      " [[0.25], [0.15]],"
      " [[0.12], [0.16]],"
      " [[0.13], [0.17]],"
      " [[0.14], [0.18]],"
      "]");

  Matrix<double>* ptr_matrix_22_hinge_result = ptr_matrix_22_hinge_a.HingeLoss(ptr_matrix_22_hinge_b);

  assertTrueOrFail(ptr_matrix_22_hinge_result.ToString(false, 4) ==
                       "[[0.9000,0.9625],[0.9478,0.9536],[0.9513,0.9244],[0.9475,0.9784]]",
                   "Matrix::HingeLoss(): Invalid result!");

  delete ptr_matrix_22_hinge_result;
  delete ptr_matrix_22_hinge_a;
  delete ptr_matrix_22_hinge_b;

  Matrix<double>* ptr_matrix_23_cos_sim_a = Matrix<double>::CreateFromString(
      "["
      " [1.0, 0.5, 0.3],"
      " [0.5, 0.6, 0.2],"
      "]");

  Matrix<double>* ptr_matrix_23_cos_sim_b = Matrix<double>::CreateFromString(
      "["
      " [1.0, 0.5, 0.2],"
      "]");

  Matrix<double>* ptr_matrix_23_cos_sim_result_0 =
      ptr_matrix_23_cos_sim_a.CosineSimilarity(ptr_matrix_23_cos_sim_b, -1);

  assertTrueOrFail(ptr_matrix_23_cos_sim_result_0.ToString(false, 4) == "[0.9964,0.9173]",
                   "Matrix::CosineSimilarity(): Invalid result!");

  Matrix<double> matrix_copied = *ptr_matrix_23_cos_sim_result_0;

  Print(matrix_copied.ToString(true, 4));

  delete ptr_matrix_23_cos_sim_result_0;
  delete ptr_matrix_23_cos_sim_a;
  delete ptr_matrix_23_cos_sim_b;

  Matrix<double> matrix_24_relu("[-1, -2, 0, 1, 2]");
  matrix_24_relu.Relu_();

  assertTrueOrFail(matrix_24_relu.ToString(false, 4) == "[0.0000,0.0000,0.0000,1.0000,2.0000]",
                   "Matrix::Relu(): Invalid result!");

  Matrix<double> matrix_26("[1, 2, 3]");
  Matrix<double> matrix_27(
      "[[1, 1, 1]"
      " [0, 1, 0]"
      " [0, 0, 2]]");

  Matrix<double>* ptr_matrix_27_matmul = matrix_26 ^ matrix_27;

  assertTrueOrFail(ptr_matrix_27_matmul.ToString(false, 2) == "[6.00,2.00,6.00]",
                   "Matrix::operator=(MatrixDimension): Invalid result!");

  Matrix<double> matrix_27_bias("[1, 0, 5]");

  Matrix<double>* ptr_matrix_27_add = ptr_matrix_27_matmul + matrix_27_bias;
  assertTrueOrFail(ptr_matrix_27_add.ToString(false, 0) == "[7,2,11]", "Matrix::operator+(Matrix): Invalid result!");

  Matrix<double>* ptr_matrix_27_sub = ptr_matrix_27_matmul - matrix_27_bias;
  assertTrueOrFail(ptr_matrix_27_sub.ToString(false, 0) == "[5,2,1]", "Matrix::operator+(Matrix): Invalid result!");

  Matrix<double>* ptr_matrix_27_mul = ptr_matrix_27_matmul * matrix_27_bias;
  assertTrueOrFail(ptr_matrix_27_mul.ToString(false, 0) == "[6,0,30]", "Matrix::operator+(Matrix): Invalid result!");

  delete ptr_matrix_27_matmul;
  delete ptr_matrix_27_add;
  delete ptr_matrix_27_sub;
  delete ptr_matrix_27_mul;

  Matrix<double> matrix_27_dim = matrix_27[2];
  Matrix<double> matrix_27_dim_val = matrix_27[2][2];

  assertTrueOrFail(matrix_27_dim.ToString(false, 0) == "[0,0,2]",
                   "Matrix::operator=(MatrixDimension): Invalid result!");

  assertTrueOrFail(matrix_27_dim_val.ToString(false, 0) == "[2]",
                   "Matrix::operator=(MatrixDimension): Invalid result!");

  return INIT_SUCCEEDED;
}
