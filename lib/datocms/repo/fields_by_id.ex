defmodule DatoCMS.Repo.FieldsById do
  def from(site) do
    {:ok, fields} = DatoCMS.Repo.Fields.from(site)
    fields = Enum.map(fields, fn (f) ->
      {:ok, v} = DatoCMS.Repo.TransformField.from(f)
      v
    end)
    {:ok, IndexEntities.by_id(fields)}
  end
end
