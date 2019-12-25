defmodule DatoCMS.Repo.Test.Support.FixtureHelper do
  def fixtures_path, do: Path.join("test", "fixtures")

  def read_fixture(name) do
    Path.join(fixtures_path(), name <> ".json")
    |> File.read!
  end

  def load_fixture(name) do
    {:ok, data} =
      read_fixture(name)
      |> Jason.decode(keys: :atoms)

    data
  end
end
