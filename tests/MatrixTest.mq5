//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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

  Matrix<double> matrix(2, 3, 20);

  assertTrueOrFail(matrix.GetRange(0) == 2, "1st dimension's length is not valid!");
  assertTrueOrFail(matrix.GetRange(1) == 3, "2nd dimension's length is not valid!");
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

  Matrix<double> l1_i(
      "[0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,79.50,77.94,0.00,2.00,0.00,0.00,0.00,0."
      "00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.00,0.00,1.00,2.00,0.00,1.00,0.00,2.00,0.00,0.00,0.00,0.00,0.00,0.00,1."
      "00,0.00,1.00,0.00,0.00,0.00,1.00,0.00,1.00,1.00]");
  Matrix<double> l1_w(
      "[[ 0.06802414,-0.13124417,-0.04978080, 0.00802748, 0.01757991,-0.09855934,-0.06253231, 0.03122447, 0.11640503,  "
      "-0.08797313,-0.07451697,-0.07349315,-0.01920757,-0.08681660, 0.03603749,-0.11662622,-0.11465146, 0.10781013,   "
      "0.04601330,-0.11869494,-0.00883655,-0.07383379,-0.12356956, 0.08394660, 0.02952106, 0.01086511, 0.12630011,   "
      "0.13254958, 0.01658969,-0.13130958,-0.07762549, 0.07593315,-0.12846386, 0.11302549, 0.07812338,-0.02531734,  "
      "-0.12275826,-0.05557810,-0.03900402,-0.06134873, 0.00098449, 0.00432260,-0.00427739,-0.00750504, 0.01956665,   "
      "0.00638379,-0.05212853, 0.06035342,-0.01514503, 0.12603012, 0.00297704,-0.10251677,-0.04097040], "
      "[-0.02125784,-0.03079563, 0.07140799,-0.01517146, 0.00070445, 0.04151216, 0.06988654,-0.07408761, 0.09510107,   "
      "0.08851559, 0.03025059, 0.13722707, 0.01908905,-0.11735330,-0.12988861,-0.02145242, 0.08141516,-0.05842554,   "
      "0.08612294, 0.05623045,-0.05930895,-0.09935471, 0.10974267, 0.12600087,-0.02757318,-0.13238171, 0.13337189,  "
      "-0.12000031, 0.02736658,-0.11844559,-0.04647089,-0.11782771,-0.13186201, 0.11381631, 0.01759159,-0.10965412,  "
      "-0.03407916,-0.13123372, 0.00645338,-0.05297266, 0.05869024, 0.07904740, 0.13722625, 0.09057375,-0.09049158,  "
      "-0.11949019,-0.03714407,-0.07250491, 0.00064551, 0.04854618,-0.13293219, 0.13546543,-0.10160580], [ "
      "0.11300036,-0.02272227, 0.07881275, 0.04067931,-0.03716503, 0.12511338,-0.12749532,-0.06345899, 0.12461724,   "
      "0.03014841, 0.02555483, 0.03767585,-0.05945881,-0.01853644,-0.01323948,-0.13058427,-0.02333729,-0.04899888,   "
      "0.09770855,-0.03100205, 0.07065631,-0.13135217, 0.12669592,-0.12512696, 0.02659548,-0.05114168, 0.11773936,  "
      "-0.00874280, 0.01852352, 0.09954763,-0.12767623,-0.02698802, 0.03777210, 0.11775022,-0.03510492,-0.06872734,  "
      "-0.11902222, 0.11955379, 0.08611891, 0.02421191, 0.05662464, 0.08412246,-0.03740579, 0.11573648, 0.05494718,  "
      "-0.00697636, 0.02998939,-0.04745255, 0.10072042, 0.05018574, 0.09227251, 0.11057937, 0.03807539], "
      "[-0.03458703,-0.10632971,-0.08834437, 0.04377511, 0.08824695, 0.11842059,-0.06819713,-0.07741627,-0.16237539,   "
      "0.02857608,-0.04795560,-0.08457221, 0.11905287, 0.12338003, 0.03398518, 0.11238244, 0.09522281,-0.02117417,  "
      "-0.05121550, 0.01331317,-0.01332923,-0.08474755,-0.02162049, 0.15262055,-0.09104714,-0.00383118, 0.09422712,   "
      "0.02528213, 0.06140643,-0.11730921, 0.10755948,-0.09457747, 0.04887920,-0.07075248, 0.00313721,-0.01427449,  "
      "-0.04300454, 0.06255732,-0.01566263,-0.02327750, 0.09536604, 0.08209554,-0.07293249, 0.08322282, 0.12460402,   "
      "0.08824116, 0.12454552,-0.01163778,-0.09578866, 0.01574161, 0.09101549,-0.05910842, 0.12682372], [-0.01057197, "
      "0.07081331,-0.00997630, 0.07721867,-0.10333233,-0.00622725, 0.09035350, 0.00621731,-0.09489185,   0.03022627, "
      "0.12212897,-0.13714972,-0.02162943, 0.02918551, 0.05539620, 0.02536645, 0.11091726, 0.04914385,   "
      "0.06819079,-0.01341472,-0.07878960, 0.00876270, 0.00013431,-0.12732959,-0.04260543,-0.00422884,-0.04733421,   "
      "0.12311355,-0.08824699,-0.09566057,-0.09842447,-0.05643446,-0.06624573, 0.01341736, 0.01482686, 0.12986198,  "
      "-0.00751125,-0.06150535,-0.07404546,-0.07318554,-0.08134460, 0.05318199, 0.04242334, 0.06099377,-0.02710454,   "
      "0.02120388, 0.07695480,-0.05932154,-0.09146120,-0.07471706, 0.04551839, 0.06987573, 0.04614700], [ "
      "0.03292423,-0.09026390, 0.02912163, 0.05674477, 0.14278956, 0.11522961,-0.02144311, 0.07401627,-0.03147682,   "
      "0.10840506, 0.10846589, 0.00920290,-0.02732196, 0.05087397, 0.08772268,-0.09144465, 0.04858227,-0.15121995,   "
      "0.11456491, 0.07397555, 0.05557800, 0.07556733,-0.12464540, 0.00165036,-0.00240833,-0.08853193, 0.08322188,  "
      "-0.10848705,-0.10292342,-0.12342484,-0.09994559, 0.04021312, 0.08149151, 0.03099517,-0.05428096,-0.01946725,  "
      "-0.05830617, 0.10296135,-0.00501608, 0.05515743,-0.04532680,-0.09771076, 0.11478646,-0.00680543, 0.03603604,  "
      "-0.05897891, 0.08909428,-0.05530223,-0.13331704,-0.11870743,-0.08891041,-0.00639967, 0.01341070], [ 0.02727809, "
      "0.07483605, 0.10182553,-0.08052624,-0.02954473,-0.02461503,-0.00920472, 0.15794489,-0.05508346,  "
      "-0.01366453,-0.02871604, 0.13989231,-0.10347480, 0.07809231, 0.07544303,-0.00524980,-0.06099759,-0.08499423,   "
      "0.01619396,-0.10723319, 0.10056285,-0.05352360, 0.08816505, 0.08702539, 0.09258316,-0.12923430,-0.13090338,  "
      "-0.03505372, 0.10369259,-0.01753805,-0.15672520, 0.09955614,-0.05616540,-0.10510994, 0.01401097, 0.06219862,  "
      "-0.09897984,-0.01022450,-0.03497517,-0.10895923, 0.09586296,-0.13603354,-0.12466437, 0.10424981, 0.07046165,  "
      "-0.04632833, 0.03249953,-0.13664962, 0.13398702,-0.03439471,-0.04930557,-0.04766618, 0.00266937], "
      "[-0.11726335,-0.03008622, 0.11985776, 0.11564086,-0.08332565, 0.13597766,-0.04116043,-0.08968718,-0.11739476,   "
      "0.11991923,-0.03476318, 0.12287489, 0.07707302, 0.03987983, 0.00826799,-0.09825064,-0.10197740,-0.00748368,   "
      "0.09278359, 0.10448536,-0.05908997,-0.06192626,-0.13712955,-0.06366429, 0.11915667,-0.09958091,-0.13498303,   "
      "0.01872802,-0.10110992, 0.06327654,-0.12488671, 0.07580090,-0.00117126,-0.02226671,-0.07167201,-0.01166450,  "
      "-0.06507347,-0.06545721,-0.00435283,-0.01802360, 0.01542001, 0.07173932, 0.09678675,-0.06882939,-0.09478207,   "
      "0.08840936, 0.05146137,-0.11637104,-0.12081230,-0.08150142,-0.08046771, 0.02997403, 0.00123768], [ "
      "0.10635741,-0.10292839,-0.00111944,-0.04436439,-0.09359609,-0.03381107,-0.05000602,-0.04474566, 0.02675910,  "
      "-0.07173415, 0.06419258, 0.00218382, 0.04971643, 0.11228374, 0.07740343,-0.08621137,-0.08586974,-0.12424123,   "
      "0.02471158,-0.04105853, 0.01352917, 0.00947511, 0.06473719,-0.06081261,-0.08936016, 0.09915202, 0.13113634,  "
      "-0.07762514,-0.01014382, 0.12997255, 0.01171622, 0.01192396,-0.04876049, 0.08071517, 0.11069661, 0.10511643,  "
      "-0.01505644,-0.13091658,-0.11693706,-0.08901387,-0.05701920,-0.10813237,-0.10060804,-0.03672954, 0.09851717,   "
      "0.09704069, 0.09021839,-0.11163472, 0.12462673,-0.03274911, 0.10418348,-0.11751629, 0.10209840], [ 0.10701114, "
      "0.06558776,-0.08019511, 0.15085280, 0.08422010,-0.05426683, 0.12504442, 0.07862443, 0.11768061,   0.09900886, "
      "0.06201933,-0.09430263, 0.12795027,-0.11039394,-0.05351437, 0.04782097, 0.14879704,-0.03669698,   0.17617606, "
      "0.14988057,-0.08669297,-0.08721446,-0.03841083,-0.01906421, 0.13667913, 0.05502598, 0.02085848,  -0.01648694, "
      "0.06125334,-0.05444537,-0.08837208, 0.01542107, 0.05394542, 0.03115705, 0.03516599, 0.03872309,   "
      "0.05758746,-0.07206801,-0.09932902, 0.09716669,-0.12970757, 0.04288187,-0.02220808,-0.03249855,-0.05129860,  "
      "-0.01271715,-0.02415795, 0.13304074,-0.07574080,-0.09964278, 0.00527076,-0.04848608, 0.10193325], [-0.02569991, "
      "0.06246859,-0.02137357,-0.11245700, 0.10227193,-0.10170170,-0.01158063, 0.02379413,-0.04369513,  -0.07954060, "
      "0.02764687,-0.08369332,-0.13691722, 0.01359506,-0.09082132,-0.12433916,-0.12267565, 0.10636948,  "
      "-0.11089977,-0.07257243,-0.10959125, 0.01604064,-0.11135147, 0.11720730,-0.09448577, 0.02042368,-0.10880521,   "
      "0.11707942,-0.12703213, 0.00517211,-0.06665927, 0.07153744,-0.11362818, 0.09167938, 0.00760452, 0.09855125,   "
      "0.10463141, 0.09938801,-0.06908837,-0.04705871,-0.12851508, 0.06499348, 0.01640721,-0.06137117,-0.04848105,   "
      "0.11068204, 0.04232972, 0.05010145,-0.02519160, 0.01055279,-0.09958680, 0.02656678, 0.08082917], "
      "[-0.12401903,-0.03360629,-0.10138307, 0.10614015,-0.13668460, 0.04772716,-0.10228359,-0.03609688,-0.02187626,   "
      "0.08696053,-0.02938422, 0.09082464, 0.05235606, 0.01835147,-0.11397146,-0.05716566, 0.03157606, 0.01315620,  "
      "-0.02259334, 0.09409487,-0.09260091, 0.10251135,-0.02448870,-0.11020254,-0.09644208,-0.01934921, 0.02168851,  "
      "-0.08842877, 0.05352265, 0.01462416, 0.11854944, 0.03702006, 0.12999283,-0.13403162, 0.04233803,-0.03465561,   "
      "0.08960196,-0.11247370, 0.01504680, 0.13104899, 0.07050613,-0.09114886,-0.05108322,-0.09764200,-0.03501540,   "
      "0.12502144,-0.02350308,-0.10701736,-0.08747951,-0.12194410, 0.06499842,-0.03736549,-0.03626550], "
      "[-0.04815856,-0.08642715, 0.05379608,-0.04476580,-0.12157068, 0.02236210, 0.05239261,-0.04741903,-0.08494442,   "
      "0.11398391,-0.02806883,-0.02428949,-0.10427625, 0.03388730, 0.07789993,-0.04211189, 0.00804957,-0.05129865,   "
      "0.06494874, 0.08670358, 0.03341576,-0.12095443,-0.02492755,-0.11481954,-0.10328609,-0.05025177, 0.09148442,  "
      "-0.00750861,-0.08260678, 0.02261948,-0.11714214,-0.09096366,-0.11649249, 0.04258012,-0.11601449, 0.03232170,  "
      "-0.15099092, 0.09118363,-0.10105805,-0.15171641,-0.10537331, 0.03352786, 0.09634647, 0.00760321, 0.01936288,  "
      "-0.13492371,-0.10319242, 0.08912235,-0.02019038,-0.06891721, 0.06790869,-0.06081223,-0.06165602], [ "
      "0.09374589,-0.07481493, 0.00178639,-0.01697953,-0.04992815,-0.04475159,-0.13181323, 0.09835552,-0.02098479,  "
      "-0.04443204,-0.09033611,-0.10291919, 0.04237800,-0.12925275, 0.06530396,-0.13560215,-0.13028501,-0.00718443,   "
      "0.03086166,-0.12005499,-0.03595651, 0.09487735,-0.13003033, 0.01426763,-0.12198908,-0.01013251, 0.13211448,   "
      "0.00821318, 0.04456850, 0.01678672,-0.07802921, 0.00002618,-0.07625718, 0.05876014,-0.05246657, 0.07686034,   "
      "0.11896773, 0.04888701, 0.13524432, 0.01618070,-0.04467753, 0.07879374, 0.01488549,-0.00139759,-0.02176023,  "
      "-0.01888153,-0.06880563, 0.01543277, 0.12168697,-0.01725635, 0.03084056, 0.12666431,-0.12113757], [-0.03625885, "
      "0.15779099, 0.04352249, 0.07386183,-0.04968238, 0.16138022,-0.06929518,-0.06424019, 0.04585746,   "
      "0.07671190,-0.09550934, 0.11246267,-0.01332715,-0.10217567, 0.08990486, 0.13466941,-0.11023328,-0.00565988,   "
      "0.07844716,-0.04794368, 0.00305182, 0.04117291,-0.14259867,-0.03793554,-0.11872958, 0.12102890, 0.01327896,  "
      "-0.05278715, 0.00625498,-0.01655586,-0.01093487,-0.06894867, 0.12206979,-0.08605640, 0.06388444, 0.13795890,  "
      "-0.00111993, 0.08630704,-0.09899823, 0.16531613,-0.00833236,-0.09977796, 0.04517350,-0.05619408,-0.09759402,  "
      "-0.00416098, 0.03384679,-0.04561040, 0.04494869, 0.03896776, 0.10817555, 0.07292911, 0.00818605], [ "
      "0.06794277,-0.02102062, 0.03542487, 0.11342282,-0.13397004,-0.11534550, 0.05972064, 0.04904585,-0.01549452,   "
      "0.01908764,-0.08076426, 0.06561270,-0.09074937, 0.05454018, 0.03723717, 0.07723289, 0.09400365,-0.09826633,  "
      "-0.01007809, 0.11550948,-0.11749137,-0.07877653,-0.13942634,-0.14278102,-0.08852274,-0.09546294, 0.00400559,   "
      "0.07150315,-0.04623332,-0.13341798, 0.08040691, 0.01449607, 0.04712339,-0.07118663,-0.10455604,-0.05421258,   "
      "0.10709841, 0.08420550,-0.02912724,-0.01483654, 0.04264478,-0.02895463,-0.01964119, 0.06000723,-0.05712007,  "
      "-0.03875425, 0.00824266,-0.00495695,-0.01088425, 0.08527301, 0.07238318, 0.09395819, 0.05023308], [ 0.10237864, "
      "0.09146863,-0.08802321, 0.10693003,-0.02271896, 0.10848566, 0.00656376,-0.06941365, 0.06125997,  "
      "-0.07228688,-0.09305692, 0.01098415,-0.03828559, 0.00531366, 0.01791207, 0.05800388,-0.05333420, 0.09755655,   "
      "0.15110216,-0.00067307, 0.07753287, 0.05140190, 0.03621636, 0.07263546, 0.11401688,-0.13594568, 0.04696019,  "
      "-0.00613787,-0.05815681, 0.02592907, 0.12598376,-0.06354667,-0.00262259, 0.08642568, 0.07138128, 0.13277200,   "
      "0.01843260,-0.00845975, 0.00047413, 0.05048775, 0.07829318,-0.02882180, 0.08062436, 0.10998835,-0.07314401,  "
      "-0.05618824,-0.03970600, 0.14520307,-0.09958805,-0.02497145,-0.06323166,-0.07601151,-0.03605627], [ "
      "0.04985909,-0.00273208,-0.10611066,-0.11853589, 0.05648290, 0.12126391,-0.07776535, 0.09593309,-0.01100649,   "
      "0.06176906, 0.08938487, 0.11127479,-0.06093476,-0.07117131,-0.10351646,-0.13154902, 0.06062719,-0.00757973,  "
      "-0.03805357, 0.08971146, 0.07619087,-0.11600452, 0.09336501, 0.02242586, 0.07560956, 0.03231540, 0.11939232,   "
      "0.01495965,-0.13367341,-0.13617896, 0.13117296,-0.04910980, 0.13593183, 0.05313778, 0.01340809, 0.13428196,   "
      "0.03726542, 0.02551407, 0.07069683, 0.12661816, 0.04704573, 0.13148983, 0.02475142, 0.05183661,-0.03099368,  "
      "-0.04817124,-0.00343444,-0.11664066,-0.01029424,-0.11542777,-0.13106152, 0.09114642,-0.12956837], [-0.09232252, "
      "0.09459441,-0.02161083, 0.08908652,-0.03719251,-0.03737181,-0.05666500,-0.11424404, 0.00989770,  "
      "-0.13652690,-0.04371068,-0.06106646,-0.01024366,-0.03721749, 0.08834144, 0.10421614,-0.03153692,-0.07548818,  "
      "-0.10144682,-0.11460846, 0.01945676,-0.07732578,-0.10148606, 0.09692433,-0.08553604, 0.12991051, 0.03570370,  "
      "-0.11063012, 0.02283291, 0.00402862, 0.13986664,-0.05665291, 0.07702560, 0.05624860,-0.15064032,-0.00664378,   "
      "0.08455805, 0.04783555, 0.01878016, 0.11816696, 0.09537356, 0.02269041,-0.01459253, 0.03958517,-0.13176493,   "
      "0.01285894,-0.08170719, 0.00355135,-0.04009422, 0.08122379, 0.05556860,-0.14508095, 0.00408745], "
      "[-0.03366621,-0.03573804,-0.08961058, 0.03143570, 0.03812644, 0.03371687,-0.01104238,-0.13358995,-0.07089589,   "
      "0.10471773, 0.08985174, 0.01477698, 0.04191278, 0.01698920,-0.05287206, 0.00353696,-0.08935397, 0.03542972,   "
      "0.04405354,-0.08868575, 0.10898466, 0.09733552, 0.01707483,-0.06799988,-0.13317692, 0.06396873,-0.02819197,  "
      "-0.08690090,-0.00814719, 0.12691735,-0.05783973, 0.08210395, 0.01826635,-0.12125764, 0.04684766,-0.12099886,   "
      "0.06928650,-0.01666442,-0.06534276, 0.11469471, 0.05806336,-0.07687342, 0.05020233, 0.06449718, 0.13111700,  "
      "-0.11735875,-0.13469082, 0.12800746,-0.11263224,-0.01208816, 0.13269602,-0.01371651, 0.00394709], [-0.11158197, "
      "0.11766168, 0.11890528,-0.06941244, 0.12350151, 0.06127004, 0.03182995,-0.07515318, 0.06138763,   0.05117484, "
      "0.13555826,-0.12598568, 0.09944044,-0.02652468,-0.05869026,-0.05235185,-0.09237285, 0.02123139,   0.11123948, "
      "0.03760839, 0.00043352,-0.09780782,-0.04365963, 0.08333463, 0.13427386, 0.12267559, 0.06868483,  "
      "-0.05331272,-0.01227161,-0.11889632, 0.12505738, 0.09649312, 0.02650958,-0.10774213, 0.13083990, 0.06051277,  "
      "-0.02239296, 0.13004656, 0.12864222,-0.00163139,-0.12860125,-0.09224183,-0.05817347, 0.11515962, 0.12486650,  "
      "-0.08794560, 0.00549630,-0.08738384,-0.04785057,-0.13348663,-0.05824792,-0.10088099, 0.12149376], "
      "[-0.15021631,-0.00036487, 0.12644702,-0.09378199, 0.01608420,-0.04601755,-0.05571815, 0.05144025, 0.07849532,   "
      "0.00319456,-0.05636176, 0.15678620, 0.03157282,-0.05487556,-0.00945336, 0.11046776,-0.04940422,-0.00503006,  "
      "-0.06868095,-0.05726519, 0.03237692,-0.14964448, 0.08096192,-0.06308141, 0.02994557, 0.00346240,-0.09115604,   "
      "0.10608497, 0.01262448, 0.00336604, 0.08387472, 0.08235122,-0.07593264, 0.07405034,-0.02497068,-0.12612079,   "
      "0.11746942,-0.12028518,-0.04556769,-0.05271334, 0.02758613,-0.03685797, 0.08300140, 0.01323650,-0.00631582,   "
      "0.03300051,-0.11424401, 0.04163294, 0.07726669,-0.14460072,-0.08301788,-0.04199857,-0.06049171], [ "
      "0.01700803,-0.05474933, 0.09844834,-0.05941216, 0.05552847, 0.08712328,-0.04989234, 0.10114691,-0.11385623,   "
      "0.05014145,-0.03509964,-0.06666857,-0.09128858, 0.13636036,-0.01414787,-0.13546380,-0.12572016,-0.08635394,   "
      "0.11235911, 0.08787729,-0.00057722, 0.00225721, 0.04101739, 0.05531702,-0.13103487,-0.03830539, 0.00531385,   "
      "0.03450913,-0.10576350, 0.10167129,-0.10417915, 0.03595117,-0.00661099, 0.13188702, 0.12664422, 0.07089507,   "
      "0.00703123,-0.05320512,-0.02747723, 0.00565672, 0.09903543, 0.01562090,-0.11380854,-0.10861959, 0.01575139,  "
      "-0.04311356, 0.03716526,-0.11645738,-0.03857304,-0.12127893, 0.12158515, 0.06850928,-0.04271920], [ "
      "0.12059412,-0.02946676,-0.03572542,-0.01489263, 0.03948082,-0.02385563,-0.05918943, 0.04942842, 0.06899571,   "
      "0.05436757,-0.12991937,-0.08990797,-0.03323067,-0.03390840,-0.00340054,-0.09035295,-0.03475026,-0.10947439,  "
      "-0.12946630,-0.13392070, 0.09329285,-0.00079104, 0.04118766, 0.04985309,-0.02039838, 0.11594572, 0.04466803,  "
      "-0.00911752, 0.07581501, 0.11286256, 0.03980587,-0.11618076, 0.05974794,-0.09901836,-0.12825650, 0.12342520,  "
      "-0.02357836,-0.10507596, 0.07854169,-0.11774621, 0.02996076,-0.02105540, 0.04833176,-0.04113818,-0.10420865,  "
      "-0.12158643,-0.08535611,-0.08779144,-0.08438354,-0.11838491,-0.08512967, 0.03334137, 0.07937622], [ "
      "0.09861746,-0.05329113,-0.13508545,-0.11621174,-0.00248060, 0.10403319, 0.09514663, 0.05272486, 0.01984575,  "
      "-0.02680842, 0.02838741, 0.08517627, 0.10147022, 0.08641116,-0.04751301,-0.02422461, 0.11736601,-0.05627535,   "
      "0.07587624, 0.11792917, 0.06851018,-0.02106881,-0.05273249, 0.04753421,-0.11589324,-0.03276026, 0.05580232,   "
      "0.03039218,-0.12280785, 0.02110870, 0.06214429, 0.00601204,-0.02101951, 0.03509922, 0.05797566, 0.02052702,  "
      "-0.12602693, 0.04578019, 0.08571978, 0.11845684,-0.10922395, 0.01177423, 0.12654981,-0.03283385, 0.01016503,  "
      "-0.00433846, 0.04761730, 0.12263660, 0.06825853, 0.11107253, 0.03592630,-0.08367135,-0.11282050], [-0.01767942, "
      "0.05884875, 0.06349166, 0.08045880,-0.01645367, 0.08793780, 0.04971013,-0.05712449, 0.10777595,   0.03194797, "
      "0.13331245, 0.06399421,-0.00657400, 0.10318788, 0.10705853, 0.10387599,-0.02773596,-0.04881955,   "
      "0.11852134,-0.04802230, 0.11341248, 0.13245012, 0.03526736, 0.00337666, 0.03386729,-0.10377960,-0.08125610,   "
      "0.00812257,-0.05739218,-0.05180598, 0.00985418, 0.09521556, 0.06197083, 0.02699471,-0.09136678,-0.07496149,   "
      "0.01523921,-0.02550413,-0.03087885,-0.09304295,-0.09808102, 0.02565820, 0.03255780, 0.04140821,-0.11739324,  "
      "-0.04028466,-0.11341853,-0.10924779,-0.08503936,-0.08190686,-0.02306535, 0.01868775, 0.09597080], [ 0.11828826, "
      "0.10449856, 0.10434063,-0.11516419,-0.04995411, 0.12407968, 0.02508915,-0.01296563,-0.12701830,   "
      "0.06002145,-0.03355768,-0.05157544,-0.10943904, 0.05557337,-0.01238567,-0.04390554,-0.01831055, 0.01694854,   "
      "0.03040575, 0.07016622, 0.03447556,-0.04466420, 0.08878387, 0.02120773, 0.03201502, 0.00459032, 0.10356073,  "
      "-0.08863622, 0.11305556, 0.02353328, 0.11542833, 0.09730096,-0.01268430,-0.09359636, 0.11644341, 0.08319753,   "
      "0.12158065, 0.12067061,-0.02806046,-0.00043761, 0.10788254, 0.13270241, 0.07018273,-0.11554862, 0.10781559,   "
      "0.11737670,-0.06444419, 0.02576532, 0.02001150,-0.02135429, 0.09920710, 0.10117576,-0.12838840], [-0.08809599, "
      "0.07301812,-0.04751961,-0.11805818, 0.08974362, 0.02955712, 0.06961170, 0.00284906,-0.03984975,  -0.07589677, "
      "0.09419017, 0.13428262,-0.07510012,-0.05918470,-0.04677160,-0.09130669,-0.06375395, 0.04160827,  -0.08172181, "
      "0.05428508, 0.08889627, 0.07852118,-0.11067583,-0.02991489,-0.09323029, 0.11802226, 0.09802718,   "
      "0.00634564,-0.04110533, 0.05151692,-0.05403733,-0.05799364,-0.02233195,-0.10889052, 0.07679585, 0.00790914,   "
      "0.13136695, 0.11995476,-0.02159879, 0.01230730,-0.01645121,-0.03680410,-0.04174949,-0.11957279, 0.09130524,  "
      "-0.07840494, 0.06400369, 0.00155944,-0.02131865, 0.08295516,-0.04365707, 0.00650920, 0.05453952], [ 0.04390045, "
      "0.09090286,-0.02254067, 0.01867766,-0.06659081, 0.08119642, 0.03547713, 0.00948712,-0.09584820,   "
      "0.03636979,-0.15972491, 0.08871767,-0.04617235,-0.07828926,-0.05130306, 0.10873765, 0.10973700,-0.11497915,  "
      "-0.12622753,-0.13603556,-0.05024055,-0.11238339,-0.11655117,-0.11667892, 0.11324105, 0.02411304, 0.05151960,  "
      "-0.05198799, 0.09522700,-0.11494246,-0.01747657, 0.03268222,-0.10850207,-0.04211028,-0.04616284,-0.07589902,   "
      "0.04747404, 0.01452600, 0.06491998, 0.11652093, 0.03955122, 0.07737257,-0.14109869, 0.07117904,-0.10581523,  "
      "-0.14801979,-0.01497844,-0.03817135,-0.07535976,-0.15146172, 0.09553795, 0.03713001, 0.11012591], "
      "[-0.15931349,-0.01766126, 0.09121593,-0.02787914, 0.09497557, 0.01253882,-0.01267341, 0.03756469,-0.11404545,  "
      "-0.09110974,-0.09422193,-0.01428208,-0.09211653, 0.04517337, 0.09047228, 0.02680383, 0.07268127, 0.04772193,  "
      "-0.15221718, 0.11150352,-0.13305607,-0.09445821,-0.11555434, 0.09018553,-0.05239811, 0.08019928, 0.10731827,  "
      "-0.11228906, 0.03894399, 0.01576965,-0.15761308,-0.03614972, 0.04299376, 0.08908921, 0.03955255,-0.12739107,   "
      "0.02704647, 0.01117300, 0.01645188, 0.03823282, 0.03152319, 0.01674472,-0.09067143,-0.04211429, 0.04882352,   "
      "0.00498432,-0.02626223,-0.03904908,-0.02153376, 0.00802772,-0.13699174, 0.01355288, 0.06195430], "
      "[-0.12118361,-0.04368200, 0.09482280, 0.11703667,-0.12531632, 0.11948115,-0.14064083, 0.15221830, 0.04893652,   "
      "0.10196643, 0.04132460, 0.07265482,-0.09956610, 0.03694890, 0.04492108, 0.04389255, 0.05935287, 0.14005539,  "
      "-0.14001383,-0.11289057,-0.06862210,-0.07707804,-0.14468813,-0.10092571,-0.12807421, 0.09219006, 0.06657004,   "
      "0.09060346, 0.05963791,-0.12334801,-0.01637788,-0.03175305, 0.08437565, 0.11338618, 0.09021912, 0.07644834,   "
      "0.01135390,-0.01380549, 0.00131910, 0.07242680, 0.04169910,-0.02738515,-0.00658659, 0.06989700, 0.09939717,   "
      "0.13425942,-0.10613339, 0.02174312, 0.11234641,-0.00047938, 0.06820713, 0.07077432, 0.04964239], [ "
      "0.01926347,-0.08949852, 0.12567650,-0.06215981, 0.00305003, 0.05628357,-0.03276069, 0.01435849, 0.03924158,   "
      "0.03448375, 0.06774057,-0.11657177,-0.12983562,-0.02958943,-0.11194588,-0.07806358, 0.04738602,-0.07194369,  "
      "-0.00085980,-0.03277919, 0.09135212,-0.08450150,-0.06293926, 0.07331996,-0.08382650, 0.01205766,-0.00327886,   "
      "0.12647593,-0.12117051,-0.04819809,-0.02149155, 0.02270850,-0.03382768,-0.10400002,-0.11922096,-0.12552187,  "
      "-0.03483344, 0.02608566,-0.03186583,-0.02044569,-0.06532600,-0.10648496,-0.11297089, 0.08846892,-0.06452993,   "
      "0.11766151, 0.05433100, 0.05345373,-0.03915193, 0.00763701,-0.00398066, 0.03336577, 0.05925419], [ "
      "0.05604072,-0.08840879, 0.00246742, 0.15423541,-0.09407981, 0.00852299, 0.04469969, 0.06935927,-0.04791272,   "
      "0.09660448, 0.13072741, 0.03209898, 0.06412369, 0.06106030, 0.13841102, 0.03101248, 0.04551879,-0.11793125,   "
      "0.10109022, 0.14395972,-0.09566404,-0.02955816,-0.02337200, 0.06086677,-0.02870421, 0.04126706, 0.14798975,  "
      "-0.03407637, 0.10015106,-0.03834036,-0.03677544,-0.11479332, 0.07440913,-0.11208784,-0.05757186, 0.07343656,  "
      "-0.06594845, 0.13174929, 0.07715949, 0.11384146, 0.02571320,-0.12234011, 0.02655974, 0.13243075,-0.12323093,  "
      "-0.08158467, 0.10081933, 0.03888352, 0.15096553, 0.05921939,-0.04604138, 0.10240576, 0.06737926], [-0.05836464, "
      "0.02520245,-0.12132576,-0.10426253,-0.13049503, 0.05522655,-0.08547537,-0.07702699,-0.04186292,   "
      "0.11554074,-0.05501940, 0.03129381, 0.02902563,-0.12910257, 0.13893399,-0.11494481, 0.09076911, 0.14173973,   "
      "0.08984663,-0.10180774,-0.10080940, 0.01483812,-0.11181638, 0.03276005, 0.09974157, 0.12389679, 0.00565994,   "
      "0.06354333, 0.12743063,-0.04216190, 0.06394411, 0.00958110,-0.09104525, 0.04957543, 0.06087204, 0.08082007,  "
      "-0.06959872,-0.02216409,-0.07988244, 0.07898550, 0.08260627,-0.01362268, 0.07070242,-0.03130388,-0.09539829,  "
      "-0.08821203,-0.10661659, 0.05350483, 0.09140382,-0.03801434,-0.04224153, 0.09748241, 0.06739558], "
      "[-0.00187610,-0.06436701,-0.08800271,-0.04273463,-0.02068282, 0.02227327, 0.00054151, 0.06034796, 0.10200505,  "
      "-0.13570246, 0.11307360,-0.03824781, 0.00940909,-0.05323359,-0.11216797, 0.13309723, 0.03239490, 0.07431357,   "
      "0.16826326,-0.09078462,-0.03626469, 0.04064687,-0.09186204, 0.10698906, 0.04376189,-0.01605794, 0.11319729,  "
      "-0.09758485, 0.05298267, 0.11969123,-0.08516469, 0.09070750,-0.03809563, 0.05635855, 0.02129602, 0.05091165,   "
      "0.09891903, 0.08309124,-0.15195379, 0.03474834,-0.05915465, 0.05399574, 0.05737485,-0.03236380,-0.05864619,  "
      "-0.08790594,-0.02187164, 0.12282345,-0.02966354, 0.16632563, 0.03845943,-0.08820260,-0.07839604], [-0.09964023, "
      "0.13200250, 0.00336861,-0.05277379,-0.05257782, 0.07747961,-0.05482324, 0.07857487,-0.07945187,   "
      "0.02115515,-0.02463942, 0.11635520,-0.08227196, 0.04020720,-0.13273144,-0.09394192,-0.08520809,-0.10270002,  "
      "-0.13628687, 0.01857213,-0.04576004,-0.09102235,-0.02785604,-0.10449488, 0.13421197, 0.06762644, 0.04384232,  "
      "-0.06093800, 0.13550282,-0.07127354,-0.05183350,-0.07105233,-0.11910904,-0.09733292,-0.03429608, 0.03103311,  "
      "-0.00325905, 0.09725683, 0.12653887, 0.00784123, 0.10246075,-0.04141907, 0.10708380, 0.09079184,-0.04557004,  "
      "-0.03874882, 0.03373007, 0.13525558,-0.04753526,-0.01343874,-0.00527455, 0.04928547,-0.07340416], [ "
      "0.04592670,-0.06511007, 0.07466500,-0.12508863,-0.03358992,-0.11250532,-0.01952935, 0.08606619, 0.11490501,  "
      "-0.12079372, 0.01692433,-0.10990924,-0.13652205,-0.07573877,-0.06410567, 0.01080734, 0.07933261, 0.08794499,  "
      "-0.06341840,-0.10763183, 0.09005210, 0.08395713, 0.12838419,-0.05996911,-0.03204084, 0.04946411, 0.12626927,  "
      "-0.08648436, 0.03786449, 0.03164503,-0.11716249,-0.04819904,-0.13487665, 0.07151134,-0.10510355, 0.00488690,   "
      "0.10454290,-0.05904460,-0.02264744,-0.03617194, 0.10397994,-0.02068319, 0.03673149,-0.00210124, 0.09149528,   "
      "0.01777726, 0.04538449,-0.06527661,-0.06885005,-0.03880158,-0.06371389, 0.12001780,-0.03235384], [-0.02542003, "
      "0.11489494,-0.13203256,-0.02202869, 0.01182101, 0.09574303, 0.13196723, 0.08662537, 0.10402967,   0.00065538, "
      "0.03044107,-0.01454618,-0.09726085,-0.02912956,-0.03865473,-0.12856492,-0.01350233,-0.03110154,  -0.04286840, "
      "0.03216758,-0.02239781,-0.01153182, 0.08259089, 0.02504561,-0.05280808,-0.06153946,-0.01842150,  "
      "-0.08518076,-0.08292289,-0.09119552,-0.07516661, 0.13504733,-0.07530098, 0.05970780, 0.01672458, 0.08169335,  "
      "-0.09785711, 0.05158227,-0.10772555, 0.07115925,-0.12123924, 0.11305233, 0.12496053, 0.10667489, 0.05809668,   "
      "0.11560860, 0.03702108,-0.07052425, 0.00546915, 0.10190601, 0.02768643, 0.11313858, 0.11322160], [-0.11119987, "
      "0.03098745,-0.04933931, 0.11874132,-0.11962885, 0.03959526,-0.13711825,-0.07843037,-0.05828457,   0.06051091, "
      "0.03267210,-0.03188841,-0.00780830, 0.06050497,-0.12799536,-0.11747914,-0.09419065,-0.09144187,   0.03230333, "
      "0.00163814, 0.06594753,-0.08367491, 0.13592111,-0.02021435,-0.04805432, 0.08148359, 0.11872948,  "
      "-0.10799797,-0.07975369,-0.09055639, 0.06458372,-0.10278726,-0.01568184,-0.09993575,-0.11240784, 0.04401530,   "
      "0.04407168,-0.12001520,-0.09596913,-0.03165566, 0.10924926, 0.00786537,-0.02609059,-0.09887449,-0.02807795,   "
      "0.04327485,-0.06309289,-0.02468206,-0.06344646, 0.08569788,-0.00099784, 0.13414760, 0.01726018], "
      "[-0.14805272,-0.05360768, 0.00603855, 0.10201205,-0.08533400,-0.13228722,-0.12477366,-0.09948295, 0.11004051,  "
      "-0.10587835, 0.03501422,-0.00762998,-0.02040552,-0.00179700, 0.09804206, 0.04055594, 0.06160487,-0.03925381,  "
      "-0.10310376,-0.11590027, 0.04886054,-0.02130474, 0.05886726,-0.06456777, 0.05043420,-0.04233819,-0.10697596,   "
      "0.01095052,-0.14528669,-0.01673687, 0.09069990, 0.05138524, 0.10202447,-0.08210085, 0.00111263, 0.07831488,   "
      "0.07394639, 0.04494820,-0.05051894,-0.11895155, 0.05283631, 0.01214446,-0.01377143,-0.09414651, 0.08255257,   "
      "0.08978228, 0.10443273,-0.00391770, 0.04297069,-0.05794193,-0.10668816, 0.05285238, 0.00832306], [ 0.09419083, "
      "0.04501262, 0.06462205,-0.13541435,-0.02085890, 0.07114956,-0.04775082,-0.12994134, 0.02379473,  "
      "-0.09853925,-0.09407645, 0.00780793,-0.01081199,-0.01171367,-0.12937036, 0.03823467, 0.08712901, 0.12915327,   "
      "0.12728205, 0.13361785, 0.07977440, 0.12288887,-0.03094462,-0.12056050, 0.12127464, 0.10987800,-0.03694071,  "
      "-0.06308835, 0.10119957,-0.02723639,-0.05844790,-0.12494955,-0.11991798,-0.08923791,-0.06460620, 0.00524786,   "
      "0.12587792, 0.05055516, 0.06338214,-0.04012221,-0.03843069, 0.03286256, 0.06403331,-0.02275714,-0.08841788,  "
      "-0.01424546, 0.01687308,-0.04342547,-0.10710733,-0.04558252, 0.01848176, 0.06495547,-0.10657927], [ 0.10932171, "
      "0.05298832, 0.02638051, 0.12904511, 0.05388939, 0.11624362,-0.08975621, 0.05764109,-0.05429836,   "
      "0.02989927,-0.06289942, 0.05751227,-0.04514885,-0.01739412, 0.07118212,-0.08943173, 0.00381272,-0.07437360,   "
      "0.00907600,-0.05811819,-0.13434818,-0.06511527, 0.06409133,-0.13315472, 0.08002392,-0.06213494,-0.03162514,   "
      "0.02481432, 0.12963732,-0.05195979, 0.12878768, 0.08579770, 0.11411588, 0.03987051,-0.04563690, 0.12184246,  "
      "-0.05250040, 0.12666975,-0.04084568,-0.10183125, 0.04027088,-0.06089020, 0.05074862, 0.10934180,-0.01258831,  "
      "-0.09464511,-0.07531486,-0.09434149,-0.11196811, 0.04832600, 0.06333199,-0.11802801, 0.08551005], [-0.04291487, "
      "0.02116449, 0.06249847, 0.07611090,-0.10124123, 0.03026912,-0.11196173, 0.10527385,-0.02561233,   "
      "0.11606329,-0.01027018, 0.00687786,-0.11689648,-0.02812183,-0.13070880, 0.07328557, 0.11141762,-0.10954767,  "
      "-0.08227856,-0.06744114,-0.06638844,-0.06373481,-0.01041461,-0.08920157,-0.00496455, 0.08884811, 0.01708752,  "
      "-0.08293305, 0.02173210,-0.00076763, 0.05431853,-0.12735595,-0.08376162, 0.04692274, 0.13579997,-0.02663010,  "
      "-0.06650974, 0.13143730, 0.12743865, 0.12777676, 0.06333124,-0.06051791,-0.12430073, 0.05384872,-0.04997045,  "
      "-0.02626947,-0.10665599, 0.06898770, 0.01783613, 0.06548462,-0.11719070,-0.02158386, 0.01376820], "
      "[-0.04117436,-0.10464195,-0.09982625,-0.08458285,-0.08029079, 0.11239350, 0.05547993,-0.01186384,-0.09205987,  "
      "-0.02474440, 0.03564928,-0.05331899,-0.04006010, 0.01749686, 0.08168694,-0.09187122, 0.01649118, 0.04009657,  "
      "-0.12856345,-0.01840099,-0.03535189,-0.09145407,-0.02643955, 0.06437336, 0.10746951, 0.13043939,-0.03815180,   "
      "0.01485370,-0.10554828, 0.08441023,-0.01921209,-0.14449017,-0.12008327, 0.01233642, 0.03490810,-0.06904621,  "
      "-0.08903893, 0.05426045, 0.02548993, 0.11095154, 0.04654545,-0.08866836, 0.13274580, 0.02363435,-0.00221266,  "
      "-0.06830311, 0.00787541, 0.07399712,-0.08521717,-0.07668635, 0.13011093, 0.00503265, 0.01533003], "
      "[-0.04930362,-0.04626518, 0.03760570, 0.12594728,-0.02649571,-0.12540802, 0.10099500, 0.02400002,-0.06374322,  "
      "-0.11242569,-0.11510192, 0.06498326, 0.03630105, 0.03013342,-0.01861042,-0.11454076,-0.06916363, 0.08122335,  "
      "-0.12420112, 0.04787014,-0.03306301,-0.07972729, 0.01517744,-0.06752604,-0.10715567, 0.08842690, 0.10948091,   "
      "0.03537472,-0.04932887, 0.03936075,-0.12957233, 0.04097549, 0.12079127,-0.00409725, 0.03942308, 0.04265038,  "
      "-0.06327689,-0.02130156,-0.04947356, 0.11907654, 0.03511401, 0.07205161, 0.03789583,-0.07929001, 0.04135303,   "
      "0.05198850,-0.10943239,-0.12073950,-0.02358623, 0.13689360,-0.10127855, 0.11928958,-0.01091536], "
      "[-0.03714951,-0.00287892,-0.05557245, 0.10229493,-0.12431826, 0.03699316,-0.07620046, 0.00844062,-0.13951729,   "
      "0.01253873,-0.10940094,-0.04619464,-0.05150402,-0.11475573, 0.03990915, 0.11580297, 0.03430970,-0.03748647,  "
      "-0.05329280,-0.09166476, 0.00001406,-0.04552566,-0.07088374,-0.01088891,-0.06983617, 0.13437025,-0.03100179,   "
      "0.07418679,-0.00084522,-0.15180022, 0.09151141,-0.07359552, 0.08490425,-0.01256341,-0.06007640,-0.14395119,  "
      "-0.00368764, 0.05313186, 0.00513790, 0.09603135, 0.08230457,-0.09868351, 0.05135449, 0.09815288,-0.10765529,  "
      "-0.03461128, 0.09164006,-0.02304954,-0.12343717,-0.07505381, 0.06914687,-0.03214153, 0.07096781], [ "
      "0.02575866,-0.09299127, 0.08262794, 0.06559079,-0.08482654,-0.09801464, 0.12640145, 0.03451240, 0.12474640,  "
      "-0.04736253, 0.08898392, 0.11686368, 0.13714513, 0.05792611,-0.11991909, 0.00504536,-0.11410712,-0.07056955,   "
      "0.11215629, 0.01642506,-0.13087437,-0.00553568,-0.03220087,-0.02085935, 0.06904466,-0.09935081,-0.03443467,  "
      "-0.08231872,-0.00989846,-0.09542508, 0.00657524,-0.05801480,-0.06665350,-0.11460200,-0.08498883, 0.05039768,  "
      "-0.04177099,-0.09070642,-0.03958262, 0.01085738, 0.11323106,-0.13377708,-0.04350349, 0.13242224, 0.06584067,   "
      "0.12657987,-0.00983714, 0.09190395, 0.07749187, 0.02754140,-0.00343691,-0.09624200, 0.11850277], [-0.07601357, "
      "0.10697010,-0.03763552, 0.04483842,-0.02037231,-0.01815749,-0.11016127, 0.03866218,-0.11067937,  "
      "-0.05511224,-0.09964798,-0.13485114, 0.13501868,-0.07985085,-0.08989917,-0.02702447, 0.05077846, 0.08029014,   "
      "0.02419678,-0.07544817,-0.13307652,-0.05778332,-0.03369668, 0.02447495,-0.09554210,-0.05910620, 0.04605391,   "
      "0.13154687, 0.05808514,-0.05619049,-0.06550458,-0.05532079,-0.11656556, 0.09821352,-0.00278392,-0.08736656,   "
      "0.04715432, 0.07263748, 0.02120893,-0.08087604, 0.06610139,-0.03347784,-0.11785695,-0.08081219, 0.11372789,   "
      "0.09450344, 0.05692356, 0.09896247,-0.07315084,-0.04088010, 0.13026729, 0.13713720,-0.03045106], [ "
      "0.00450116,-0.09591170, 0.01401554, 0.11448754,-0.09419939, 0.06021165, 0.00275924,-0.08434747, 0.05902154,  "
      "-0.13289353, 0.02572754,-0.14664882,-0.01426720, 0.06735191, 0.08928985, 0.01335235,-0.13652238,-0.00312232,   "
      "0.09198540, 0.08668307,-0.03937490, 0.09592780,-0.09220910, 0.07050880,-0.08899216, 0.13260059, 0.08836128,   "
      "0.00993050, 0.04121745,-0.14432430,-0.05492989, 0.07021521,-0.12087302, 0.10574153, 0.08526923,-0.15113539,   "
      "0.08799346, 0.02528510,-0.13923629, 0.09697744,-0.04153611, 0.08142795,-0.12200031, 0.00225627,-0.09885860,  "
      "-0.04719384, 0.10867310,-0.07123931,-0.06797687,-0.02295347,-0.09448754, 0.10830668,-0.02849087], [ 0.06080256, "
      "0.04132756,-0.06696387, 0.13271625,-0.07225790,-0.14988182,-0.02862993, 0.03361645, 0.06651616,  "
      "-0.12177084,-0.02773445, 0.11736877,-0.05905973, 0.08242610, 0.08238482, 0.09488721,-0.03634444,-0.11847083,   "
      "0.04846940, 0.08567116, 0.07766999,-0.03776664,-0.09331014,-0.04697761, 0.07389058,-0.10009459,-0.00358350,  "
      "-0.11397126,-0.08314918, 0.07365838, 0.00307752, 0.13684909, 0.14996955, 0.05634568, 0.06667236, 0.10347035,   "
      "0.08123717, 0.04036957,-0.12686224, 0.08587859,-0.10523918,-0.07528786,-0.02615030,-0.01445534,-0.06401365,   "
      "0.10966346,-0.12843356,-0.09227290, 0.02169315, 0.12013749, 0.06120399,-0.01600814, 0.03692040], [ "
      "0.11799630,-0.13418655, 0.00369868, 0.04023157, 0.10884950, 0.07564957, 0.09926240, 0.01336680, 0.06865652,   "
      "0.09877201, 0.02016504, 0.05777389, 0.02132332, 0.07793692, 0.07849039, 0.12452106, 0.08276841,-0.06205595,  "
      "-0.04503026, 0.09626482,-0.10622848,-0.08176268,-0.03667411, 0.13490528, 0.09566024,-0.09112228,-0.03012091,  "
      "-0.04854210, 0.02558020,-0.10731722,-0.09375707, 0.05222454,-0.02959196,-0.09804149,-0.10872411,-0.08626162,  "
      "-0.00093180,-0.02375697,-0.03390818,-0.03276262,-0.13037492, 0.02282181, 0.01613944, 0.13713321,-0.01430729,  "
      "-0.11352055, 0.07279030, 0.05664828, 0.13532300, 0.04553918, 0.04167458,-0.11210816, 0.02699701], [ 0.00587054, "
      "0.03594491,-0.02831681,-0.04237441, 0.01541156, 0.02835452,-0.10028593,-0.05858832, 0.02629848,   0.01395325, "
      "0.11306124, 0.05740662, 0.10833501, 0.07454632,-0.10281096,-0.11086470,-0.11993039,-0.07340062,   0.12410690, "
      "0.03966891,-0.05900435,-0.05213895,-0.05028304,-0.13279152, 0.02374387,-0.06307538,-0.08465338,   "
      "0.03214407,-0.06599223, 0.13263966,-0.08958627, 0.01907911,-0.00378615,-0.08571252,-0.10079861, 0.06664928,   "
      "0.12690932, 0.13496386,-0.06271470, 0.07146621,-0.11540424,-0.12618491, 0.08220008, 0.11127029, 0.12457033,  "
      "-0.01876038,-0.10163065, 0.07709690,-0.12046191,-0.00555720, 0.10615091,-0.12777163,-0.00463083], [ "
      "0.10383714,-0.11009738, 0.00285414,-0.10845897,-0.09654207,-0.06998605,-0.01997469, 0.03688614,-0.11575001,   "
      "0.11466695, 0.05998234, 0.04465286,-0.12204942,-0.00533321,-0.12513936,-0.10715085,-0.02831998,-0.09638517,   "
      "0.05221172,-0.01556611,-0.03239193, 0.02214895, 0.04684453, 0.00730596, 0.09834784, 0.09127886, 0.09146124,  "
      "-0.01817069,-0.07564126,-0.12880690,-0.09875793,-0.03034459, 0.06920392,-0.08164984, 0.00087541,-0.11708046,  "
      "-0.02094664,-0.00594334,-0.11192361,-0.00739836,-0.01968813, 0.07521292,-0.09627367, 0.10830382,-0.09120318,   "
      "0.05619737, 0.09395663, 0.11201264, 0.10821883, 0.12835890, 0.13696449, 0.11250259, 0.06000325]]");
  Matrix<double> l1_b(
      "[ 0.09798564,-0.06424504,-0.08573534,-0.07783832,-0.10558987, 0.03709489, 0.10143888,-0.00917848,-0.08415429,  "
      "0.12354252,-0.02681651,-0.05264369,-0.14745007, 0.08147928, 0.10813894,-0.14736587, 0.11223645,-0.11186751, "
      "-0.03522743,-0.13632610, 0.00309106, 0.07930867, 0.03367076, 0.01800975, 0.11234721,-0.13646552, 0.10281536, "
      "-0.02418425,-0.03023838,-0.02543447, 0.01033785, 0.06316900, 0.10339016, 0.05903663, 0.09113418, 0.04280869,  "
      "0.01105271, 0.03331833,-0.11296933, 0.04508461,-0.04444651, 0.08626388, 0.05488082, 0.09459636, 0.12549311, "
      "-0.14618367, 0.04774715, 0.00887382,-0.09388578,-0.05888721, 0.13158743,-0.12547375,-0.10955674]");
  Matrix<double> l2_w(
      "[[ 0.05268617, 0.03033197, 0.12137916,-0.04782997,-0.10657888, 0.08118972,-0.10590710,-0.09897062, 0.02920101,  "
      " 0.05622371, 0.12004814, 0.11047234, 0.05848035, 0.06160325,-0.05187897, 0.08095148, 0.05782085,-0.04084525,  "
      "-0.06130803, 0.01154536, 0.00571267,-0.13476372, 0.03590911,-0.03342476, 0.05774239, 0.08625508,-0.06798886,  "
      "-0.04308887,-0.05471459, 0.08429979,-0.01648453, 0.00352383,-0.11174008, 0.01089435, 0.13498707, 0.06971286,   "
      "0.05111650,-0.03998154,-0.03334124, 0.07482772,-0.10860704,-0.08504101,-0.01490362, 0.10863660, 0.13495956,   "
      "0.10839089,-0.10430943, 0.03552650, 0.07166454, 0.09046797,-0.06196880,-0.08804578, 0.11152475], [ 0.03574456, "
      "0.07946459, 0.08315069, 0.03168394, 0.10534739, 0.14525034,-0.07982781,-0.04319310, 0.03642522,   "
      "0.06063208,-0.00263033, 0.04449681, 0.06881898,-0.08821079, 0.02520658,-0.05298010, 0.08072350,-0.09622492,  "
      "-0.08757672, 0.10522733, 0.09612833, 0.04504231,-0.04311404,-0.02974120, 0.10535522, 0.06508233,-0.12258929,   "
      "0.06536358,-0.08901413,-0.06837041,-0.09110106,-0.01034185, 0.04469432, 0.11957585, 0.01395190,-0.10007203,   "
      "0.01945661, 0.03059562, 0.01290696,-0.09450866, 0.08361030,-0.05965382,-0.00104510,-0.03487221,-0.09433324,   "
      "0.01014004,-0.09562292,-0.12250280,-0.00687207,-0.06484544, 0.13023302, 0.02356768,-0.08015821], [-0.05870938, "
      "0.09163903,-0.09310632,-0.07089170, 0.07012817, 0.10584350,-0.04575619, 0.05970025, 0.11763859,  -0.04127159, "
      "0.00589864, 0.06335010, 0.09794325,-0.13598463,-0.03690770,-0.10642382,-0.05973168, 0.13588914,   "
      "0.08848199,-0.08044589,-0.05720451,-0.02381936, 0.05749239,-0.08479273,-0.02663953,-0.06878442,-0.04850402,  "
      "-0.03796123, 0.08410601,-0.09814329,-0.13203713, 0.03601998, 0.09888797, 0.10535318, 0.05725847,-0.13544162,  "
      "-0.06832248,-0.10162253, 0.13496746,-0.10296027,-0.01560991, 0.12249988,-0.06837759,-0.13378116,-0.04742974,   "
      "0.06526761, 0.06417191,-0.04984620, 0.10962552, 0.00068776, 0.12229306,-0.10474518,-0.09068646], "
      "[-0.09947650,-0.04266040, 0.03650703,-0.02353701,-0.01016781, 0.03052022, 0.07763514,-0.06462030, 0.07059400,  "
      "-0.03935020, 0.06887396,-0.02131816,-0.09760201, 0.00400434,-0.11289348, 0.08192898, 0.00184146,-0.02027826,  "
      "-0.07894979,-0.10688028, 0.01991837,-0.12208221, 0.07708221, 0.08383674,-0.00075109, 0.09440837,-0.12895796,   "
      "0.07317152,-0.11938601,-0.02003712, 0.12748507, 0.05512326, 0.09032917, 0.08036758, 0.03080014,-0.00339371,  "
      "-0.13709398,-0.07511527, 0.03096288,-0.01072217, 0.03150289,-0.08467277,-0.05489045,-0.02372549, 0.08610879,  "
      "-0.06070586,-0.02008926, 0.02553916, 0.01786396, 0.14373690,-0.10146737, 0.01750657, 0.00081441], [ 0.00803359, "
      "0.07767580, 0.03720461, 0.01936314,-0.00532120,-0.07465138, 0.01518557, 0.03904007, 0.12423766,   "
      "0.07920198,-0.05938765, 0.10003653,-0.00060055,-0.12660785, 0.03934297, 0.04018606, 0.06137585, 0.08469550,  "
      "-0.00335854,-0.01908833, 0.07682201, 0.03450117,-0.00277978, 0.01250811,-0.00683894, 0.12001507,-0.00518271,   "
      "0.11000507, 0.08894155, 0.02654444,-0.06654630, 0.12796025,-0.05783452, 0.03991172, 0.16675735,-0.13555282,  "
      "-0.09008780,-0.04223248, 0.06075729, 0.09398258, 0.05424244, 0.12242416, 0.12205009,-0.13960952,-0.02612272,  "
      "-0.15051806, 0.12055132,-0.12616590,-0.07954873,-0.09082488,-0.10157628,-0.06383969,-0.05600446], [ 0.07261842, "
      "0.09713658,-0.08183464, 0.08138169,-0.06044996,-0.10782577,-0.08437512, 0.04821093,-0.00113999,   "
      "0.10070844,-0.13207194, 0.06890448,-0.10009194,-0.07413492, 0.06402951,-0.11615563,-0.01885301, 0.12096062,  "
      "-0.03563674,-0.10343062, 0.05862997,-0.11049868,-0.13056062, 0.13271767,-0.12561962,-0.09394804, 0.02946370,  "
      "-0.02141527,-0.10236071,-0.11923964, 0.14295685, 0.02612019, 0.02497266, 0.11962240,-0.00924146,-0.01332250,  "
      "-0.05357127, 0.05278813, 0.13165322,-0.06422676, 0.02198361,-0.04784682,-0.11177158,-0.08810618,-0.12421297,   "
      "0.00674939, 0.07646692,-0.00250291,-0.10127967, 0.12573647, 0.10719759,-0.03496591,-0.02534798], [ 0.04225013, "
      "0.06268935, 0.06164204,-0.05463592, 0.12978035, 0.12492063,-0.03859427, 0.12190961,-0.11248977,   "
      "0.09603823,-0.01589987,-0.13595308,-0.04131884,-0.01635274,-0.10724835, 0.05617386, 0.12357154,-0.06971118,   "
      "0.06027405, 0.12446313,-0.06094076,-0.06780677,-0.11106177,-0.02240953,-0.02912615, 0.12354374, 0.08506379,   "
      "0.10645474,-0.09170020,-0.01566518,-0.05698182,-0.07631462, 0.12715676,-0.07450632, 0.03747188,-0.07724681,  "
      "-0.11470534, 0.10839817, 0.03108034, 0.13686654,-0.03584975,-0.09107133,-0.08913627, 0.12940590, 0.06505780,  "
      "-0.05287328, 0.08782238,-0.05401229,-0.10816840,-0.03701571,-0.04764079,-0.13436384, 0.03465118]]");
  Matrix<double> l2_b("[ 0.08705060,-0.08923306,-0.08941498,-0.06293385, 0.00990367, 0.11257403, 0.03444391]");

  Matrix<double>* l1_i_mul_w = l1_i ^ l1_w;
  Matrix<double>* l1_res = l1_i_mul_w + l1_b;
  l1_res.Relu_();
  Matrix<double>* l2_i_mul_w = l1_res ^ l2_w;
  Matrix<double>* l2_res = l2_i_mul_w + l2_b;

  Print(l2_res.ToString(true, 4));

  return INIT_SUCCEEDED;
}
