defmodule Socket.Test do

    use ExUnit.Case

    @valid_state %{user: "alice", game: "game-xyz"}

    test "Socket init [accepts state with user and game]" do
        state = @valid_state
        assert {:ok, ^state} = Socket.init(state)
    end

    test "Socket init [rejects state missing user]" do
        assert {:error, _} = Socket.init(%{game: "game-xyz"})
    end

    test "Socket init [rejects state missing game]" do
        assert {:error, _} = Socket.init(%{user: "alice"})
    end

    test "Socket init [rejects empty map]" do
        assert {:error, _} = Socket.init(%{})
    end

    test "Socket handle_in [ignores non-text/binary opcodes]" do
        state = @valid_state
        assert {:ok, ^state} = Socket.handle_in({"payload", [opcode: :ping]}, state)
    end

    test "Socket handle_in [ignores continuation frames]" do
        state = @valid_state
        assert {:ok, ^state} = Socket.handle_in({"payload", [opcode: :continuation]}, state)
    end

    test "Socket handle_in [text: error on malformed JSON]" do
        state = @valid_state
        result = Socket.handle_in({"not valid json", [opcode: :text]}, state)
        assert {:reply, :ok, {:text, body}, ^state} = result
        assert %{"error" => _} = Jason.decode!(body)
    end

    test "Socket handle_in [text: error on unknown message type]" do
        state = @valid_state
        msg = Jason.encode!(%{"type" => "unknown_type", "body" => %{}})
        result = Socket.handle_in({msg, [opcode: :text]}, state)
        assert {:reply, :ok, {:text, body}, ^state} = result
        assert %{"error" => _} = Jason.decode!(body)
    end

    test "Socket handle_in [text: error when type field is missing]" do
        state = @valid_state
        msg = Jason.encode!(%{"body" => %{}})
        result = Socket.handle_in({msg, [opcode: :text]}, state)
        assert {:reply, :ok, {:text, body}, ^state} = result
        assert %{"error" => _} = Jason.decode!(body)
    end

    test "Socket handle_in [text: error when body field is missing]" do
        state = @valid_state
        msg = Jason.encode!(%{"type" => "domove"})
        result = Socket.handle_in({msg, [opcode: :text]}, state)
        assert {:reply, :ok, {:text, body}, ^state} = result
        assert %{"error" => _} = Jason.decode!(body)
    end

    test "Socket handle_in [binary: error on malformed MsgPack]" do
        state = @valid_state
        result = Socket.handle_in({<<0xC1>>, [opcode: :binary]}, state)
        assert {:reply, :ok, {:binary, body}, ^state} = result
        assert {:ok, %{"error" => _}} = Msgpax.unpack(body)
    end

    test "Socket handle_in [binary: error on unknown message type]" do
        state = @valid_state
        {:ok, packed} = Msgpax.pack(%{"type" => "unknown_type", "body" => %{}})
        msg = IO.iodata_to_binary(packed)
        result = Socket.handle_in({msg, [opcode: :binary]}, state)
        assert {:reply, :ok, {:binary, body}, ^state} = result
        assert {:ok, %{"error" => _}} = Msgpax.unpack(body)
    end

    test "Socket handle_info [forwards {:forward, msg} as text reply]" do
        state = @valid_state
        payload = "game-state-payload"
        assert {:reply, :ok, {:text, ^payload}, ^state} = Socket.handle_info({:forward, payload}, state)
    end

    test "Socket handle_info [rejects unrecognized atom messages]" do
        state = @valid_state
        assert {:error, _} = Socket.handle_info(:unrecognized, state)
    end

    test "Socket handle_info [rejects unknown tuple messages]" do
        state = @valid_state
        assert {:error, _} = Socket.handle_info({:game_update, %{}}, state)
    end
end
