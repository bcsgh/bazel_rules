def role_call_test(name="role_call_test", root=None, inputs=None, extra=[]):
    if not root: fail("root is requred")
    if type(inputs) != type([]): fail("inputs must be a list, found %s" % type(inputs))
    if type(extra) != type([]): fail("extra must be a list, found %s" % type(extra))

    native.sh_test(
      name = name,
      srcs = ["@bazel_rules//latex:role_call.sh"],
      args = [
          "$(location :%s)" % root,
      ] + [
          "$(locations %s)" % f
          for f in inputs
      ],
      data = [root] + extra + inputs,
    )
