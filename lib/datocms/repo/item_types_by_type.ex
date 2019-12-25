defmodule DatoCMS.Repo.ItemTypesByType do
  def from(site) do
    {:ok, item_types} = DatoCMS.Repo.ItemTypes.from(site)
    {:ok, fields_by_id} = DatoCMS.Repo.FieldsById.from(site)
    item_types = Enum.map(item_types, fn (item_type) ->
      {:ok, v} = DatoCMS.Repo.ItemType.from(item_type, fields_by_id)
      v
    end)
    {:ok, IndexEntities.by_key(item_types, :type_name)}
  end
end
