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

## Proposing changes

To propose a code change on GitHub,
please send a [Pull Request](https://support.github.com/features/pull-requests).

## Testing

### Continuous integration

The project uses [GitHub Actions](https://github.com/features/actions)
to automate builds and tests.

When contributing, your code should pass all the CI tests.
