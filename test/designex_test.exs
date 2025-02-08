defmodule DesignexTest do
  use ExUnit.Case, async: false

  @version Designex.latest_version()
  @commit Designex.latest_commit()

  test "start function with configured version and commit" do
    assert {:ok, pid} = Designex.start(nil, nil)
    assert is_pid(pid)
  end

  test "warn on start function without configured version and commit" do
    Application.delete_env(:designex, :version)
    Application.delete_env(:designex, :commit)

    on_exit(fn -> Application.put_env(:designex, :version, @version) end)
    on_exit(fn -> Application.put_env(:designex, :commit, @commit) end)

    warning_message_version = """
    [warning] designex version is not configured. Please set it in your config files:

        config :designex, :version, \"#{@version}\"
    """

    commit_message_version = """
    [warning] designex commit is not configured. Please set it in your config files:

        config :designex, :commit, \"#{@commit}\"
    """

    output =
      ExUnit.CaptureLog.capture_log(fn ->
        {:ok, pid} = Designex.start(nil, nil)
        assert is_pid(pid)
      end)

    assert output =~ warning_message_version
    assert output =~ commit_message_version

    Application.put_env(:designex, :version, @version)
    Application.put_env(:designex, :commit, @commit)
  end

  test "run bin_version()" do
    assert Designex.bin_version() == {:ok, @version}
  end

  test "run --version" do
    path = Designex.bin_path()
    {output, exit_code} = System.cmd(path, ["--version"])

    expected_output = "@netoum/designex/#{@version} linux-x64 node-v22.9.0\n"
    assert {output, exit_code} == {expected_output, 0}
  end

  test "setup on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Designex.setup(:test, []) == 0
           end) =~ """
           Designex template \"shadcn/tokens-studio/single\"\n✅ build.mjs copied to: #{Application.get_env(:designex, :cd)}/tmp/build.mjs\n✅ tokens.json copied to: #{Application.get_env(:designex, :cd)}/tmp/tokens/tokens.json\n✅ transform.mjs copied to: #{Application.get_env(:designex, :cd)}/tmp/transform.mjs
           """
  end

  test "run on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Designex.run(:test, []) == 0
           end) =~ """
           Executing script at: #{Application.get_env(:designex, :cd)}/tmp/build.mjs\n✔︎ tmp/tokens/multi/$metadata.json\n✔︎ tmp/tokens/multi/$themes.json\n✔︎ tmp/tokens/multi/shadcn.json\n✔︎ tmp/tokens/multi/shadcn.json\n✔︎ tmp/tokens/multi/mode/dark.json\n✅ Tokens transformed successfully\n\ncss\n✔︎ #{Application.get_env(:designex, :cd)}/tmp/build/css/mode/dark.css\n\ncss\n✔︎ #{Application.get_env(:designex, :cd)}/tmp/build/css/shadcn.css\n\ntailwind/colors\n✔︎ #{Application.get_env(:designex, :cd)}/tmp/build/shadcn/colors.js\n\ntailwind/borderRadius\n✔︎ #{Application.get_env(:designex, :cd)}/tmp/build/shadcn/borderRadius.js\n\ntailwind/fontFamily\n✔︎ #{Application.get_env(:designex, :cd)}/tmp/build/shadcn/fontFamily.js\n✅ Build completed successfully\n\n✅ Script executed successfully.
           """
  end
end
