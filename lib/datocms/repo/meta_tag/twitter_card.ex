defmodule DatoCMS.Repo.MetaTag.TwitterCard do
  import DatoCMS.Repo.MetaTag.Helpers

  def build(%{}) do
    {:ok, [card_tag("twitter:card", "summary")]}
  end
end
