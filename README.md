# TurboFlop
TurboFlop is a low poly multiplayer arcade racing game built with the [Godot 4.4](https://godotengine.org) Engine. The multiplayer features are implemented with [SpacetimeDB](https://spacetimedb.com) using the inofficial  [Godot-SpacetimeDB-SDK](https://github.com/flametime/Godot-SpacetimeDB-SDK) which is implemented entirely in GDScript. For user management there is an admin UI written in [React](https://react.dev/) using the [Bun](https://bun.sh/) package manager.

## Dependencies
* [Godot 4.4](https://godotengine.org/download) (no .NET support)
* [SpacetimeDB](https://spacetimedb.com/install) (recommended, 1.1.1, full install)
* [Rust](https://www.rust-lang.org/tools/install) (required for multiplayer, preferrably using rustup)
* [wasm-opt](https://github.com/WebAssembly/binaryen) (optional)
* [Bun](https://bun.sh/) (optional)

## Usage (Debug)
### Start SpacetimeDB server (recommended)
1. You can use the `server/start.sh` script which runs the SpacetimeDB server on docker or start the server using the spacetime CLI command `spacetime start`.
2. Run `server/publish.sh` (or its contents separately).

### Start the game in Godot
Should be pretty straightforward. Make sure to use Compatibility mode for development to ensure parity with web environments.

### Start the admin interface (optional)
1. Copy `.env.example` to `.env`
2. Run `bun i` to install node modules
3. Run `bun dev` which starts the webserver on `localhost:5173` by default
4. Run `spacetime logs turboflop` and look for the admin token
5. Enter the admin token on the website and you're good to go

## Deployment
TODO

## Future Work / Major ToDos
* Performance improvements (especially first track load)
* Client refactoring (current directory structure is not very logical)
* Backend refactoring (split reducers into multiple files)
* Deployment documentation / Docker Compose file
* Build pipeline (currently three separate builds are necessary)

## References
* Countdown sound by [Lesiakower from Pixabay](https://pixabay.com/users/lesiakower-25701529/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=151797)
* Checkpoint sound by [Štefan Baša from Pixabay](https://pixabay.com/users/malarbrush-43159066/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=204151)
* Engine sound from [Godot 3D Truck Town Demo](https://godotengine.org/asset-library/asset/524)
