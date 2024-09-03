//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/**
 * State structure.
 */
struct State {
 protected:
  unsigned int state;  // Bitwise value.
 public:
  // Struct constructor.
  State() : state(0) {}
  unsigned int GetState() { return state; }
  // Struct methods for bitwise operations.
  bool Has(unsigned int _state) { return (state & _state) != 0 || state == _state; }
  // Checks whether current states has any given states.
  bool HasAny(unsigned int _state) { return (state & _state) != 0; }
  // Checks whether current states has all given states.
  bool HasMulti(unsigned int _state) { return (state & _state) == _state; }
  // Adds a single state to the current states.
  void Add(unsigned int _state) { state |= _state; }
  // Clear all states.
  void ClearAll() { state = 0; }
  // Clears given state or multiple states from the current states.
  void Clear(unsigned int _state) { state &= ~_state; }
  void SetState(unsigned int _state, bool _value = true) {
    if (_value) {
      Add(_state);
    } else {
      Clear(_state);
    }
  }
  void SetState(unsigned int _state) { state = _state; }
  // Static methods.
  static bool Compare(unsigned int _state1, unsigned int _state2) {
    return (_state2 & _state1) != 0 || _state2 == _state1;
  }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer &_s) {
    int _size = sizeof(int) * 8;
    for (int i = 0; i < _size; i++) {
      int _value = Has(1 << i) ? 1 : 0;
      _s.Pass(THIS_REF, IntegerToString(i + 1), _value, SERIALIZER_FIELD_FLAG_DYNAMIC);
    }
    return SerializerNodeObject;
  }
};
