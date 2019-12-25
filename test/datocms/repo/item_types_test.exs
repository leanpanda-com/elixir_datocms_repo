defmodule DatoCMS.Repo.ItemTypes.Test do
  use ExUnit.Case, async: true
  import DatoCMS.Repo.Test.Support.FixtureHelper

  setup _context do
    site = load_fixture("site")
    [site: site]
  end

  test "it extracts item types from the site", context do
    {:ok, items} = DatoCMS.Repo.ItemTypes.from(context[:site])

    assert(length(items) == 3)

    assert(%{id: "123", type: "item_type"} = Enum.fetch!(items, 0))
  end
end
