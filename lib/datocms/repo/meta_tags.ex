defmodule DatoCMS.Repo.MetaTags do
  @meta_tag_modules [
    DatoCMS.Repo.MetaTag.Title,
    DatoCMS.Repo.MetaTag.Description,
    DatoCMS.Repo.MetaTag.Image,
    DatoCMS.Repo.MetaTag.Robots,
    DatoCMS.Repo.MetaTag.OgLocale,
    DatoCMS.Repo.MetaTag.OgType,
    DatoCMS.Repo.MetaTag.OgSiteName,
    DatoCMS.Repo.MetaTag.ArticleModifiedTime,
    DatoCMS.Repo.MetaTag.ArticlePublisher,
    DatoCMS.Repo.MetaTag.TwitterCard,
    DatoCMS.Repo.MetaTag.TwitterSite
  ]

  def for_item({type, _id} = specifier, locale) do
    item = item(specifier, locale)
    item_type = item_type(type)
    build_tags(item, item_type, %{}, locale)
  end
  def for_item(item, locale) do
    type = item.item_type
    item_type = item_type(type)
    build_tags(item, item_type, %{}, locale) # TODO: don't inject site into modules
  end

  defp item(specifier, locale), do: DatoCMS.Repo.get!(specifier, locale)
  defp item_type(type), do: DatoCMS.Repo.item_type!(type)

  defp build_tags(item, item_type, site, locale) do
    args = [%{locale: locale, item: item, item_type: item_type, site: site}]
    tags = Enum.map(@meta_tag_modules, fn (module) ->
      {:ok, tags} = apply(module, :build, args)
      tags
    end) |> List.flatten
    {:ok, tags}
  end
end
