defmodule DatoCMS.Repo.Transformer do
  def internalize(site, items) do
    {:ok, item_types_by_type} =
      DatoCMS.Repo.ItemTypesByType.from(site)
    {:ok, items_by_type} =
      DatoCMS.Repo.ItemsByType.from(items, item_types_by_type)
    {:ok, items_by_type} =
      DatoCMS.Repo.AddMissingSlugs.to(items_by_type, item_types_by_type)

    {
      :ok,
      [
        items_by_type: items_by_type,
        item_types_by_type: item_types_by_type,
        site: site
      ]
    }
  end
end
