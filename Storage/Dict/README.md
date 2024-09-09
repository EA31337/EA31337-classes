# Dict

## Classes

### `Dict` class

Use this class to store the values in form of a collective attribute–value pairs,
in similar way as [associative arrays](https://en.wikipedia.org/wiki/Associative_array)
with a [hash table](https://en.wikipedia.org/wiki/Hash_table) work.

#### Example 1 - Storing string-int data structures

Example of storing key-value data with string as a key:

    Dict<string, int> data1;
    data1.Set("a", 1);
    data1.Set("b", 2);
    data1.Set("c", 3);
    data1.Unset("c");
    Print(data1.GetByKey("a"));
