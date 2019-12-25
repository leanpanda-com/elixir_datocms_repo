defmodule DatoCMS.Repo.ItemsByType.Test do
  use ExUnit.Case, async: true
  import DatoCMS.Repo.Test.Support.FixtureHelper

  setup _context do
    site = load_fixture("site")
    item_data = load_fixture("items1")
    {:ok, item_types_by_type} =
      DatoCMS.Repo.ItemTypesByType.from(site)

    [
      items: item_data[:data],
      item_types_by_type: item_types_by_type
    ]
  end

  test "it groups items by type name and id", context do
    {:ok, collections} =
      DatoCMS.Repo.ItemsByType.from(
        context[:items], context[:item_types_by_type]
      )

    assert(Map.has_key?(collections, :post))
    assert(Map.keys(collections.post) == [:"12345"])
  end

  test "it internalizes items", context do
    {:ok, collections} = DatoCMS.Repo.ItemsByType.from(
      context.items, context.item_types_by_type
    )

    post = collections.post[:"12345"]

    assert(post.item_type == :post)
    assert(post.title == %{en: "The Title", it: "Il titolo"})
    assert(post.category == {:category, "12346"})
    assert(post.tags == {:tag, ["12347"]})
  end
end
