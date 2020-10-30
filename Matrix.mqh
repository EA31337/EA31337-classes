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

#define MATRIX_DIMENSIONS 5

// Forward declarations.
template <typename X>
class MatrixDimension;

template <typename X>
class Matrix;

// Types of matrix dimensions.
enum ENUM_MATRIX_DIMENSION_TYPE { MATRIX_DIMENSION_TYPE_CONTAINERS, MATRIX_DIMENSION_TYPE_VALUES };

// Matrix operation types.
enum ENUM_MATRIX_OPERATION {
  MATRIX_OPERATION_ADD,
  MATRIX_OPERATION_SUBTRACT,
  MATRIX_OPERATION_MULTIPLY,
  MATRIX_OPERATION_DIVIDE,
  MATRIX_OPERATION_ABS,
  MATRIX_OPERATION_FILL,
  MATRIX_OPERATION_FILL_RANDOM,
  MATRIX_OPERATION_FILL_RANDOM_RANGE,
  MATRIX_OPERATION_FILL_POS_ADD,
  MATRIX_OPERATION_FILL_POS_NULL,
  MATRIX_OPERATION_SUM,
  MATRIX_OPERATION_MIN,
  MATRIX_OPERATION_MAX,
  MATRIX_OPERATION_AVG,
  MATRIX_OPERATION_MED,
};

/**
 * Matrix's dimension accessor. Used by matrix's index operator.
 */
template <typename X>
struct MatrixDimensionAccessor {
 protected:
  // Pointer to matrix instance.
  Matrix<X>* ptr_matrix;

  // Pointer to matrix's dimension instance.
  MatrixDimension<X>* ptr_dimension;

  // Index of container or value pointed by accessor.
  int index;

 public:
  /**
   * Constructor.
   */
  MatrixDimensionAccessor(Matrix<X>* _ptr_matrix = NULL, MatrixDimension<X>* _ptr_dimension = NULL, int _index = 0)
      : ptr_matrix(_ptr_matrix), ptr_dimension(_ptr_dimension), index(_index) {}

  /**
   * Index operator. Returns container or value accessor.
   */
  MatrixDimensionAccessor<X> operator[](int _index) {
    return MatrixDimensionAccessor(ptr_matrix, ptr_dimension.containers[index], _index);
  }

  /**
   * Assignment operator. Sets value for this dimensions.
   */
  void operator=(X _value) {
    if (ptr_dimension.type != MATRIX_DIMENSION_TYPE_VALUES) {
      Print("Error: Trying to set matrix", ptr_matrix.Repr(), "'s value in a dimension which doesn't contain values!");
      return;
    }

    ptr_dimension.values[index] = _value;
  }

  /**
   * Returns value pointed by this accessor.
   */
  X Val() {
    if (ptr_dimension.type != MATRIX_DIMENSION_TYPE_VALUES) {
      Print("Error: Trying to get value from matrix", ptr_matrix.Repr(), "'s dimension which doesn't contain values!");
      return (X)EMPTY_VALUE;
    }

    return ptr_dimension.values[index];
  }
};

/**
 * A single matrix's dimension. Contains array of containers or values.
 */
template <typename X>
class MatrixDimension {
 public:
  ENUM_MATRIX_DIMENSION_TYPE type;

  // Values array if type is "Values".
  X values[];

  // Containers array if type is "Containers"
  MatrixDimension<X>* containers[];

  /**
   * Constructor.
   */
  MatrixDimension(ENUM_MATRIX_DIMENSION_TYPE _type = MATRIX_DIMENSION_TYPE_VALUES) { type = _type; }

  /**
   * Destructor.
   */
  ~MatrixDimension() {
    for (int i = 0; i < ArraySize(containers); ++i) {
      if (containers[i] != NULL) {
        delete containers[i];
      }
    }
  }

