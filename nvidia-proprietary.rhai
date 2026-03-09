let ctx = #{
    name: "nvidia-proprietary-driver",
    repo_id: "cuda-rhel10-x86_64",
    repo_url: "https://developer.download.nvidia.com/compute/cuda/repos/rhel10/x86_64/cuda-rhel10.repo",
    packages: "nvidia-driver kmod-nvidia-latest-dkms nvidia-driver-cuda nvidia-settings nvidia-modprobe dkms gcc make kernel-devel-6.12.0-124.40.1.el10_1.x86_64 kernel-headers",
    reboot_required: false,
    install_note: "",
};

fn has_pkg(name) {
    shell_status("rpm -q " + name + " >/dev/null 2>&1") == 0
}

fn kernel_devel_pkg() {
    "kernel-devel-" + trim(shell_output("uname -r"))
}

fn is_installed(ctx) {
    if !has_pkg("nvidia-driver") { throw "nvidia-driver missing"; }
    if !has_pkg("kmod-nvidia-latest-dkms") { throw "nvidia dkms package missing"; }
    if !has_pkg("nvidia-driver-cuda") { throw "nvidia userspace tools missing"; }
    if !has_pkg(kernel_devel_pkg()) { throw "matching kernel-devel missing"; }
    if shell_status("test -f /usr/lib/modprobe.d/nvidia.conf") != 0 { throw "nvidia modprobe config missing"; }
    ctx.install_note = "Installed. Reboot if the nvidia kernel modules are not active yet.";
    ctx
}

fn is_acquired(ctx) {
    ctx
}

fn acquire(ctx) {
    ctx
}

fn install(ctx) {
    shell("sudo dnf -y install dnf-plugins-core");
    shell("sudo dnf config-manager --add-repo " + ctx.repo_url);

    let install_cmd =
        "sudo dnf -y install " +
        "dkms gcc make " +
        kernel_devel_pkg() + " " +
        "kernel-headers " +
        "nvidia-driver " +
        "kmod-nvidia-latest-dkms " +
        "nvidia-driver-cuda " +
        "nvidia-settings " +
        "nvidia-modprobe";
    shell(install_cmd);

    ctx.packages =
        "nvidia-driver kmod-nvidia-latest-dkms nvidia-driver-cuda nvidia-settings nvidia-modprobe dkms gcc make " +
        kernel_devel_pkg() + " kernel-headers";
    ctx.reboot_required = true;
    ctx.install_note = "Install complete. Reboot, then verify with: nvidia-smi";
    ctx
}

fn cleanup(ctx, reason) {
    ctx
}
