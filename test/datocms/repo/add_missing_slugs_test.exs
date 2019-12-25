defmodule DatoCMS.Repo.AddMissingSlugs.Test do
  use ExUnit.Case, async: true
  import DatoCMS.Repo.Test.Support.FixtureHelper

  setup do
    site = load_fixture("site")
    item_data = load_fixture("items1")
    items = item_data[:data]

    {:ok, item_types_by_type} =
      DatoCMS.Repo.ItemTypesByType.from(site)
    {:ok, original_items_by_type} =
      DatoCMS.Repo.ItemsByType.from(items, item_types_by_type)

    {:ok, items_by_type} = DatoCMS.Repo.AddMissingSlugs.to(
      original_items_by_type, item_types_by_type
    )

    [
      items_by_type: items_by_type,
      original_items_by_type: original_items_by_type
    ]
  end

  test "it adds slugs based on the title field", context do
    posts = context[:items_by_type].post
    item = posts[:"12345"]

    assert(item.slug == %{en: "12345-the-title", it: "12345-il-titolo"})
  end

  describe "if there are already slugs" do
    test "it does nothing", context do
      tags = context[:items_by_type].tag
      tag = tags[:"12347"]

      assert(tag.slug == "a-custom-tag-slug")
    end
  end

  describe "if there isn't a title field" do
    test "it does nothing", context do
      original = context[:items_by_type].tag[:"XXXXXXXXXXXXXX"]
      modified = context[:original_items_by_type].tag[:"XXXXXXXXXXXXXX"]

      assert(original == modified)
    end
  end
end
