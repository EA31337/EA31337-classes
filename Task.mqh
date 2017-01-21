//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
   This file is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Custom task handling functions.
 */

class Task {
  protected:
    int todo_queue[100][8];
    datetime last_queue_process;

  public:

    enum ENUM_TASK_TYPE { // Define type of tasks.
      TASK_ORDER_OPEN,
      TASK_ORDER_CLOSE,
      TASK_CALC_STATS,
    };

    /*
     * Add new closing order task.
     */
    /* @todo
       bool TaskAddOrderOpen(int cmd, int volume, int order_type) {
       int key = cmd+volume+order_type;
       int job_id = TaskFindEmptySlot(cmd+volume+order_type);
       if (job_id >= 0) {
       todo_queue[job_id][0] = key;
       todo_queue[job_id][1] = TASK_ORDER_OPEN;
       todo_queue[job_id][2] = MaxTries; // Set number of retries.
       todo_queue[job_id][3] = cmd;
       todo_queue[job_id][4] = EMPTY; // FIXME: Not used currently.
       todo_queue[job_id][5] = order_type;
    // todo_queue[job_id][6] = order_comment; // FIXME: Not used currently.
    // Print(__FUNCTION__ + "(): Added task (", job_id, ") for ticket: ", todo_queue[job_id][0], ", type: ", todo_queue[job_id][1], " (", todo_queue[job_id][3], ").");
    return true;
    } else {
    return false; // Job not allocated.
    }
    }
     */

    /*
     * Add new close task by job id.
     */
    /* @todo
       bool TaskAddCloseOrder(int ticket_no, int reason = EMPTY) {
       int job_id = TaskFindEmptySlot(ticket_no);
       if (job_id >= 0) {
       todo_queue[job_id][0] = ticket_no;
       todo_queue[job_id][1] = TASK_ORDER_CLOSE;
       todo_queue[job_id][2] = MaxTries; // Set number of retries.
       todo_queue[job_id][3] = reason;
    // if (VerboseTrace) Print("TaskAddCloseOrder(): Allocated task (id: ", job_id, ") for ticket: ", todo_queue[job_id][0], ".");
    return true;
    } else {
    if (VerboseTrace) Print(__FUNCTION__ + "(): Failed to allocate close task for ticket: " + ticket_no);
    return false; // Job is not allocated.
    }
    }
     */

    /*
     * Add new task to recalculate loss/profit.
     */
    /* @todo
       bool TaskAddCalcStats(int ticket_no, int order_type = EMPTY) {
       int job_id = TaskFindEmptySlot(ticket_no);
       if (job_id >= 0) {
       todo_queue[job_id][0] = ticket_no;
       todo_queue[job_id][1] = TASK_CALC_STATS;
       todo_queue[job_id][2] = MaxTries; // Set number of retries.
       todo_queue[job_id][3] = order_type;
    // if (VerboseTrace) Print(__FUNCTION__ + "(): Allocated task (id: ", job_id, ") for ticket: ", todo_queue[job_id][0], ".");
    return true;
    } else {
    if (VerboseTrace) Print(__FUNCTION__ + "(): Failed to allocate task for ticket: " + ticket_no);
    return false; // Job is not allocated.
    }
    }
     */

    // Remove specific task.
    /* @todo
       bool TaskRemove(int job_id) {
       todo_queue[job_id][0] = 0;
       todo_queue[job_id][2] = 0;
    // if (VerboseTrace) Print(__FUNCTION__ + "(): Task removed for id: " + job_id);
    return true;
    }
     */

    // Check if task for specific ticket already exists.
    /* @todo
       bool TaskExistByKey(int key) {
       for (int job_id = 0; job_id < ArrayRange(todo_queue, 0); job_id++) {
       if (todo_queue[job_id][0] == key) {
    // if (VerboseTrace) Print(__FUNCTION__ + "(): Task already allocated for key: " + key);
    return (true);
    break;
    }
    }
    return (false);
    }
     */

