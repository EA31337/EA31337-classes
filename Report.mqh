/*
 * Custom report handling functions.
 */

class Report {
public:

    /*
     * Add message into the report file.
     */
    void ReportAdd(string msg) {
      int last = ArraySize(log);
      ArrayResize(log, last + 1);
      log[last] = TimeToStr(time_current,TIME_DATE|TIME_SECONDS) + ": " + msg;
    }

    /*
     * Write report into file.
     */
    void WriteReport(string report_name) {
      int handle = FileOpen(report_name, FILE_CSV|FILE_WRITE, '\t');
      if (handle < 1) return;

      string report = GenerateReport();
      FileWrite(handle, report);
      FileClose(handle);

      if (VerboseDebug) {
        PrintText(report);
      }
    }

}
