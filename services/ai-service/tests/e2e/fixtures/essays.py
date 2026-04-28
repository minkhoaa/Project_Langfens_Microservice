"""Deterministic essay fixtures for E2E tests.

Three essays at different band targets. Each is hand-picked to exercise
the comparative pipeline at meaningful quality differences. Topics are
real IELTS Writing Task 2 prompts.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Literal


@dataclass(frozen=True)
class EssayFixture:
    id: str
    target_band: float
    student_band: float  # what the student claims / what grading would assign
    task_type: Literal["TASK_1", "TASK_2"]
    topic: str
    text: str


WC_A_BAND9 = EssayFixture(
    id="WC-A",
    target_band=9.0,
    student_band=8.5,
    task_type="TASK_2",
    topic=(
        "Some people think that universities should provide graduates with the knowledge "
        "and skills needed in the workplace. Others think that the true function of a "
        "university should be to give access to knowledge for its own sake, regardless "
        "of whether the course is useful to an employer. Discuss both views and give "
        "your own opinion."
    ),
    text=(
        "The role of higher education has long been debated, with some advocating that "
        "universities ought to function as vocational pipelines, while others insist on "
        "preserving the academy as a sanctuary for disinterested inquiry. In my view, "
        "though both perspectives carry weight, an exclusively employer-oriented "
        "curriculum would impoverish intellectual life and, paradoxically, undermine "
        "the very versatility that modern labour markets demand.\n\n"
        "Proponents of workplace-aligned degrees rightly note that tuition is a "
        "considerable financial commitment; graduates burdened by debt naturally expect "
        "their qualifications to translate into gainful employment. Programmes such as "
        "engineering, nursing, and computer science illustrate how rigorously vocational "
        "training can produce immediately deployable practitioners, thereby benefiting "
        "individuals, employers, and the broader economy.\n\n"
        "Nevertheless, conceiving of universities solely as job factories overlooks "
        "their historic mandate: to cultivate critical reasoning, ethical judgement, "
        "and cultural literacy. Disciplines like philosophy, history, and pure "
        "mathematics seldom map onto specific occupations, yet they sharpen the very "
        "cognitive faculties that adaptive professionals rely upon when industries are "
        "disrupted. Indeed, surveys of senior executives consistently rank "
        "communication, analytical thinking, and creativity above narrow technical "
        "skills.\n\n"
        "A balanced model is therefore preferable. Curricula should integrate "
        "transferable competencies—data literacy, persuasive writing, collaborative "
        "problem-solving—into traditionally academic subjects, while vocational "
        "programmes ought to retain a substantive theoretical core. In this way, "
        "graduates emerge equipped not merely for their first job but for the several "
        "careers they are statistically likely to pursue.\n\n"
        "In conclusion, while immediate employability is a legitimate concern, "
        "universities must guard against narrowing themselves into mere training "
        "providers. The pursuit of knowledge and the demands of the workplace are "
        "best treated as complementary, not competing, ambitions."
    ),
)


WC_B_BAND6 = EssayFixture(
    id="WC-B",
    target_band=6.0,
    student_band=6.0,
    task_type="TASK_2",
    topic=(
        "In many countries, the proportion of older people is steadily increasing. "
        "Does this trend have positive or negative effects on society?"
    ),
    text=(
        "Nowadays in many countries the number of old people is going up every year. "
        "Some peoples think this is good but others think it brings many problems. In "
        "my opinion, this trend has both positive and negative effects but the negative "
        "effects are more.\n\n"
        "Firstly, when there are more old people in the society, the goverment must to "
        "spend more money on healthcare and pensions. This means less money for other "
        "things like education and roads. Also, the workers are less because old people "
        "they cannot work anymore, so the economy is grow slower than before.\n\n"
        "On the other hand, old people have a lot of experience and they can teach "
        "young generation many things. For example my grandfather, he tells me about "
        "history of our country and i learn many lessons from him. Also old people can "
        "help to take care of grandchildren when parents are working, this is very "
        "useful for family.\n\n"
        "However, the negative things are still more serious. Many old people they "
        "live alone and feel lonely, this make them have depression. The hospitals are "
        "always full because of old patient. The young people they must to pay more "
        "tax to support old people and this is unfair for them.\n\n"
        "In conclusion, although elderly people give some benefits to society, the "
        "increase of older population create more problems than benefits. The goverment "
        "should make policy to solve this issue as soon as possible."
    ),
)


WC_C_BAND4 = EssayFixture(
    id="WC-C",
    target_band=4.5,
    student_band=4.5,
    task_type="TASK_2",
    topic=(
        "Some people believe that children should be allowed to use mobile phones at "
        "school. Do you agree or disagree?"
    ),
    text=(
        "I think children should not be allow to use mobile phone in school. There are "
        "many reason for this opinion.\n\n"
        "First, mobile phone is make student not focus in the class. When teacher "
        "teaching, student look at phone, play game, watching video, then they don't "
        "understand the lesson. After, they cannot do the homework and the score is "
        "low.\n\n"
        "Second, phone make problem between student. Some student have expensive phone "
        "and other student feel jealous. Sometime they fighting because of phone. Also "
        "some student use phone for cheating in exam, this is very bad behavior.\n\n"
        "But sometime phone is useful, for example student can search information when "
        "they don't know answer, or call parent when emergency happen. So I think "
        "school should make rule, student can bring phone but must turn off in class "
        "and only use in break time.\n\n"
        "In conclusion mobile phone in school have more bad than good and school must "
        "controll it carefully."
    ),
)


ALL_ESSAYS = [WC_A_BAND9, WC_B_BAND6, WC_C_BAND4]
