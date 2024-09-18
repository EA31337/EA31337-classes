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

    clang-format -i File.h

### Syntax

To improve code compatibility, please use the following syntax:

| MQL                | C++                      | Syntax to use              |
|:-------------------|:-------------------------|:---------------------------|
| `&this`            | `this`                   | `THIS_PTR`                 |
| `this`             | `*this`                  | `THIS_REF`                 |
| `GetPointer(obj)`  | `&obj`                   | `GET_PTR(obj)`             |
| `T name[]`         | `std::vector<T> name`    | `ARRAY(T, name)`           |
| `T name[5]`        | `T name[5]`              | `FIXED_ARRAY(T, name, 5)`  |
| `X f(T[] v)`      ⁵| `X f(T(&n)[5])`          | `FIXED_ARRAY_REF(T, n, 5)` |
| `T<A, B> name[]`   | `vector<T<A, B>> name`   | `ARRAY(T<A, B>, N)`        |
| `long`             | `long long`              | `int64`                    |
| `unsigned long`    | `unsigned long long`     | `uint64`                   |
| `obj.Method()`    ¹| `obj->Method()`          | `obj PTR_DEREF Method()`   |
| `obj.Ptr().a`     ³| `obj.Ptr()->a`           | `obj REF_DEREF a`          |
| `obj.a1.a2`       ¹| `obj->a1->a2`            | `PTR_ATTRIB2(obj, a1, a2)` |
| `obj.attr`        ¹| `obj->attr`              | `PTR_ATTRIB(obj, attr)`    |
| `str == NULL`      | `str == NULL`            | `IsNull(str)`              |
| `foo((Ba&)obj)`   ²| `foo(*obj)`              | `foo(PTR_TO_REF(obj))`     |
| `foo((Ba*)obj)`   ¹| `foo(&obj)`              | `foo(REF_TO_PTR(obj))`     |
| `void* N`         ⁴| `void*& N[]`             | `VOID_DATA(N)`             |
| `int foo`         ⁵| `const int foo`          | `CONST_CPP int foo`        |
| `int foo(int v)`  ⁵| `int foo(int& v)`        | `int foo(int REF_CPP v)`   |
| `X foo()`         ⁵| `X& foo()`               | `X REF_CPP foo()`          |
| `obj == NULL`     ¹| `obj == nullptr`         | `obj == nullptr`           |
| `datetime d = NULL`| `datetime d = 0`         | `datetime = 0`             |

Footnotes:

* ¹ Only if `obj` is a pointer.
* ² Only if `obj` is an object or reference type (e.g., `Foo &`).
* ³ Only if `obj` is `Ref<X>`.
* ⁴ Only when used as a parameter to function.
* ⁵ In C++ we could want to return structure by reference or add `const` to the variable or result.

## Proposing changes

To propose a code change on GitHub,
please send a [Pull Request](https://support.github.com/features/pull-requests).

## Testing

### Continuous integration

The project uses [GitHub Actions](https://github.com/features/actions)
to automate builds and tests.

When contributing, your code should pass all the CI tests.
