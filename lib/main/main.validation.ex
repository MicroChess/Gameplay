defmodule ClusterChess.Main.Validation do

    @signer Joken.Signer.create("HS256", System.get_env("JWT_SECRET"))


    def validate_token("Bearer " <> token), do: validate_token(token)
    def validate_token(nil), do: {:error, :no_jwt_token_provided}
    def validate_token("Guest"), do: {:ok, %{ uid: "guest" }}

    def validate_token(token) do
        with {:ok, claims} <- Joken.verify(token, @signer),
        :ok <- validate_claims(claims) do
            {:ok, claims}
        end
    end

    defp validate_claims(claims) do
        cond do
            claims["iss"] != "clusterchess" -> {:error, :invalid_issuer}
            claims["aud"] != "clusterchess_client" -> {:error, :invalid_audience}
            claims["exp"] <= System.system_time(:second) -> {:error, :token_expired}
            claims["nbf"] >  System.system_time(:second) -> {:error, :token_not_yet_valid}
            true -> :ok
        end
    end
end
