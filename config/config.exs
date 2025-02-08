import Config

config :designex,
  version: "1.0.2",
  commit: "1da4b31",
  cd: Path.expand("../test", __DIR__),
  test: [
    setup_args: ~w(
    --dir=tmp
    --template=shadcn/tokens-studio/single
  ),
    build_args: ~w(
    --dir=tmp
    --script=build.mjs
    --tokens=tokens
  )
  ]
