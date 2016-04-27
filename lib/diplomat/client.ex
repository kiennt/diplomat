defmodule Diplomat.Client do
  alias Diplomat.Proto.{Key, Key.PathElement, AllocateIdsRequest}
  require Logger

  @api_version "v1beta2"
  # @api_version "v1beta3"

  def allocate_ids(req) do
    req
    |> Diplomat.Proto.AllocateIdsRequest.encode
    |> call("allocateIds")
    |> case do
      {:ok, body} ->
        body
        |> Diplomat.Proto.AllocateIdsResponse.decode
        |> Diplomat.Key.from_allocate_ids_proto
      any -> any
    end
  end

  def commit(req) do
    req # honestly, I just want to see what this looks like in the git things
    |> Diplomat.Proto.CommitRequest.encode
    |> call("commit")
    |> case do
         {:ok, body} ->
           IO.puts "a good response: #{inspect body}"
           decoded = Diplomat.Proto.CommitResponse.decode(body)
           {:ok, decoded}
         any ->
           IO.puts "the bad response: #{inspect any}"
           any
    end
  end

  def begin_transaction(req) do
    req
    |> Diplomat.Proto.BeginTransactionRequest.encode
    |> call("beginTransaction")
    |> case do
         {:ok, body} ->
           {:ok, Diplomat.Proto.BeginTransactionResponse.decode(body)}
         any -> any
    end
  end

  def rollback(req) do
    req
    |> Diplomat.Proto.RollbackRequest.encode
    |> call("rollback")
    |> case do
         {:ok, body} ->
           {:ok, Diplomat.Proto.RollbackResponse.decode(body)}
          any -> any
    end
  end

  def run_query(req) do
    req
    |> Diplomat.Proto.RunQueryRequest.encode
    |> call("runQuery")
    |> case do
         {:ok, body} ->
           result = body |> Diplomat.Proto.RunQueryResponse.decode
           Enum.map result.batch.entity_result, fn(e) ->
             Diplomat.Entity.from_proto(e.entity)
           end
         any -> any
    end
  end
  defp call(data, method) do
    url(method)
    # "https://www.googleapis.com/datastore/v1beta2/datasets/vitalsource-gc/commit"
    |> HTTPoison.post(data, [auth_header, proto_header])
    |> case do
      {:ok, %{body: body, status_code: code}} when code in 200..299 ->
        Logger.info "the response body: #{inspect body}"
        {:ok, body}
      {_, response} -> {:error, response.body}
    end
  end


  defp url(method), do: url(@api_version, method)
  defp url("v1beta2", method) do
    Path.join([endpoint, "datastore", @api_version, "datasets", project, method])
  end
  defp url("v1beta3", method) do
    Path.join([endpoint, @api_version, "projects", "#{project}:#{method}"])
  end

  defp endpoint, do: Application.get_env(:diplomat, :endpoint, default_endpoint(@api_version))
  defp default_endpoint("v1beta2"), do: "https://www.googleapis.com"
  defp default_endpoint("v1beta3"), do: "https://datastore.googleapis.com"
  defp token_module, do: Application.get_env(:diplomat, :token_module, Goth.Token)

  defp project do
    {:ok, project} = Goth.Config.get(:project_id)
    project
  end

  defp api_scope, do: api_scope(@api_version)
  defp api_scope("v1beta2"), do: "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/datastore"
  defp api_scope("v1beta3"), do: "https://www.googleapis.com/auth/datastore"

  defp auth_header do
    {:ok, token} = token_module.for_scope(api_scope)
    {"Authorization", "#{token.type} #{token.token}"}
  end

  defp proto_header do
    {"Content-Type", "application/x-protobuf"}
  end
end
