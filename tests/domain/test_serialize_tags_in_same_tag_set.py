import unittest

from domain.sanitizers.terraform import serialize_tags_in_same_tag_set

TIER = '"${length(data.octopusdeploy_tag_sets.tagset_tier.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_tier.tag_sets[0].id : octopusdeploy_tag_set.tagset_tier[0].id}"'
REGION = '"${octopusdeploy_tag_set.tagset_region[0].id}"'


def tag(label, name, tag_set, extra=""):
    return (
        f'resource "octopusdeploy_tag" "{label}" {{\n'
        f'  name       = "{name}"\n'
        f"  tag_set_id = {tag_set}\n"
        '  color      = "#333333"\n'
        f"{extra}"
        "}\n"
    )


class TestSerializeTagsInSameTagSet(unittest.TestCase):
    def test_observed_two_tags_in_one_set_are_serialized(self):
        config = tag("tagset_tier_tag_gold", "Gold", TIER) + tag("tagset_tier_tag_platinum", "Platinum", TIER)
        result = serialize_tags_in_same_tag_set(config)
        platinum = result[result.index('"tagset_tier_tag_platinum"'):]
        self.assertIn("depends_on = [octopusdeploy_tag.tagset_tier_tag_gold]", platinum)
        gold = result[: result.index('"tagset_tier_tag_platinum"')]
        self.assertNotIn("depends_on", gold)

    def test_three_tags_form_a_chain(self):
        config = tag("t_a", "A", TIER) + tag("t_b", "B", TIER) + tag("t_c", "C", TIER)
        result = serialize_tags_in_same_tag_set(config)
        self.assertIn("depends_on = [octopusdeploy_tag.t_a]", result)
        self.assertIn("depends_on = [octopusdeploy_tag.t_b]", result)
        self.assertNotIn("depends_on = [octopusdeploy_tag.t_c]", result)

    def test_tags_in_different_sets_are_unchanged(self):
        config = tag("t_gold", "Gold", TIER) + tag("t_eu", "EU", REGION)
        self.assertEqual(config, serialize_tags_in_same_tag_set(config))

    def test_existing_depends_on_is_extended(self):
        config = tag("t_a", "A", TIER) + tag(
            "t_b", "B", TIER, "  depends_on = [octopusdeploy_tag_set.tagset_tier]\n"
        )
        result = serialize_tags_in_same_tag_set(config)
        self.assertIn("depends_on = [octopusdeploy_tag.t_a, octopusdeploy_tag_set.tagset_tier]", result)
        self.assertEqual(1, result.count("depends_on"))

    def test_empty_depends_on_is_filled(self):
        config = tag("t_a", "A", TIER) + tag("t_b", "B", TIER, "  depends_on = []\n")
        self.assertIn("depends_on = [octopusdeploy_tag.t_a]", serialize_tags_in_same_tag_set(config))

    def test_already_serialized_is_unchanged(self):
        config = tag("t_a", "A", TIER) + tag("t_b", "B", TIER, "  depends_on = [octopusdeploy_tag.t_a]\n")
        self.assertEqual(config, serialize_tags_in_same_tag_set(config))

    def test_empty(self):
        self.assertEqual("", serialize_tags_in_same_tag_set(""))
        self.assertIsNone(serialize_tags_in_same_tag_set(None))


if __name__ == "__main__":
    unittest.main()
