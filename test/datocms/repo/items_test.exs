defmodule DatoCMS.Repo.ItemsTest.FakeHTTPClient do
  import DatoCMS.Repo.Test.Support.FixtureHelper

  @api_base "https://site-api.datocms.com"

  def request(_method, url, _body, _headers, _options) do
    respond(url)
  end

  defp respond(@api_base <> "/items?page%5Blimit%5D=500&page%5Boffset%5D=0") do
    response_body = read_fixture("items1")
    {:ok, %HTTPoison.Response{status_code: 200, body: response_body}}
  end
end

defmodule DatoCMS.Repo.ItemsTest.TestData do
  def access_token, do: "access_token"

  def test_env() do
    [
      %{headers: ["Authorization": "Bearer #{access_token()}"]},
      http_client: DatoCMS.Repo.ItemsTest.FakeHTTPClient
    ]
  end
end

defmodule DatoCMS.Repo.ItemsTest do
  use ExUnit.Case, async: true
  import DatoCMS.Repo.ItemsTest.TestData
  import DatoCMS.Repo.Test.Support.FixtureHelper

  setup _context do
    DatoCMS.Repo.Test.Support.ApplicationEnvironment.set(test_env())
    items = read_fixture("items1") |> Jason.decode!
    [items: items]
  end

  test "it returns item data", context do
    {:ok, items} = DatoCMS.Repo.Items.fetch()

    assert(items == context[:items]["data"])
  end
end
