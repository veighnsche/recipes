let ctx = #{
    name: "shell-suite",
    version: "0.1.0",
    bootstrap_packages: "curl ca-certificates tar gzip",
    local_root: "",
    local_bin: "",
    install_note: "",
};

fn home_dir() {
    env("HOME")
}

fn local_root_dir() {
    join_path(home_dir(), ".local")
}

fn local_bin_dir() {
    join_path(local_root_dir(), "bin")
}

fn command_exists(name) {
    shell_status("command -v " + name + " >/dev/null 2>&1") == 0
}

fn ensure_starship() {
    if command_exists("starship") || is_file(join_path(local_bin_dir(), "starship")) { return; }
    shell("curl -sS https://starship.rs/install.sh | sh -s -- -y -b " + local_bin_dir());
}

fn is_installed(ctx) {
    let local_bin = local_bin_dir();

    if !command_exists("starship") && !is_file(join_path(local_bin, "starship")) { throw "starship missing"; }

    ctx.local_root = local_root_dir();
    ctx.local_bin = local_bin;
    ctx.install_note = "Starship installed in ~/.local/bin.";
    ctx
}

fn is_acquired(ctx) {
    ctx
}

fn acquire(ctx) {
    mkdir(BUILD_DIR);

    ctx.local_root = local_root_dir();
    ctx.local_bin = local_bin_dir();
    ctx
}

fn install(ctx) {
    let local_root = local_root_dir();
    let local_bin = local_bin_dir();

    mkdir(local_root);
    mkdir(local_bin);

    shell("sudo dnf -y install " + ctx.bootstrap_packages);

    ensure_starship();

    ctx.local_root = local_root;
    ctx.local_bin = local_bin;
    ctx.install_note = "Starship install complete.";
    ctx
}

fn cleanup(ctx, reason) {
    ctx
}
