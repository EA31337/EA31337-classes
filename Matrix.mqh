//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

#ifdef USE_MQL_MATH_STAT
#ifdef __MQL5__
#include <Math/Stat/Normal.mqh>
#endif
#endif

#include "Math.h"

#define MATRIX_DIMENSIONS 6
#define MATRIX_VALUES_ARRAY_INCREMENT 500

// Forward declarations.
template <typename X>
class MatrixDimension;

template <typename X>
class Matrix;

#define MATRIX_STRIDE_AS_POOL -1

enum ENUM_MATRIX_VECTOR_REDUCE { MATRIX_VECTOR_REDUCE_COSINE_SIMILARITY, MATRIX_VECTOR_REDUCE_HINGE_LOSS };

// Types of matrix pool padding.
// @see https://keras.io/api/layers/pooling_layers/average_pooling2d/
enum ENUM_MATRIX_PADDING {
  // No padding.
  MATRIX_PADDING_VALID,

  // Results in padding evenly to the left/right or up/down of the input such that output has the same height/width
  // dimension as the input.
  MATRIX_PADDING_SAME
};

// Types of matrix dimensions.
enum ENUM_MATRIX_DIMENSION_TYPE {
  MATRIX_DIMENSION_TYPE_UNKNOWN,
  MATRIX_DIMENSION_TYPE_CONTAINERS,
  MATRIX_DIMENSION_TYPE_VALUES
};

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
  MATRIX_OPERATION_FILL_POS_MUL,
  MATRIX_OPERATION_POWER,
  MATRIX_OPERATION_SUM,
  MATRIX_OPERATION_MIN,
  MATRIX_OPERATION_MAX,
  MATRIX_OPERATION_AVG,
  MATRIX_OPERATION_MED,
  MATRIX_OPERATION_POISSON,   // b - a * log(b)
  MATRIX_OPERATION_LOG_COSH,  // log((exp((b-a)) + exp(-(b-a)))/2)
  MATRIX_OPERATION_ABS_DIFF,
  MATRIX_OPERATION_ABS_DIFF_SQUARE,
  MATRIX_OPERATION_ABS_DIFF_SQUARE_LOG,
  MATRIX_OPERATION_RELU,
};

/**
 * Return minimum value of double.
 */
double MinOf(double value) { return -DBL_MAX; }

/**
 * Return minimum value of double.
 */
float MinOf(float value) { return -FLT_MAX; }

/**
 * Return minimum value of integer.
 */
int MinOf(int value) { return INT_MIN; }

/**
 * Return maximum value of double.
 */
double MaxOf(double value) { return DBL_MAX; }

/**
 * Return maximum value of double.
 */
float MaxOf(float value) { return FLT_MAX; }

/**
 * Return minimum value of integer.
 */
int MaxOf(int value) { return INT_MAX; }

/**
 * Matrix's dimension accessor. Used by matrix's index operator.
 */
template <typename X>
struct MatrixDimensionAccessor {
  // Pointer to matrix instance.
  Matrix<X>* ptr_matrix;

  // Pointer to matrix's dimension instance.
  MatrixDimension<X>* ptr_dimension;

