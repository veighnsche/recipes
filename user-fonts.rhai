let ctx = #{
    fonts_root: "/home/vince/.local/share/fonts/user-fonts",
    install_note: "Installed Iosevka 34.2.1, Inter 4.1, and San Francisco Pro 8bfea09aa6f1139479f80358b2e1e5c6dc991a58, plus selected Nerd Fonts 3.4.0 into /home/vince/.local/share/fonts/user-fonts.",
    inter_archive: "/tmp/.tmpDARcie/Inter-4.1.zip",
    inter_dir: "/home/vince/.local/share/fonts/user-fonts/inter",
    inter_version: "4.1",
    iosevka_archive: "/tmp/.tmpDARcie/PkgTTC-Iosevka-34.2.1.zip",
    iosevka_dir: "/home/vince/.local/share/fonts/user-fonts/iosevka",
    iosevka_version: "34.2.1",
    name: "user-fonts",
    nerd_fonts_version: "3.4.0",
    sf_pro_archive: "/tmp/.tmpDARcie/San-Francisco-Pro-Fonts-8bfea09aa6f1139479f80358b2e1e5c6dc991a58.zip",
    sf_pro_commit: "8bfea09aa6f1139479f80358b2e1e5c6dc991a58",
    sf_pro_dir: "/home/vince/.local/share/fonts/user-fonts/san-francisco-pro",
};

fn home_dir() {
    env("HOME")
}

fn local_dir() {
    join_path(home_dir(), ".local")
}

fn share_dir() {
    join_path(local_dir(), "share")
}

fn user_fonts_dir() {
    join_path(share_dir(), "fonts")
}

fn recipe_fonts_root() {
    join_path(user_fonts_dir(), "user-fonts")
}

fn iosevka_target_dir() {
    join_path(recipe_fonts_root(), "iosevka")
}

fn inter_target_dir() {
    join_path(recipe_fonts_root(), "inter")
}

fn sf_pro_target_dir() {
    join_path(recipe_fonts_root(), "san-francisco-pro")
}

fn nerd_fonts_root() {
    join_path(recipe_fonts_root(), "nerd-fonts")
}

fn version_file(dir) {
    join_path(dir, ".recipe-version")
}

fn nerd_fonts() {
    [
        #{ slug: "jetbrains-mono", asset: "JetBrainsMono.tar.xz" },
        #{ slug: "hack", asset: "Hack.tar.xz" },
        #{ slug: "fira-code", asset: "FiraCode.tar.xz" },
        #{ slug: "iosevka-nerd", asset: "Iosevka.tar.xz" },
        #{ slug: "caskaydia-cove", asset: "CascadiaCode.tar.xz" },
        #{ slug: "code-new-roman", asset: "CodeNewRoman.tar.xz" },
        #{ slug: "meslo", asset: "Meslo.tar.xz" },
        #{ slug: "ubuntu-mono", asset: "UbuntuMono.tar.xz" },
        #{ slug: "source-code-pro", asset: "SourceCodePro.tar.xz" },
        #{ slug: "geist-mono", asset: "GeistMono.tar.xz" },
        #{ slug: "commit-mono", asset: "CommitMono.tar.xz" },
        #{ slug: "monaspace", asset: "Monaspace.tar.xz" }
    ]
}

fn iosevka_url(ctx) {
    "https://github.com/be5invis/Iosevka/releases/download/v" +
        ctx.iosevka_version +
        "/PkgTTC-Iosevka-" +
        ctx.iosevka_version +
        ".zip"
}

fn inter_url(ctx) {
    "https://github.com/rsms/inter/releases/download/v" +
        ctx.inter_version +
        "/Inter-" +
        ctx.inter_version +
        ".zip"
}

fn sf_pro_url(ctx) {
    "https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts/archive/" +
        ctx.sf_pro_commit +
        ".zip"
}

fn nerd_font_url(ctx, asset) {
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v" +
        ctx.nerd_fonts_version +
        "/" +
        asset
}

fn nerd_font_archive_path(build_dir, font) {
    join_path(build_dir, font.asset)
}

fn nerd_font_target_dir(font) {
    join_path(nerd_fonts_root(), font.slug)
}

fn nerd_font_unpack_dir(build_dir, font) {
    join_path(build_dir, font.slug + "-unpack")
}

fn has_matching_fonts(dir, pattern) {
    shell_status("find " + dir + " -maxdepth 1 -type f -name '" + pattern + "' | grep -q .") == 0
}

