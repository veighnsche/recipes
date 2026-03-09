let ctx = #{
    install_note: "Installed cloudflared 2026.2.0.",
    name: "cloudflared",
    repo: "cloudflare/cloudflared",
    rpm_path: "/tmp/.tmp2Ec0J9/cloudflared-linux-x86_64-2026.2.0.rpm",
    version: "2026.2.0",
};

fn package_name() {
    "cloudflared"
}

fn release_version(ctx) {
    if ctx.version != "" { return ctx.version; }
    github_latest_release(ctx.repo)
}

fn release_url(ctx) {
    "https://github.com/" +
        ctx.repo +
        "/releases/download/" +
        release_version(ctx) +
        "/cloudflared-linux-x86_64.rpm"
}

fn installed_version() {
    trim(shell_output("rpm -q --qf '%{VERSION}' " + package_name()))
}

fn is_installed(ctx) {
    if shell_status("rpm -q " + package_name() + " >/dev/null 2>&1") != 0 {
        throw "cloudflared not installed";
    }

    let wanted = release_version(ctx);
    let installed = installed_version();
    if installed != wanted { throw "version mismatch"; }

    ctx.version = wanted;
    ctx.install_note = "Installed cloudflared " + wanted + ".";
    ctx
}

fn is_acquired(ctx) {
    if ctx.rpm_path == "" || !is_file(ctx.rpm_path) { throw "RPM missing"; }
    ctx
}

fn acquire(ctx) {
    mkdir(BUILD_DIR);

    let version = release_version(ctx);
    let rpm_path = join_path(BUILD_DIR, "cloudflared-linux-x86_64-" + version + ".rpm");
    ctx.version = version;
    ctx.rpm_path = download(release_url(ctx), rpm_path);
    ctx
}

fn install(ctx) {
    shell("sudo dnf -y install " + ctx.rpm_path);

    ctx.install_note = "Installed cloudflared " + ctx.version + ".";
    ctx
}

fn cleanup(ctx, reason) {
    ctx
}
