defmodule Mix.Tasks.Designex.Install do
  @moduledoc """
  Installs Designex executable and assets.

      $ mix designex.install
      $ mix designex.install --if-missing

  By default, it installs #{Designex.latest_version()} but you
  can configure it in your config files, such as:

      config :designex, :version, "#{Designex.latest_version()}"

  ## Options

      * `--runtime-config` - load the runtime configuration
        before executing command

      * `--if-missing` - install only if the given version
        does not exist

      * `--no-deps` - does not install Designex Node dependencies. Use this in case you already have a node_modules folder.
      Add instead the dependencies to your own package.json\n
        "dependencies": {
        "@tokens-studio/sd-transforms": "^1.2.9",
        "sd-tailwindcss-transformer": "^2.0.0",
        "style-dictionary": "^4.3.0"
        }

  ## Assets

  Whenever Designex is installed, a default designex configuration
  will be placed in a new `assets/designex.config.js` file. See
  the [designex documentation](https://tailwindcss.com/docs/configuration)
  on configuration options.

  The default designex configuration includes Designex variants for Phoenix
  LiveView specific lifecycle classes:

    * phx-no-feedback - applied when feedback should be hidden from the user
    * phx-click-loading - applied when an event is sent to the server on click
      while the client awaits the server response
    * phx-submit-loading - applied when a form is submitted while the client awaits the server response
    * phx-submit-loading - applied when a form input is changed while the client awaits the server response

  Therefore, you may apply a variant, such as `phx-click-loading:animate-pulse`
  to customize designex classes when Phoenix LiveView classes are applied.
  """

  @shortdoc "Installs Designex executable and dependencies"
  @compile {:no_warn_undefined, Mix}

  use Mix.Task

  @impl true
  def run(args) do
    valid_options = [runtime_config: :boolean, if_missing: :boolean, deps: :boolean]

    {opts, base_url} =
      case OptionParser.parse_head!(args, strict: valid_options) do
        {opts, []} ->
          {opts, Designex.default_base_url()}

        {opts, [base_url]} ->
          {opts, base_url}

        {_, _} ->
          Mix.raise("""
          Invalid arguments to designex.install, expected one of:

              mix designex.install
              mix designex.install 'https://github.com/netoum/designex_js/releases/download/v$version/designex-$target'
              mix designex.install --runtime-config
              mix designex.install --if-missing
              mix designex.install --no-deps
          """)
      end

    if opts[:runtime_config], do: Mix.Task.run("app.config")

    if opts[:if_missing] && latest_version?() do
      :ok
    else
      if function_exported?(Mix, :ensure_application!, 1) do
        Mix.ensure_application!(:inets)
        Mix.ensure_application!(:ssl)
      end

      Mix.Task.run("loadpaths")
      Designex.install(opts[:deps], base_url)
    end
  end

  defp latest_version?() do
    version = Designex.configured_version()
    match?({:ok, ^version}, Designex.bin_version())
  end
end
