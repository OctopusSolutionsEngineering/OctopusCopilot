from domain.exceptions.octopus_version_invalid import OctopusVersionInvalid
from domain.validation.argument_validation import ensure_string_not_empty
from domain.validation.int_validation import is_int


def octopus_version_at_least(version, compare_to):
    """
    Compares two octopus versions. Returns True if the first version is later than or equal to
    the second version.
    """
    ensure_string_not_empty(version, 'version must be the version to compare (octopus_version_later_or_equal).')
    ensure_string_not_empty(compare_to,
                            'compare_to must be the version to compare to (octopus_version_later_or_equal).')

    split_version = list(map(lambda x: x.strip(), version.split(".")))
    split_compare_to = list(map(lambda x: x.strip(), compare_to.split(".")))

    if len(split_version) != 3 or not all(map(lambda x: is_int(x), split_version)):
        raise OctopusVersionInvalid(version)

    if len(split_compare_to) != 3 or not all(map(lambda x: is_int(x), split_compare_to)):
        raise OctopusVersionInvalid(compare_to)

    for i in range(3):
        if int(split_version[i]) > int(split_compare_to[i]):
            return True

        if int(split_version[i]) < int(split_compare_to[i]):
            return False

    return True
