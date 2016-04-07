/*
 * Convert timeframe constant to period value.
 */
class Convert {
public:

    /*
     * Convert timeframe constant to period value.
     */
    static int TimeframeToPeriod(int tf) {
        int period = M30;
        switch (tf) {
        case PERIOD_M1: // 1 minute
            period = M1;
            break;
        case PERIOD_M5: // 5 minutes
            period = M5;
            break;
        case PERIOD_M15: // 15 minutes
            period = M15;
            break;
        case PERIOD_M30: // 30 minutes
            period = M30;
            break;
        case PERIOD_H1: // 1 hour
            period = H1;
            break;
        case PERIOD_H4: // 4 hours
            period = H4;
            break;
        case PERIOD_D1: // daily
            period = D1;
            break;
        case PERIOD_W1: // weekly
            period = W1;
            break;
        case PERIOD_MN1: // monthly
            period = MN1;
            break;
        }
        return period;
    }


    /*
     * Convert period to proper chart timeframe value.
     */
    int PeriodToTimeframe(int period) {
        int tf = PERIOD_M30;
        switch (period) {
            case M1: // 1 minute
            tf = PERIOD_M1;
            break;
            case M5: // 5 minutes
            tf = PERIOD_M5;
            break;
            case M15: // 15 minutes
            tf = PERIOD_M15;
            break;
            case M30: // 30 minutes
            tf = PERIOD_M30;
            break;
            case H1: // 1 hour
            tf = PERIOD_H1;
            break;
            case H4: // 4 hours
            tf = PERIOD_H4;
            break;
            case D1: // daily
            tf = PERIOD_D1;
            break;
            case W1: // weekly
            tf = PERIOD_W1;
            break;
            case MN1: // monthly
            tf = PERIOD_MN1;
            break;
        }
        return tf;
    }

    /*
     * Return opposite trade command operation.
     *
     * @param
     *   cmd (int) - trade command operation
     */
    int CmdOpp(int cmd) {
        if (cmd == OP_BUY) return OP_SELL;
        if (cmd == OP_SELL) return OP_BUY;
        return EMPTY;
    }

};
