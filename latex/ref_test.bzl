def latex_ref_test(name = "ref_test", jobname = None, ignore_dups = False):
    if not jobname: fail("jobname is requred")

    args = []
    if ignore_dups: args += ["--ignore_dups"]


    native.py_test(
        name = name,
        srcs = ["@bazel_rules//latex:ref_test.py"],
        main = "@bazel_rules//latex:ref_test.py",
        args = args + ["$(location :%s.log)" % jobname],
        data = [
            ":%s.aux" % jobname,
            ":%s.log" % jobname,
        ],
    )
