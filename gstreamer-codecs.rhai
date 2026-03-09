let ctx = #{
    description: "Install broader GStreamer codec plugins from RPM Fusion",
    installed: true,
    name: "gstreamer-codecs",
    required_packages: "gstreamer1-plugins-bad-freeworld\ngstreamer1-plugins-ugly",
};

fn package_installed(name) {
    shell_status("rpm -q " + name + " >/dev/null 2>&1") == 0
}

fn package_available(name) {
    shell_status("dnf -q info " + name + " >/dev/null 2>&1") == 0
}

fn selected_packages(ctx) {
    let packages = "";

    for pkg in split(ctx.required_packages, "\n") {
        let name = trim(pkg);
        if name == "" { continue; }
        if !package_available(name) { throw name + " is not available"; }
        if packages != "" { packages += " "; }
        packages += name;
    }

    packages
}

fn is_acquired(ctx) {
    selected_packages(ctx);
    ctx
}

fn acquire(ctx) {
    log("Installable GStreamer codec packages:\n" + ctx.required_packages);
    ctx
}

fn is_installed(ctx) {
    for pkg in split(ctx.required_packages, "\n") {
        let name = trim(pkg);
        if name == "" { continue; }
        if !package_installed(name) { throw name + " is not installed"; }
    }

    ctx.installed = true;
    ctx
}

fn install(ctx) {
    let packages = selected_packages(ctx);
    shell("sudo -n dnf install -y " + packages);
    ctx.installed = true;
    ctx
}

fn cleanup(ctx, reason) {
    ctx
}
