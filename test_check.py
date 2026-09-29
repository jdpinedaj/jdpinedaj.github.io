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
writing an adapter; a full offline regression suite driven by a scripted mock LLM (no API spend).
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

    def test_truncated_sentence_fails(self):
        html = CARD.replace(
            "A review that took a reviewer a full working day now takes about ten minutes.",
            "A review that took a reviewer a full working day.",
        )
        missing = check.missing_sentences(html, SOURCES)
        self.assertEqual(len(missing), 1)
        self.assertTrue(missing[0].startswith("a review that took"))

    def test_fragment_after_label_colon_passes(self):
        html = '<dl class="card-text"><dd>Four domain architect agents (Business, Technology, Information, Data Science &amp; AI) run on a shared quality-agent engine orchestrated through LangGraph state machines, and only the domains the deck flags as architecturally impacted actually run.</dd></dl>'
        src = "Multi-Agent Architecture: Four domain architect agents (Business, Technology, Information, Data Science & AI) run on a shared quality-agent engine orchestrated through LangGraph state machines, and only the domains the deck flags as architecturally impacted actually run. More text."
        self.assertEqual(check.missing_sentences(html, src), [])

    def test_dd_and_dl_with_extra_attributes_are_still_checked(self):
        html = '<dl class="card-text" id="x"><dd class="y">Not a real claim.</dd></dl>'
        self.assertEqual(check.card_sentences(html), ["not a real claim"])
        self.assertEqual(check.card_blocks(html), 1)

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

    def test_external_links_ignore_link_tags(self):
        html = '<link rel="preconnect" href="https://fonts.gstatic.com"><a href="https://example.com/b">b</a>'
        self.assertEqual(check.external_links(html), ["https://example.com/b"])

    def test_head_falls_back_to_get(self):
        calls = []

        def opener(req, timeout):
            calls.append(req.get_method())
            if req.get_method() == "HEAD":
                raise urllib.error.HTTPError(req.full_url, 405, "nope", {}, None)
            return mock.Mock(status=200)

        self.assertTrue(check.url_ok("https://example.com", opener=opener))
        self.assertEqual(calls, ["HEAD", "GET"])

    def test_bot_block_999_counts_as_reachable(self):
        def opener(req, timeout):
            raise urllib.error.HTTPError(req.full_url, 999, "request denied", {}, None)

        self.assertTrue(check.url_ok("https://www.linkedin.com/in/x/", opener=opener))

    def test_url_not_ok_on_404(self):
        def opener(req, timeout):
            raise urllib.error.HTTPError(req.full_url, 404, "gone", {}, None)

        self.assertFalse(check.url_ok("https://example.com/x", opener=opener))


class PreviewImage(unittest.TestCase):
    def test_og_image_local_path(self):
        html = '<meta property="og:image" content="https://jdpinedaj.github.io/og-image.png">'
        self.assertEqual(check.og_image_path(html), "og-image.png")

    def test_og_image_rejects_svg(self):
        html = '<meta property="og:image" content="https://jdpinedaj.github.io/og-image.svg">'
        self.assertIsNone(check.og_image_path(html))


class EmDash(unittest.TestCase):
    def test_detects_em_dash(self):
        self.assertTrue(check.has_em_dash("a " + chr(0x2014) + " b"))
        self.assertFalse(check.has_em_dash("a - b"))


class MainChecks(unittest.TestCase):
    """main() against the real files; the repository walk is stubbed to keep it fast."""

    def run_main(self, argv):
        with mock.patch.object(check, "tracked_text_files", return_value=[]):
            with mock.patch.object(check, "url_ok", return_value=True) as url_ok:
                with mock.patch("builtins.print"):
                    check.main(argv)
        return url_ok

    def test_offline_skips_the_link_check(self):
        url_ok = self.run_main(["--offline"])

        url_ok.assert_not_called()

    def test_online_checks_every_external_link(self):
        url_ok = self.run_main([])

        html = check.INDEX.read_text(encoding="utf-8")
        self.assertEqual(url_ok.call_count, len(check.external_links(html)))


if __name__ == "__main__":
    unittest.main()
