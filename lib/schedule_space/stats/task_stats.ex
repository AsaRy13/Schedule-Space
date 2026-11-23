defmodule ScheduleSpace.Stats.TaskStats do
  def summarize(tasks) do
    completed = Enum.filter(tasks, &(&1.status == :completed))
    total = length(tasks)
    completed_count = length(completed)

    %{
      total_tasks: total,
      pending_tasks: total - completed_count,
      completed_tasks: completed_count,
      completion_rate: completion_rate(completed_count, total),
      average_actual_minutes: average_actual_minutes(completed)
    }
  end

  defp completion_rate(_completed, 0), do: 0.0
  defp completion_rate(completed, total), do: completed / total

  defp average_actual_minutes([]), do: nil

  defp average_actual_minutes(tasks) do
    tasks
    |> Enum.map(& &1.actual_minutes)
    |> Enum.sum()
    |> Kernel./(length(tasks))
  end
end
