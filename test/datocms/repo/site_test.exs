defmodule DatoCMS.Repo.SiteTest.FakeHTTPClient do
  import DatoCMS.Repo.Test.Support.FixtureHelper

  @api_base "https://site-api.datocms.com"

  def request(_method, url, _body, _headers, _options) do
    respond(url)
  end

  defp respond(@api_base <> "/site?include=item_types%2Citem_types.fields") do
    response_body = read_fixture("site")
    {:ok, %HTTPoison.Response{status_code: 200, body: response_body}}
  end
end

defmodule DatoCMS.Repo.SiteTest.TestData do
  def access_token, do: "access_token"

  def test_env() do
    [
      %{headers: ["Authorization": "Bearer #{access_token()}"]},
      http_client: DatoCMS.Repo.SiteTest.FakeHTTPClient
    ]
  end
end

defmodule DatoCMS.Repo.SiteTest do
  use ExUnit.Case, async: true
  import DatoCMS.Repo.SiteTest.TestData
  import DatoCMS.Repo.Test.Support.FixtureHelper

  setup _context do
    DatoCMS.Repo.Test.Support.ApplicationEnvironment.set(test_env())
    site = read_fixture("site") |> Jason.decode!
    [site: site]
  end

  test "it returns site data", context do
    {:ok, site} = DatoCMS.Repo.Site.fetch()

    assert(site == context[:site])
  end
end
