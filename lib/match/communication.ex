defmodule KubeChess.Match.Communication do

    @derive Jason.Encoder
    defstruct [
        :type,
        :token,
        :game,
        :count,
    ]
end
