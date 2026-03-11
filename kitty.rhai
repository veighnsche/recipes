let ctx = #{
    archive_path: "",
    arm64_sha256: "e1641510492594dd74004d8f82d1b1319adef2e9d1c072e5c014262696c5b359",
    install_note: "Installed kitty 0.46.0 in /home/vince/.local/kitty.app.",
    name: "kitty",
    version: "0.46.0",
    x86_64_sha256: "4a60e3590352ca1794430f3479d1a5814766192ca076ba03998c761e7c2080b7",
};

fn home_dir() {
    env("HOME")
}

fn local_dir() {
    join_path(home_dir(), ".local")
}

fn local_bin_dir() {
    join_path(local_dir(), "bin")
}

fn share_dir() {
    join_path(local_dir(), "share")
}

fn applications_dir() {
    join_path(share_dir(), "applications")
}

fn icons_dir() {
    join_path(share_dir(), "icons")
}

fn install_root_dir() {
    join_path(local_dir(), "kitty.app")
}

fn version_file() {
    join_path(install_root_dir(), ".recipe-version")
}

fn host_arch() {
    trim(shell_output("uname -m"))
}

fn archive_name(ctx) {
    let arch = host_arch();
    if arch == "x86_64" {
        return "kitty-" + ctx.version + "-x86_64.txz";
    }
    if arch == "aarch64" || arch == "arm64" {
        return "kitty-" + ctx.version + "-arm64.txz";
    }
    throw "unsupported architecture: " + arch;
}

fn archive_sha256(ctx) {
    let arch = host_arch();
    if arch == "x86_64" {
        return ctx.x86_64_sha256;
    }
    if arch == "aarch64" || arch == "arm64" {
        return ctx.arm64_sha256;
    }
    throw "unsupported architecture: " + arch;
}

fn release_url(ctx) {
    "https://github.com/kovidgoyal/kitty/releases/download/v" + ctx.version + "/" + archive_name(ctx)
}

fn kitty_bin() {
    join_path(join_path(install_root_dir(), "bin"), "kitty")
}

fn kitten_bin() {
    join_path(join_path(install_root_dir(), "bin"), "kitten")
}

fn local_kitty_link() {
    join_path(local_bin_dir(), "kitty")
}

fn local_kitten_link() {
    join_path(local_bin_dir(), "kitten")
}

fn installed_desktop_file() {
    join_path(applications_dir(), "kitty.desktop")
}

fn installed_open_desktop_file() {
    join_path(applications_dir(), "kitty-open.desktop")
}

fn icon_png_dir() {
    join_path(join_path(join_path(icons_dir(), "hicolor"), "256x256"), "apps")
}

fn icon_svg_dir() {
    join_path(join_path(join_path(icons_dir(), "hicolor"), "scalable"), "apps")
}

fn icon_png_path() {
    join_path(icon_png_dir(), "kitty.png")
}

fn icon_svg_path() {
    join_path(icon_svg_dir(), "kitty.svg")
}

fn installed_version() {
    trim(shell_output(kitty_bin() + " --version | awk '{print $2}'"))
}

fn is_installed(ctx) {
    let root = install_root_dir();

    if !is_dir(root) { throw "install root missing"; }
    if !is_file(kitty_bin()) { throw "kitty binary missing"; }
    if !is_file(kitten_bin()) { throw "kitten binary missing"; }
    if !is_file(local_kitty_link()) { throw "kitty symlink missing"; }
    if !is_file(local_kitten_link()) { throw "kitten symlink missing"; }
    if !is_file(installed_desktop_file()) { throw "kitty desktop entry missing"; }
    if !is_file(installed_open_desktop_file()) { throw "kitty open desktop entry missing"; }
    if !is_file(icon_png_path()) { throw "kitty png icon missing"; }
    if !is_file(icon_svg_path()) { throw "kitty svg icon missing"; }

    let persisted_version = trim(read_file_or_empty(version_file()));
    let detected_version = installed_version();
    if detected_version != ctx.version { throw "version mismatch"; }
    if persisted_version != "" && persisted_version != ctx.version { throw "persisted version mismatch"; }

    ctx.install_note = "Installed kitty " + detected_version + " in " + root + ".";
    ctx
}

fn is_acquired(ctx) {
    if ctx.archive_path == "" || !is_file(ctx.archive_path) { throw "archive missing"; }
    ctx
}

fn acquire(ctx) {
    mkdir(BUILD_DIR);

    let archive_path = join_path(BUILD_DIR, archive_name(ctx));
    ctx.archive_path = download(release_url(ctx), archive_path);
    verify_sha256(ctx.archive_path, archive_sha256(ctx));
    ctx
}

fn install(ctx) {
    let root = install_root_dir();
    let local_bin = local_bin_dir();
    let share = share_dir();
    let applications = applications_dir();
    let icons = icons_dir();

    mkdir(local_dir());
    mkdir(local_bin);
    mkdir(share);
    mkdir(applications);
    mkdir(icons);
    mkdir(join_path(icons, "hicolor"));
    mkdir(join_path(join_path(icons, "hicolor"), "256x256"));
    mkdir(icon_png_dir());
    mkdir(join_path(join_path(icons, "hicolor"), "scalable"));
    mkdir(icon_svg_dir());
    if is_dir(root) { rm(root); }
    mkdir(root);

    shell("tar -xJf " + ctx.archive_path + " -C " + root);
    shell("ln -sfn " + kitty_bin() + " " + local_kitty_link());
    shell("ln -sfn " + kitten_bin() + " " + local_kitten_link());
    shell("cp -f " + join_path(join_path(root, "share/applications"), "kitty.desktop") + " " + installed_desktop_file());
    shell("cp -f " + join_path(join_path(root, "share/applications"), "kitty-open.desktop") + " " + installed_open_desktop_file());
    shell("cp -f " + join_path(join_path(root, "share/icons/hicolor/256x256/apps"), "kitty.png") + " " + icon_png_path());
    shell("cp -f " + join_path(join_path(root, "share/icons/hicolor/scalable/apps"), "kitty.svg") + " " + icon_svg_path());
    shell("sed -i 's#^Exec=kitty$#Exec=" + kitty_bin() + "#' " + installed_desktop_file());
    shell("sed -i 's#^TryExec=kitty$#TryExec=" + kitty_bin() + "#' " + installed_desktop_file());
    shell("sed -i 's#^Exec=kitty +open %U$#Exec=" + kitty_bin() + " +open %U#' " + installed_open_desktop_file());
    shell("sed -i 's#^TryExec=kitty$#TryExec=" + kitty_bin() + "#' " + installed_open_desktop_file());
    shell("update-desktop-database " + applications + " >/dev/null 2>&1 || true");
    shell("kbuildsycoca6 >/dev/null 2>&1 || true");
    write_file(version_file(), ctx.version);

    ctx.install_note = "Installed kitty " + ctx.version + " in " + root + ".";
    ctx
}

fn cleanup(ctx, reason) {
    ctx
}
