defmodule Helix.Event.Listenable.Flow do

  defmacro listenable(event, do: block) do
    quote do

      defimpl Helix.Event.Listenable do
        @moduledoc false

        def get_objects(unquote(event)) do
          unquote(block)
        end
      end

    end
  end
end
