load("//Config:configs.bzl", "binary_configs", "library_configs", "pod_library_configs")

def merge_dicts(first, second):
    all_keys = first.keys() + second.keys()

    return {key: second.get(key, first.get(key)) for key in all_keys}

def apple_pod_lib(
        name,
        swift_version = "4.2",
        modular = True,
        compiler_flags = None,
        swift_compiler_flags = None,
        warning_as_error = False,
        **kwargs):
    compiler_flags = compiler_flags or []
    swift_compiler_flags = swift_compiler_flags or []

    # Don't treat warnings as errors for Beta Xcode versions
    if native.read_config("xcode", "beta") == "True":
        warning_as_error = False

    if warning_as_error:
        compiler_flags.append("-Werror")
        swift_compiler_flags.append("-warnings-as-errors")
    else:
        compiler_flags.append("-w")
        swift_compiler_flags.append("-suppress-warnings")

    configs = library_configs()
    if 'configs' in kwargs:
        configs = merge_dicts(configs, kwargs['configs'])
        kwargs.pop('configs', None)

    native.apple_library(
        name = name,
        swift_version = swift_version,
        configs = configs,
        modular = modular,
        compiler_flags = compiler_flags,
        swift_compiler_flags = swift_compiler_flags,
        **kwargs
    )

def files_mapping(file_descriptions, dir_mappings=[]):
    """
    Returns a mapping of header name -> header location

    dir_mappings is a list of tupples where the first element is a path prefix
    and the second element is what is should be replaced with
    """
    res = {}
    for f in native.glob(file_descriptions):
        found = False
        for k, v in dir_mappings:
            if k in f:
                res[f.replace(k, v)] = f
                found = True
                break
        if not found:
            res[f] = f

    return res
