class SetFile {
    protected:
        // @todo: Store mixed values.
        double& data[]
        string& data[]

    public:
        // Load settings from file.
        bool LoadFromText(string text) {
            // @todo
        }

        // Load .set file.
        bool LoadFromFile(string path) {
            // FileOpen // https://docs.mql4.com/files/fileopen
            // LoadFromText($data);
            // @todo
        }

        // Get integer value.
        int GetValue(string key) {
            // @todo
        }

        // Get double value.
        // @todo: https://docs.mql4.com/basis/function/functionoverload for getters?
        double GetValue(string key) {
            // @todo
        }

        // Set integer value.
        bool SetValue(string key, int value) {
            // @todo
        }

        // Set double value.
        bool SetValue(string key, double value) {
            // @todo
        }

        // Set string value.
        bool SetValue(string key, string value) {
            // @todo
        }

};
