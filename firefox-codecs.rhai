let ctx = #{
    description: "Install Firefox/RPM Fusion codec packages for web video playback",
    installable_packages: "ffmpeg\nlibavcodec-freeworld\nmesa-va-drivers-freeworld",
    installed: true,
    missing_required_packages: "",
    name: "firefox-codecs",
    optional_packages: "mozilla-openh264\nopenh264\nmesa-va-drivers-freeworld",
    required_packages: "ffmpeg\nlibavcodec-freeworld",
    unavailable_packages: "mozilla-openh264\nopenh264",
};

fn append_line(text, line) {
    if text == "" { return line; }
    text + "\n" + line
}

fn package_installed(name) {
    shell_status("rpm -q " + name + " >/dev/null 2>&1") == 0
}

fn package_available(name) {
    shell_status("dnf -q info " + name + " >/dev/null 2>&1") == 0
}

fn fedora_releasever() {
    trim(shell_output("rpm -E %fedora"))
}

fn ensure_rpmfusion_free() {
    if package_available("ffmpeg") && package_available("libavcodec-freeworld") { return; }
    let releasever = fedora_releasever();
    let release_rpm =
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-" +
        releasever +
        ".noarch.rpm";
    shell("sudo -n dnf install -y " + release_rpm);
}

fn refresh_plan(ctx) {
    let installable = "";
    let unavailable = "";
    let missing_required = "";

    for pkg in split(ctx.required_packages, "\n") {
        if trim(pkg) == "" { continue; }
        if package_available(pkg) {
            installable = append_line(installable, pkg);
        } else {
            unavailable = append_line(unavailable, pkg);
            missing_required = append_line(missing_required, pkg);
        }
    }

    for pkg in split(ctx.optional_packages, "\n") {
        if trim(pkg) == "" { continue; }

        if package_available(pkg) {
            installable = append_line(installable, pkg);
        } else {
            unavailable = append_line(unavailable, pkg);
        }
    }

    ctx.installable_packages = installable;
    ctx.missing_required_packages = missing_required;
    ctx.unavailable_packages = unavailable;
    ctx
}

fn is_acquired(ctx) {
    ctx = refresh_plan(ctx);
    if ctx.missing_required_packages != "" {
        throw "required packages unavailable:\n" + ctx.missing_required_packages;
    }
    if ctx.installable_packages == "" { throw "no installable packages found"; }
    ctx
}

fn acquire(ctx) {
    ensure_rpmfusion_free();
    ctx = refresh_plan(ctx);
    if ctx.missing_required_packages != "" {
        throw "required packages unavailable:\n" + ctx.missing_required_packages;
    }
    log("Installable codec packages:\n" + ctx.installable_packages);
    if ctx.unavailable_packages != "" {
        warn("Unavailable optional codec packages:\n" + ctx.unavailable_packages);
    }
    ctx
}

fn is_installed(ctx) {
    ctx = refresh_plan(ctx);
    if ctx.missing_required_packages != "" {
        throw "required packages unavailable:\n" + ctx.missing_required_packages;
    }

    for pkg in split(ctx.installable_packages, "\n") {
        if trim(pkg) == "" { continue; }
        if !package_installed(pkg) { throw pkg + " is not installed"; }
    }

    ctx.installed = true;
    ctx
}

fn install(ctx) {
    ensure_rpmfusion_free();
    ctx = refresh_plan(ctx);
    if ctx.missing_required_packages != "" {
        throw "required packages unavailable:\n" + ctx.missing_required_packages;
    }

    let packages = "";
    for pkg in split(ctx.installable_packages, "\n") {
        if trim(pkg) == "" { continue; }
        if packages != "" { packages += " "; }
        packages += pkg;
    }

    if packages == "" { throw "no packages selected for install"; }

    shell("sudo -n dnf install -y --allowerasing " + packages);
    ctx.installed = true;
    ctx
}

fn cleanup(ctx, reason) {
    ctx
}
