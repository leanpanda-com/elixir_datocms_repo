defmodule DatoCMS.Repo.Site do
  require DatoCMS.RESTClient

  def fetch() do
    params = %{include: "item_types,item_types.fields"}
    DatoCMS.RESTClient.Site.get(params)
  end
end
