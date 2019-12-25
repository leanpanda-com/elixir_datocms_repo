defmodule DatoCMS.Repo.MetaTag.OgLocale do
  import DatoCMS.Repo.MetaTag.Helpers

  def build(%{locale: locale}) do
    string = Atom.to_string(locale)
    locale_string = "#{locale}_#{String.upcase(string)}"
    {:ok, [og_tag("og:locale", locale_string)]}
  end
end
