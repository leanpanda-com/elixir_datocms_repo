defmodule DatoCMS.Repo.FieldsTest do
  use ExUnit.Case, async: true
  import DatoCMS.Repo.Test.Support.FixtureHelper

  setup _context do
    site = load_fixture("site")
    [site: site]
  end

  test "it extracts fields from site info", context do
    {:ok, fields} = DatoCMS.Repo.Fields.from(context[:site])

    assert(length(fields) == 7)

    assert(%{id: "1234", type: "field"} = Enum.fetch!(fields, 0))
  end
end
