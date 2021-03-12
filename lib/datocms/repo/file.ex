defmodule DatoCMS.Repo.File do
  @doc """
  ```
  dato_file_url(file)
  ```
  """
  def url_for(file) do
    domain() <> file.path
  end

  defp domain() do
    imgix_host = DatoCMS.Repo.site!(:imgix_host)
    "https://#{imgix_host}"
  end
end
