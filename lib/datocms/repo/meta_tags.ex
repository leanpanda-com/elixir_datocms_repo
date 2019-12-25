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
    item = item(specifier)
    item_type = item_type(type)
    site = site()
    build_tags(item, item_type, site, locale)
  end
  def for_item(item, locale) do
    type = item.item_type
    item_type = item_type(type)
    site = site()
    build_tags(item, item_type, site, locale)
  end

  defp item(specifier), do: DatoCMS.Repo.get!(specifier)
  defp item_type(type), do: DatoCMS.Repo.item_type!(type)
  defp site(), do: DatoCMS.Repo.site!()

  defp build_tags(item, item_type, site, locale) do
    args = [%{locale: locale, item: item, item_type: item_type, site: site}]
    tags = Enum.map(@meta_tag_modules, fn (module) ->
      {:ok, tags} = apply(module, :build, args)
      tags
    end) |> List.flatten
    {:ok, tags}
  end
end
