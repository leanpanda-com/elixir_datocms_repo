defmodule DatoCMS.Repo.Loader do
  @cache_path "tmp/dato.cache"

  def start(_start_type, _args \\ []) do
    DatoCMS.Repo.Supervisor.start_link()
  end

  def load(opts \\ []) do
    if opts[:from_cache] && File.exists?(@cache_path) do
      load_from_cache()
    else
      {:ok} = DatoCMS.Repo.Site.fetch() |> handle_fetch_site
      if opts[:cache] do
        cache()
      else
        {:ok}
      end
    end
  end

  def put(state) do
    {:ok} = DatoCMS.Repo.put(state)
  end

  defp handle_fetch_site({:ok, site}) do
    DatoCMS.Repo.Items.fetch() |> handle_fetch_items(site)
  end
  defp handle_fetch_site({:error, response}), do: {:error, response}

  defp handle_fetch_items({:ok, items}, site) do
    {:ok, state} = DatoCMS.Repo.Transformer.internalize(site, items)
    {:ok} = put(state)
  end
  defp handle_fetch_items({:error, response}, _site), do: {:error, response}

  def all do
    DatoCMS.Repo.all!()
  end

  defp cache do
    {:ok, state} = DatoCMS.Repo.all()
    path = Path.dirname(@cache_path)
    :ok = File.mkdir_p(path)
    binary = :erlang.term_to_binary(state)
    File.write!(@cache_path, binary)
    {:ok}
  end

  defp load_from_cache do
    {:ok, binary} = File.read(@cache_path)
    state = :erlang.binary_to_term(binary)
    {:ok} = DatoCMS.Repo.put(state)
  end
end
