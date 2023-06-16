//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * Provides task management.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../DictObject.mqh"
#include "../Serializer/SerializerConverter.h"
#include "../Serializer/SerializerJson.h"
#include "Task.struct.h"
#include "TaskObject.h"

class TaskManager {
 protected:
  DictStruct<int, Ref<Task>> tasks;
  // DictObject<int, TaskObject<Task, Task>> tasks;
  // DictObject<int, TaskObject<Taskable, Taskable>> tasks; // @todo: Which one?

  /* Protected methods */

  /**
   * Init code (called on constructor).
   */
  void Init() {}

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  TaskManager() { Init(); }

  /**
   * Class deconstructor.
   */
  ~TaskManager() {}

  /* Adder methods */

  /**
   * Adds new task.
   */
  bool Add(Task *_task) {
    Ref<Task> _ref(_task);
    return tasks.Push(_ref);
  }

  /**
   * Adds new task.
   */
  bool Add(string _entry_str) {
    TaskEntry _entry;
    SerializerConverter::FromString<SerializerJson>(_entry_str).ToObject(_entry);
    Ref<Task> _task(new Task(_entry));
    return Add(_task.Ptr());
  }

  /**
   * Adds new object task.
   */
  template <typename TA, typename TC>
  bool Add(TaskObject<TA, TC> *_task_obj) {
    return Add((Task *)_task_obj);
  }

  /**
   * Clears tasks list.
   */
  void Clear() {
    Task *task0 = tasks[0].Ptr();

#ifndef __MQL__
    for (unsigned int i = 0; i < tasks.Size(); ++i) {
      std::cout << "Task #" << i << ": " << tasks[i].ToString() << std::endl;
    }
#endif

    tasks.Clear();

#ifndef __MQL__
    std::cout << "Tasks cleared." << std::endl;
    std::cout << task0 PTR_DEREF ToString() << std::endl;
    // std::cout.flush();
#endif
  }

  /* Processing methods */

  /**
   * Process tasks.
   */
  bool Process() {
    bool _result = true;
    for (DictStructIterator<int, Ref<Task>> _iter = tasks.Begin(); _iter.IsValid(); ++_iter) {
      Task *_task = _iter.Value().Ptr();
      _result &= _task PTR_DEREF Process();
    }
    return _result;
  }
};

#ifdef EMSCRIPTEN
#include <emscripten/bind.h>

EMSCRIPTEN_BINDINGS(TaskManager) {
  emscripten::class_<TaskManager>("TaskManager")
      .constructor()
      .function("Add", emscripten::optional_override([](TaskManager &self, Ref<Task> task) {
                  Print("Adding Task");
                  Print(StringToUpper("Testing StringToUpper"));
                  Print(StringToLower("Testing StringToLower"));
                  self.Add(task.Ptr());
                }))
      //      .function("Add", emscripten::select_overload<bool(Task*)>(&TaskManager::Add))
      .function("Clear", &TaskManager::Clear)
      .function("Process", &TaskManager::Process);
}
#endif
