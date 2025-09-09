defmodule KoombeaScraper.Workers.WorkerSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_worker(page) do
    child_spec = {KoombeaScraper.Workers.Worker, page}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
