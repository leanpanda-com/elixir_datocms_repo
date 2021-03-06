defmodule DatoCMS.Repo.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [worker(DatoCMS.Repo, [])]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
