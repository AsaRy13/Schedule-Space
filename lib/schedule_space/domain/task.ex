defmodule ScheduleSpace.Domain.Task do
  @enforce_keys [:id, :title, :estimated_minutes, :complexity]
  defstruct [
    :id,
    :title,
    :estimated_minutes,
    :complexity,
    :actual_minutes,
    status: :pending
  ]

  def new(id, attrs) when is_map(attrs) do
    title = Map.get(attrs, :title)
    estimated_minutes = Map.get(attrs, :estimated_minutes)
    complexity = Map.get(attrs, :complexity)

    cond do
      not (is_binary(title) and String.trim(title) != "") ->
        {:error, :invalid_title}

      not (is_integer(estimated_minutes) and estimated_minutes > 0) ->
        {:error, :invalid_estimated_minutes}

      not (is_integer(complexity) and complexity in 1..5) ->
        {:error, :invalid_complexity}

      true ->
        {:ok,
         %__MODULE__{
           id: id,
           title: String.trim(title),
           estimated_minutes: estimated_minutes,
           complexity: complexity
         }}
    end
  end

  def new(_id, _attrs), do: {:error, :invalid_task}
end
