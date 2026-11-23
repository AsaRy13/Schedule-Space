defmodule ScheduleSpace.Infrastructure.TaskStore do
  alias ScheduleSpace.Domain.Task

  defstruct tasks: %{}, next_id: 1, feedback_by_complexity: %{}

  def add_task(%__MODULE__{} = store, attrs) do
    with {:ok, task} <- Task.new(store.next_id, normalize_attrs(attrs)) do
      updated_store = %{
        store
        | tasks: Map.put(store.tasks, task.id, task),
          next_id: store.next_id + 1
      }

      {:ok, updated_store, task}
    end
  end

  def list_tasks(%__MODULE__{} = store) do
    store.tasks
    |> Map.values()
    |> Enum.sort_by(&(&1.id))
  end

  def record_feedback(%__MODULE__{} = store, id, actual_minutes)
      when is_integer(actual_minutes) and actual_minutes > 0 do
    case Map.fetch(store.tasks, id) do
      :error ->
        {:error, :task_not_found}

      {:ok, %{status: :completed}} ->
        {:error, :task_already_completed}

      {:ok, task} ->
        updated_task = %{task | status: :completed, actual_minutes: actual_minutes}
        ratio = actual_minutes / task.estimated_minutes
        {count, ratio_sum} = Map.get(store.feedback_by_complexity, task.complexity, {0, 0.0})

        updated_store = %{
          store
          | tasks: Map.put(store.tasks, id, updated_task),
            feedback_by_complexity:
              Map.put(
                store.feedback_by_complexity,
                task.complexity,
                {count + 1, ratio_sum + ratio}
              )
        }

        {:ok, updated_store, updated_task}
    end
  end

  def record_feedback(%__MODULE__{}, _id, _actual_minutes), do: {:error, :invalid_actual_minutes}

  def calibration(%__MODULE__{} = store) do
    Map.new(store.feedback_by_complexity, fn {complexity, {count, ratio_sum}} ->
      {complexity, ratio_sum / count}
    end)
  end

  defp normalize_attrs(attrs) when is_list(attrs) do
    if Keyword.keyword?(attrs), do: Map.new(attrs), else: :invalid
  end

  defp normalize_attrs(attrs), do: attrs
end
