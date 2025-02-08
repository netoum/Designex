defmodule Designex do
  # https://github.com/netoum/designex_cli/releases
  @latest_version "1.0.2"
  @latest_commit "1da4b31"

  @moduledoc """
  # Designex

  Mix tasks for installing and invoking [designex](https://github.com/netoum/designex_cli) via the
  stand-alone [designex cli](https://github.com/netoum/designex_cli/releases/tag/v1.0.2)

  ## Installation

  If you are going to build assets in production, then you add
  `designex` as dependency on all environments but only start it
  in dev:

  ```elixir
  def deps do
  [
    {:designex, "~> 1.0.2", runtime: Mix.env() == :dev}
  ]
  end
  ```

  However, if your assets are precompiled during development,
  then it only needs to be a dev dependency:

  ```elixir
  def deps do
  [
    {:designex, "~> 1.0.2", only: :dev}
  ]
  end
  ```

  Once installed, change your `config/config.exs` to pick your
  designex version of choice:

  ```elixir
  config :designex,
  version: "1.0.2",
  commit: "1da4b31",
  cd: Path.expand("../assets", __DIR__),
  dir: "design",
  demo: [
    setup_args: ~w(
    --dir=demo
    --template=shadcn/tokens-studio/single
  ),
    build_args: ~w(
    --dir=demo
    --script=build.mjs
    --tokens=tokens
  )
  ]
  ```

  Now you can install designex by running:

  ```bash
  $ mix designex.install
  ```

  The executable is kept at `_build/designex-TARGET`.
  Where `TARGET` is your system target architecture.

  If your platform isn't officially supported by Designex,
  you can supply a third party path to the binary the installer wants
  (beware that we cannot guarantee the compatibility of any third party executable):
  The installer also copy the node_modules needed into the assets path. Oclif currently do not pack dependencies

  ```bash
  $ mix designex.install https://people.freebsd.org/~dch/pub/designex/v0.0.1/designex-linux-x64
  ```

  If you already use Node and have a node_modules folder, you must install the dependencies seperatly by by adding them to your package.json

  ```bash
  $ mix designex.install --no-deps
  ```
  Then in you package.json add the dependencies needed by your scripts
  "dependencies": {
    "@tokens-studio/sd-transforms": "^1.2.9",
    "sd-tailwindcss-transformer": "^2.0.0",
    "style-dictionary": "^4.3.0"
  },

  ## Profiles

  The first argument to `designex` is the execution profile.
  You can define multiple execution profiles with the current
  directory, the OS environment, and default arguments to the
  `designex` task:

  ```elixir
  demo: [
    setup_args: ~w(
    --dir=demo
    --template=shadcn/tokens-studio/single
  ),
    build_args: ~w(
    --dir=demo
    --script=build.mjs
    --tokens=tokens
  )
  ],
  email: [
    setup_args: ~w(
    --dir=email
    --template=shadcn/tokens-studio/multi
  ),
    build_args: ~w(
    --dir=email
    --script=build.mjs
    --tokens=tokens
  )
  ]
  ```

  When `mix designex demo` is invoked, the task arguments will be appended
  to the ones configured above. Note profiles must be configured in your
  `config/config.exs`, as `designex` runs without starting your application
  (and therefore it won't pick settings in `config/runtime.exs`).


  ## Designex Setup
  To setup Invoke Designex Setup with your profile:

  ```bash
  $ mix designex.setup demo
  $ mix designex.setup email

  ```

  You can choose the template and directory by adding them to your designex profile


  ## Designex build
  To setup Invoke Designex Build with your profile:

  ```bash
  $ mix designex demo
  $ mix designex email
  ```
  or
  ```bash
  $ mix designex.build demo
  $ mix designex.build email
  ```

  You can choose the template and directory by adding them to your designex profile

  ## Watch Mode

  For development, we want to enable watch mode. So find the `watchers`
  configuration in your `config/dev.exs` and add:

  ```elixir
  designex: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ```

  Note we are enabling the file system watcher.

  Finally, run the command:

  ```bash
  $ mix designex default
  ```

  This command installs the Design tokens and scripts.
  It also generates a default configuration file called
  `designex.config.js` for you. This is the file we referenced
  when we configured `designex` in `config/config.exs`. See
  `mix help designex.install` to learn more.

  ## Designex configuration

  There are two global configurations for the designex application:

    * `:version` - the expected designex version

    * `:commit` - the expected designex commit

    * `:cacerts_path` - the directory to find certificates for
      https connections

    * `:path` - the path to find the designex executable at. By
      default, it is automatically downloaded and placed inside
      the `_build` directory of your current app

  Overriding the `:path` is not recommended, as we will automatically
  download and manage `designex` for you. But in case you can't download
  it (for example, GitHub behind a proxy), you may want to
  set the `:path` to a configurable system location.

  For instance, you can install `designex` globally with `npm`:

      $ npm install -g designex

  On Unix, the executable will be at:

      NPM_ROOT/designex/node_modules/designex-TARGET/bin/designex

  On Windows, it will be at:

      NPM_ROOT/designex/node_modules/designex-windows-(32|64)/designex.exe

  Where `NPM_ROOT` is the result of `npm root -g` and `TARGET` is your system
  target architecture.

  Once you find the location of the executable, you can store it in a
  `MIX_DESIGNEX_PATH` environment variable, which you can then read in
  your configuration file:

      config :designex, path: System.get_env("MIX_DESIGNEX_PATH")

  """
  use Application
  require Logger

  @doc false
  def start(_, _) do
    unless Application.get_env(:designex, :version) do
      Logger.warning("""
      designex version is not configured. Please set it in your config files:

          config :designex, :version, "#{latest_version()}"
      """)
    end

    unless Application.get_env(:designex, :commit) do
      Logger.warning("""
      designex commit is not configured. Please set it in your config files:

          config :designex, :commit, "#{latest_commit()}"
      """)
    end

    configured_version = configured_version()

    case bin_version() do
      {:ok, ^configured_version} ->
        :ok

      {:ok, version} ->
        Logger.warning("""
        Outdated designex version. Expected #{configured_version}, got #{version}. \
        Please run `mix designex.install` or update the version in your config files.\
        """)

      :error ->
        :ok
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  @doc false
  # Latest known version at the time of publishing.
  def latest_version, do: @latest_version

  @doc false
  # Latest known commit at the time of publishing.
  def latest_commit, do: @latest_commit

  @doc """
  Returns the configured designex version.
  """
  def configured_version do
    Application.get_env(:designex, :version, latest_version())
  end

  @doc """
  Returns the configured designex version.
  """
  def configured_commit do
    Application.get_env(:designex, :commit, latest_commit())
  end

  @doc """
  Returns the configured cd directory path.
  """
  def configured_cd do
    Application.get_env(:designex, :cd, File.cwd!())
  end

  @doc """
  Returns the configured designex directory name.
  """
  def configured_dir do
    Application.get_env(:designex, :dir, "")
  end

  @doc """
  Returns the configured designex directory name.
  """
  def profile_path(profile) do
    Path.join([configured_cd(), configured_dir(), to_string(profile)])
  end

  @doc """
  Returns the configuration for the given profile.

  Returns nil if the profile does not exist.
  """
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:designex, profile) ||
      raise ArgumentError, """
      unknown designex profile. Make sure the profile is defined in your config/config.exs file, such as:

          config :designex,
            version: "#{@latest_version}",
            commit: "#{@latest_commit}",
            cd: Path.expand("../assets/designex", __DIR__),
            #{profile}: [
              args: ~w(
                --config=designex.config.js
              )            ]
      """
  end

  @doc """
  Returns the path to the executable.

  The executable may not be available if it was not yet installed.
  """
  def bin_path do
    # name = "designex-#{target()}"
    name = "designex-#{target()}/bin/designex"

    Application.get_env(:designex, :path) ||
      if Code.ensure_loaded?(Mix.Project) do
        Path.join(Path.dirname(Mix.Project.build_path()), name)
      else
        Path.expand("_build/#{name}")
      end
  end

  def extract_path do
    name = "designex-#{target()}"

    Application.get_env(:designex, :path) ||
      if Code.ensure_loaded?(Mix.Project) do
        Path.join(Path.dirname(Mix.Project.build_path()), name)
      else
        Path.expand("_build/#{name}")
      end
  end

  @doc """
  Returns the version of the designex executable.

  Returns `{:ok, version_string}` on success or `:error` when the executable
  is not available.
  """
  def bin_version do
    path = bin_path()

    with true <- File.exists?(path),
         {out, 0} <- System.cmd(path, ["--version"]),
         [vsn] <- Regex.run(~r/designex\/([^\s]+)/, out, capture: :all_but_first) do
      {:ok, vsn}
    else
      _ -> :error
    end
  end

  @doc """
  Runs the given command with `args`.

  The given args will be appended to the configured args.
  The task output will be streamed directly to stdio. It
  returns the status of the underlying call.
  """
  def setup(profile, extra_args) when is_atom(profile) and is_list(extra_args) do
    config = config_for!(profile)
    args = config[:setup_args] || []
    destination = Path.join([configured_cd(), configured_dir() || to_string(profile)])

    unless File.exists?(destination) do
      File.mkdir_p!(destination)
    end

    env =
      config
      |> Keyword.get(:env, %{})
      |> add_env_variable_to_ignore_browserslist_outdated_warning()

    opts = [
      cd: destination,
      env: env,
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    bin_path()
    |> System.cmd(["setup"] ++ args, opts)
    |> elem(1)
  end

  @doc """
  Runs the given command with `args`.

  The given args will be appended to the configured args.
  The task output will be streamed directly to stdio. It
  returns the status of the underlying call.
  """
  def run(profile, extra_args) when is_atom(profile) and is_list(extra_args) do
    config = config_for!(profile)
    args = config[:build_args] || []
    destination = Path.join([configured_cd(), configured_dir() || to_string(profile)])

    env =
      config
      |> Keyword.get(:env, %{})
      |> add_env_variable_to_ignore_browserslist_outdated_warning()

    opts = [
      cd: destination,
      env: env,
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    bin_path()
    |> System.cmd(["build"] ++ args ++ extra_args, opts)
    |> elem(1)
  end

  defp add_env_variable_to_ignore_browserslist_outdated_warning(env) do
    Enum.into(env, %{"BROWSERSLIST_IGNORE_OLD_DATA" => "1"})
  end

  @doc """
  Installs, if not available, and then runs `designex`.

  Returns the same as `run/2`.
  """
  def install_and_run(profile, args) do
    config = config_for!(profile)

    unless File.exists?(bin_path()) do
      install(config[:deps])
    end

    unless File.exists?(profile_path(profile)) do
      setup(profile, args)
    end

    run(profile, args)
  end

  @doc """
  The default URL to install Designex from.
  """
  def default_base_url do
    "https://github.com/netoum/designex_cli/releases/download/v$version/designex-v$version-$commit-$target.tar.gz"
  end

  @doc """
  Installs designex with `configured_version/0`.
  """
  def install(deps, base_url \\ default_base_url()) do
    url = get_url(base_url)
    bin_path = bin_path()
    extract_path = extract_path()
    tar = fetch_body!(url)

    # MacOS doesn't recompute code signing information if a binary
    # is overwritten with a new version, so we force creation of a new file
    if File.exists?(bin_path) do
      File.rm!(bin_path)
    end

    File.mkdir_p!(Path.dirname(extract_path))

    case :erl_tar.extract({:binary, tar}, [:compressed, :memory]) do
      {:ok, files} ->
        Enum.each(files, fn
          {file_path, content} when is_list(file_path) ->
            path = List.to_string(file_path)
            cleaned_path = String.replace_prefix(path, "designex/", "")
            full_path = Path.join(extract_path, cleaned_path)
            File.mkdir_p!(Path.dirname(full_path))
            File.write!(full_path, content)

          _ ->
            :ok
        end)

      {:error, reason} ->
        IO.puts("Failed to extract tar: #{inspect(reason)}")
    end

    File.chmod(bin_path, 0o755)

    if is_nil(deps) do
      target_path = Path.join(configured_cd(), "node_modules")
      source_path = Path.join(extract_path, "node_modules")

      unless File.exists?(target_path) do
        File.mkdir!(target_path)
        File.cp_r!(source_path, target_path)
      end
    end
  end

  # Available targets:
  #  linux-x64
  #  linux-arm
  #  linux-arm64
  #  win32-x64
  #  win32-x86
  #  win32-arm64
  #  darwin-x64
  #  darwin-arm64

  defp target do
    arch_str = :erlang.system_info(:system_architecture)
    [arch | _] = arch_str |> List.to_string() |> String.split("-")

    case {:os.type(), arch, :erlang.system_info(:wordsize) * 8} do
      {{:win32, _}, "x86_64", 64} -> "win32-x86"
      {{:win32, _}, arch, 64} when arch in ~w(arm aarch64) -> "win32-arm64"
      {{:win32, _}, _arch, 64} -> "win32-x64"
      {{:unix, :darwin}, arch, 64} when arch in ~w(arm aarch64) -> "darwin-arm64"
      {{:unix, :darwin}, "x86_64", 64} -> "darwin-x64"
      {{:unix, :linux}, "aarch64", 64} -> "linux-arm64"
      {{:unix, :linux}, "arm", 32} -> "linux-arm"
      {{:unix, :linux}, "armv7" <> _, 32} -> "linux-arm"
      {{:unix, _osname}, arch, 64} when arch in ~w(x86_64 amd64) -> "linux-x64"
      {_os, _arch, _wordsize} -> raise "designex is not available for architecture: #{arch_str}"
    end
  end

  defp fetch_body!(url) do
    scheme = URI.parse(url).scheme
    url = String.to_charlist(url)
    Logger.debug("Downloading designex from #{url}")

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    if proxy = proxy_for_scheme(scheme) do
      %{host: host, port: port} = URI.parse(proxy)
      Logger.debug("Using #{String.upcase(scheme)}_PROXY: #{proxy}")
      set_option = if "https" == scheme, do: :https_proxy, else: :proxy
      :httpc.set_options([{set_option, {{String.to_charlist(host), port}, []}}])
    end

    # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
    cacertfile = cacertfile() |> String.to_charlist()

    http_options =
      [
        ssl: [
          verify: :verify_peer,
          cacertfile: cacertfile,
          depth: 2,
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ],
          versions: protocol_versions()
        ]
      ]
      |> maybe_add_proxy_auth(scheme)

    options = [body_format: :binary]

    case :httpc.request(:get, {url, []}, http_options, options) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        body

      other ->
        raise """
        Couldn't fetch #{url}: #{inspect(other)}

        This typically means we cannot reach the source or you are behind a proxy.
        You can try again later and, if that does not work, you might:

          1. If behind a proxy, ensure your proxy is configured and that
             your certificates are set via the cacerts_path configuration

          2. Manually download the executable from the URL above and
             place it inside "_build/designex-#{target()}"

          3. Install and use Designex from npmJS. See our module documentation
             to learn more: https://hexdocs.pm/designex
        """
    end
  end

  defp proxy_for_scheme("http") do
    System.get_env("HTTP_PROXY") || System.get_env("http_proxy")
  end

  defp proxy_for_scheme("https") do
    System.get_env("HTTPS_PROXY") || System.get_env("https_proxy")
  end

  defp maybe_add_proxy_auth(http_options, scheme) do
    case proxy_auth(scheme) do
      nil -> http_options
      auth -> [{:proxy_auth, auth} | http_options]
    end
  end

  defp proxy_auth(scheme) do
    with proxy when is_binary(proxy) <- proxy_for_scheme(scheme),
         %{userinfo: userinfo} when is_binary(userinfo) <- URI.parse(proxy),
         [username, password] <- String.split(userinfo, ":") do
      {String.to_charlist(username), String.to_charlist(password)}
    else
      _ -> nil
    end
  end

  defp cacertfile() do
    Application.get_env(:designex, :cacerts_path) || CAStore.file_path()
  end

  defp protocol_versions do
    if otp_version() < 25, do: [:"tlsv1.2"], else: [:"tlsv1.2", :"tlsv1.3"]
  end

  defp otp_version do
    :erlang.system_info(:otp_release) |> List.to_integer()
  end

  defp get_url(base_url) do
    base_url
    |> String.replace("$version", configured_version())
    |> String.replace("$target", target())
    |> String.replace("$commit", configured_commit())
  end
end
