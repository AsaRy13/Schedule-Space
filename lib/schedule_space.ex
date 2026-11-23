defmodule ScheduleSpace do
  @moduledoc """
  Public API for creating a task store, managing tasks, and scheduling work.

  Start with `new/0`, then pass the returned store to the other functions.
  Store updates are immutable; use the updated store returned by each operation.
  """

  alias ScheduleSpace.Infrastructure.TaskStore
  alias ScheduleSpace.Optimizer.Scheduler
  alias ScheduleSpace.Stats.TaskStats

  def new, do: %TaskStore{}

  def add_task(%TaskStore{} = store, attrs) do
    TaskStore.add_task(store, attrs)
  end

  def list_tasks(%TaskStore{} = store), do: TaskStore.list_tasks(store)

  def schedule(%TaskStore{} = store) do
    Scheduler.schedule(list_tasks(store), TaskStore.calibration(store))
  end

  def record_feedback(%TaskStore{} = store, id, actual_minutes) do
    TaskStore.record_feedback(store, id, actual_minutes)
  end

  def stats(%TaskStore{} = store), do: TaskStats.summarize(list_tasks(store))
end