  /**
   * Resizes this dimension and sets its type (containers or values array).
   */
  virtual void Resize(int _num_items, ENUM_MATRIX_DIMENSION_TYPE _type = MATRIX_DIMENSION_TYPE_VALUES) {
    int i, _last_size;

    if (_type != MATRIX_DIMENSION_TYPE_CONTAINERS) {
      // Removing containers if there's any.
      for (i = 0; i < ArraySize(containers); ++i) {
        if (containers[i] != NULL) {
          delete containers[i];
          // Clearing container pointer for later reuse.
          containers[i] = NULL;
        }
      }
    }

    if (_type != MATRIX_DIMENSION_TYPE_VALUES) {
      // Removing values.
      ArrayResize(values, 0);
    }

    switch (_type) {
      case MATRIX_DIMENSION_TYPE_CONTAINERS:
        if (type == MATRIX_DIMENSION_TYPE_CONTAINERS) {
          // There already were containers, resizing.
          if (_num_items < ArraySize(containers)) {
            // Deleting not needed containers.
            for (i = _num_items; i < ArraySize(containers); ++i) {
              if (containers[i] != NULL) {
                delete containers[i];
                // Clearing container pointer for later reuse.
                containers[i] = NULL;
              }
            }
          } else if (_num_items > ArraySize(containers)) {
            // Inserting new containers.
            _last_size = ArraySize(containers);
            ArrayResize(containers, _num_items);
            for (i = _last_size; i < ArraySize(containers); ++i) {
              containers[i] = NULL;
            }
          }
        } else {
          // There were no containers.
          ArrayResize(containers, _num_items);
        }
        break;

      case MATRIX_DIMENSION_TYPE_VALUES:
        _last_size = ArraySize(values);
        ArrayResize(values, _num_items);
        if (_num_items > _last_size) {
          // Clearing new values.
          ArrayFill(values, _last_size, _num_items - _last_size, (X)0);
        }
        break;
    }

    type = _type;
  }

  /**
   * Initializes dimensions deeply.
   *
   * @todo Allow of resizing containers instead of freeing them firstly.
   */
  static MatrixDimension<X>* SetDimensions(MatrixDimension<X>* _ptr_parent_dimension, int& _dimensions[], int index) {
    if (_ptr_parent_dimension == NULL) _ptr_parent_dimension = new MatrixDimension();

    if (_dimensions[0] == 0) {
      // Matrix with no dimensions.
      return _ptr_parent_dimension;
    }

    int i;

    if (_dimensions[index + 1] == 0) {
      _ptr_parent_dimension.Resize(_dimensions[index], MATRIX_DIMENSION_TYPE_VALUES);

      for (i = 0; i < _dimensions[index]; ++i) {
        //_ptr_parent_dimension.values[i] = (X)0;
      }
    } else {
      _ptr_parent_dimension.Resize(_dimensions[index], MATRIX_DIMENSION_TYPE_CONTAINERS);

      for (i = 0; i < _dimensions[index]; ++i) {
        _ptr_parent_dimension.containers[i] =
            SetDimensions(_ptr_parent_dimension.containers[i], _dimensions, index + 1);
      }
    }

    return _ptr_parent_dimension;
  }

