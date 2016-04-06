// @todo: Implement AccountStopoutLevel
// @todo: Implement AccountFreeMarginMode
// @todo: Implement AccountFreeMarginCheck

class AccountInfo {
public:
    static string AccountName() {
        #ifdef __MQL5__
        return AccountInfoString(ACCOUNT_NAME);
        #else
        return AccountName();
        #endif
    }
    static string AccountServer() {
        #ifdef __MQL5__
        return AccountInfoString(ACCOUNT_SERVER);
        #else
        return AccountServer();
        #endif
    }
    static string AccountCurrency() {
        #ifdef __MQL5__
        return AccountInfoString(ACCOUNT_CURRENCY);
        #else
        return AccountCurrency();
        #endif
    }
    static string AccountCompany() {
        #ifdef __MQL5__
        return AccountInfoString(ACCOUNT_COMPANY);
        #else
        return AccountCompany();
        #endif
    }
    static double AccountBalance() {
        #ifdef __MQL5__
        return AccountInfoDouble(ACCOUNT_BALANCE);
        #else
        return AccountBalance();
        #endif
    }
    static double AccountCredit() {
        #ifdef __MQL5__
        return AccountInfoDouble(ACCOUNT_CREDIT);
        #else
        return AccountCredit();
        #endif
    }
    static double AccountProfit() {
        #ifdef __MQL5__
        return AccountInfoDouble(ACCOUNT_PROFIT);
        #else
        return AccountProfit();
        #endif
    }
    static double AccountEquity() {
        #ifdef __MQL5__
        return AccountInfoDouble(ACCOUNT_EQUITY);
        #else
        return AccountEquity();
        #endif
    }
    static double AccountMargin() {
        #ifdef __MQL5__
        return AccountInfoDouble(ACCOUNT_MARGIN);
        #else
        return AccountMargin();
        #endif
    }
    static double AccountFreeMargin() {
        #ifdef __MQL5__
        return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        #else
        return AccountFreeMargin();
        #endif
    }
    static long AccountLeverage() {
        #ifdef __MQL5__
        return AccountInfoInteger(ACCOUNT_LEVERAGE);
        #else
        return AccountLeverage();
        #endif
    }
    static long AccountNumber() {
        #ifdef __MQL5__
        return AccountInfoInteger(ACCOUNT_LOGIN);
        #else
        return AccountNumber();
        #endif
    }
    static long AccountStopoutMode() {
        #ifdef __MQL5__
        return AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
        #else
        return AccountStopoutMode();
        #endif
    }
};
