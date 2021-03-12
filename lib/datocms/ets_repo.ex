defmodule DatoCMS.ETSRepo do
  @items_table :datocms_repo_items
  @item_types_table :datocms_repo_item_types
  @site_table :datocms_repo_site

  def init(args) do
    {:ok, args}
  end

  def start_link() do
    Application.put_env(
      :datocms_rest_client,
      :json_parser_options,
      [keys: :atoms]
    )

    :ets.new(@site_table, [:named_table, :set, :public, {:read_concurrency, true}])
    :ets.new(@items_table, [:named_table, :set, :public, {:read_concurrency, true}])
    :ets.new(@item_types_table, [:named_table, :set, :public, {:read_concurrency, true}])

    {:ok, self()}
  end


  def put(state) do
    put_site(state)
    put_item_types(state)
    put_items(state)

    {:ok}
  end

  defp put_site(state) do
    site_attributes = Enum.map(
      state[:site].data.attributes,
      fn
        {:locales, locales} -> {:locales, Enum.map(locales, &(String.to_atom(&1)))}
        {key, value} -> {key, value}
      end
    )
    :ets.insert(@site_table, site_attributes)
  end

  defp put_item_types(state) do
    item_types_by_type = state[:item_types_by_type]

    item_types = Enum.map(
      item_types_by_type,
      fn {type_name, type} -> {type_name, type} end
    )
    :ets.insert(@item_types_table, item_types)
  end

  defp put_items(state) do
    item_types_by_type = state[:item_types_by_type]
    locales = locales!()

    items = Enum.flat_map(
      state[:items_by_type],
      fn {type, items} ->
        Enum.map(
          items || [],
          fn {id, item} ->
            by_locale = Enum.reduce(locales, %{}, fn locale, acc ->
              item_type = item_types_by_type[type]
              localized = localize(item, item_type, locale)
              Map.put(acc, locale, localized)
            end)
            {{type, id}, by_locale}
          end)
      end
    )
    :ets.insert(@items_table, items)
  end

  def all do
    {:ok, nil}
  end

  def all! do
    {:ok, state} = all()
    state
  end

  def site(attribute) do
    values = :ets.lookup(@site_table, attribute)
    if values != [] do
      [{^attribute, value}] = values
      {:ok, value}
    else
      {:error, :not_found}
    end
  end

  def site!(attribute) do
    {:ok, site} = site(attribute)
    site
  end

  def locales! do
    [locales: locales] = :ets.lookup(@site_table, :locales)
    locales
  end

  def items_of_type(type) do
    items = :ets.match_object(@items_table, {{type, :_}, :"$1"})
    {:ok, Enum.map(items, fn {_k, v} -> v end)}
  end

  def items_of_type!(type) do
    {:ok, items_of_type} = items_of_type(type)
    items_of_type
  end

  def localized_items_of_type(type, locale) do
    items_of_type = items_of_type!(type)
    localized = Enum.map(items_of_type, &(&1[locale]))
    {:ok, localized}
  end

  def localized_items_of_type!(type, locale) do
    {:ok, localized_items_of_type} = localized_items_of_type(type, locale)
    localized_items_of_type
  end

  def get({type, id}, locale) when is_atom(type) and is_binary(id) do
    get({type, String.to_atom(id)}, locale)
  end
  def get({type, ids}, locale) when is_atom(type) and is_list(ids) do
    localized_items = Enum.map(
      ids,
      fn id ->
        items = :ets.lookup(@items_table, {type, id})
        if items != [] do
          hd(items)[locale]
        end
      end
    )
    |> Enum.filter(&(&1))
    {:ok, localized_items}
  end
  def get({type, id}, locale) when is_atom(type) and is_atom(id) do
    [{{^type, ^id}, item}] = :ets.lookup(@items_table, {type, id})
    {:ok, item[locale]}
  end
  def get({type}, locale) do
    items = items_of_type!(type)
    if items != [] do
      item = hd(items)
      {:ok, item[locale]}
    else
      {:error, :not_found}
    end
  end

  def get!(specifier, locale) do
    {:ok, result} = get(specifier, locale)
    result
  end

  def item_type(type) do
    types = :ets.lookup(@item_types_table, type)
    case types do
      [{^type, item_type}] -> {:ok, item_type}
      _ -> {:error, :not_found}
    end
  end

  def item_type!(type) do
    {:ok, item_type} = item_type(type)
    item_type
  end

  def localize(item, item_type, locale) do
    localized_fields = Enum.reduce(item_type.fields, %{slug: "string"}, fn (f, acc) ->
      %{attributes: %{api_key: api_key, localized: localized}} = f
      Map.put(acc, AtomKey.to_atom(api_key), localized)
    end)
    Enum.reduce(item, %{}, fn ({k, v}, acc) ->
      localized = localized_fields[k]
      value = if localized do
        localize_field(k, v, locale)
      else
        v
      end
      Map.put(acc, k, value)
    end)
  end

  defp localize_field(_k, %{} = v, locale) do
    v[locale]
  end
  defp localize_field(_k, v, _locale) do
    v
  end
end
