# TurboFlop
TurboFlop is a low poly multiplayer arcade racing game built with the [Godot 4.4](https://godotengine.org) Engine. The multiplayer features are implemented with [SpacetimeDB](https://spacetimedb.com) using the inofficial  [Godot-SpacetimeDB-SDK](https://github.com/flametime/Godot-SpacetimeDB-SDK) which is implemented entirely in GDScript. For user management there is an admin UI written in [React](https://react.dev/) using the [Bun](https://bun.sh/) package manager ([yarn](https://classic.yarnpkg.com/en/) is also supported).

## Dependencies
* [Godot 4.4](https://godotengine.org/download) (no .NET support)
* [SpacetimeDB](https://spacetimedb.com/install) (required for multiplayer, version 1.1.1, full install)
* [Rust](https://www.rust-lang.org/tools/install) (required for multiplayer, preferrably using rustup)
* [wasm-opt](https://github.com/WebAssembly/binaryen) (optional)
* [Bun](https://bun.sh/) or [yarn](https://classic.yarnpkg.com/lang/en/docs/install) (optional, required for admin UI)

## Deployment
### Quickstart with Docker Compose (recommended)
Download `docker-compose.yml` and execute `docker-compose up` or `deploy.sh` to fetch and deploy the pre-built Docker containers of the current turboflop version.

### Build and run the Docker containers yourself
If you want to deploy your own version of the game, you can either:
1. Fork this repository and publish a new tag which will build and publish the Docker images on `ghcr.io/{{repository_owner}}/turboflop-{{web/spacetime}}` which you can then replace the current URLs in `docker-compose.yml` with (NOTE: you have to add a personal access token (classic) to the GHCR_TOKEN secret in your repository) or
2. Run `docker build server -t legendariusx/turboflop-spacetime -f server/Dockerfile.spacetime` and `docker build . -t legendariusx/turboflop-web -f Dockerfile.web`

Afterwards you can start the docker containers separately 
```
docker run --rm --pull always -p 3000:3000 -d legendariusx/turboflop-spacetime
docker run --rm --pull always -p 80:80 -d legendariusx/turboflop-web
```

### Fetch admin token from spacetime container
Run `docker exec -it {{turboflop-spacetime_container_id}} spacetime logs turboflop` which should give an output that looks something like this:

`1970-01-01T00:00:00.000Z  INFO: src/lib.rs:83: New admin token: ABCDEFGHIJKLMNOPQRSTUVWXYZ`

Note that this admin token is regenerated on every restart but once authenticated users remain authenticated.

### Manual
See below

## Development 
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

## Future Work / Major ToDos
* Performance improvements (especially first track load)
* Client refactoring (current directory structure is not very logical)
* Backend refactoring (split reducers into multiple files)
* Server Lobbies
* Real singleplayer mode which stores personal bests
* Anti-Cheat
* More and better UI (e.g. menu)

## References
* Countdown sound by [Lesiakower from Pixabay](https://pixabay.com/users/lesiakower-25701529/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=151797)
* Checkpoint sound by [Štefan Baša from Pixabay](https://pixabay.com/users/malarbrush-43159066/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=204151)
* Engine sound from [Godot 3D Truck Town Demo](https://godotengine.org/asset-library/asset/524)
