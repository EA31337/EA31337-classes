/*
 * Custom array functions.
 */

class Arrays {
public:

    /*
     * Find lower value within the 1-dim array of floats.
     */
    static double LowestArrValue(double& arr[]) {
      return (arr[ArrayMinimum(arr)]);
    }

    /*
     * Find higher value within the 1-dim array of floats.
     */
    static double HighestArrValue(double& arr[]) {
      return (arr[ArrayMaximum(arr)]);
    }

    /*
     * Find lower value within the 2-dim array of floats by the key.
     */
    static double LowestArrValue2(double& arr[][], int key1) {
      double lowest = 0;
      for (int i = 0; i < ArrayRange(arr, 1); i++) {
        if (arr[key1][i] < lowest) {
          lowest = arr[key1][i];
        }
      }
      return lowest;
    }

    /*
     * Find higher value within the 2-dim array of floats by the key.
     */
    static double HighestArrValue2(double& arr[][], int key1) {
      double highest = 0;
      for (int i = 0; i < ArrayRange(arr, 1); i++) {
        if (arr[key1][i] > highest) {
          highest = arr[key1][i];
        }
      }
      return highest;
    }

    /*
     * Find highest value in 2-dim array of integers by the key.
     */
    static int HighestValueByKey(int& arr[][], int key) {
      double highest = 0;
      for (int i = 0; i < ArrayRange(arr, 1); i++) {
        if (arr[key][i] > highest) {
          highest = arr[key][i];
        }
      }
      return highest;
    }

    /*
     * Find lowest value in 2-dim array of integers by the key.
     */
    static int LowestValueByKey(int& arr[][], int key) {
      double lowest = 0;
      for (int i = 0; i < ArrayRange(arr, 1); i++) {
        if (arr[key][i] < lowest) {
          lowest = arr[key][i];
        }
      }
      return lowest;
    }

    /*
    static int GetLowestArrDoubleValue(double& arr[][], int key) {
      double lowest = -1;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
        for (int j = 0; j < ArrayRange(arr, 1); j++) {
          if (arr[i][j] < lowest) {
            lowest = arr[i][j];
          }
        }
      }
      return lowest;
    }*/

    /*
     * Find key in array of integers with highest value.
     */
    static int GetArrKey1ByHighestKey2Value(int& arr[][], int key2) {
      int key1 = EMPTY;
      int highest = 0;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
          if (arr[i][key2] > highest) {
            highest = arr[i][key2];
            key1 = i;
          }
      }
      return key1;
    }

    /*
     * Find key in array of integers with lowest value.
     */
    static int GetArrKey1ByLowestKey2Value(int& arr[][], int key2) {
      int key1 = EMPTY;
      int lowest = 0;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
          if (arr[i][key2] < lowest) {
            lowest = arr[i][key2];
            key1 = i;
          }
      }
      return key1;
    }

    /*
     * Find key in array of doubles with highest value.
     */
    static int GetArrKey1ByHighestKey2ValueD(double& arr[][], int key2) {
      int key1 = EMPTY;
      int highest = 0;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
          if (arr[i][key2] > highest) {
            highest = arr[i][key2];
            key1 = i;
          }
      }
      return key1;
    }

    /*
     * Find key in array of doubles with lowest value.
     */
    static int GetArrKey1ByLowestKey2ValueD(double& arr[][], int key2) {
      int key1 = EMPTY;
      int lowest = 0;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
          if (arr[i][key2] < lowest) {
            lowest = arr[i][key2];
            key1 = i;
          }
      }
      return key1;
    }

    /*
     * Set array value for double items with specific keys.
     */
    static void ArrSetValueD(double& arr[][], int key, double value) {
      for (int i = 0; i < ArrayRange(info, 0); i++) {
        arr[i][key] = value;
      }
    }

    /*
     * Set array value for integer items with specific keys.
     */
    static void ArrSetValueI(int& arr[][], int key, int value) {
      for (int i = 0; i < ArrayRange(info, 0); i++) {
        arr[i][key] = value;
      }
    }

    /*
     * Calculate sum of 2 dimentional array based on given key.
     */
    static double GetArrSumKey1(double& arr[][], int key1, int offset = 0) {
      double sum = 0;
      offset = MathMin(offset, ArrayRange(arr, 1) - 1);
      for (int i = offset; i < ArrayRange(arr, 1); i++) {
        sum += arr[key1][i];
      }
      return sum;
    }
}
