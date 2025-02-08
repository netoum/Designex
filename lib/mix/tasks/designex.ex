defmodule Mix.Tasks.Designex do
  use Mix.Task

  @shortdoc "Alias for mix designex.build"

  def run(args) do
    Mix.Task.run("designex.build", args)
  end
end