    /*
     * Find available slot id.
     */
    /* @todo
       int TaskFindEmptySlot(int key) {
       int taken = 0;
       if (!TaskExistByKey(key)) {
       for (int job_id = 0; job_id < ArrayRange(todo_queue, 0); job_id++) {
       if (VerboseTrace) Print(__FUNCTION__ + "(): job_id = " + job_id + "; key: " + todo_queue[job_id][0]);
       if (todo_queue[job_id][0] <= 0) { // Find empty slot.
    // if (VerboseTrace) Print(__FUNCTION__ + "(): Found empty slot at: " + job_id);
    return job_id;
    } else taken++;
    }
    // If no empty slots, Otherwise increase size of array.
    int size = ArrayRange(todo_queue, 0);
    if (size < 1000) { // Set array hard limit.
    ArrayResize(todo_queue, size + 10);
    if (VerboseDebug) Print(__FUNCTION__ + "(): Couldn't allocate Task slot, re-sizing array. New size: ",  (size + 1), ", Old size: ", size);
    return size;
    } else {
    // Array exceeded hard limit, probably because of some memory leak.
    if (VerboseDebug) Print(__FUNCTION__ + "(): Couldn't allocate task slot, all are taken (" + taken + "). Size: " + size);
    }
    }
    return EMPTY;
    }
     */

    /*
     * Run specific task.
     */
    /* @todo
       bool TaskRun(int job_id) {
       bool result = false;
       int key = todo_queue[job_id][0];
       int task_type = todo_queue[job_id][1];
       int retries = todo_queue[job_id][2];
       int cmd, sid, reason_id;
    // if (VerboseTrace) Print(__FUNCTION__ + "(): Job id: " + job_id + "; Task type: " + task_type);

    switch (task_type) {
    case TASK_ORDER_OPEN:
    cmd = todo_queue[job_id][3];
    // double volume = todo_queue[job_id][4]; // FIXME: Not used as we can't use double to integer array.
    sid = todo_queue[job_id][5];
    // string order_comment = todo_queue[job_id][6]; // FIXME: Not used as we can't use double to integer array.
    result = ExecuteOrder(cmd, sid, EMPTY, EMPTY, false);
    break;
    case TASK_ORDER_CLOSE:
    reason_id = todo_queue[job_id][3];
    if (OrderSelect(key, SELECT_BY_TICKET)) {
    if (CloseOrder(key, reason_id, false))
    result = TaskRemove(job_id);
    }
    break;
    case TASK_CALC_STATS:
    if (OrderSelect(key, SELECT_BY_TICKET, MODE_HISTORY)) {
    OrderCalc(key);
    } else {
    if (VerboseDebug) Print(__FUNCTION__ + "(): Access to history failed with error: (" + GetLastError() + ").");
    }
    break;
    default:
    if (VerboseDebug) Print(__FUNCTION__ + "(): Unknown task: ", task_type);
    };
    return result;
    }
     */

    /*
     * Process task list.
     */
    /* @todo
       bool TaskProcessList(bool with_force = false) {
       int total_run, total_failed, total_removed = 0;
       int no_elem = 8;
       datetime _bar_time = iTime(_Symbol, PERIOD_M1, 0);

    // Check if bar time has been changed since last time.
    if (_bar_time == last_queue_process && !with_force) {
    // if (VerboseTrace) Print("TaskProcessList(): Not executed. Bar time: " + bar_time + " == " + last_queue_process);
    return (false); // Do not process job list more often than per each minute bar.
    } else {
    last_queue_process = _bar_time; // Set bar time of last queue process.
    }

    RefreshRates();
    for (int job_id = 0; job_id < ArrayRange(todo_queue, 0); job_id++) {
    if (todo_queue[job_id][0] > 0) { // Find valid task.
    if (TaskRun(job_id)) {
    total_run++;
    } else {
    total_failed++;
    if (todo_queue[job_id][2]-- <= 0) { // Remove task if maximum tries reached.
    if (TaskRemove(job_id)) {
    total_removed++;
    }
    }
    }
    }
    } // end: for
    if (VerboseDebug && total_run+total_failed > 0)
    Print(__FUNCTION__, "(): Processed ", total_run+total_failed, " jobs (", total_run, " run, ", total_failed, " failed (", total_removed, " removed)).");
    return true;
    }
     */
};
