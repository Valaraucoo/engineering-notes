from typing import TypeAlias, Callable

from returns.result import Result, Success, Failure, safe

Numeric: TypeAlias = int | float


def divide_100(value: Numeric) -> Result:
    if value:
        return Success(100 / value)
    return Failure(ZeroDivisionError)


double: Callable[[Numeric], Numeric] = lambda value: value * 2


if __name__ == "__main__":
    assert Result.from_value(10).bind(divide_100).map(double).unwrap() == 20
    assert Result.from_value(0).bind(divide_100).map(double).value_or(10) == 10
