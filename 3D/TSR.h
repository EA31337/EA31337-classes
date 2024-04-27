//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

/**
 * @file
 * Translations, scale and rotation matrices.
 */

#include "Math.h"

class TSR {
 public:
  DXVector3 translation;
  DXVector3 scale;
  DXVector3 rotation;

  TSR() {
    translation.x = translation.y = translation.z = 0.0f;
    scale.x = scale.y = scale.z = 1.0f;
    rotation.x = rotation.y = rotation.z = 0.0f;
  }

  DXMatrix ToMatrix() const {
    DXMatrix _mtx_translation = {};
    DXMatrix _mtx_scale = {};
    DXMatrix _mtx_rotation_1 = {};
    DXMatrix _mtx_rotation_2 = {};
    DXMatrix _mtx_result = {};

    DXMatrixTranslation(_mtx_translation, translation.x, translation.y, translation.z);
    DXMatrixScaling(_mtx_scale, scale.x, scale.y, scale.z);
    DXMatrixRotationYawPitchRoll(_mtx_rotation_1, rotation.x, 0, rotation.z);
    DXMatrixRotationYawPitchRoll(_mtx_rotation_2, 0, rotation.y, 0);

    DXMatrixIdentity(_mtx_result);
    DXMatrixMultiply(_mtx_result, _mtx_result, _mtx_rotation_1);
    DXMatrixMultiply(_mtx_result, _mtx_result, _mtx_rotation_2);
    DXMatrixMultiply(_mtx_result, _mtx_result, _mtx_scale);
    DXMatrixMultiply(_mtx_result, _mtx_result, _mtx_translation);

    return _mtx_result;
  }
};
