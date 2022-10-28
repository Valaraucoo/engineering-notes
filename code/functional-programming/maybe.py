from typing import TypeAlias

from returns.maybe import Maybe, Some, Nothing
from pydantic import BaseModel

Numeric: TypeAlias = int | float


class User(BaseModel):
    name: str
    age: int | None = None


def double(value: Numeric) -> Numeric:
    return value * 2


def increase(value: Numeric) -> Numeric:
    return value + 1


def decrease(value: Numeric) -> Numeric:
    return value - 1


def evaluate(user: User) -> Maybe:
    return Maybe.from_optional(user.age).bind_optional(increase).bind_optional(double).bind_optional(decrease)


if __name__ == "__main__":
    user_without_age = User(name="John Doe")
    user_with_age = User(name="Adam Smith", age=20)

    assert evaluate(user_without_age) == Nothing
    assert evaluate(user_with_age) == Some(41)

    assert evaluate(user_without_age).value_or(0) == 0
    assert evaluate(user_with_age).unwrap() == 41

    assert evaluate(user_without_age).or_else_call(lambda: 10) == 10
    assert evaluate(user_without_age).map(lambda: None) == Nothing

    match evaluate(User(name="Larry Wall", age=30)):
        case Some(age):
            print(f"Age = {age}")
        case Nothing:
            print("Age is not provided")
