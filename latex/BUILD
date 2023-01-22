load(":latex.bzl", "latex_toolchain")

exports_files([
  "detex.sed",
  "git_stamp.tpl",
  "latex.py",
  "pull.sh",
  "ref_test.py",
  "role_call.py",
  "spelling.tex",
])

toolchain_type(name = "toolchain_type")

latex_toolchain(
    name = "linux_local_texlive_toolchain",
    pdflatex = "/usr/bin/pdflatex",
    detex = "/usr/bin/detex",
)

toolchain(
    name = "linux_texlive",
    # Blindly asssume this is avalable if registered.
    # exec_compatible_with = ["@platforms//os:linux"], # TODO Would this be more correct?
    target_compatible_with = [], # Output is OS/CPU agnostic
    toolchain = ":linux_local_texlive_toolchain",
    toolchain_type = ":toolchain_type",
)