  /**
   * Executes operation on all matrix's values.
   */
  void Op(ENUM_MATRIX_OPERATION _op, X _arg1, X _arg2, X _arg3, X& _out1, X& _out2, int& _out3) {
    int i;
    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      for (i = 0; i < ArraySize(containers); ++i) {
        containers[i].Op(_op, _arg1, _arg2, _arg3, _out1, _out2, _out3);
      }
    } else {
      for (i = 0; i < ArraySize(values); ++i) {
        switch (_op) {
          case MATRIX_OPERATION_ADD:
            values[i] += _arg1;
            break;
          case MATRIX_OPERATION_SUBTRACT:
            values[i] -= _arg1;
            break;
          case MATRIX_OPERATION_MULTIPLY:
            values[i] *= _arg1;
            break;
          case MATRIX_OPERATION_DIVIDE:
            values[i] /= _arg1;
            break;
          case MATRIX_OPERATION_FILL:
            values[i] = _arg1;
            break;
          case MATRIX_OPERATION_FILL_RANDOM:
            values[i] = -(X)1 + (X)MathRand() / 32767 * 2;
            break;
          case MATRIX_OPERATION_FILL_RANDOM_RANGE:
            values[i] = (X)MathRand() / 32767 * (_arg2 - _arg1) + _arg1;
            break;
          case MATRIX_OPERATION_SUM:
            _out1 += values[i];
            break;
          case MATRIX_OPERATION_MIN:
            if (values[i] < _out1) {
              _out1 = values[i];
            }
            break;
          case MATRIX_OPERATION_MAX:
            if (values[i] > _out1) {
              _out1 = values[i];
            }
            break;
        }
      }
    }
  }

  /**
   * Executes operation on the children containers and values. Used internally.
   */
  void Op(ENUM_MATRIX_OPERATION _op, X _arg1 = 0, X _arg2 = 0, X _arg3 = 0) {
    X _out1, _out2;
    int _out3;

    Op(_op, _arg1, _arg2, _arg3, _out1, _out2, _out3);
  }

  /**
   * Extracts dimensions's values to the given array. Used internally.
   */
  void FillArray(X& array[], int& offset) {
    int i;
    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      for (i = 0; i < ArraySize(containers); ++i) {
        containers[i].FillArray(array, offset);
      }
    } else {
      for (i = 0; i < ArraySize(values); ++i, ++offset) {
        array[offset] = values[i];
      }
    }
  }
};

/**
 * Matrix class.
 */
template <typename X>
class Matrix {
 public:
  // First/root dimension.
  MatrixDimension<X>* ptr_first_dimension;

  // Array with declaration of items per matrix's dimension.
  int dimensions[6];

  // Current size of the matrix (all dimensions multiplied).
  int size;

  // Number of matrix dimensions.
  int num_dimensions;

  /**
   * Constructor.
   */
  Matrix(const int num_1d = 0, const int num_2d = 0, const int num_3d = 0, const int num_4d = 0, const int num_5d = 0) {
    ptr_first_dimension = NULL;
    SetShape(num_1d, num_2d, num_3d, num_4d, num_5d);
  }

  /**
   * Destructor.
   */
  ~Matrix() { delete ptr_first_dimension; }

  /**
   * Index operator. Returns container or value accessor.
   */
  MatrixDimensionAccessor<X> operator[](int index) {
    MatrixDimensionAccessor<X> accessor(&this, ptr_first_dimension, index);
    return accessor;
  }

  /**
   * Sets or changes matrix's dimensions.
   */
  void SetShape(const int num_1d = 0, const int num_2d = 0, const int num_3d = 0, const int num_4d = 0,
                const int num_5d = 0) {
    dimensions[0] = num_1d;
    dimensions[1] = num_2d;
    dimensions[2] = num_3d;
    dimensions[3] = num_4d;
    dimensions[4] = num_5d;
    dimensions[5] = 0;

    ptr_first_dimension = MatrixDimension<X>::SetDimensions(ptr_first_dimension, dimensions, 0);

    // Calculating size.
    size = 0;

    num_dimensions = (num_1d != 0 ? 1 : 0) + (num_2d != 0 ? 1 : 0) + (num_3d != 0 ? 1 : 0) + (num_4d != 0 ? 1 : 0) +
                     (num_5d != 0 ? 1 : 0);

    for (int i = 0; i < ArraySize(dimensions); ++i) {
      if (dimensions[i] != 0) {
        if (size == 0) {
          size = 1;
        }

        size *= dimensions[i];
      }
    }
  }

  int GetRange(int _dimension) {
    if (_dimension >= MATRIX_DIMENSIONS) {
      Print("Matrix::GetRange(): Dimension should be between 0 and ", MATRIX_DIMENSIONS - 1, ". Got ", _dimension, "!");
      return -1;
    }

    return dimensions[_dimension];
  }

  /**
   * Returns total number of values the matrix contain of.
   */
  int GetSize() { return size; }

  /**
   * Returns number of matrix dimensions.
   */
  int GetDimensions() { return num_dimensions; }

