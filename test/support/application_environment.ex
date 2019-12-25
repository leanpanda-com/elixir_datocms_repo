defmodule DatoCMS.Repo.Test.Support.ApplicationEnvironment do
  def set(value) do
    Application.put_env(
      :datocms_rest_client,
      :api_config,
      value
    )
  end
end
