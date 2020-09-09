defmodule DatoCMS.Repo.Helpers do
  @doc false
  defmacro __using__(_opts) do
    quote do
      def dato_item({type, _id} = specifier, locale) when is_atom(type) and is_atom(locale) do
        DatoCMS.Repo.get!(specifier, locale)
      end
      def dato_item({type, _id} = specifier, locale) when is_atom(type) and is_binary(locale) do
        dato_item(specifier, String.to_atom(locale))
      end

      def dato_item({type} = specifier, locale) when is_atom(type) and is_atom(locale) do
        DatoCMS.Repo.get!(specifier, locale)
      end
      def dato_item({type} = specifier, locale) when is_atom(type) and is_binary(locale) do
        dato_item(specifier, locale)
      end

      def dato_item(type, locale) when is_atom(type) and is_atom(locale) do
        dato_item({type}, locale)
      end
      def dato_item(type, locale) when is_atom(type) and is_binary(locale) do
        dato_item({type}, String.to_atom(locale))
      end
      def dato_item(type, locale) when is_binary(type) and is_atom(locale) do
        dato_item({String.to_atom(type)}, locale)
      end
      def dato_item(type, locale) when is_binary(type) and is_binary(locale) do
        dato_item({String.to_atom(type)}, String.to_atom(locale))
      end

      def dato_item({type, _id} = specifier) when is_atom(type) do
        DatoCMS.Repo.get!(specifier)
      end
      def dato_item({type} = specifier) when is_atom(type) do
        DatoCMS.Repo.get!(specifier)
      end
      def dato_item(type) when is_atom(type) do
        dato_item({type})
      end
      def dato_item(type) when is_binary(type) do
        dato_item({String.to_atom(type)})
      end

      # {:type, %{en: [], it: [...]}}
      def dato_items({type, %{} = locale_ids}, locale) when is_atom(type) and is_atom(locale) do
        ids = locale_ids[locale]
        Enum.map(ids, &dato_item({type, &1}, locale))
      end
      def dato_items({type, specifiers}, locale) when is_atom(type) and is_list(specifiers) and is_atom(locale) do
        Enum.map(specifiers, &dato_item({type, &1}, locale))
      end
      def dato_items(specifiers, locale) when is_list(specifiers) and is_atom(locale) do
        Enum.map(specifiers, &dato_item(&1, locale))
      end
      def dato_items({type}, locale) when is_atom(type) and is_atom(locale) do
        DatoCMS.Repo.localized_items_of_type!(type, locale)
      end
      def dato_items(type, locale) when is_atom(type) and is_atom(locale) do
        DatoCMS.Repo.localized_items_of_type!(type, locale)
      end

      def dato_meta_tags(specifier, locale) when is_atom(locale) do
        {:ok, tags} = DatoCMS.Repo.MetaTags.for_item(specifier, locale)
        stringify_tags(tags)
      end

      def dato_favicon_meta_tags(theme_color \\ nil) do
        {:ok, tags} = DatoCMS.Repo.FaviconMetaTags.meta_tags(
          DatoCMS.Repo.site!(),
          theme_color
        )
        stringify_tags(tags)
      end

      def dato_file_url(file) do
        DatoCMS.Repo.File.url_for(file)
      end

      def dato_image_url(image, attributes \\ %{}) do
        DatoCMS.Repo.Image.url_for(image, attributes)
      end

      defp stringify_tags(tags) do
        Enum.map(tags, fn (tag) ->
          attributes = if tag[:attributes] do
              tag[:attributes]
              |> Enum.map(fn ({k, v}) -> "#{k}=\"#{v}\"" end)
              |> Enum.join(" ")
            else
              ""
            end
          if tag[:content] do
            "<#{tag.tag_name} #{attributes}>#{tag.content}</#{tag.tag_name}>"
          else
            "<#{tag.tag_name} #{attributes}/>"
          end
        end)
        |> Enum.join("\n")
      end
    end
  end
end
