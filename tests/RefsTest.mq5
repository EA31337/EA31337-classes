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
 * Test functionality of Ref/WeakRef classes.
 */

// Includes.
#include "../DictObject.mqh"
#include "../DictStruct.mqh"
#include "../Refs.mqh"
#include "../Test.mqh"

/**
 * Good example of child -> parent cyclic tree.
 */
class DynamicClass : public Dynamic {
 public:
  WeakRef<DynamicClass> parent;
  int number;

  DynamicClass(int _number, DynamicClass* _parent = NULL) : number(_number), parent(_parent) {}
};

/**
 * Bad example of child -> parent cyclic tree.
 */
class BadDynamicClass : public Dynamic {
 public:
  Ref<BadDynamicClass> parent;
  int number;

  BadDynamicClass(int _number, BadDynamicClass* _parent = NULL) : number(_number), parent(_parent) {}
};

/**
 * Implements Init event handler.
 */
int OnInit() {
  // Weak references only.

  WeakRef<DynamicClass> dyn1 = new DynamicClass(1);
  assertTrueOrFail(dyn1.ObjectExists(), "Object should exist");

  dyn1 = NULL;
  assertTrueOrFail(!dyn1.ObjectExists(), "Object shouldn't exist");

  WeakRef<DynamicClass> dyn2 = new DynamicClass(2);
  WeakRef<DynamicClass> dyn3 = new DynamicClass(3, dyn2.Ptr());
  assertTrueOrFail(dyn2.ObjectExists(), "Object should exist");
  assertTrueOrFail(dyn3.ObjectExists(), "Object should exist");
  assertTrueOrFail(dyn3.Ptr().parent.ObjectExists(), "Object should exist");

  dyn2 = NULL;
  assertTrueOrFail(dyn3.ObjectExists(), "Object should exist");
  assertTrueOrFail(dyn3.Ptr().parent.ObjectExists(), "Object should exist");

  dyn3 = NULL;

  // Strong and weak references (cyclic child -> parent references).

  Ref<DynamicClass> dyn4 = new DynamicClass(4);
  ReferenceCounter* dyn4_rc = dyn4.Ptr().ptr_ref_counter;
  dyn4.Ptr().parent = dyn4;  // Cyclic reference.
  WeakRef<DynamicClass> dyn4_weak_ref = dyn4;

  dyn4 = NULL;
  assertTrueOrFail(!dyn4_weak_ref.ObjectExists(), "Object shouldn't exist as there were no more strong references");

  dyn4_weak_ref = NULL;
  assertTrueOrFail(!CheckPointer(dyn4_rc),
                   "ReferenceCounter object should be freed as there were no more strong nor weak references.");

  // Cyclic scenario (it's what should be avoided).

  Ref<BadDynamicClass> bad1 = new BadDynamicClass(1);
  bad1.Ptr().parent = bad1;  // This object will stay allocated forever.
  ReferenceCounter* bad1_rc = bad1.Ptr().ptr_ref_counter;
  bad1 = NULL;
  assertTrueOrFail(!bad1_rc.deleted, "Object should stay undeleted");
  assertTrueOrFail(CheckPointer(bad1_rc.ptr_object), "Object should stay allocated");

  BadDynamicClass* bad1_obj = ((BadDynamicClass*)bad1_rc.ptr_object);
  ReferenceCounter* bad1_obj_rc = bad1_obj.ptr_ref_counter;

  // Deleting objects explicitly.
  bad1_obj.parent = NULL;

  // Strong -> weak -> strong refereces cyclic scenario. Checking for unexpected delete loop.
  {
    Ref<DynamicClass> dyn5 = new DynamicClass(5);
    dyn5.Ptr().parent = dyn5;
  }

  // Weak -> strong scenario. Checking if object is deleted correctly.
  WeakRef<DynamicClass> dyn6 = new DynamicClass(6);
  { Ref<DynamicClass> dyn7 = dyn6; }
  assertTrueOrFail(!dyn6.ObjectExists(), "Object shouldn't exist");

  // Dictionary of strong references.

  DictStruct<string, Ref<DynamicClass>> refs1;
  {
    Ref<DynamicClass> dyn8_1 = new DynamicClass(1);
    refs1.Set("1", dyn8_1);

    Ref<DynamicClass> dyn8_2 = new DynamicClass(2);
    refs1.Set("2", dyn8_2);

    Ref<DynamicClass> dyn8_3 = new DynamicClass(3);
    refs1.Set("3", dyn8_3);
  }

  assertTrueOrFail(refs1.GetByKey("1").Ptr().number == 1, "Object should exists and have proper value");
  assertTrueOrFail(refs1.GetByKey("2").Ptr().number == 2, "Object should exists and have proper value");
  assertTrueOrFail(refs1.GetByKey("3").Ptr().number == 3, "Object should exists and have proper value");

  // Dictionary of weak references.

  DictStruct<string, WeakRef<DynamicClass>> refs2;

  Ref<DynamicClass> dyn9_1 = new DynamicClass(1);
  Ref<DynamicClass> dyn9_2 = new DynamicClass(2);
  Ref<DynamicClass> dyn9_3 = new DynamicClass(3);

  WeakRef<DynamicClass> dyn9_1_weak_ref = dyn9_1;
  WeakRef<DynamicClass> dyn9_2_weak_ref = dyn9_2;
  WeakRef<DynamicClass> dyn9_3_weak_ref = dyn9_3;

  refs2.Set("1", dyn9_1_weak_ref);
  refs2.Set("2", dyn9_2_weak_ref);
  refs2.Set("3", dyn9_3_weak_ref);

  // Should make refs2["2"] to have no existing object.
  dyn9_2 = NULL;

  assertTrueOrFail(refs2.GetByKey("1").ObjectExists(), "Object should exists");
  assertTrueOrFail(!refs2.GetByKey("2").ObjectExists(), "Object should not exists as it has no more strong references");
  assertTrueOrFail(refs2.GetByKey("3").ObjectExists(), "Object should exists");

  return INIT_SUCCEEDED;
}
