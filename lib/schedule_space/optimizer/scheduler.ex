defmodule ScheduleSpace.Optimizer.Scheduler do
  def schedule(tasks, calibration) do
    tasks
    |> Enum.filter(&(&1.status == :pending))
    |> Enum.sort_by(fn task ->
      projected_minutes = task.estimated_minutes * Map.get(calibration, task.complexity, 1.0)
      {projected_minutes, task.complexity, task.id}
    end)
  end
end
