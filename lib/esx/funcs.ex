defmodule ESx.Funcs do

  def to_mod(%{__struct__: mod}), do: mod
  def to_mod(mod), do: mod

  def to_index_name(mod) do
    to_mod(mod)
    |> to_string
    |> String.split(".")
    |> Enum.take(-2)
    |> Enum.join("-")
    |> String.downcase
  end

  def to_document_type(mod), do: to_index_name mod

  def to_map(any) when is_map(any), do: to_map Enum.into(any, [])
  def to_map(any) when is_list(any) do
    Enum.reduce any, %{}, fn {key, value}, acc ->
      map =
        if Keyword.keyword?(value) do
          Map.new [{:"#{key}", to_map(value)}]
        else
          Map.new [{:"#{key}", value}]
        end

      Map.merge acc, map
    end
  end

  def nameid(mod, name) do
    Enum.join([mod, name])
    |> :erlang.md5
    |> Base.encode16(case: :lower)
    |> String.to_atom
  end

  def build_url([url: url]) do
    case URI.parse(url) do
      %URI{scheme: nil} -> raise ArgumentError, "Missing scheme in Mix.Config"
      %URI{host: nil}   -> raise ArgumentError, "Missing host in Mix.Config"
      _                 -> [url: url]
    end
  end

  def build_url({:system, env}) when is_binary(env) do
    build_url [url: System.get_env(env)]
  end

  def build_url(cfg) when is_list(cfg) do
    u = struct URI, cfg
    u = if cfg[:protocol], do: Map.put(u, :scheme, cfg[:protocol]), else: u
    u = if cfg[:user], do: Map.put(u, :userinfo, "#{cfg[:user]}:#{cfg[:password]}"), else: u

    build_url [url: URI.to_string u]
  end

end
