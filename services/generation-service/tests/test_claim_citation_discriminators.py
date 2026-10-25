"""Bibliographic exclusion must not erase ordinary parenthetical facts."""
import pytest

from app.reading_evaluation import claim_discriminators


@pytest.mark.parametrize("text,wanted", [
    ("Production began (Nsukka in 2002).", {"entity:nsukka", "number:2002"}),
    ("Production began (in Nigeria around 1992).", {"entity:nigeria", "number:1992", "qualifier:around"}),
    ("The site (Jos Plateau, dated to 2002) produced iron.", {"entity:jos plateau", "number:2002"}),
    ("The study (conducted in Senegal in 2020) measured 12 sites.", {"entity:senegal", "number:2020", "number:12"}),
])
def test_factual_parenthesis_retains_provenance_discriminators(text, wanted):
    assert wanted <= claim_discriminators(text)


@pytest.mark.parametrize("citation", [
    "(Okafor, 2002 ; Okafor & Phillips, 1992 )",
    "(Junius, 2023 )",
    "(Robion-Brunner, 2018; Holl, 2009)",
    "(Okafor et al., 2002)",
])
def test_author_year_groups_do_not_compete_as_factual_dates(citation):
    markers = claim_discriminators("Evidence remains limited " + citation + ".")
    assert markers == {"qualifier:limited"}
