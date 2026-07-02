alias CerebelumDemo.Workflows.OrderWorkflow

# 1. Ejecutar workflow
{:ok, exec} = Cerebelum.execute_workflow(OrderWorkflow, %{
  order: %{id: "ORD-123", items: [%{name: "Widget", price: 25}]}
})
Process.sleep(500)

exec_id = exec.id

# 2. Estado resumido
{:ok, s} = Cerebelum.get_execution_status(exec_id)
IO.puts("Estado: #{s.state} | Progreso: #{s.timeline_progress}")
IO.puts("")

# 3. Eventos — historial completo
{:ok, events} = Cerebelum.EventStore.get_events(exec_id)
IO.puts("📋 Historial de eventos (#{length(events)} eventos):")
IO.puts("")

Enum.each(events, fn event ->
  icon = case event.event_type do
    "ExecutionStartedEvent" -> "🚀"
    "StepExecutedEvent" -> "✅"
    "StepFailedEvent" -> "❌"
    "ExecutionCompletedEvent" -> "🏁"
    "DivergeTakenEvent" -> "🔀"
    "BranchTakenEvent" -> "🔁"
    _ -> "📌"
  end

  IO.puts("#{icon} v#{event.version} | #{event.event_type}")
  case event.event_type do
    "StepExecutedEvent" ->
      step = event.event_data["step_name"]
      dur = event.event_data["duration_ms"]
      IO.puts("   step: #{step} (#{dur}ms)")
    "StepFailedEvent" ->
      IO.puts("   step: #{event.event_data["step_name"]}")
      IO.puts("   error: #{event.event_data["error_message"] |> String.slice(0..80)}")
    _ -> nil
  end
end)
