# TurboFlop

## Dependencies
- [Godot 4.4](https://godotengine.org/download) (no .NET support required)
- [SpacetimeDB](https://spacetimedb.com/install) (1.1.1, full install required)
- [Rust](https://www.rust-lang.org/tools/install) (preferrably using rustup)
- [wasm-opt](https://github.com/WebAssembly/binaryen) (optional)
- [Bun](https://bun.sh/) (optional)

## Usage
### Start SpacetimeDB server
You can use the `server/start.sh` script which runs the SpacetimeDB server on docker or start the server using the spacetime CLI command `spacetime start`.

### Build & publish the module
Run `server/publish.sh` (or its contents separately).

### Start the game in Godot
Should be pretty straightforward.

### Start the admin interface (optional)
1. Copy `.env.example` to `.env`
2. Run `bun i` to install node modules
3. Run `bun dev` which starts the webserver on `localhost:5173` by default
4. Run `spacetime logs turboflop` and look for the admin token
5. Enter the admin token on the website and you're good to go

## References
* Countdown sound by [Lesiakower from Pixabay](https://pixabay.com/users/lesiakower-25701529/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=151797)
* Checkpoint sound by [Štefan Baša from Pixabay](https://pixabay.com/users/malarbrush-43159066/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=204151)