  // Index of container or value pointed by accessor.
  int index;

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
   * Returns target dimension type.
   */
  ENUM_MATRIX_DIMENSION_TYPE Type() const { return ptr_dimension.type; }

#define MATRIX_ACCESSOR_OPERATOR(OP)                                                   \
  void operator OP(X _value) {                                                         \
    if (ptr_dimension.type != MATRIX_DIMENSION_TYPE_VALUES) {                          \
      Print("Error: Trying to use matrix", ptr_matrix.Repr(),                          \
            "'s value operator " #OP " in a dimension which doesn't contain values!"); \
      return;                                                                          \
    }                                                                                  \
                                                                                       \
    ptr_dimension.values[index] OP _value;                                             \
  }

  MATRIX_ACCESSOR_OPERATOR(+=)
  MATRIX_ACCESSOR_OPERATOR(-=)
  MATRIX_ACCESSOR_OPERATOR(*=)
  MATRIX_ACCESSOR_OPERATOR(/=)

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

  /**
   * Returns value pointed by this accessor or first value if it holds only one value or zero if index is above the
   * dimension length.
   */
  X ValOrZero() {
    if (ptr_dimension.type != MATRIX_DIMENSION_TYPE_VALUES) {
      Print("Error: Trying to get value from matrix", ptr_matrix.Repr(), "'s dimension which doesn't contain values!");
      return (X)EMPTY_VALUE;
    }

    int _num_values = ArraySize(ptr_dimension.values);

    if (_num_values == 0 || index >= _num_values) return (X)0;

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

  // Physical position of the dimension in the matrix.
  int position[MATRIX_DIMENSIONS - 1];

  // Containers array if type is "Containers"
  MatrixDimension<X>* containers[];

  /**
   * Constructor.
   */
  MatrixDimension(ENUM_MATRIX_DIMENSION_TYPE _type = MATRIX_DIMENSION_TYPE_UNKNOWN) { type = _type; }

  /**
   * Destructor.
   */
  ~MatrixDimension() {
    for (int i = 0; i < ArraySize(containers); ++i) {
      delete containers[i];
    }
  }

  /**
   * Makes a clone of this and child dimensions.
   */
  MatrixDimension<X>* Clone() const {
    MatrixDimension<X>* _clone = new MatrixDimension<X>(type);
    int i;

    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      ArrayResize(_clone.containers, ArraySize(containers));

      for (i = 0; i < ArraySize(containers); ++i) {
        _clone.containers[i] = containers[i].Clone();
      }
    } else {
      ArrayCopy(_clone.values, values);
    }

    return _clone;
  }

  /**
   * Adds container to the list.
   */
  void AddContainer(MatrixDimension* _dimension) {
    ArrayResize(containers, ArraySize(containers) + 1);
    containers[ArraySize(containers) - 1] = _dimension;
  }

  /**
   * Adds value to the list.
   */
  void AddValue(X value) {
    ArrayResize(
        values, ArraySize(values) + 1,
        (ArraySize(values) - ArraySize(values) % MATRIX_VALUES_ARRAY_INCREMENT) + MATRIX_VALUES_ARRAY_INCREMENT);
    values[ArraySize(values) - 1] = value;
  }

  /**
   * Sets physical position of the dimension in the matrix.
   */
  void SetPosition(int& _position[], int _level) {
    for (int i = 0; i < ArraySize(_position); ++i) {
      position[i] = i < _level ? _position[i] : -1;
    }
  }

  string Spaces(int _num) {
    string _padding;
    StringInit(_padding, _num, ' ');
    return _padding;
  }

  string ToString(bool _whitespaces = false, int _precision = 3, int level = 1) {
    string out = "";
    int i;

    if (ArraySize(containers) != 0) {
      out += (_whitespaces ? Spaces((level - 1) * 2) : "") + (_whitespaces ? "[\n" : "[");
      for (i = 0; i < ArraySize(containers); ++i) {
        out += containers[i].ToString(_whitespaces, _precision, level + 1) +
               (i != ArraySize(containers) - 1 ? "," : "") + (_whitespaces ? "\n" : "");
      }
      out += (_whitespaces ? Spaces((level - 1) * 2) : "") + "]";
    } else {
      out += (_whitespaces ? Spaces(level * 2) : "") + (_whitespaces ? "[ " : "[");
      for (i = 0; i < ArraySize(values); ++i) {
        if (values[i] > -MaxOf(values[i]) && values[i] < MaxOf(values[i])) {
          out += DoubleToString((double)values[i], _precision);
        } else {
          out += (values[i] < 0 ? "-inf" : "inf");
        }
        out += (i != ArraySize(values) - 1) ? (_whitespaces ? ", " : ",") : "";
      }
      out += (_whitespaces ? " ]" : "]");
    }

    return out;
  }

  /**
   * Reduces dimension if it contains values. Goes recursively up to _level.
   */
  void ReduceSimple(int _level = 0, ENUM_MATRIX_OPERATION _reduce_op = MATRIX_OPERATION_SUM, int _current_level = 0) {
    int i;
    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS && _current_level <= _level) {
      for (i = 0; i < ArraySize(containers); ++i) {
        containers[i].ReduceSimple(_level, _reduce_op, _current_level + 1);
      }
    }

    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS && ArraySize(containers) > 0 &&
        containers[0].type == MATRIX_DIMENSION_TYPE_VALUES && ArraySize(containers[0].values) == 1) {
      type = MATRIX_DIMENSION_TYPE_VALUES;

      for (i = 0; i < ArraySize(containers); ++i) {
        X _sum = 0;
        for (int k = 0; k < ArraySize(containers[i].values); ++k) {
          _sum += containers[i].values[k];
        }
        AddValue(_sum);
        delete containers[i];
      }

      ArrayResize(containers, 0);
    }
  }

  /**
   * Reduces (aggregates) dimensions up to _level.
   */
  void Reduce(int _level = 0, ENUM_MATRIX_OPERATION _reduce_op = MATRIX_OPERATION_SUM, int _current_level = 0) {
    int i;
    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS && _current_level < _level) {
      for (i = 0; i < ArraySize(containers); ++i) {
        containers[i].Reduce(_level, _reduce_op, _current_level + 1);
      }
    }

    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS && _current_level >= _level) {
      // There will be as many values as containers.
      ArrayResize(values, ArraySize(containers));
      for (i = 0; i < ArraySize(containers); ++i) {
        X _sum = 0;
        X _out1 = 0, _out2;
        int _out3;

        containers[i].Op(_reduce_op, 0, 0, 0, _out1, _out2, _out3);

        values[i] = _out1;

        delete containers[i];
      }

      ArrayResize(containers, 0);
      type = MATRIX_DIMENSION_TYPE_VALUES;
    }
  }

  /**
   * Reduces dimension if it contains values. Goes recursively up to _level.
   * Returns initial dimensions size for the given level.
   */
  int DuplicateDimension(int _level, int _num, int _current_level = 0) {
    int i, k, num_initial_containers = 0;
    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS && _current_level < _level) {
      for (i = 0; i < ArraySize(containers); ++i) {
        num_initial_containers = containers[i].DuplicateDimension(_level, _num, _current_level + 1);
      }
      return num_initial_containers;
    }

    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      num_initial_containers = ArraySize(containers);
      for (i = 0; i < _num; ++i) {
        for (k = 0; k < num_initial_containers; ++k) {
          MatrixDimension<X>* _new_dim = containers[k].Clone();
          AddContainer(_new_dim);
        }
      }

      return num_initial_containers;
    }

    return 0;
  }

  /**
   * Initializes dimension data from another dimension.
   */
  void CopyFrom(MatrixDimension<X>& _r) {
    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      for (int i = 0; i < ArraySize(containers); ++i) {
        containers[i].CopyFrom(_r.containers[i]);
      }
    } else if (type == MATRIX_DIMENSION_TYPE_VALUES) {
      ArrayCopy(values, _r.values);
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
        delete containers[i];
      }
      ArrayResize(containers, 0);
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
              delete containers[i];
            }
          }
        }
        ArrayResize(containers, _num_items);
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
  static MatrixDimension<X>* SetDimensions(MatrixDimension<X>* _ptr_parent_dimension, int& _dimensions[], int index,
                                           int& _current_position[]) {
    if (_ptr_parent_dimension == NULL) _ptr_parent_dimension = new MatrixDimension();

    if (index == 0 && _dimensions[0] == 0) {
      // Matrix without any dimensions.
      _ptr_parent_dimension.type = MATRIX_DIMENSION_TYPE_VALUES;
    }

    _ptr_parent_dimension.SetPosition(_current_position, index);

    int i;

    if (_dimensions[index + 1] == 0) {
      _ptr_parent_dimension.Resize(_dimensions[index], MATRIX_DIMENSION_TYPE_VALUES);
    } else {
      _ptr_parent_dimension.Resize(_dimensions[index], MATRIX_DIMENSION_TYPE_CONTAINERS);

      for (i = 0; i < _dimensions[index]; ++i) {
        _ptr_parent_dimension.containers[i] =
            SetDimensions(_ptr_parent_dimension.containers[i], _dimensions, index + 1, _current_position);

        ++_current_position[index];
      }
    }

    return _ptr_parent_dimension;
  }

  /**
   * Executes operation on a single value.
   */
  X OpSingle(ENUM_MATRIX_OPERATION _op, X _src = (X)0, X _arg1 = (X)0, X _arg2 = (X)0, X _arg3 = (X)0) {
    int _pos = 0;
    switch (_op) {
      case MATRIX_OPERATION_ABS:
        return MathAbs(_src);
      case MATRIX_OPERATION_ADD:
        return _src + _arg1;
      case MATRIX_OPERATION_SUBTRACT:
        return _src - _arg1;
      case MATRIX_OPERATION_MULTIPLY:
        return _src * _arg1;
      case MATRIX_OPERATION_DIVIDE:
        return _src / _arg1;
        break;
      case MATRIX_OPERATION_FILL:
        return _arg1;
      case MATRIX_OPERATION_FILL_RANDOM:
        if (_arg1 != -1) {
          srand((int)_arg3);
        }
        return -(X)1 + (X)MathRand() / 32767 * 2;
      case MATRIX_OPERATION_FILL_RANDOM_RANGE:
        if (_arg3 != -1) {
          srand((int)_arg3);
        }
        return (X)MathRand() / 32767 * (_arg2 - _arg1) + _arg1;
      case MATRIX_OPERATION_ABS_DIFF:
        return MathAbs(_src - _arg1);
      case MATRIX_OPERATION_ABS_DIFF_SQUARE:
        return (X)pow(MathAbs(_src - _arg1), (X)2);
      case MATRIX_OPERATION_ABS_DIFF_SQUARE_LOG:
        return (X)pow(log(_src + 1) - log(_arg1 + 1), (X)2);
      case MATRIX_OPERATION_POISSON:
        return (X)(_arg1 - _src * log(_arg1));
      case MATRIX_OPERATION_LOG_COSH:
        // log((exp((b-a)) + exp(-(b-a)))/2)
        return (X)log((exp((_arg1 - _src)) + exp(-(_arg1 - _src))) / (X)2);
      case MATRIX_OPERATION_RELU:
        return Math::ReLU(_src);
      default:
        Print("MatrixDimension::OpSingle(): Invalid operation ", EnumToString(_op), "!");
    }

    return (X)0;
  }

  /**
   * Executes operation on all matrix's values.
   */
  void Op(ENUM_MATRIX_OPERATION _op, X _arg1, X _arg2, X _arg3, X& _out1, X& _out2, int& _out3) {
    int i, k;
    if (type == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      for (i = 0; i < ArraySize(containers); ++i) {
        containers[i].Op(_op, _arg1, _arg2, _arg3, _out1, _out2, _out3);
      }
    } else {
      for (i = 0; i < ArraySize(values); ++i) {
        switch (_op) {
          case MATRIX_OPERATION_ABS:
          case MATRIX_OPERATION_ADD:
          case MATRIX_OPERATION_SUBTRACT:
          case MATRIX_OPERATION_MULTIPLY:
          case MATRIX_OPERATION_DIVIDE:
          case MATRIX_OPERATION_FILL:
          case MATRIX_OPERATION_FILL_RANDOM:
          case MATRIX_OPERATION_FILL_RANDOM_RANGE:
          case MATRIX_OPERATION_POISSON:
          case MATRIX_OPERATION_LOG_COSH:
          case MATRIX_OPERATION_RELU:
            values[i] = OpSingle(_op, values[i], _arg1, _arg2, _arg3);
            break;
          case MATRIX_OPERATION_FILL_POS_ADD:
            values[i] = 0;
            for (k = 0; k < ArraySize(position); ++k) {
              if (position[k] == -1) {
                break;
              }
              values[i] += (X)position[k];
            }
            values[i] += (X)i;
            break;
          case MATRIX_OPERATION_FILL_POS_MUL:
            values[i] = MinOf((X)0);
            for (k = 0; k < ArraySize(position); ++k) {
              if (position[k] == -1) {
                break;
              }
              values[i] = (values[i] == MinOf((X)0)) ? position[k] : values[i] * position[k];
            }
            values[i] = (values[i] == MinOf((X)0)) ? i : values[i] * i;
            break;
          case MATRIX_OPERATION_POWER:
            values[i] = (X)pow(values[i], _arg1);
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
          case MATRIX_OPERATION_ABS_DIFF:
            values[i] = MathAbs(values[i] - _arg1);
            break;
          default:
            Print("MatrixDimension::Op(): Invalid operation ", EnumToString(_op), "!");
        }
      }
    }
  }

  /**
   * Executes operation on the children containers and values. Used internally.
   */
  void Op(ENUM_MATRIX_OPERATION _op, X _arg1 = (X)0, X _arg2 = (X)0, X _arg3 = (X)0) {
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

  void FromArray(X& _array[], int& offset) {
    int i;
    switch (type) {
      case MATRIX_DIMENSION_TYPE_CONTAINERS:
        for (i = 0; i < ArraySize(containers); ++i) {
          containers[i].FromArray(_array, offset);
        }
        break;
      case MATRIX_DIMENSION_TYPE_VALUES:
        for (i = 0; i < ArraySize(values); ++i, ++offset) {
          values[i] = _array[offset];
        }
        break;
    }
  }

  /**
   * Performs operation between current matrix/tensor and another one of the same or lower level.
   */
  void Op(MatrixDimension<X>* _r, ENUM_MATRIX_OPERATION _op, X _arg1 = (X)0, int _only_value_index = -1) {
    int i;
    bool r_is_single = ArraySize(_r.values) == 1;

    if (_r.type == MATRIX_DIMENSION_TYPE_VALUES && ArraySize(_r.values) == 1) {
      // There is only one value in the right container, we will use that value for all operations.
      _only_value_index = 0;
    }

    switch (type) {
      case MATRIX_DIMENSION_TYPE_CONTAINERS:
        switch (_r.type) {
          case MATRIX_DIMENSION_TYPE_CONTAINERS:
            // Both dimensions have containers.
            for (i = 0; i < ArraySize(containers); ++i) {
              containers[i].Op(_r.containers[ArraySize(_r.containers) == 1 ? 0 : i], _op, _arg1);
            }
            break;
          case MATRIX_DIMENSION_TYPE_VALUES:
            // Left dimension have containers, but right dimension have values.
            for (i = 0; i < ArraySize(containers); ++i) {
              // If there is only a single value in the right dimension, use it for all operations inside current
              // container.
              containers[i].Op(_r, _op, _arg1, _only_value_index != -1 ? _only_value_index : i);
            }
            break;
        }
        break;
      case MATRIX_DIMENSION_TYPE_VALUES:
        switch (_r.type) {
          case MATRIX_DIMENSION_TYPE_CONTAINERS:
            // Right dimension have containers.
            if (ArraySize(_r.containers) != 1) {
              Alert("Right container must have exactly one element!");
              return;
            }

            Op(_r.containers[0], _op, _arg1);
            break;

          case MATRIX_DIMENSION_TYPE_VALUES:
            // Left and right dimensions have values or we use single right value.
            for (i = 0; i < ArraySize(values); ++i) {
              values[i] = OpSingle(_op, values[i], _r.values[_only_value_index != -1 ? _only_value_index : i]);
            }

            break;
        }
        break;
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
  int dimensions[MATRIX_DIMENSIONS];

  // Current size of the matrix (all dimensions multiplied).
  int size;

  // Number of matrix dimensions.
  int num_dimensions;

  /**
   * Constructor.
   */
  Matrix(string _data) { FromString(_data); }

  /**
   * Constructor.
   */
  Matrix(const int num_1d = 0, const int num_2d = 0, const int num_3d = 0, const int num_4d = 0, const int num_5d = 0) {
    ptr_first_dimension = NULL;
    SetShape(num_1d, num_2d, num_3d, num_4d, num_5d);
  }

  /**
   * Constructor.
   */
  Matrix(MatrixDimension<X>* _dimension) : ptr_first_dimension(NULL) { Initialize(_dimension); }

  /**
   * Copy constructor.
   */
  Matrix(const Matrix<X>& _right) {
    if (_right.ptr_first_dimension == NULL) {
      return;
    }

    Initialize(_right.ptr_first_dimension.Clone());
  }

  /**
   * Private copy constructor. We don't want to assign Matrix via pointer due to memory leakage.
   */

 private:
  Matrix(const Matrix<X>* _right) {}

 public:
  /**
   * Matrix initializer.
   */
  void Initialize(MatrixDimension<X>* _dimension) {
    if (ptr_first_dimension != NULL) delete ptr_first_dimension;

    ptr_first_dimension = _dimension;
    // Calculating dimensions.
    int i;

    for (i = 0; i < MATRIX_DIMENSIONS; ++i) {
      dimensions[i] = 0;
    }

    for (i = 0; i < MATRIX_DIMENSIONS; ++i) {
      if (_dimension == NULL) break;

      if (_dimension.type == MATRIX_DIMENSION_TYPE_CONTAINERS) {
        dimensions[i] = ArraySize(_dimension.containers);
        _dimension = _dimension.containers[0];
      } else if (_dimension.type == MATRIX_DIMENSION_TYPE_VALUES) {
        dimensions[i++] = ArraySize(_dimension.values);
        break;
      } else {
        Print("Internal error: unknown dimension type!");
      }
    }

    num_dimensions = i;

    RecalculateSize();
  }

  void RecalculateSize() {
    size = 0;

    for (int i = 0; i < ArraySize(dimensions); ++i) {
      if (dimensions[i] != 0) {
        if (size == 0) {
          size = 1;
        }

        size *= dimensions[i];
      }
    }
  }

  /**
   * Assignment operator.
   */
  void operator=(const Matrix<X>& _right) { Initialize(_right.ptr_first_dimension.Clone()); }

  /**
   * Assignment operator. Initializes matrix using given dimension.
   */
  Matrix(MatrixDimensionAccessor<X>& accessor) {
    if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      Initialize(accessor.ptr_dimension.containers[accessor.index].Clone());
    } else if (accessor.Type() == MATRIX_DIMENSION_TYPE_VALUES) {
      SetShape(1);
      this[0] = accessor.Val();
    }
  }

  /**
   * Assignment operator.
   */
  void operator=(string _data) { FromString(_data); }

  /**
   * Destructor.
   */
  ~Matrix() {
    if (ptr_first_dimension != NULL) {
      delete ptr_first_dimension;
    }
  }

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

    int _current_position[] = {0, 0, 0, 0};

    ptr_first_dimension = MatrixDimension<X>::SetDimensions(ptr_first_dimension, dimensions, 0, _current_position);

    // Calculating size.
    size = 0;

    num_dimensions = (num_1d != 0 ? 1 : 0) + (num_2d != 0 ? 1 : 0) + (num_3d != 0 ? 1 : 0) + (num_4d != 0 ? 1 : 0) +
                     (num_5d != 0 ? 1 : 0);

    // Calculating size.
    for (int i = 0; i < MATRIX_DIMENSIONS; ++i) {
      if (dimensions[i] != 0) {
        if (size == 0) {
          size = 1;
        }

        size *= dimensions[i];
      }
    }
  }

  /**
   * Returns length of the given dimension.
   */
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

  void DuplicateDimension(int _level, int _num, int _current_level = 0) {
    if (_num < 1) {
      return;
    }

    if (_level >= GetDimensions()) {
      return;
    }

    int initial_container_size = ptr_first_dimension.DuplicateDimension(_level, _num);
    dimensions[_level] += _num * initial_container_size;
    RecalculateSize();
  }

  /**
   * Returns value at the given position.
   */
  X GetValue(int _pos_1d, int _pos_2d = -1, int _pos_3d = -1, int _pos_4d = -1, int _pos_5d = -1) {
    MatrixDimensionAccessor<X> accessor = this[_pos_1d];

    if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      accessor = accessor[_pos_2d];
      if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
        accessor = accessor[_pos_3d];
        if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
          accessor = accessor[_pos_4d];
          if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
            Alert("Matrix::GetValue(): Internal error. Last dimensions shouldn't be a container!");
          }
        }
      }
    }

    return accessor.Val();
  }

  /**
   * Returns value at the given position (or parent one for missing dimensions, or zero for missing indices).
   */
  X GetValueLossely(int _source_dimensions, int _pos_1d, int _pos_2d = -1, int _pos_3d = -1, int _pos_4d = -1,
                    int _pos_5d = -1) {
    int _shift_dimensions = _source_dimensions - GetDimensions();

    while (_shift_dimensions-- > 0) {
      _pos_1d = _pos_2d;
      _pos_2d = _pos_3d;
      _pos_3d = _pos_4d;
      _pos_4d = _pos_5d;
      _pos_5d = 0;
    }

    if (GetDimensions() < 1) return 0;

    MatrixDimensionAccessor<X> accessor;

    if (_pos_1d >= dimensions[0]) {
      if (dimensions[0] == 1)
        _pos_1d = 0;
      else
        return 0;
    }

    accessor = this[_pos_1d];

    // Returning prematurely if we experienced value instead of a container.
    if (accessor.Type() == MATRIX_DIMENSION_TYPE_VALUES) return accessor.Val();

    if (_pos_2d >= dimensions[1]) {
      if (dimensions[1] == 1)
        _pos_2d = 0;
      else
        return 0;
    }

    accessor = accessor[_pos_2d];

    // Returning prematurely if we experienced value instead of a container.
    if (accessor.Type() == MATRIX_DIMENSION_TYPE_VALUES) return accessor.Val();

    if (_pos_3d >= dimensions[2]) {
      if (dimensions[2] == 1)
        _pos_3d = 0;
      else
        return 0;
    }

    accessor = accessor[_pos_3d];

    // Returning prematurely if we experienced value instead of a container.
    if (accessor.Type() == MATRIX_DIMENSION_TYPE_VALUES) return accessor.Val();

    if (_pos_4d >= dimensions[3]) {
      if (dimensions[3] == 1)
        _pos_4d = 0;
      else
        return 0;
    }

    accessor = accessor[_pos_4d];

    // Returning prematurely if we experienced value instead of a container.
    if (accessor.Type() == MATRIX_DIMENSION_TYPE_VALUES) return accessor.Val();

    if (_pos_5d >= dimensions[4]) {
      if (dimensions[4] == 1)
        _pos_5d = 0;
      else
        return 0;
    }

    accessor = accessor[_pos_5d];

    // Returning prematurely if we experienced value instead of a container.
    if (accessor.Type() == MATRIX_DIMENSION_TYPE_VALUES) return accessor.Val();

    Alert("Matrix::GetValueLossely(): Internal error. Last dimensions shouldn't be a container!");

    return 0;
  }

  /**
   * Returns values at the given position.
   */
  void SetValue(X _value, int _pos_1d, int _pos_2d = -1, int _pos_3d = -1, int _pos_4d = -1, int _pos_5d = -1) {
    MatrixDimensionAccessor<X> accessor = this[_pos_1d];

    if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
      accessor = accessor[_pos_2d];
      if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
        accessor = accessor[_pos_3d];
        if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
          accessor = accessor[_pos_4d];
          if (accessor.Type() == MATRIX_DIMENSION_TYPE_CONTAINERS) {
            Alert("Matrix::GetValue(): Internal error. Last dimensions shouldn't be a container!");
          }
        }
      }
    }

    accessor = _value;
  }

  /**
   * Increments all existing matrix's values by given one.
   */
  void operator+=(X value) { Add(value); }

  /**
   * Makes all values absolute (negatives becomes positive).
   */
  void Abs() {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_ABS);
    }
  }

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
  void FillRandom(int _seed = -1) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_FILL_RANDOM, _seed);
    }
  }

  /**
   * Replaces existing matrix's values by random value from a given range.
   */
  void FillRandom(X _start, X _end, int _seed = -1) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_FILL_RANDOM_RANGE, _start, _end, _seed);
    }
  }

  /**
   * Fills matrix with values which are sum of all the matrix coordinates.
   */
  void FillPosAdd() {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_FILL_POS_ADD);
    }
  }

  /**
   * Fills matrix with values which are multiply of all the matrix coordinates.
   */
  void FillPosMul() {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_FILL_POS_MUL);
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
      return GetSize() > 0 ? _out1 / GetSize() : 0;
    }
    return MinOf((X)0);
  }

  void Power(X value) {
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_POWER, value);
    }
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

      return (X)median;
    }
    return MinOf((X)0);
  }

  static void MatMul(Matrix<X>& source, Matrix<X>& target, Matrix<X>& output) {
    if (source.GetSize() != target.GetRange(1)) {
      Alert("Inconsistent size of matrices!");
    }

    int num_outputs = target.GetRange(0);
    int num_inputs = target.GetRange(1);

    output.SetShape(num_outputs);

    for (int output_idx = 0; output_idx < num_outputs; ++output_idx) {
      output[output_idx] = 0;
      for (int input_idx = 0; input_idx < num_inputs; ++input_idx) {
        output[output_idx] += source[input_idx].Val() * target[output_idx][input_idx].Val();
      }
    }
  }

  /**
   * Performs matrix multiplication.
   */
  Matrix<X>* MatMul(Matrix<X>& target) {
    Matrix<X>* output = new Matrix<X>();
    MatMul(this, target, output);
    return output;
  }

  /**
   * Performs matrix multiplication.
   */
  Matrix<X>* operator^(Matrix<X>& target) { return MatMul(target); }

  /**
   * Performs in-place matrix multiplication.
   */
  void operator^=(Matrix<X>& target) {
    Matrix<X> result;
    MatMul(this, target, result);
    this = result;
  }

  /**
   * Matrix-matrix addition operator.
   */
  Matrix<X>* operator+(const Matrix<X>& r) {
    Matrix<X>* result = Clone();

    if (result.ptr_first_dimension) {
      result.ptr_first_dimension.Op(r.ptr_first_dimension, MATRIX_OPERATION_ADD);
    }

    return result;
  }

  /**
   * Matrix-matrix inplace addition operator.
   */
  void operator+=(const Matrix<X>& r) {
    if (ptr_first_dimension && r.ptr_first_dimension) {
      ptr_first_dimension.Op(r.ptr_first_dimension, MATRIX_OPERATION_ADD);
    }
  }

  /**
   * Matrix-matrix subtraction operator.
   */
  Matrix<X>* operator-(const Matrix<X>& r) {
    Matrix<X>* result = Clone();

    if (result.ptr_first_dimension) {
      result.ptr_first_dimension.Op(r.ptr_first_dimension, MATRIX_OPERATION_SUBTRACT);
    }

    return result;
  }

  /**
   * Matrix-matrix inplace subtraction operator.
   */
  void operator-=(const Matrix<X>& r) {
    if (ptr_first_dimension && r.ptr_first_dimension) {
      ptr_first_dimension.Op(r.ptr_first_dimension, MATRIX_OPERATION_SUBTRACT);
    }
  }

  /**
   * Matrix-matrix multiplication operator.
   */
  Matrix<X>* operator*(const Matrix<X>& r) {
    Matrix<X>* result = Clone();

    if (result.ptr_first_dimension) {
      result.ptr_first_dimension.Op(r.ptr_first_dimension, MATRIX_OPERATION_MULTIPLY);
    }

    return result;
  }

  /**
   * Matrix-matrix inplace multiplication operator.
   */
  void operator*=(const Matrix<X>& r) {
    if (ptr_first_dimension && r.ptr_first_dimension) {
      ptr_first_dimension.Op(r.ptr_first_dimension, MATRIX_OPERATION_MULTIPLY);
    }
  }

  /**
   * Matrix-matrix division operator.
   */
  Matrix<X>* operator/(const Matrix<X>& r) {
    Matrix<X>* result = Clone();

    if (result.ptr_first_dimension) {
      result.ptr_first_dimension.Op(r.ptr_first_dimension, MATRIX_OPERATION_DIVIDE);
    }

    return result;
  }

  /**
   * Matrix-matrix inplace division operator.
   */
  void operator/=(const Matrix<X>& r) {
    if (ptr_first_dimension && r.ptr_first_dimension) {
      ptr_first_dimension.Op(r.ptr_first_dimension, MATRIX_OPERATION_DIVIDE);
    }
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
   * Flattens matrix.
   */
  Matrix<X>* Flatten() {
    X values[];

    GetRawArray(values);

    Matrix<X>* result = new Matrix<X>(ArraySize(values));

    for (int i = 0; i < ArraySize(values); ++i) {
      result[i] = values[i];
    }

    return result;
  }

  /**
   * Initializer that generates tensors with a uniform distribution.
   */
  void FillRandomUniform(X _min, X _max, int _seed = -1) { FillRandom(_min, _max, _seed); }

#ifdef USE_MQL_MATH_STAT
  /**
   * Initializer that generates tensors with a normal distribution.
   */
  void FillRandomNormal(X _mean, X _stddev, int _seed = -1) {
#ifdef __MQL5__
    if (_seed != -1) {
      Print("Matrix::FillRandomNormal(): _seed parameter is not yet implemented! Please use -1 as _seed.");
    }

    double _values[];
    MathRandomNormal(_mean, _stddev, GetSize(), _values);
    FillFromArray(_values);
#else
    Print("Matrix::FillRandomNormal() is implemented only in MQL5!");
#endif
  }
#endif

  void FillFromArray(X& _array[]) {
    if (ArraySize(_array) != GetSize()) {
      Print("Matrix::FillFromArray(): input array (", ArraySize(_array), " elements) must be the same size as matrix (",
            GetSize(), " elements)!");
    }

    int offset = 0;
    ptr_first_dimension.FromArray(_array, offset);
  }

  /**
   * Initializer that generates a truncated normal distribution.
   */
  void FillTruncatedNormal(X _mean, X _stddev, int _seeds = -1) {
    Print("Matrix::FillTruncatedNormal() is not yet implemented!");
  }

  /**
   * The Glorot normal initializer, also called Xavier normal initializer.
   */
  void FillGlorotNormal(int _seed = -1) { Print("Matrix::FillGlorotNormal() is not yet implemented!"); }

  /**
   * The Glorot uniform initializer, also called Xavier uniform initializer.
   */
  void FillGlorotUniform(int _seed = -1) { Print("Matrix::FillGlorotUniform() is not yet implemented!"); }

  /**
   * Initializer that generates the identity matrix.
   */
  void FillIdentity(X _gain = (X)1) {
    if (GetDimensions() != 2) {
      Print("Matrix::FillIdentity() has no sense in the non-2d matrix!");
      return;
    }
    if (GetRange(0) != GetRange(1)) {
      Print("Matrix::FillIdentity(): Both dimensions should have exact size! Passed ", Repr(), ".");
      return;
    }
    Fill(0);
    for (int i = 0; i < GetRange(0); ++i) {
      this[i][i] = _gain;
    }
  }

  /**
   * Initializer that generates an orthogonal matrix.
   */
  void FillOrthogonal(X _gain, int _seed = -1) { Print("Matrix::FillOrthogonal() is not yet implemented!"); }

  /**
   * Calculates absolute difference between this tensor and given one using optional weights tensor.
   */
  Matrix<X>* Mean(ENUM_MATRIX_OPERATION _abs_diff_op, ENUM_MATRIX_OPERATION _reduction, Matrix<X>* _prediction,
                  Matrix<X>* _weights = NULL) {
    switch (_abs_diff_op) {
      case MATRIX_OPERATION_ABS_DIFF:
      case MATRIX_OPERATION_ABS_DIFF_SQUARE:
      case MATRIX_OPERATION_ABS_DIFF_SQUARE_LOG:
        break;
      default:
        Print("Mean(): Unsupported absolute difference operator: ", EnumToString(_abs_diff_op), "!");
    }

    if (!ShapeCompatible(&this, _prediction)) {
      Print("MeanAbsolute(): Shape ", Repr(), " is not compatible with prediction shape ", _prediction.Repr(), "!");
      return NULL;
    }

    if (_weights != NULL && _weights.GetDimensions() > this.GetDimensions()) {
      Print("MeanAbsolute(): Shape ", Repr(), ": Weights must be a tensor level <= ", this.GetDimensions(), "!");
      return NULL;
    }

    Matrix<X>*_matrix, *_pooled;

    // We'll be working on copy of the current tensor.
    _matrix = Clone();

    // Calculating absolute difference between copied tensor and given prediction.
    _matrix.ptr_first_dimension.Op(_prediction.ptr_first_dimension, _abs_diff_op);

    switch (_abs_diff_op) {
      case MATRIX_OPERATION_ABS_DIFF_SQUARE:
      case MATRIX_OPERATION_ABS_DIFF_SQUARE_LOG:
        // Reducing values of the last dimension of the matrix.
        _pooled = _matrix.GetPooled(_reduction, MATRIX_PADDING_SAME, dimensions[1] == 0 ? dimensions[0] : 1,
                                    dimensions[2] == 0 ? dimensions[1] : 1, dimensions[3] == 0 ? dimensions[2] : 1,
                                    dimensions[4] == 0 ? dimensions[3] : 1, dimensions[5] == 0 ? dimensions[4] : 1);

        // Physically reducing last dimension of the matrix.
        _pooled.ReduceSimple();
        delete _matrix;
        _matrix = _pooled;
        break;
    }

    if (_weights != NULL) {
      // Multiplying copied tensor by given weights. Note that weights tensor could be of lower level than original
      // tensor.
      _matrix.ptr_first_dimension.Op(_weights.ptr_first_dimension, MATRIX_OPERATION_MULTIPLY);
    }

    return _matrix;
  }

  /**
   * Reduces single or all dimensions containing only a single value.
   */
  void ReduceSimple(bool _only_last_dimension = true, ENUM_MATRIX_OPERATION _reduce_op = MATRIX_OPERATION_SUM) {
    if (ptr_first_dimension != NULL) {
      ptr_first_dimension.ReduceSimple(_only_last_dimension ? GetDimensions() - 1 : 0, _reduce_op);
    }
  }

  void Reduce(int _level = 0, ENUM_MATRIX_OPERATION _reduce_op = MATRIX_OPERATION_SUM) {
    if (ptr_first_dimension == NULL) {
      return;
    }

    ptr_first_dimension.Reduce(_level, _reduce_op);

    for (int i = _level + 1; i < MATRIX_DIMENSIONS; ++i) {
      dimensions[i] = 0;
    }

    RecalculateSize();
  }

  /**
   * Computes the Poisson loss
   */
  Matrix<X>* Poisson(Matrix<X>* _prediction) {
    if (ptr_first_dimension == NULL) {
      return NULL;
    }
    Matrix<X>* _clone = Clone();
    _clone.ptr_first_dimension.Op(_prediction.ptr_first_dimension, MATRIX_OPERATION_POISSON);
    return _clone;
  }

  /**
   * Reduces matrix using vector math.
   *
   * Use _dimension = -1 for last dimension.
   *
   * @todo Support multiple dimensions for reduction.
   */
  Matrix<X>* VectorReduce(Matrix<X>* _product, ENUM_MATRIX_VECTOR_REDUCE _reduce, int _dimension = 0) {
    if (_dimension == -1) _dimension = GetDimensions() - 1;

    if (!ShapeCompatibleLossely(&this, _product)) {
      // Alert("VectorReduce(): Incompatible shapes: ", Repr(), " and ", _product.Repr(), "!");
      // return NULL;
    }

    int i, k, _index[] = {0, 0, 0, 0, 0, 0, 0};

    // Preparing dimension indices.
    for (i = 0; i < MATRIX_DIMENSIONS; ++i) {
      if (dimensions[i] == 0) break;

      _index[i] = 0;
    }

    int _out_dims[MATRIX_DIMENSIONS] = {0, 0, 0, 0, 0};
    int _out_index[MATRIX_DIMENSIONS] = {0, 0, 0, 0, 0};

    // Calculating output matrix dimensions.
    for (i = 0, k = 0; i < GetDimensions(); ++i) {
      if (i != _dimension) {
        _out_dims[k++] = dimensions[i];
      }
    }

    Matrix<X>* _ptr_result = new Matrix<X>(_out_dims[0], _out_dims[1], _out_dims[2], _out_dims[3], _out_dims[4]);

    int _curr_dimension = 0;
    bool _stop = false;

    while (!_stop) {
      X _dot = 0, _mag1 = 0, _mag2 = 0;

      for (i = 0, k = 0; i < GetDimensions(); ++i) {
        if (i != _dimension) {
          _out_index[k++] = _index[i];
        }
      }

      X _aux1 = 0, _aux2 = 0, _aux3 = 0, _aux4 = 0;
      int _aux5 = 0;

      // Taking one group at a time.
      for (int b = 0; b < dimensions[_dimension]; ++b) {
        X _value_a = GetValue(_index[0], _index[1], _index[2], _index[3], _index[4]);
        X _value_b = _product.GetValueLossely(GetDimensions(), _index[0], _index[1], _index[2], _index[3], _index[4]);

        switch (_reduce) {
          case MATRIX_VECTOR_REDUCE_COSINE_SIMILARITY:
            // Dot.
            _aux1 += _value_a * _value_b;
            // Mag1.
            _aux2 += _value_a * _value_a;
            // Mag2.
            _aux3 += _value_b * _value_b;
            break;

          case MATRIX_VECTOR_REDUCE_HINGE_LOSS:
            // Sum.
            _aux1 += MathMax(0, 1 - _value_a * _value_b);
            // Counter.
            _aux5 += 1;
            break;
        }

        ++_index[_dimension];
      }

      _index[_dimension] = 0;

      X _res = 0;

      switch (_reduce) {
        case MATRIX_VECTOR_REDUCE_COSINE_SIMILARITY:
          _res = (X)(_aux1 / (sqrt(_aux2) * sqrt(_aux3)));
          break;

        case MATRIX_VECTOR_REDUCE_HINGE_LOSS:
          // Res = Sum / Count.
          _res = _aux1 / _aux5;
          break;
      }

      _ptr_result.SetValue(_res, _out_index[0], _out_index[1], _out_index[2], _out_index[3], _out_index[4]);

      if (_dimension == 0)
        ++_index[1];
      else
        ++_index[0];

      for (k = 0; k < GetDimensions(); ++k) {
        if (_index[k] >= dimensions[k]) {
          if (k >= GetDimensions() - 1) {
            // No more dimensions.
            _stop = true;
            break;
          }

          _index[k] = 0;

          if (k + 1 == _dimension) {
            if (_dimension == GetDimensions() - 1) {
              // Incrementing last dimension have no sense, stopping.
              _stop = true;
              break;
            }
            ++_index[k + 2];
          } else
            ++_index[k + 1];
        }
      }
    }

    return _ptr_result;
  }

  Matrix<X>* CosineSimilarity(Matrix<X>* _product, int _dimension = 0) {
    return VectorReduce(_product, MATRIX_VECTOR_REDUCE_COSINE_SIMILARITY, _dimension);
  }

  Matrix<X>* HingeLoss(Matrix<X>* _product) { return VectorReduce(_product, MATRIX_VECTOR_REDUCE_HINGE_LOSS, -1); }

  /**
   * Calculates absolute difference between this tensor and given one using optional weights tensor.
   */
  Matrix<X>* MeanAbsolute(Matrix<X>* _prediction, ENUM_MATRIX_OPERATION _reduction, Matrix<X>* _weights = NULL) {
    return Mean(MATRIX_OPERATION_ABS_DIFF, _reduction, _prediction, _weights);
  }

  /**
   * Calculates squared absolute difference between this tensor and given one using optional weights tensor.
   */
  Matrix<X>* MeanSquared(Matrix<X>* _prediction, ENUM_MATRIX_OPERATION _reduction, Matrix<X>* _weights = NULL) {
    return Mean(MATRIX_OPERATION_ABS_DIFF_SQUARE, _reduction, _prediction, _weights);
  }

  /**
   * Calculates logarithmic squared absolute difference between this tensor and given one using optional weights tensor.
   */
  Matrix<X>* MeanSquaredLogarithmic(Matrix<X>* _prediction, ENUM_MATRIX_OPERATION _reduction,
                                    Matrix<X>* _weights = NULL) {
    return Mean(MATRIX_OPERATION_ABS_DIFF_SQUARE_LOG, _reduction, _prediction, _weights);
  }

  /**
   * Calculates mean absolute using given reduction operation and optionally, weights tensor.
   */
  X MeanReduced(ENUM_MATRIX_OPERATION _abs_diff_op, ENUM_MATRIX_OPERATION _reduction, Matrix<X>* _prediction,
                Matrix<X>* _weights = NULL) {
    Matrix<X>* _diff = Mean(_abs_diff_op, _reduction, _prediction, _weights);

    X result;

    switch (_reduction) {
      case MATRIX_OPERATION_SUM:
        result = _diff.Sum();
        break;
      case MATRIX_OPERATION_MIN:
        result = _diff.Min();
        break;
      case MATRIX_OPERATION_MAX:
        result = _diff.Max();
        break;
      case MATRIX_OPERATION_AVG:
        result = _diff.Avg();
        break;
      case MATRIX_OPERATION_MED:
        result = _diff.Med();
        break;
      default:
        Print("MeanAbsolute(): Unsupported reduction type: ", EnumToString(_reduction), "!");
        return MinOf((X)0);
    }

    delete _diff;

    return result;
  }

  /**
   * Calculates mean absolute using given reduction operation and optionally, weights tensor.
   */
  X MeanAbsolute(ENUM_MATRIX_OPERATION _reduction, Matrix<X>* _prediction, Matrix<X>* _weights = NULL) {
    return MeanReduced(MATRIX_OPERATION_ABS_DIFF, _reduction, _prediction, _weights);
  }

  /**
   * Calculates squared mean absolute using given reduction operation and optionally, weights tensor.
   */
  X MeanSquared(ENUM_MATRIX_OPERATION _reduction, Matrix<X>* _prediction, Matrix<X>* _weights = NULL) {
    return MeanReduced(MATRIX_OPERATION_ABS_DIFF_SQUARE, _reduction, _prediction, _weights);
  }

  /**
   * Calculates logarithmic squared mean absolute using given reduction operation and optionally, weights tensor.
   */
  X MeanSquaredLogarithmic(ENUM_MATRIX_OPERATION _reduction, Matrix<X>* _prediction, Matrix<X>* _weights = NULL) {
    return MeanReduced(MATRIX_OPERATION_ABS_DIFF_SQUARE_LOG, _reduction, _prediction, _weights);
  }

  /**
   * ReLU activator.
   */
  Matrix<X>* Relu() {
    Matrix<X>* result = Clone();
    result.Relu_();
    return result;
  }

  /**
   * Inplace ReLU activator.
   */
  void Relu_() {
    X _out1 = 0, _out2;
    int _out3;
    if (ptr_first_dimension) {
      ptr_first_dimension.Op(MATRIX_OPERATION_RELU, 0, 0, 0, _out1, _out2, _out3);
    }
  }

  /**
   * Clones current matrix.
   */
  Matrix<X>* Clone() const {
    Matrix<X>* _cloned = new Matrix<X>(dimensions[0], dimensions[1], dimensions[2], dimensions[3], dimensions[4]);
    _cloned.ptr_first_dimension.CopyFrom(ptr_first_dimension);
    return _cloned;
  }

  /**
   * Sets value of the given matrix's dimension.
   *
   * @todo Deep version of this method.
   */

  void Set(X value, const int _1d, const int _2d = -1, const int _3d = -1, const int _4d = -1, const int _5d = -1) {
    if (_2d == -1) {
      this[_1d] = value;
    } else if (_3d == -1) {
      this[_1d][_2d] = value;
    } else if (_4d == -1) {
      this[_1d][_2d][_3d] = value;
    } else if (_5d == -1) {
      this[_1d][_2d][_3d][_4d] = value;
    } else {
      this[_1d][_2d][_3d][_4d][_5d] = value;
    }
  }

  Matrix<X>* GetConv2d(int _in_channels, int _out_channels, int _krn_1d, int _krn_2d,
                       int _stride_1d = MATRIX_STRIDE_AS_POOL, int _stride_2d = MATRIX_STRIDE_AS_POOL,
                       Matrix<X>* _weights = NULL) {
    if (dimensions[0] < _in_channels) {
      Alert("Insufficient number of channels in the input. First dimensions should have ", _in_channels,
            " arrays, got ", dimensions[0]);
      return NULL;
    }

    Matrix<X>* clone = Clone();

    clone.DuplicateDimension(1, _out_channels - 1);

    if (_weights != NULL) {
      Matrix<X>* weight_flattened = _weights.Flatten();
      for (int _in_channel_idx = 0; _in_channel_idx < _in_channels; ++_in_channel_idx) {
        clone.ptr_first_dimension.containers[_in_channel_idx].Op(weight_flattened.ptr_first_dimension,
                                                                 MATRIX_OPERATION_MULTIPLY);
      }
      delete weight_flattened;
    }

    Matrix<X>* pooled =
        clone.GetPooled(MATRIX_OPERATION_SUM, MATRIX_PADDING_VALID, 1, 2, _krn_1d, _krn_2d, 0,  // Kernel size.
                        1, 2, _stride_1d, _stride_2d);

    delete clone;
    return pooled;
  }

  static void GetPooledSize(ENUM_MATRIX_PADDING _padding, int _dim_1d, int _dim_2d, int _dim_3d, int _dim_4d,
                            int _dim_5d, int _pool_1d, int _pool_2d, int _pool_3d, int _pool_4d, int _pool_5d,
                            int _stride_1d, int _stride_2d, int _stride_3d, int _stride_4d, int _stride_5d,
                            int& _out_1d, int& _out_2d, int& _out_3d, int& _out_4d, int& _out_5d) {
    // Calculating resulting matrix required sizes per dimension.

#define _MATRIX_CHECK_POOL_AND_STRIDE(num)                 \
  if (_pool_##num##d == 0) _pool_##num##d = _dim_##num##d; \
  if (_stride_##num##d == MATRIX_STRIDE_AS_POOL)           \
    _stride_##num##d = _pool_##num##d;                     \
  else if (_stride_##num##d == 0) {                        \
    _stride_##num##d = 1;                                  \
  }

    _MATRIX_CHECK_POOL_AND_STRIDE(1);
    _MATRIX_CHECK_POOL_AND_STRIDE(2);
    _MATRIX_CHECK_POOL_AND_STRIDE(3);
    _MATRIX_CHECK_POOL_AND_STRIDE(4);
    _MATRIX_CHECK_POOL_AND_STRIDE(5);

    if (_padding == MATRIX_PADDING_VALID) {
      _out_1d = _stride_1d > 0 ? int(MathCeil(((X)_dim_1d - _pool_1d + 1) / _stride_1d))
                               : 0;  // (3 - z2 + 1) / 2  =  Ceil(1)    = 1
      _out_2d = _out_1d == 0 ? 0
                             : (_stride_2d > 0 ? int(MathCeil(((X)_dim_2d - _pool_2d + 1) / _stride_2d))
                                               : 0);  // (2 - 2 + 1) / 2  =  Ceil(0.5)  = 1
      _out_3d = _out_2d == 0 ? 0 : (_stride_3d > 0 ? int(MathCeil(((X)_dim_3d - _pool_3d + 1) / _stride_3d)) : 0);
      _out_4d = _out_3d == 0 ? 0 : (_stride_4d > 0 ? int(MathCeil(((X)_dim_4d - _pool_4d + 1) / _stride_4d)) : 0);
      _out_5d = _out_4d == 0 ? 0 : (_stride_5d > 0 ? int(MathCeil(((X)_dim_5d - _pool_5d + 1) / _stride_5d)) : 0);
    } else {
      _out_1d =
          _stride_1d > 0 ? int(_stride_1d == 0 ? 0 : ceil((X)_dim_1d / _stride_1d)) : 0;  // 3 / 2  =  Ceil(1.5)  =  2
      _out_2d = _out_1d == 0 ? 0
                             : (_stride_2d > 0 ? int(_stride_2d == 0 ? 0 : ceil((X)_dim_2d / _stride_2d))
                                               : 0);  // 2 / 2  =  Ceil(1) = 1
      _out_3d = _out_2d == 0 ? 0 : (_stride_3d > 0 ? int(_stride_3d == 0 ? 0 : ceil((X)_dim_3d / _stride_3d)) : 0);
      _out_4d = _out_3d == 0 ? 0 : (_stride_4d > 0 ? int(_stride_4d == 0 ? 0 : ceil((X)_dim_4d / _stride_4d)) : 0);
      _out_5d = _out_4d == 0 ? 0 : (_stride_5d > 0 ? int(_stride_5d == 0 ? 0 : ceil((X)_dim_5d / _stride_5d)) : 0);
    }
  }

  static int GetPooledSizeTotal(ENUM_MATRIX_PADDING _padding, int _dim_1d, int _dim_2d, int _dim_3d, int _dim_4d,
                                int _dim_5d, int _pool_1d, int _pool_2d, int _pool_3d, int _pool_4d, int _pool_5d,
                                int _stride_1d, int _stride_2d, int _stride_3d, int _stride_4d, int _stride_5d) {
    int _dimensions[MATRIX_DIMENSIONS];

    GetPooledSize(_padding, _dim_1d, _dim_2d, _dim_3d, _dim_4d, _dim_5d, _pool_1d, _pool_2d, _pool_3d, _pool_4d,
                  _pool_5d, _stride_1d, _stride_2d, _stride_3d, _stride_4d, _stride_5d, _dimensions[0], _dimensions[1],
                  _dimensions[2], _dimensions[3], _dimensions[4]);

    return GetDimensionsTotal(_dimensions);
  }

  static int GetDimensionsTotal(int& dimensions[]) {
    int size = 0;

    for (int i = 0; i < ArraySize(dimensions); ++i) {
      if (dimensions[i] != 0) {
        if (size == 0) {
          size = 1;
        }

        size *= dimensions[i];
      }
    }

    return size;
  }

  /**
   * Returns matrix reduces by given method (avg, min, max) using pooling.
   *
   * Stride, when set to 0, will revert back to 1.
   */
  Matrix<X>* GetPooled(ENUM_MATRIX_OPERATION _op, ENUM_MATRIX_PADDING _padding, int _pool_1d = 0, int _pool_2d = 0,
                       int _pool_3d = 0, int _pool_4d = 0, int _pool_5d = 0, int _stride_1d = MATRIX_STRIDE_AS_POOL,
                       int _stride_2d = MATRIX_STRIDE_AS_POOL, int _stride_3d = MATRIX_STRIDE_AS_POOL,
                       int _stride_4d = MATRIX_STRIDE_AS_POOL, int _stride_5d = MATRIX_STRIDE_AS_POOL) {
    int _out_1d, _out_2d, _out_3d, _out_4d, _out_5d;

#define _MATRIX_STRIDE_AS_POOL_MAYBE(dim)          \
  if (_stride_##dim##d == MATRIX_STRIDE_AS_POOL) { \
    _stride_##dim##d = _pool_##dim##d;             \
  }

    _MATRIX_STRIDE_AS_POOL_MAYBE(1);
    _MATRIX_STRIDE_AS_POOL_MAYBE(2);
    _MATRIX_STRIDE_AS_POOL_MAYBE(3);
    _MATRIX_STRIDE_AS_POOL_MAYBE(4);
    _MATRIX_STRIDE_AS_POOL_MAYBE(5);

    GetPooledSize(_padding, dimensions[0], dimensions[1], dimensions[2], dimensions[3], dimensions[4], _pool_1d,
                  _pool_2d, _pool_3d, _pool_4d, _pool_5d, _stride_1d, _stride_2d, _stride_3d, _stride_4d, _stride_5d,
                  _out_1d, _out_2d, _out_3d, _out_4d, _out_5d);

    Matrix<X>* _result = new Matrix<X>(_out_1d, _out_2d, _out_3d, _out_4d, _out_5d);

// If limit is 0 then var will end up as -1 and no loop will be performed.
// If limit is not 0 then normal for(var = 0; var < limit; ++var) will be performed.
#define _MATRIX_FOR_OR_MINUS_1(var, limit) \
  for (int var = (limit == 0 ? -1 : 0); (limit == 0) ? var == -1 : var < limit; ++var)

    _MATRIX_FOR_OR_MINUS_1(_chunk_1d, _out_1d) {
      _MATRIX_FOR_OR_MINUS_1(_chunk_2d, _out_2d) {
        _MATRIX_FOR_OR_MINUS_1(_chunk_3d, _out_3d) {
          _MATRIX_FOR_OR_MINUS_1(_chunk_4d, _out_4d) {
            _MATRIX_FOR_OR_MINUS_1(_chunk_5d, _out_5d) {
              X result =
                  ChunkOp(_op, _padding, _pool_1d, _pool_2d, _pool_3d, _pool_4d, _pool_5d, _stride_1d, _stride_2d,
                          _stride_3d, _stride_4d, _stride_5d, _chunk_1d, _chunk_2d, _chunk_3d, _chunk_4d, _chunk_5d);

              _result.Set(result, _chunk_1d, _chunk_2d, _chunk_3d, _chunk_4d, _chunk_5d);
            }
          }
        }
      }
    }

    return _result;
  }

  /**
   * Performs given operation on the multidimensional data, taking into consideration pool/chunk size, stride and
   * paddings previously calculated by GetPooled().
   */
  X ChunkOp(ENUM_MATRIX_OPERATION _op, ENUM_MATRIX_PADDING _padding, const int _pool_1d, const int _pool_2d,
            const int _pool_3d, const int _pool_4d, const int _pool_5d, const int _stride_1d, const int _stride_2d,
            const int _stride_3d, const int _stride_4d, const int _stride_5d, const int _chunk_1d, const int _chunk_2d,
            const int _chunk_3d, const int _chunk_4d, const int _chunk_5d) {
#define _MATRIX_FOR_DIM(dim)                                                                                       \
  int _start_##dim##d = _chunk_##dim##d == -1 ? 0 : (_chunk_##dim##d * _stride_##dim##d);                          \
  for (int d##dim = (_chunk_##dim##d == -1) ? (dimensions[dim - 1] != 0 ? _start_##dim##d : -1) : _start_##dim##d; \
       (d##dim == -1 || d##dim < _start_##dim##d + _pool_##dim##d); ++d##dim)

    X value = 0;
    MatrixDimensionAccessor<X> _accessor_d1, _accessor_d2, _accessor_d3, _accessor_d4, _accessor_d5;

#define _MATRIX_AGGR(val)    \
  ++_count;                  \
  _min = MathMin(_min, val); \
  _max = MathMax(_max, val); \
  _sum += val;

    int _count = 0;
    X _min = MaxOf((X)0);
    X _max = MinOf((X)0);
    X _sum = 0;
    X _avg = 0;

    X _val;

    _MATRIX_FOR_DIM(1) {
      bool _d1_valid = d1 < dimensions[0] && d1 >= 0;
      if (!_d1_valid) {
        // We don't aggreate zeroes.
        continue;
      } else {
        // First dimension have values?
        _accessor_d1 = this[d1];

        if (_accessor_d1.Type() == MATRIX_DIMENSION_TYPE_VALUES) {
          _MATRIX_AGGR(ptr_first_dimension.values[d1]);
          continue;
        }

        _MATRIX_FOR_DIM(2) {
          bool _d2_valid = d2 < dimensions[1] && d2 >= 0;
          if (!_d2_valid) {
            // We don't aggreate zeroes.
            continue;
          } else {
            // Second dimension have values?
            _accessor_d2 = _accessor_d1[d2];

            if (_accessor_d2.Type() == MATRIX_DIMENSION_TYPE_VALUES) {
              _val = _accessor_d2.Val();
              _MATRIX_AGGR(_val);
              continue;
            }

            _MATRIX_FOR_DIM(3) {
              bool _d3_valid = d3 < dimensions[2] && d3 >= 0;
              if (!_d3_valid) {
                // We don't aggreate zeroes.
                continue;
              } else {
                // Third dimension have values?
                _accessor_d3 = _accessor_d2[d3];

                if (_accessor_d3.Type() == MATRIX_DIMENSION_TYPE_VALUES) {
                  _val = _accessor_d3.Val();
                  _MATRIX_AGGR(_val);
                  continue;
                }

                _MATRIX_FOR_DIM(4) {
                  bool _d4_valid = d4 < dimensions[3] && d4 >= 0;
                  if (!_d4_valid) {
                    // We don't aggreate zeroes.
                    continue;
                  } else {
                    // Fourth dimension have values?
                    _accessor_d4 = _accessor_d3[d4];

                    if (_accessor_d4.Type() == MATRIX_DIMENSION_TYPE_VALUES) {
                      _val = _accessor_d4.Val();
                      _MATRIX_AGGR(_val);
                      continue;
                    }

                    _MATRIX_FOR_DIM(5) {
                      bool _d5_valid = d5 < dimensions[4] && d5 >= 0;
                      if (!_d5_valid) {
                        // We don't aggreate zeroes.
                        continue;
                      } else {
                        // Fifth dimension have values?
                        _accessor_d5 = _accessor_d4[d5];

                        if (_accessor_d4.Type() == MATRIX_DIMENSION_TYPE_VALUES) {
                          _val = _accessor_d5.Val();
                          _MATRIX_AGGR(_val);
                          continue;
                        } else {
                          Print("Matrix::ChunkOp(): Internal error. 5th dimension shouldn't have containers!");
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    _avg = _sum / _count;

    switch (_op) {
      case MATRIX_OPERATION_MIN:
        return _min;
      case MATRIX_OPERATION_MAX:
        return _max;
      case MATRIX_OPERATION_SUM:
        return _sum;
      case MATRIX_OPERATION_AVG:
        return _avg;
      default:
        Print("Matrix::ChunkOp(): Invalid operation ", EnumToString(_op), "!");
    }

    return 0;
  }

  /**
   * Checks whether both matrices have the same dimensions' length.
   */
  static bool ShapeCompatible(Matrix<X>* _a, Matrix<X>* _b) { return _a.Repr() == _b.Repr(); }

  /**
   * Checks whether right matrix have less or equal dimensions' length..
   */
  static bool ShapeCompatibleLossely(Matrix<X>* _a, Matrix<X>* _b) {
    if (_b.GetDimensions() > _a.GetDimensions()) return false;

    for (int i = 0; i < _b.GetDimensions(); ++i) {
      if (_b.dimensions[i] != 1 && _b.dimensions[i] > _a.dimensions[i]) return false;
    }

    return true;
  }

  static Matrix<X>* CreateFromString(string text) {
    Matrix<X>* _ptr_matrix = new Matrix<X>();

    _ptr_matrix.FromString(text);

    return _ptr_matrix;
  }

  void FromString(string text) {
    MatrixDimension<X>*_dimensions[], *_root_dimension = NULL;
    int _dimensions_length[MATRIX_DIMENSIONS] = {0, 0, 0, 0, 0};
    int i, _number_start_pos;
    bool _had_values;
    X _number;
    bool _expecting_value_or_child = true;
    bool _expecting_comma = false;
    bool _expecting_end = false;

    for (i = 0; i < StringLen(text); ++i) {
      unsigned short _char = StringGetCharacter(text, i), c;

      switch (_char) {
        case '[':
          if (!_expecting_value_or_child) {
            Print("Unexpected '[' at offset ", i, "!");
            return;
          }

          _had_values = false;

          if (ArraySize(_dimensions) != 0) {
            _dimensions[ArraySize(_dimensions) - 1].type = MATRIX_DIMENSION_TYPE_CONTAINERS;
          }

          ArrayResize(_dimensions, ArraySize(_dimensions) + 1, MATRIX_DIMENSIONS);
          _dimensions[ArraySize(_dimensions) - 1] = new MatrixDimension<X>();

          if (ArraySize(_dimensions) >= 2) {
            _dimensions[ArraySize(_dimensions) - 2].AddContainer(_dimensions[ArraySize(_dimensions) - 1]);
          }

          if (_root_dimension == NULL) {
            _root_dimension = _dimensions[0];
          }

          _expecting_value_or_child = true;
          _expecting_end = true;
          break;

        case ']':
          ArrayResize(_dimensions, ArraySize(_dimensions) - 1, MATRIX_DIMENSIONS);
          _expecting_value_or_child = true;
          _expecting_comma = false;
          break;

        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case '-':
        case '.':
          if (!_expecting_value_or_child) {
            Print("Unexpected number at offset ", i, "!");
            return;
          }

          // Parsing number.
          _number_start_pos = i;
          do {
            c = StringGetCharacter(text, i++);
          } while ((c >= '0' && c <= '9') || c == '.' || c == '-' || c == 'e');
          _number = (X)StringToDouble(StringSubstr(text, _number_start_pos, i));
          i -= 2;
          _dimensions[ArraySize(_dimensions) - 1].type = MATRIX_DIMENSION_TYPE_VALUES;
          _dimensions[ArraySize(_dimensions) - 1].AddValue(_number);
          _expecting_end = true;
          _expecting_value_or_child = true;
          _expecting_comma = false;
          break;

        case ',':
          _expecting_value_or_child = true;
          _expecting_comma = false;
          _expecting_end = false;
          break;
        case ' ':
        case '\t':
        case '\r':
          break;
      }
    }

    Initialize(_root_dimension);
  }

  /**
   * Returns string or human-readable representation of the matrix's values.
   *
   * [
   *   [2,  3,  4]
         [2, 5] [6, 7]
       [5,  6,  7]
       [8,  9, 10]
   * ]
   *
   */
  string ToString(bool _whitespaces = false, int _precision = 3) {
    return ptr_first_dimension.ToString(_whitespaces, _precision);
  }

  /**
   * Returns representation of matrix's dimension, e.g., "[2, 5, 10]".
   */
  string Repr() {
    string _out = "[";

    for (int i = 0; i < ArraySize(dimensions); ++i) {
      if (dimensions[i] == 0) {
        continue;
      }

      _out += IntegerToString(dimensions[i]) + ((i < MATRIX_DIMENSIONS && dimensions[i + 1] != 0) ? ", " : "");
    }

    return _out + "]";
  }
};

#endif