  /**
   * Increments all existing matrix's values by given one.
   */
  void operator+=(X value) { Add(value); }

  /**
   * Increments all existing matrix's values by given one.
   */
  void Add(X value) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_ADD, value);
    }
  }

  /**
   * Decrements all existing matrix's values by given one.
   */
  void operator-=(X value) { Sub(value); }

  /**
   * Decrements all existing matrix's values by given one.
   */
  void Sub(X value) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_SUBTRACT, value);
    }
  }

  /**
   * Multiplies all existing matrix's values by given one.
   */
  void operator*=(X value) { Mul(value); }

  /**
   * Multiplies all existing matrix's values by given one.
   */
  void Mul(X value) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_MULTIPLY, value);
    }
  }

  /**
   * Divides all existing matrix's values by given one.
   */
  void operator/=(X value) { Div(value); }

  /**
   * Divides all existing matrix's values by given one.
   */
  void Div(X value) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_DIVIDE, value);
    }
  }

  /**
   * Replaces all matrix's values by given one.
   */
  void Fill(X value) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_FILL, value);
    }
  }

  /**
   * Replaces existing matrix's values by random one (-1.0 - 1.0).
   */
  void FillRandom() {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_FILL_RANDOM);
    }
  }

  /**
   * Replaces existing matrix's values by random value from a given range.
   */
  void FillRandom(X start, X end) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_FILL_RANDOM_RANGE, start, end);
    }
  }

  /**
   * Replaces existing matrix's values by random value from a given range.
   */
  X Sum() {
    X _out1 = 0, _out2;
    int _out3;
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_SUM, 0, 0, 0, _out1, _out2, _out3);
    }
    return _out1;
  }

  /**
   * Calculates the lowest value in the whole matrix.
   */
  X Min() {
    X _out1 = MaxOf((X)0), _out2;
    int _out3;
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_MIN, 0, 0, 0, _out1, _out2, _out3);
    }
    return _out1;
  }

  /**
   * Calculates the lowest value in the whole matrix.
   */
  X Max() {
    X _out1 = MinOf((X)0), _out2;
    int _out3;
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_MAX, 0, 0, 0, _out1, _out2, _out3);
    }
    return _out1;
  }

  /**
   * Calculates the average value in the whole matrix.
   */
  X Avg() {
    X _out1 = 0, _out2;
    int _out3;
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_SUM, 0, 0, 0, _out1, _out2, _out3);
      return _out1 / GetSize();
    }
    return MinOf((X)0);
  }

  /**
   * Calculates median of the matrix values.
   */
  X Med() {
    if (ptr_first_dimension) {
      X array[];
      GetRawArray(array);
      ArraySort(array);

      double median;

      int len = ArraySize(array);

      if (len % 2 == 0)
        median = (array[len / 2] + array[(len / 2) - 1]) / 2;
      else
        median = array[len / 2];

      return median;
    }
    return MinOf((X)0);
  }

  /**
   * Fills array with all values from the matrix.
   */
  void GetRawArray(X& array[]) {
    ArrayResize(array, GetSize());
    int offset = 0;
    ptr_first_dimension.FillArray(array, offset);
  }

  /**
   * Return minimum value of double.
   */
  static double MinOf(double value) { return DBL_MIN; }

  /**
   * Return minimum value of integer.
   */
  static int MinOf(int value) { return INT_MIN; }

  /**
   * Return maximum value of double.
   */
  static double MaxOf(double value) { return DBL_MAX; }

  /**
   * Return minimum value of integer.
   */
  static int MaxOf(int value) { return INT_MAX; }

  /**
   * Returns representation of matrix's dimension, e.g., "[2, 5, 10]".
   */
  string Repr() {
    string _out = "[";

    for (int i = 0; i < ArraySize(dimensions); ++i) {
      if (dimensions[i] == 0) {
        continue;
      }

      _out += IntegerToString(dimensions[i]) + (dimensions[i + 1] != 0 ? ", " : "");
    }

    return _out + "]";
  }
};

#endif