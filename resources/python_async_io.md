**Event loop** — is the core of every asyncio application. Event loops run asynchronous tasks and callbacks, perform network IO operations, and run subprocesses.

- `Event loop = Task scheduler`
- The main purpose of an Event Loop is to unclog blocking operations and let multiple operations execute in “parallel”
- The event loop iterate through the tasks and executes them.

💡 Event loops use cooperative scheduling: an event loop runs one Task at a time. While a Task awaits for the completion of a Future, the event loop runs other Tasks, callbacks, or performs IO operations.

- Details: [https://python.plainenglish.io/build-your-own-event-loop-from-scratch-in-python-da77ef1e3c39](https://python.plainenglish.io/build-your-own-event-loop-from-scratch-in-python-da77ef1e3c39)

**Awaitables** — we say that an object is an **awaitable** object if it can be used in an `[await](https://docs.python.org/3/reference/expressions.html#await)` expression. 

There are three main types of *awaitable* objects: **Coroutines**, **Tasks**, and **Futures**.

**Coroutines** — awaitable object; declared with `async/await` syntax. Coroutines can be awaited from other coroutines. Example coro:

```python
from typing import Coroutine

async def coro() -> Coroutine[None, None, None]:
	return 1
```

To actually run a coroutine, asyncio provides three main mechanisms:

- `asyncio.run(coro())`
- `await` in another coroutine
- `[asyncio.create_task()](https://docs.python.org/3/library/asyncio-task.html#asyncio.create_task)` function to run coroutines **concurrently** as asyncio `Tasks`:

```python
task = asyncio.create_task(coro())
await task
```

**Task** — awaitable object; Tasks are used to schedule coroutines **concurrently**.

- Tasks are used to run coroutines in event loops.
- If a coroutine awaits on a Future, the Task suspends the execution of the coroutine and waits for the completion of the Future.
- When the Future is *done*, the execution of the wrapped coroutine resumes.

- When a coroutine is wrapped into a Task with functions like `[asyncio.create_task()](https://docs.python.org/3/library/asyncio-task.html#asyncio.create_task)`
 the coroutine is **automatically scheduled to run** soon.

- Tasks can be **cancelled**: `task.cancel()`

**Future** — awaitable object; special **low-level** awaitable object that represents an **eventual result** of an asynchronous operation.

- When a Future object is *awaited* it means that the coroutine will wait until the Future is resolved in some other place.

- **Running Coroutines** — to run any coroutine you can use `asyncio.run(...)` function
    - `asynctio.run` always creates a new event loop and closes it at the end.
        - It should be used as a main entry point for asyncio programs, and should ideally only be called once
        - `asyncio.run` cannot be called when another asyncio event loop is running in the same thread
    
    ```python
    async def main():
        await asyncio.sleep(1)
        print('hello')
    
    asyncio.run(main())
    ```
    
- **Creating Tasks** — tasks are used to schedule coroutines concurrently; to run coro concurrently you should wrap its into task, by using `asyncio.create_task(...)` func
    - `asyncio.create_task` wrap the coro into a Task object and schedule its execution
    
- **Running Tasks Concurrently** — you can run many tasks concurrently using `asyncio.gather(*awaitables)` method
    - If any awaitable in `awaitables` is a coroutine, it is automatically scheduled as a Task
    - If all awaitables are completed successfully, the result is an aggregate list of returned values
    - If `gather()` is *cancelled*, all submitted awaitables (that have not completed yet) are also *cancelled*.
    
- **Timeouts** — `asyncio.wait_for(awaitable, timeout)` is used to wait for the `awaitable` execution complete with a specified `timeout`
    - If a timeout occurs, it cancels the task and raises ` [asyncio.TimeoutError](https://docs.python.org/3/library/asyncio-exceptions.html#asyncio.TimeoutError)`
    - To avoid the task `[cancellation](https://docs.python.org/3/library/asyncio-task.html#asyncio.Task.cancel)`, wrap it in `asyncio.shield` method