fn is_installed(ctx) {
    let fonts_root = recipe_fonts_root();
    let iosevka_dir = iosevka_target_dir();
    let inter_dir = inter_target_dir();
    let sf_pro_dir = sf_pro_target_dir();
    let nerd_root = nerd_fonts_root();

    if !is_dir(fonts_root) { throw "font root missing"; }
    if !is_dir(iosevka_dir) { throw "Iosevka target missing"; }
    if !is_dir(inter_dir) { throw "Inter target missing"; }
    if !is_dir(sf_pro_dir) { throw "San Francisco Pro target missing"; }
    if !is_dir(nerd_root) { throw "Nerd Fonts root missing"; }

    let iosevka_version = trim(read_file_or_empty(version_file(iosevka_dir)));
    let inter_version = trim(read_file_or_empty(version_file(inter_dir)));
    let sf_pro_version = trim(read_file_or_empty(version_file(sf_pro_dir)));

    if iosevka_version != ctx.iosevka_version { throw "Iosevka version mismatch"; }
    if inter_version != ctx.inter_version { throw "Inter version mismatch"; }
    if sf_pro_version != ctx.sf_pro_commit { throw "San Francisco Pro version mismatch"; }
    if !has_matching_fonts(iosevka_dir, "*.ttc") { throw "Iosevka TTC files missing"; }
    if !has_matching_fonts(inter_dir, "*.ttf") && !has_matching_fonts(inter_dir, "*.otf") {
        throw "Inter font files missing";
    }
    if !has_matching_fonts(sf_pro_dir, "*.ttf") && !has_matching_fonts(sf_pro_dir, "*.otf") {
        throw "San Francisco Pro font files missing";
    }
    for font in nerd_fonts() {
        let dir = nerd_font_target_dir(font);
        if !is_dir(dir) { throw "Nerd Font target missing: " + font.slug; }
        let version = trim(read_file_or_empty(version_file(dir)));
        if version != ctx.nerd_fonts_version { throw "Nerd Font version mismatch: " + font.slug; }
        if !has_matching_fonts(dir, "*.ttf") && !has_matching_fonts(dir, "*.otf") {
            throw "Nerd Font files missing: " + font.slug;
        }
    }

    ctx.fonts_root = fonts_root;
    ctx.iosevka_dir = iosevka_dir;
    ctx.inter_dir = inter_dir;
    ctx.sf_pro_dir = sf_pro_dir;
    ctx.install_note =
        "Installed Iosevka " + ctx.iosevka_version +
        ", Inter " + ctx.inter_version +
        ", and San Francisco Pro " + ctx.sf_pro_commit +
        ", plus selected Nerd Fonts " + ctx.nerd_fonts_version +
        " into " + fonts_root + ".";
    ctx
}

fn is_acquired(ctx) {
    if ctx.iosevka_archive == "" || !is_file(ctx.iosevka_archive) { throw "Iosevka archive missing"; }
    if ctx.inter_archive == "" || !is_file(ctx.inter_archive) { throw "Inter archive missing"; }
    if ctx.sf_pro_archive == "" || !is_file(ctx.sf_pro_archive) { throw "San Francisco Pro archive missing"; }
    for font in nerd_fonts() {
        if !is_file(nerd_font_archive_path(BUILD_DIR, font)) { throw "Nerd Font archive missing: " + font.asset; }
    }
    ctx
}

fn acquire(ctx) {
    mkdir(BUILD_DIR);

    ctx.iosevka_archive = download(
        iosevka_url(ctx),
        join_path(BUILD_DIR, "PkgTTC-Iosevka-" + ctx.iosevka_version + ".zip")
    );
    ctx.inter_archive = download(
        inter_url(ctx),
        join_path(BUILD_DIR, "Inter-" + ctx.inter_version + ".zip")
    );
    ctx.sf_pro_archive = download(
        sf_pro_url(ctx),
        join_path(BUILD_DIR, "San-Francisco-Pro-Fonts-" + ctx.sf_pro_commit + ".zip")
    );
    for font in nerd_fonts() {
        download(nerd_font_url(ctx, font.asset), nerd_font_archive_path(BUILD_DIR, font));
    }
    ctx
}

