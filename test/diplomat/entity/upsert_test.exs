defmodule Diplomat.Entity.UpsertTest do
  use ExUnit.Case

  alias Diplomat.Entity
  alias Diplomat.Proto.{CommitResponse, MutationResult}

  setup do
    bypass = Bypass.open
    Application.put_env(:diplomat, :endpoint, "http://localhost:#{bypass.port}")
    {:ok, bypass: bypass}
  end

  test "upserting a single Entity", %{bypass: bypass} do
    entity = Entity.new(%{title: "20k Leagues", author: "Jules Verne"}, "Book", "20k-key")

    {:ok, project} = Goth.Config.get(:project_id)
    {kind, name}   = {"TestBook", "my-book-unique-id"}

    entity = Entity.new(
      %{"name" => "My awesome book", "author" => "Phil Burrows"},
      kind, name
    )

    Bypass.expect bypass, fn conn ->
      assert Regex.match?(~r{/datastore/v1beta2/datasets/#{project}/commit}, conn.request_path)
      resp = CommitResponse.new(
        mutation_result: MutationResult.new(
          index_updates: 1,
          # insert_auto_id_key: [ (Key.new(kind, name) |> Key.proto) ]
        )
      ) |> CommitResponse.encode
      Plug.Conn.resp conn, 201, resp
    end

    resp = Entity.upsert(entity)
    assert %CommitResponse{} = resp
  end
end

