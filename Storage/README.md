# Storage classes

## `Collection` class

This class is for storing various type of objects. Here is the example usage:

    // Define custom classes of Object type.
    class Stack : Object {
      public:
        virtual string GetName() = NULL;
    };
    class Foo : Stack {
      public:
        string GetName() { return "Foo"; };
        double Weight() { return 0; };
    };
    class Bar : Stack {
      public:
        string GetName() { return "Bar"; };
        double Weight() { return 1; };
    };
    class Baz : Stack {
      public:
        string GetName() { return "Baz"; };
        double Weight() { return 2; };
    };

    int OnInit() {
      // Define and add items.
      Collection *stack = new Collection();
      stack.Add(new Foo);
      stack.Add(new Bar);
      stack.Add(new Baz);
      // Print the lowest and the highest items.
      Print("Lowest: ", ((Stack *)stack.GetLowest()).GetName());
      Print("Highest: ", ((Stack *)stack.GetHighest()).GetName());
      // Print all the items.
      for (uint i = 0; i < stack.GetSize(); i++) {
        Print(i, ": ", ((Stack *)stack.GetByIndex(i)).GetName());
      }
      // Clean up.
      Object::Delete(stack);
      return (INIT_SUCCEEDED);
    }
