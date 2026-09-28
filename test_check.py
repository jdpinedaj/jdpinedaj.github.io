import unittest
from unittest import mock
import urllib.error

import check


CARD = """
<article class="card">
<dl class="card-text">
<dt>Problem</dt>
<dd>ARIA automates J&amp;J's Architecture Review Board.</dd>
<dt>Architecture</dt>
<dd>Four domain architect agents (Business, Technology, Information,
Data Science &amp; AI) run on a shared <span class="term" data-term="engine">quality-agent engine</span> orchestrated through LangGraph state machines, and only the domains the deck flags as architecturally impacted actually run. A review that took a reviewer a full working day now takes about ten minutes.</dd>
<dd>A full offline regression suite driven by a scripted mock LLM (no API spend).</dd>
</dl>
</article>
"""

SOURCES = """
ARIA automates J&J's Architecture Review Board. Four domain architect agents (Business, Technology, Information, Data Science & AI) run on a shared quality-agent engine orchestrated through LangGraph state machines, and only the domains the deck flags as architecturally impacted actually run. A review that took a reviewer a full working day now takes about ten minutes.
plus a full offline regression suite driven by a scripted mock LLM (no API spend).
"""


class SentenceChecks(unittest.TestCase):
    def test_card_sentences_strip_tags_and_split(self):
        sentences = check.card_sentences(CARD)
        self.assertEqual(len(sentences), 4)
        self.assertTrue(sentences[0].startswith("aria automates"))
        self.assertNotIn("<", "".join(sentences))

    def test_entities_unescaped(self):
        self.assertIn("j&j's", check.card_sentences(CARD)[0])

    def test_split_keeps_parenthesised_sentence(self):
        self.assertEqual(
            check.card_sentences(CARD)[-1],
            "a full offline regression suite driven by a scripted mock llm (no api spend)",
        )

    def test_all_sentences_found(self):
        self.assertEqual(check.missing_sentences(CARD, SOURCES), [])

    def test_sentence_not_in_sources_fails(self):
        html = CARD.replace("about ten minutes", "about five minutes")
        missing = check.missing_sentences(html, SOURCES)
        self.assertEqual(len(missing), 1)
        self.assertIn("five minutes", missing[0])


class LinkChecks(unittest.TestCase):
    HTML = """
    <a href="#systems">S</a><a href="#missing">M</a>
    <section id="systems"></section>
    <a href="https://example.com/a">a</a>
    <a href="mailto:x@y.z">m</a>
    <a href="JuanPineda_CV_AI_LLM.pdf">cv</a>
    """

    def test_anchor_targets_reports_missing(self):
        self.assertEqual(check.missing_anchors(self.HTML), ["#missing"])

    def test_external_links_only_http(self):
        self.assertEqual(check.external_links(self.HTML), ["https://example.com/a"])

    def test_head_falls_back_to_get(self):
        calls = []

        def opener(req, timeout):
            calls.append(req.get_method())
            if req.get_method() == "HEAD":
                raise urllib.error.HTTPError(req.full_url, 405, "nope", {}, None)
            return mock.Mock(status=200)

        self.assertTrue(check.url_ok("https://example.com", opener=opener))
        self.assertEqual(calls, ["HEAD", "GET"])

    def test_url_not_ok_on_404(self):
        def opener(req, timeout):
            raise urllib.error.HTTPError(req.full_url, 404, "gone", {}, None)

        self.assertFalse(check.url_ok("https://example.com/x", opener=opener))


class EmDash(unittest.TestCase):
    def test_detects_em_dash(self):
        self.assertTrue(check.has_em_dash("a " + chr(0x2014) + " b"))
        self.assertFalse(check.has_em_dash("a - b"))


if __name__ == "__main__":
    unittest.main()
