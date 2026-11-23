defmodule ScheduleSpaceTest do
  use ExUnit.Case, async: true

  test "stores multiple tasks" do
    store = ScheduleSpace.new()

    {:ok, store, first_task} =
      ScheduleSpace.add_task(store, %{title: "First task", estimated_minutes: 30, complexity: 2})

    {:ok, store, second_task} =
      ScheduleSpace.add_task(store, %{title: "Second task", estimated_minutes: 45, complexity: 3})

    assert ScheduleSpace.list_tasks(store) == [first_task, second_task]
  end

  test "schedules shortest estimates first, then lowest complexity" do
    store = ScheduleSpace.new()

    {:ok, store, long_simple} =
      ScheduleSpace.add_task(store, %{title: "Long simple", estimated_minutes: 60, complexity: 1})

    {:ok, store, short_complex} =
      ScheduleSpace.add_task(store, %{
        title: "Short complex",
        estimated_minutes: 20,
        complexity: 4
      })

    {:ok, store, short_simple} =
      ScheduleSpace.add_task(store, %{title: "Short simple", estimated_minutes: 20, complexity: 2})

    assert Enum.map(ScheduleSpace.schedule(store), & &1.id) ==
             [short_simple.id, short_complex.id, long_simple.id]
  end

  test "feedback calibrates pending task estimates in the same complexity group" do
    store = ScheduleSpace.new()

    {:ok, store, completed} =
      ScheduleSpace.add_task(store, %{title: "Done", estimated_minutes: 10, complexity: 3})

    {:ok, store, same_complexity} =
      ScheduleSpace.add_task(store, %{title: "Calibrated", estimated_minutes: 20, complexity: 3})

    {:ok, store, other_complexity} =
      ScheduleSpace.add_task(store, %{title: "Unaffected", estimated_minutes: 15, complexity: 2})

    {:ok, store, _task} = ScheduleSpace.record_feedback(store, completed.id, 40)

    assert Enum.map(ScheduleSpace.schedule(store), & &1.id) ==
             [other_complexity.id, same_complexity.id]
  end

  test "rejects invalid input and reports task performance stats" do
    store = ScheduleSpace.new()

    assert {:error, :invalid_complexity} =
             ScheduleSpace.add_task(store, %{title: "Bad", estimated_minutes: 5, complexity: 6})

    {:ok, store, task} =
      ScheduleSpace.add_task(store, %{title: "Done", estimated_minutes: 10, complexity: 1})

    assert {:ok, store, _task} = ScheduleSpace.record_feedback(store, task.id, 12)
    assert ScheduleSpace.schedule(store) == []

    assert ScheduleSpace.stats(store) == %{
             total_tasks: 1,
             pending_tasks: 0,
             completed_tasks: 1,
             completion_rate: 1.0,
             average_actual_minutes: 12.0
           }
  end
end
