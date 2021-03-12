defmodule DatoCMS.Repo.Image do
  @extra_attributes %{ixlib: "rb-1.1.0", auto: "compress,format"}

  @doc """
  Accepts a chain of attributes to be converted to params:

  ```
  dato_image_url(img, ch: "Width,DPR", width: 200, ...)
  ```
  """
  def url_for(image, attributes \\ %{}) do
    all = Map.merge(@extra_attributes, attributes)
    domain() <> image.path <> "?" <> URI.encode_query(all)
  end

  defp domain() do
    imgix_host = DatoCMS.Repo.site!(:imgix_host)
    "https://#{imgix_host}"
  end
end
