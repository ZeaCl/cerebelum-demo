defmodule CerebelumDemo.Workflows.LongRunningWorkflow do
  @moduledoc """
  Demo: Multi-day onboarding with sleep and resurrection.

  Shows long-running workflows that survive system restarts.
  """

  use Cerebelum.Workflow

  workflow do
    timeline do
      send_welcome_email()
      |> wait_3_days()
      |> send_reminder()
      |> wait_1_day()
      |> check_completion()
    end

    branch after: check_completion(), on: result do
      result[:completed] -> :continue
      true -> back_to(:send_reminder)
    end
  end

  # ── Step implementations ──

  def send_welcome_email(context) do
    user = context.inputs[:user] || %{email: "user@example.com"}
    IO.puts("📧 Sending welcome email to #{user[:email]}...")
    {:ok, %{email_sent: true, to: user[:email], at: DateTime.utc_now()}}
  end

  def wait_3_days(_context, _result) do
    IO.puts("⏳ Sleeping for 3 days... (demo: 3 seconds)")
    Process.sleep(3000)
    {:ok, :awake}
  end

  def send_reminder(_context, _result) do
    IO.puts("📧 Sending reminder email...")
    {:ok, %{reminder_sent: true, at: DateTime.utc_now()}}
  end

  def wait_1_day(_context, _result) do
    IO.puts("⏳ Sleeping for 1 day... (demo: 1 second)")
    Process.sleep(1000)
    {:ok, :awake}
  end

  def check_completion(_context, _result) do
    completed = :rand.uniform() > 0.3
    IO.puts("🔍 Checking completion: #{completed}")
    {:ok, %{completed: completed}}
  end
end
