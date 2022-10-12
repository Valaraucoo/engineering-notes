from __future__ import annotations

from typing import Generic, TypeVar, Callable


T = TypeVar("T")
V = TypeVar("V")


class Maybe(Generic[T]):
    def map(self, callback: Callable[[T], V]) -> Maybe[V]:
        ...

    def bind(self, callback: Callable[[T], Maybe[V]]) -> Maybe[V]:
        ...

    def value_of(self) -> T | None:
        ...

    def __or__(self, callback: Callable[[T], V]) -> Maybe[V]:
        return self.map(callback)

    def __rshift__(self, callback: Callable[[T], Maybe[V]]) -> Maybe[V]:
        return self.bind(callback)


class Just(Maybe[T]):
    def __init__(self, value: T):
        self.value = value

    def __repr__(self) -> str:
        return f"Just({self.value_of()})"

    def map(self, callback: Callable[[T], V]) -> Maybe[V]:
        try:
            return Just(callback(self.value))
        except Exception:
            return Nothing()

    def bind(self, callback: Callable[[T], Maybe[V]]) -> Maybe[V]:
        try:
            return callback(self.value)
        except Exception:
            return Nothing()

    def value_of(self) -> T:
        return self.value


class Nothing(Maybe[T]):
    def __repr__(self) -> str:
        return "Nothing()"

    def map(self, _: Callable[[T], V]) -> Maybe[V]:
        return self

    def bind(self, _: Callable[[T], Maybe[V]]) -> Maybe[V]:
        return self

    def value_of(self) -> None:
        return None


if __name__ == "__main__":
    double: Callable[[T], V] = lambda value: value * 2
    increase: Callable[[T], V] = lambda value: value + 1

    print(Just("A") | double | increase | double)
    print(Just(5) | double | increase | double)

    foo: Callable[[T], Maybe[V]] = lambda value: Just(value * 2) if value > 5 else Nothing()
    bar: Callable[[T], Maybe[V]] = lambda value: Just(value + 1) if value > 10 else Nothing()

    print(Just(10) >> foo >> bar | double)
    print(Just(3) >> foo >> bar | increase)
    