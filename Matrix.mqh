//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Prevents processing this includes file for the second time.
#ifndef MATRIX_MQH
#define MATRIX_MQH

template <typename X>
class MatrixDimension;


template <typename X>
class MatrixDimension {
 public:
  virtual bool IsLastDimension() = 0;

  typedef MatrixDimension* (*MatrixDimensionFactory)();

  virtual void Resize(int num_items, MatrixDimensionFactory factory = NULL) = 0;
};


template <typename X>
class MatrixDimensionContainer : public MatrixDimension<X> {
public:
  MatrixDimension<X>* next_dimensions[];

  virtual bool IsLastDimension() { return false; }

  virtual void Resize(int num_items, MatrixDimensionFactory factory = NULL) {
    ArrayResize(next_dimensions, num_items);
    for (int i = 0; i < num_items; ++i) {
      //next_
    }
  }
};

template <typename X>
class MatrixDimensionValues : public MatrixDimension<X> {
public:
  X values[];

  MatrixDimensionValues() {}

  virtual void Resize(int num_d, MatrixDimensionFactory factory = NULL) { ArrayResize(values, num_d); }

  virtual bool IsLastDimension() { return true; }

  static MatrixDimensionValues<X>* Factory() {
    return new MatrixDimensionValues<X>();
  }
};

template <typename X>
class Matrix {
public:
  MatrixDimension<X>* ptr_first_dimension;

  int dimensions[6];

  /**
   * Constructor.
   */
  Matrix(const int num_1d = 0, const int num_2d = 0, const int num_3d = 0, const int num_4d = 0, const int num_5d = 0) {
    SetShape(num_1d, num_2d, num_3d, num_4d, num_5d);
  }



  void SetShape(const int num_1d = 0, const int num_2d = 0, const int num_3d = 0, const int num_4d = 0,
                const int num_5d = 0) {
    if (ptr_first_dimension != NULL) {
      delete ptr_first_dimension;
    }

    dimensions[0] = num_1d;
    dimensions[1] = num_2d;
    dimensions[2] = num_3d;
    dimensions[3] = num_4d;
    dimensions[4] = num_5d;
    dimensions[5] = 0;

    ptr_first_dimension = SetDimensions(NULL, dimensions, 0);
  }

protected:
 
  MatrixDimension<X>* SetDimensions(MatrixDimension<X>* _ptr_parent_dimension, int& _dimensions[], int index) {
    for (int i = index; i < ArraySize(_dimensions); i++) {
      if (_dimensions[i + 1] == 0) {
        // Assuming last dimension (values).
        if (_ptr_parent_dimension == NULL) {
          // Only a single dimension with values for the whole matrix.
          _ptr_parent_dimension = new MatrixDimensionValues<X>();
          _ptr_parent_dimension.Resize(_dimensions[i]);
        }
        else {
          // 2D+ matrix. Resizing container with another containers.
          _ptr_parent_dimension.Resize(_dimensions[i - 1], MatrixDimensionValues<X>::Factory);
        }
      }
      else {
        // Not a last dimension. Assuming container.
        
      }
    }

    return _ptr_parent_dimension;
  }
};

#endif
