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

## License

> This is a based on [Phoenix Tailwind](https://github.com/phoenixframework/tailwind). See original for License and Contributors
Copyright (c) 2025 Karim Semmoud.

Designex source code is licensed under the [MIT License](LICENSE.md).