fn install(ctx) {
    let fonts_root = recipe_fonts_root();
    let iosevka_dir = iosevka_target_dir();
    let inter_dir = inter_target_dir();
    let sf_pro_dir = sf_pro_target_dir();
    let nerd_root = nerd_fonts_root();
    let iosevka_unpack = join_path(BUILD_DIR, "iosevka-unpack");
    let inter_unpack = join_path(BUILD_DIR, "inter-unpack");
    let sf_pro_unpack = join_path(BUILD_DIR, "sf-pro-unpack");

    mkdir(local_dir());
    mkdir(share_dir());
    mkdir(user_fonts_dir());
    mkdir(fonts_root);
    mkdir(iosevka_dir);
    mkdir(inter_dir);
    mkdir(sf_pro_dir);
    mkdir(nerd_root);

    rm(join_path(iosevka_dir, "*"));
    rm(join_path(inter_dir, "*"));
    rm(join_path(sf_pro_dir, "*"));
    rm(join_path(iosevka_unpack, "*"));
    rm(join_path(inter_unpack, "*"));
    rm(join_path(sf_pro_unpack, "*"));
    mkdir(iosevka_unpack);
    mkdir(inter_unpack);
    mkdir(sf_pro_unpack);
    for font in nerd_fonts() {
        let dir = nerd_font_target_dir(font);
        let unpack = nerd_font_unpack_dir(BUILD_DIR, font);
        mkdir(dir);
        rm(join_path(dir, "*"));
        rm(join_path(unpack, "*"));
        mkdir(unpack);
    }

    extract(ctx.iosevka_archive, iosevka_unpack);
    extract(ctx.inter_archive, inter_unpack);
    extract(ctx.sf_pro_archive, sf_pro_unpack);
    for font in nerd_fonts() {
        extract(nerd_font_archive_path(BUILD_DIR, font), nerd_font_unpack_dir(BUILD_DIR, font));
    }

    shell("find " + iosevka_unpack + " -type f -name '*.ttc' -exec cp -f {} " + iosevka_dir + "/ \\;");
    shell("find " + inter_unpack + " -type f \\( -name '*.ttf' -o -name '*.otf' \\) -exec cp -f {} " + inter_dir + "/ \\;");
    shell("find " + sf_pro_unpack + " -type f \\( -name '*.ttf' -o -name '*.otf' \\) -exec cp -f {} " + sf_pro_dir + "/ \\;");
    for font in nerd_fonts() {
        let dir = nerd_font_target_dir(font);
        let unpack = nerd_font_unpack_dir(BUILD_DIR, font);
        shell("find " + unpack + " -type f \\( -name '*.ttf' -o -name '*.otf' \\) -exec cp -f {} " + dir + "/ \\;");
    }

    if !has_matching_fonts(iosevka_dir, "*.ttc") { throw "Iosevka install produced no TTC files"; }
    if !has_matching_fonts(inter_dir, "*.ttf") && !has_matching_fonts(inter_dir, "*.otf") {
        throw "Inter install produced no font files";
    }
    if !has_matching_fonts(sf_pro_dir, "*.ttf") && !has_matching_fonts(sf_pro_dir, "*.otf") {
        throw "San Francisco Pro install produced no font files";
    }
    for font in nerd_fonts() {
        let dir = nerd_font_target_dir(font);
        if !has_matching_fonts(dir, "*.ttf") && !has_matching_fonts(dir, "*.otf") {
            throw "Nerd Font install produced no font files: " + font.slug;
        }
    }

    write_file(version_file(iosevka_dir), ctx.iosevka_version + "\n");
    write_file(version_file(inter_dir), ctx.inter_version + "\n");
    write_file(version_file(sf_pro_dir), ctx.sf_pro_commit + "\n");
    for font in nerd_fonts() {
        write_file(version_file(nerd_font_target_dir(font)), ctx.nerd_fonts_version + "\n");
    }
    shell("fc-cache -f " + fonts_root);

    ctx.fonts_root = fonts_root;
    ctx.iosevka_dir = iosevka_dir;
    ctx.inter_dir = inter_dir;
    ctx.sf_pro_dir = sf_pro_dir;
    ctx.install_note =
        "Installed Iosevka " + ctx.iosevka_version +
        ", Inter " + ctx.inter_version +
        ", and San Francisco Pro " + ctx.sf_pro_commit +
        ", plus selected Nerd Fonts " + ctx.nerd_fonts_version +
        " into " + fonts_root + ".";
    ctx
}

fn cleanup(ctx, reason) {
    ctx
}
