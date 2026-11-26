//! Embeds the Windows resources of the executable: its icon, its description and a manifest
//! requiring administrator rights.

fn main() {
    // The executable always runs as administrator
    println!("cargo:rustc-link-arg-bins=/MANIFEST:EMBED");
    println!("cargo:rustc-link-arg-bins=/MANIFESTUAC:level='requireAdministrator'");
    // The playbook folder is embedded: a file added to it must trigger a rebuild
    println!("cargo:rerun-if-changed=playbook");
    println!("cargo:rerun-if-changed=assets/gem.ico");
    println!("cargo:rerun-if-changed=build.rs");

    winresource::WindowsResource::new()
        .set_icon("assets/gem.ico")
        .set("ProductName", "GleamingOS")
        .set("FileDescription", "GleamingOS")
        .compile()
        .expect("the Windows resources must compile");
}
