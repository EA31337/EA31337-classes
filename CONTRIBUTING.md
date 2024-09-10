# Contributing

## Bugs

### Submitting A Bug Report

Bugs are tracked as [GitHub issues](https://guides.github.com/features/issues/).
After you've determined which repository your bug is related to,
create an issue on that repository and provide the details.

## Code

### Compatibility

We aim at syntax compatibility with 3 languages at once: MQL4, MQL5 and C++.

### Coding conventions

To optimize the code for readability, please follow these guidelines:

* Indent using two spaces (soft tabs).
* Consider the people who will read your code, and make it look nice for them.

We use a `clang-format` code formatter tool to format the code
(both MQL and C++ files).

For example, to format file inplace, run:

    clang-format -i File.mqh

### Syntax

To improve code compatibility, please use the following syntax:

| MQL                | C++                      | Syntax to use              |
|:-------------------|:-------------------------|:---------------------------|
| `&this`            | `this`                   | `THIS_PTR`                 |
| `this`             | `*this`                  | `THIS_REF`                 |
| `GetPointer(obj)`  | `&obj`                   | `GET_PTR(obj)`             |
| `T name[]`         | `std::vector<T> name`    | `ARRAY(T, name)`           |
| `T name[5]`        | `T name[5]`              | `FIXED_ARRAY(T, name, 5)`  |
| `X f(T[] v)`  [ ]=5| `X f(T(&n)[5])`          | `FIXED_ARRAY_REF(T, n, 5)` |
| `T<A, B> name[]`   | `vector<T<A, B>> name`   | `ARRAY(T<A, B>, N)`        |
| `long`             | `long long`              | `int64`                    |
| `unsigned long`    | `unsigned long long`     | `uint64`                   |
| `obj.Method()`   *1| `obj->Method()`          | `obj PTR_DEREF Method()`   |
| `obj.Ptr().a`    *3| `obj.Ptr()->a`           | `obj REF_DEREF a`          |
| `obj.a1.a2`      *1| `obj->a1->a2`            | `PTR_ATTRIB2(obj, a1, a2)` |
| `obj.attr`       *1| `obj->attr`              | `PTR_ATTRIB(obj, attr)`    |
| `str == NULL`      | `str == NULL`            | `IsNull(str)`              |
| `foo((Ba&)obj)`  *2| `foo(*obj)`              | `foo(PTR_TO_REF(obj))`     |
| `foo((Ba*)obj)`  *1| `foo(&obj)`              | `foo(REF_TO_PTR(obj))`     |
| `void* N`        *4| `void*& N[]`             | `VOID_DATA(N)`             |
| `int foo`          | `const int foo`          | `CONST_CPP int foo`        |
| `int foo(int v)`   | `int foo(int& v)`        | `int foo(int REF_CPP v)`   |
| `X foo()`          | `X& foo()`               | `X REF_CPP foo()`          |
| `obj == NULL`    *1| `obj == nullptr`         | `obj == nullptr`           |
| `X foo(T* v)`      | `X foo(T* v)`            | `obj == nullptr`           |
| `datetime d = NULL`| `datetime d = 0`         | `datetime = 0`             |

**\*1** - Only if `obj` is a pointer.
**\*2** - Only if `obj` is an object or reference type (e.g., `Foo &`).
**\*3** - Only if `obj` is `Ref<X>`.
**\*4** - Only when used as a parameter to function.

## Proposing changes

To propose a code change on GitHub,
please send a [Pull Request](https://support.github.com/features/pull-requests).

## Testing

### Continuous integration

The project uses [GitHub Actions](https://github.com/features/actions)
to automate builds and tests.

When contributing, your code should pass all the CI tests.
