defmodule DatoCMS.Repo.MetaTag.Helpers do
  def tag(tag_name, attributes) do
    %{tag_name: tag_name, attributes: attributes}
  end

  def meta_tag(name, content) do
    tag("meta", %{name: name, content: content})
  end

  def og_tag(property, content) do
    tag("meta", %{property: property, content: content})
  end

  def card_tag(name, content) do
    meta_tag(name, content)
  end

  def content_tag(tag_name, content) do
    %{tag_name: tag_name, content: content}
  end
end
