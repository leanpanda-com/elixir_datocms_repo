defmodule DatoCMS.Repo do
  use GenServer
  use Memoize

  @server_name :datocms_repo

  def init(args) do
    {:ok, args}
  end

  def start_link() do
    Application.put_env(
      :datocms_rest_client,
      :json_parser_options,
      [keys: :atoms]
    )

    GenServer.start_link(__MODULE__, [], name: @server_name)

    {:ok, self()}
  end

  def put(state) do
    GenServer.call(@server_name, {:put, state})

    {:ok}
  end

  def all do
    GenServer.call(@server_name, {:all})
  end

  def all! do
    {:ok, state} = all()
    state
  end

  defmemo site(attribute) do
    {:ok, site!().data.attributes[attribute]}
  end

  def site!(attribute) do
    {:ok, site} = site(attribute)
    site
  end

  def site do
    GenServer.call(@server_name, {:site})
  end

  def site! do
    {:ok, site} = site()
    site
  end

  defmemo items_of_type(type) do
    GenServer.call(@server_name, {:items_of_type, type})
  end

  defmemo items_of_type!(type) do
    {:ok, items_of_type} = items_of_type(type)
    items_of_type
  end

  defmemo localized_items_of_type(type, locale) do
    GenServer.call(@server_name, {:localized_items_of_type, type, locale})
  end

  defmemo localized_items_of_type!(type, locale) do
    {:ok, localized_items_of_type} = localized_items_of_type(type, locale)
    localized_items_of_type
  end

  defmemo get(specifier) do
    GenServer.call(@server_name, {:get, {specifier}})
  end
  defmemo get(specifier, locale) do
    GenServer.call(@server_name, {:get, {specifier, locale}})
  end

  def get!(specifier) do
    {:ok, result} = get(specifier)
    result
  end
  def get!(specifier, locale) do
    {:ok, result} = get(specifier, locale)
    result
  end

  def item_type(type) do
    GenServer.call(@server_name, {:item_type, type})
  end

  def item_type!(type) do
    {:ok, result} = item_type(type)
    result
  end

  def handle_call({:put, state}, _from, _state) do
    {:reply, {:ok}, state}
  end
  def handle_call({:all}, _from, state) do
    {:reply, {:ok, state}, state}
  end
  def handle_call({:site}, _from, state) do
    site = state[:site]
    {:reply, {:ok, site}, state}
  end
  def handle_call({:items_of_type, type}, _from, state) do
    {:ok, locales} = locales(state)
    item_type = item_type(type, state)
    items = items_of_type(type, state)
    |> Enum.map(fn {_id, item} ->
      Enum.reduce(locales, %{}, fn locale, acc ->
        localized = localize(item, item_type, locale)
        put_in(acc, [locale], localized)
      end)
    end)
    {:reply, {:ok, items}, state}
  end
  def handle_call({:localized_items_of_type, type, locale}, _from, state) do
    item_type = item_type(type, state)
    items_of_type(type, state)
    |> handle_items_of_type_for_localization(state, item_type, locale)
  end
  def handle_call({:get, {specifier}}, _from, state) do
    handle_get(specifier, state)
  end
  def handle_call({:get, {specifier, locale}}, _from, state) do
    handle_get(specifier, locale, state)
  end
  def handle_call({:item_type, type}, _from, state) do
    item_type(type, state) |> handle_item_type(state)
  end

  defp items_of_type(type, state) do
    state[:items_by_type][type]
  end

  def handle_get({_type, nil}, _locale, state) do
    {:reply, {:ok, nil}, state}
  end
  def handle_get({type, id_or_ids}, locale, state) when not is_atom(type) do
    handle_get({AtomKey.to_atom(type), id_or_ids}, locale, state)
  end
  def handle_get({type}, locale, state) when not is_atom(type) do
    handle_get({AtomKey.to_atom(type)}, locale, state)
  end
  def handle_get({type, ids}, locale, state) when is_list(ids) do
    items = items_of_type(type, state)
    item_type = item_type(type, state)
    localized_items = Enum.map(ids, fn (id) ->
      item_key = AtomKey.to_atom(id)
      localize(items[item_key], item_type, locale)
    end)
    {:reply, {:ok, localized_items}, state}
  end
  def handle_get({type, id}, locale, state) do
    items = items_of_type(type, state)
    item_type = item_type(type, state)
    item_key = AtomKey.to_atom(id)
    item = localize(items[item_key], item_type, locale)
    {:reply, {:ok, item}, state}
  end
  def handle_get({type}, locale, state) do
    items = items_of_type(type, state)
    first = hd(Map.keys(items))
    item_key = AtomKey.to_atom(first)
    item_type = item_type(type, state)
    item = localize(items[item_key], item_type, locale)
    {:reply, {:ok, item}, state}
  end
  def handle_get({type, ids}, state) when is_list(ids) do
    {:ok, locale} = default_locale(state)
    handle_get({type, ids}, locale, state)
  end
  def handle_get({type, id}, state) do
    {:ok, locale} = default_locale(state)
    handle_get({type, id}, locale, state)
  end
  def handle_get({type}, state) do
    {:ok, locale} = default_locale(state)
    handle_get({type}, locale, state)
  end

  def handle_item_type(item_type, state) do
    {:reply, {:ok, item_type}, state}
  end

  def handle_items_of_type_for_localization(nil, state, _item_type, _locale) do
    {:reply, {:ok, []}, state}
  end
  def handle_items_of_type_for_localization(unlocalized, state, item_type, locale) do
    items = Enum.map(unlocalized, fn ({_id, item}) ->
      localize(item, item_type, locale)
    end)
    {:reply, {:ok, items}, state}
  end

  defp locales(state) do
    locales = state[:site][:data][:attributes][:locales]
    |> Enum.map(&(AtomKey.to_atom(&1)))
    {:ok, locales}
  end

  defp default_locale(state) do
    {:ok, [first_locale | _]} = locales(state)
    {:ok, first_locale}
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

  defp item_type(type, state) do
    item_types = state[:item_types_by_type]
    item_types[type]
  end
end
