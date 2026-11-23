# ScheduleSpace

ScheduleSpace is an Elixir task scheduler. Its public entry point is the
`ScheduleSpace` module in `lib/schedule_space.ex`.

## Requirements

- Elixir 1.14 or newer
- Erlang/OTP

## Run the tests

From the project directory:

```shell
mix test
```

## Use the API

Start an interactive session with the project compiled and loaded:

```shell
iex -S mix
```

Then create a task store and schedule a task:

```elixir
store = ScheduleSpace.new()

{:ok, store, task} =
  ScheduleSpace.add_task(store, %{
    title: "Write a report",
    estimated_minutes: 45,
    complexity: 2
  })

ScheduleSpace.schedule(store)
{:ok, store, _task} = ScheduleSpace.record_feedback(store, task.id, 50)
ScheduleSpace.stats(store)
```

The store is immutable, so use the updated store returned by `add_task/2` and
`record_feedback/3` for subsequent operations.
