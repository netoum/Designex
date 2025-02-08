defmodule Mix.Tasks.Designex.Setup do
  @moduledoc """
  Invokes designex with the given args.

  Usage:

      $ mix designex TASK_OPTIONS PROFILE TAILWIND_ARGS

  Example:

      $ mix designex default --config=designex.config.js \
        --input=css/app.css \
        --output=../priv/static/assets/app.css \
        --minify

  If designex is not installed, it is automatically downloaded.
  Note the arguments given to this task will be appended
  to any configured arguments.

  ## Options

    * `--runtime-config` - load the runtime configuration
      before executing command

  Note flags to control this Mix task must be given before the
  profile:

      $ mix designex --runtime-config default
  """

  @shortdoc "Invokes designex with the profile and args"
  @compile {:no_warn_undefined, Mix}

  use Mix.Task

  @impl true
  def run(args) do
    switches = [runtime_config: :boolean]
    {opts, remaining_args} = OptionParser.parse_head!(args, switches: switches)

    if function_exported?(Mix, :ensure_application!, 1) do
      Mix.ensure_application!(:inets)
      Mix.ensure_application!(:ssl)
    end

    if opts[:runtime_config] do
      Mix.Task.run("app.config")
    else
      Mix.Task.run("loadpaths")
      Application.ensure_all_started(:designex)
    end

    Mix.Task.reenable("designex")

    setup(remaining_args)
  end

  defp setup([profile | args] = all) do
    case Designex.setup(String.to_atom(profile), args) do
      0 -> :ok
      status -> Mix.raise("`mix designex #{Enum.join(all, " ")}` exited with #{status}")
    end
  end

  defp setup([]) do
    Mix.raise("`mix designex` expects the profile as argument")
  end
end
