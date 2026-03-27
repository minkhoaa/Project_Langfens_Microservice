# Golden Dataset for AI Grading Evaluation
#
# Curated essays with known band scores for evaluating AI grading quality.
# Each essay has been assessed by expert IELTS examiners.
# Ground truth band breakdowns are provided for comparison.

from dataclasses import dataclass, field
from typing import Optional


@dataclass
class BandBreakdown:
    """Band score breakdown for a single criterion."""
    vocabulary: float  # Lexical resource
    coherence: float   # Coherence and cohesion
    grammar: float    # Grammatical range and accuracy
    task_response: float  # Task achievement


@dataclass
class GoldenEssay:
    """A golden standard essay with verified band scores."""
    essay_id: str
    topic: str
    question_type: str  # "discussion" | "opinion" | "problem_solution" | "advantage_disadvantage"
    essay_text: str
    overall_band: float
    breakdown: BandBreakdown
    strengths: list[str] = field(default_factory=list)
    weaknesses: list[str] = field(default_factory=list)
    notes: Optional[str] = None


# =============================================================================
# BAND 6 ESSAYS (5 essays)
# =============================================================================

BAND_6_ESSAYS = [
    GoldenEssay(
        essay_id="band6_education_01",
        topic="Education: Some people believe that university students should study whatever they like. Others think that they should only be allowed to study subjects that will be useful in the future, such as those related to science and technology. Discuss both views and give your own opinion.",
        question_type="discussion",
        essay_text="""In today's world, there is a debate about what university students should study. Some people think that students should be free to choose any subject they want. Others believe that they should only study subjects that will be useful in the future like science and technology.

On the one hand, there are good reasons for students to study whatever they like. First, when students study subjects they enjoy, they usually work harder and get better results. For example, a student who likes art will spend more time practicing and improve faster. Second, not all good jobs require science subjects. There are many successful people who studied history, literature or philosophy and now have good careers in areas like journalism, law or teaching.

On the other hand, those who support useful subjects have some valid points. The main reason is that science and technology are becoming more important in our modern world. Companies need people with skills in these areas to compete globally. Also, students who study useful subjects may have better job opportunities after graduation. Another point is that practical skills in fields like engineering or medicine can help solve real problems in society.

In my opinion, I believe students should have the freedom to choose their own path. While practical skills are important, happiness and interest in the subject also matter for success. Not everyone is suited for science, and asking students to study subjects they hate may lead to poor performance and stress.

To conclude, although useful subjects like science and technology have their benefits, I think students should be allowed to study whatever they find interesting and meaningful. This way, they can follow their passion while also contributing to society in their own way.""",
        overall_band=6.0,
        breakdown=BandBreakdown(
            vocabulary=6.0,
            coherence=6.0,
            grammar=6.0,
            task_response=6.0
        ),
        strengths=[
            "Clear structure with introduction, body paragraphs and conclusion",
            "Attempts to discuss both sides of the argument",
            "Uses some topic-related vocabulary"
        ],
        weaknesses=[
            "Vocabulary range is limited; repetition of words like 'important' and 'subjects'",
            "Paragraphs could be better organized with clearer topic sentences",
            "Some grammar errors but they do not cause misunderstanding",
            "Examples are somewhat superficial and lack detail"
        ],
        notes="Typical Band 6 essay - communicates adequately but lacks sophistication"
    ),
    GoldenEssay(
        essay_id="band6_technology_01",
        topic="Technology: Some people believe that the internet has brought people closer together. Others believe that the internet has made people more isolated. Discuss both views and give your own opinion.",
        question_type="discussion",
        essay_text="""The internet is now a big part of our daily lives. Some people think it has brought us together, while others feel it has made us more isolated. This essay will discuss both opinions.

Those who believe the internet connects people have several arguments. First, social media platforms like Facebook and Twitter allow us to stay in touch with friends and family around the world. Before the internet, it was very difficult and expensive to communicate with people far away. Now we can video call our relatives in other countries for free. Second, the internet helps people find others who share the same interests. Online communities and forums bring together people with similar hobbies from different places.

However, other people think the internet has made us more isolated. One reason is that people spend too much time looking at screens instead of talking to others face to face. Many young people prefer to text message instead of meeting their friends in person. Another problem is that online relationships are not as deep as real ones. While you may have hundreds of online friends, you might not have anyone you can truly count on when you have problems. Also, the internet can be addictive, and some people spend so much time online that they neglect their work, studies and real-life relationships.

In my view, the internet is neither completely good nor bad for human connections. It depends on how we use it. If we use it to enhance our real relationships and not replace them, then it can bring people together. But if we use it as an excuse to avoid real human contact, then it will make us more isolated.

To conclude, while the internet has made communication easier and faster, I believe it has also created new problems of isolation. The key is to find a balance between online and offline interactions.""",
        overall_band=6.0,
        breakdown=BandBreakdown(
            vocabulary=6.0,
            coherence=5.5,
            grammar=6.0,
            task_response=6.0
        ),
        strengths=[
            "Presents both views clearly",
            "Some good transition words used",
            "Essay addresses the question directly"
        ],
        weaknesses=[
            "Coherence could be improved - ideas within paragraphs are not always well-connected",
            "Vocabulary is adequate but not varied enough",
            "Some sentences are too long and confusing",
            "Second body paragraph arguments are stronger than the first"
        ],
        notes="Shows understanding of the topic but lacks precision in language"
    ),
    GoldenEssay(
        essay_id="band6_environment_01",
        topic="Environment: Many countries are experiencing major environmental problems. Some people think that individuals should be responsible for solving these problems. To what extent do you agree or disagree?",
        question_type="opinion",
        essay_text="""Environmental problems are becoming more serious in many countries around the world. Some people think that individuals should take responsibility for solving these problems. I partly agree with this view, but I also believe that governments and big companies have important roles to play.

On the one hand, individual actions can make a difference. When each person tries to reduce pollution and waste, the combined effect can be significant. For example, if everyone in a city used public transportation instead of driving cars, air quality would improve a lot. People can also help by recycling, using less plastic, and saving energy at home. Furthermore, when individuals demand change, it can influence government policies and business practices.

On the other hand, some environmental problems are too big for individuals to solve. Large factories and power plants are major sources of pollution, and it is the government that can regulate their activities. Also, solving issues like climate change requires coordinated international action and significant financial investments that only governments can provide. Individual people do not have the power to change the policies of big corporations or to enforce environmental laws.

In addition, I believe that environmental responsibility should be shared. Governments should create laws and provide resources to protect the environment. Businesses should be required to follow environmental standards and develop cleaner technologies. At the same time, ordinary people should also do their part by living more sustainably.

To conclude, while individuals have a role to play in solving environmental problems, I think that governments and large organizations bear the main responsibility. Without proper regulation and investment, individual efforts alone will not be enough to address the scale of the environmental challenges we face.""",
        overall_band=6.0,
        breakdown=BandBreakdown(
            vocabulary=6.0,
            coherence=6.0,
            grammar=6.5,
            task_response=6.0
        ),
        strengths=[
            "Clear opinion expressed in the introduction",
            "Logical organization of arguments",
            "Good use of cohesive devices in some places"
        ],
        weaknesses=[
            "The word 'environment' is repeated many times",
            "Some arguments are not developed fully",
            "Could provide more specific examples",
            "Conclusion repeats ideas from the essay rather than synthesizing them"
        ],
        notes="Solid Band 6 performance with some Band 6.5 grammar control"
    ),
    GoldenEssay(
        essay_id="band6_work_01",
        topic="Work: In many countries, people are now able to work from home. Do you think this is a positive or negative development?",
        question_type="advantage_disadvantage",
        essay_text="""Working from home has become very common in recent years, especially after the COVID-19 pandemic. This essay will discuss whether this is a positive or negative development.

There are several advantages to working from home. The first benefit is that it saves time and money on commuting. People do not need to spend hours traveling to and from work every day, which gives them more time for other activities. Second, working from home can help people achieve a better work-life balance. Employees can arrange their work around family responsibilities, like picking up children from school. Third, it can reduce traffic and pollution because fewer people are driving to offices every day.

However, there are also some disadvantages to consider. One problem is that some people find it difficult to separate work from home life. When your office is in your home, it can be hard to switch off from work. Another disadvantage is that not all jobs can be done from home. Workers in manufacturing, healthcare, and many service industries still need to be physically present at their workplaces. This can create inequality between different types of workers. Additionally, some employees may feel isolated working alone at home and miss the social interaction that comes with a traditional office environment.

In my opinion, working from home can be beneficial for many people, but it is not suitable for everyone or every type of work. The ideal situation would be a flexible approach that allows people to work from home for part of the week and come to the office for meetings and collaboration when needed.

To conclude, while working from home has both benefits and drawbacks, I believe it is generally a positive development as long as proper support and guidelines are provided. The key is to find a balance that works for both employers and employees.""",
        overall_band=6.0,
        breakdown=BandBreakdown(
            vocabulary=6.0,
            coherence=6.0,
            grammar=6.0,
            task_response=6.0
        ),
        strengths=[
            "Consistent structure with clear advantages and disadvantages sections",
            "Attempts to give examples to support points",
            "Conclusion summarizes the main points"
        ],
        weaknesses=[
            "Language is quite basic and repetitive",
            "Examples are brief and could be more developed",
            "Some good vocabulary items but not consistently used",
            "The essay is somewhat mechanical in its approach"
        ],
        notes="Adequate response that addresses the question but lacks nuance"
    ),
    GoldenEssay(
        essay_id="band6_health_01",
        topic="Health: Some people think that governments should spend money on preventing health problems rather than treating people who are already ill. To what extent do you agree or disagree?",
        question_type="opinion",
        essay_text="""Health is very important for everyone. There is a question about whether governments should focus more on preventing health problems or on treating people who are already sick. I strongly agree that prevention is better than cure.

First, preventing health problems is usually more cost-effective than treatment. It is much cheaper to encourage people to exercise regularly and eat healthy food than to pay for expensive surgeries and medications later. For example, programs that help people stop smoking can prevent many cases of lung cancer and heart disease, saving the government millions in healthcare costs. Second, prevention can improve people's quality of life. If people stay healthy, they can enjoy their lives more and be more productive at work. They also do not have to suffer from painful treatments or long recovery periods.

However, I also understand that treatment is necessary for people who are already ill. Even with the best prevention strategies, some people will still get sick and need medical care. We cannot ignore the needs of those who are suffering. A good healthcare system should do both prevention and treatment.

In my opinion, the best approach is to emphasize prevention while still providing good treatment services. Governments should invest in public health campaigns that educate people about healthy lifestyles. They should also make sure that healthy food options are affordable and accessible to everyone. At the same time, hospitals and medical professionals should continue to provide high-quality treatment for those who need it.

To conclude, I believe that prevention should be the main focus of government health spending, but not at the expense of treatment services. A balanced approach that prioritizes both prevention and cure is the best way to ensure the health and wellbeing of all citizens.""",
        overall_band=6.0,
        breakdown=BandBreakdown(
            vocabulary=6.0,
            coherence=6.5,
            grammar=6.0,
            task_response=6.0
        ),
        strengths=[
            "Clear thesis statement in the introduction",
            "Good use of cohesive devices",
            "Ideas are reasonably well-developed"
        ],
        weaknesses=[
            "Vocabulary is repetitive - 'health problems' is used many times",
            "Some sentences are awkward or unclear",
            "Could use more sophisticated vocabulary choices",
            "Examples are somewhat generic"
        ],
        notes="Shows competent control of coherence and cohesion"
    ),
]


# =============================================================================
# BAND 7 ESSAYS (5 essays)
# =============================================================================

BAND_7_ESSAYS = [
    GoldenEssay(
        essay_id="band7_education_01",
        topic="Education: Universities should accept equal numbers of male and female students in all their courses. To what extent do you agree or disagree?",
        question_type="opinion",
        essay_text="""The question of gender balance in university admissions is a complex one. While equality between men and women is undoubtedly important, I disagree with the proposal to enforce equal numbers in all courses, as this would be both impractical and counterproductive.

The primary argument against strict gender quotas in university admissions is that it would undermine the principle of merit-based selection. Universities should admit the most qualified candidates based on their academic abilities and potential, regardless of gender. If students are admitted simply to achieve numerical balance rather than because of their suitability for the course, the quality of education may suffer. For example, less qualified students might struggle in courses that are not suited to their abilities, leading to poor academic performance and wasted resources.

Furthermore, enforcing gender balance in all courses fails to respect individual choice. Different academic subjects naturally attract different levels of interest from men and women, and this is not necessarily a problem to be solved. Courses in fields like engineering or computer science have historically been dominated by men, while education or nursing programs tend to have more female students. Rather than forcing artificial balance, we should focus on ensuring that everyone has equal opportunities to pursue their interests and develop their talents, whatever those may be.

However, I do believe that universities have a responsibility to encourage diversity and to remove any barriers that might prevent certain groups from accessing education. This means having fair admissions processes, providing support for underrepresented groups, and promoting subjects to a wider audience. The goal should be to create an environment where people of all genders can thrive, not to impose arbitrary numerical targets.

In conclusion, while the intention behind gender quotas may be admirable, I believe that enforcing equal numbers of male and female students in all university courses would be misguided. Quality of education and individual freedom should take precedence over artificial balance.""",
        overall_band=7.0,
        breakdown=BandBreakdown(
            vocabulary=7.0,
            coherence=7.0,
            grammar=7.0,
            task_response=7.0
        ),
        strengths=[
            "Clear position established and consistently maintained",
            "Well-developed arguments with relevant examples",
            "Good range of vocabulary including some less common words",
            "Effective use of cohesive devices throughout"
        ],
        weaknesses=[
            "Could explore the counterargument more thoroughly",
            "Some points could be supported with more specific evidence",
            "Conclusion is somewhat predictable"
        ],
        notes="Good Band 7 essay with clear arguments and appropriate vocabulary"
    ),
    GoldenEssay(
        essay_id="band7_technology_01",
        topic="Technology: In the future, nobody will choose to own a car. Instead, they will pay for a transportation service. To what extent do you agree or disagree with this statement?",
        question_type="opinion",
        essay_text="""The idea that car ownership will become obsolete and be replaced by transportation services is an interesting one. While I believe that shared transportation will become increasingly prevalent, I am not convinced that ownership will disappear entirely.

There are several compelling reasons to think that transportation services will become the dominant model. First, the economics strongly favor shared use. Private cars are incredibly inefficient, sitting idle for most of the day and consuming valuable urban space when parked. A transportation service, by contrast, can maximize the utilization of each vehicle, reducing costs for users and environmental impact. Second, autonomous vehicle technology is advancing rapidly, and once it matures, it will become economically viable to provide on-demand transportation at a fraction of the cost of ownership. Third, urban congestion and pollution concerns are prompting governments to discourage private car use and promote shared mobility solutions.

However, there are also strong arguments for why car ownership will persist. For many people, particularly in rural areas or developing countries, owning a car provides a level of independence and flexibility that shared services cannot match. Furthermore, cars have cultural significance in many societies, representing freedom, status, and personal identity. These emotional attachments are not easily overcome by purely rational economic arguments. Additionally, there will always be situations where immediate access to a vehicle is essential, such as medical emergencies or transporting goods.

In my assessment, the future is likely to involve a hybrid model where transportation services handle the majority of urban mobility needs, while car ownership continues for those who require it or prefer it. The relative proportions will shift over time as technology improves and attitudes change, but complete abandonment of car ownership seems unlikely in the foreseeable future.

To conclude, while transportation services will undoubtedly grow in importance and may eventually become the primary means of mobility for urban populations, I believe that car ownership will persist in some form, particularly for those with specific needs or preferences that shared services cannot adequately address.""",
        overall_band=7.0,
        breakdown=BandBreakdown(
            vocabulary=7.0,
            coherence=7.0,
            grammar=7.0,
            task_response=7.0
        ),
        strengths=[
            "Excellent structure with clear introduction, body and conclusion",
            "Thoughtful analysis of both sides of the argument",
            "Good use of hedging language appropriate to the speculative nature of the topic",
            "Relevant examples from different contexts"
        ],
        weaknesses=[
            "Some paragraphs are quite long and could be split",
            "A few vocabulary choices are slightly awkward",
            "The conclusion could be more decisive"
        ],
        notes="Confident handling of the topic with appropriate nuance"
    ),
    GoldenEssay(
        essay_id="band7_environment_01",
        topic="Environment: The increase in the production of consumer goods results in damage to the natural environment. What are the causes of this problem and what can be done to solve it?",
        question_type="problem_solution",
        essay_text="""The unprecedented growth in consumer goods production has indeed placed tremendous strain on our natural environment. This essay will examine the primary causes of this issue and propose viable solutions.

There are three main causes of environmental damage related to consumer goods production. The first is the massive consumption of raw materials. Manufacturing consumer products requires vast quantities of resources, including minerals, fossil fuels, and timber, many of which are extracted through environmentally destructive methods such as mining and deforestation. The second cause is pollution. factories that produce consumer goods release harmful emissions into the atmosphere and discharge toxic chemicals into waterways, causing air and water pollution that affects both human health and ecosystems. The third factor is waste generation. The short lifespan of many modern products, coupled with our throwaway culture, means that enormous amounts of waste are sent to landfills or end up in the oceans.

Addressing these problems requires action at multiple levels. At the governmental level, stricter environmental regulations should be implemented to hold manufacturers accountable for the ecological impact of their products. This could include requiring companies to use sustainable materials, adopt cleaner production methods, and take responsibility for recycling their products at the end of their useful life. At the corporate level, businesses should be encouraged to embrace the principles of the circular economy, designing products that are durable, repairable, and recyclable. Finally, at the individual level, consumers need to be educated about the environmental consequences of their purchasing decisions and encouraged to adopt more sustainable consumption patterns, such as buying less, choosing quality over quantity, and supporting companies with strong environmental credentials.

In conclusion, the environmental damage caused by consumer goods production is a serious issue that demands concerted effort from governments, businesses, and individuals alike. Only through collaborative action can we hope to reconcile our consumption patterns with the need to preserve the natural environment for future generations.""",
        overall_band=7.0,
        breakdown=BandBreakdown(
            vocabulary=7.0,
            coherence=7.0,
            grammar=7.0,
            task_response=7.0
        ),
        strengths=[
            "Excellent treatment of both causes and solutions",
            "Well-organized with clear paragraph development",
            "Appropriate use of topic-specific vocabulary",
            "Good balance between analysis and recommendations"
        ],
        weaknesses=[
            "Some sentences are overly long and complex",
            "Could include more concrete examples of specific solutions",
            "The conclusion is somewhat formulaic"
        ],
        notes="Strong Band 7 response that thoroughly addresses all parts of the question"
    ),
    GoldenEssay(
        essay_id="band7_work_01",
        topic="Work: Many people aim to achieve a balance between work and other aspects of their lives, but few people achieve it. What are the reasons for this? How can we overcome this problem?",
        question_type="problem_solution",
        essay_text="""Work-life balance has become an increasingly important concern in modern society, yet achieving it remains elusive for the majority of working people. This essay will explore the main reasons why so few people manage to balance work with other aspects of their lives and suggest measures to address this issue.

Several factors contribute to the difficulty of achieving work-life balance. First and foremost, the demands of the modern workplace have intensified significantly. Global competition and technological advances have created pressures to work longer hours and be constantly available, blurring the boundaries between professional and personal time. Second, economic insecurity plays a role. In an era of uncertainty, many employees feel compelled to prioritize their careers and demonstrate dedication to their employers, even at the expense of their personal lives. Third, the high cost of living in many cities forces people to work multiple jobs or take on overtime just to make ends meet, leaving little time or energy for other pursuits.

Overcoming these challenges requires coordinated effort from both employers and governments. Employers should be encouraged to adopt family-friendly policies, such as flexible working arrangements, parental leave, and childcare support. More importantly, there needs to be a cultural shift away from the expectation that employees should be available around the clock. Governments can incentivize this by offering tax breaks to companies that promote good work-life balance and by introducing regulations that protect employees' rights to disconnect outside working hours. Additionally, urban planning decisions that reduce commuting times and invest in public services can help free up time for people to pursue interests beyond their work.

In conclusion, while the difficulty of achieving work-life balance is real and widespread, it is not insurmountable. Through a combination of supportive policies, responsible business practices, and changes in societal attitudes, it should be possible to create a world where people can pursue fulfilling careers while still enjoying rich personal lives.""",
        overall_band=7.0,
        breakdown=BandBreakdown(
            vocabulary=7.0,
            coherence=7.5,
            grammar=7.0,
            task_response=7.0
        ),
        strengths=[
            "Excellent paragraph structure with clear topic sentences",
            "Thoughtful analysis of causes and practical solutions",
            "Good use of complex sentence structures",
            "Strong cohesion throughout the essay"
        ],
        weaknesses=[
            "Some points could benefit from more specific examples",
            "A few vocabulary choices are slightly overambitious",
            "The introduction could be more engaging"
        ],
        notes="Very well-organized response with strong coherence"
    ),
    GoldenEssay(
        essay_id="band7_society_01",
        topic="Society: In some countries, many more people are choosing to live alone nowadays than in the past. Do you think this is a positive or negative development?",
        question_type="advantage_disadvantage",
        essay_text="""The trend towards living alone has accelerated dramatically in recent decades, particularly in developed nations. While this phenomenon reflects important social changes, I believe it presents both advantages and disadvantages that must be carefully considered.

On the positive side, living alone can promote personal independence and self-reliance. Individuals who live alone must learn to manage all aspects of their daily lives, from finances to household chores, fostering important life skills and personal growth. This arrangement also offers greater freedom and privacy, allowing people to structure their lives according to their own preferences without the need to accommodate others. For those who value solitude, living alone can provide the peace and quiet necessary for concentration, creativity, or simply relaxation after a demanding day.

However, there are also significant drawbacks to consider. Living alone can lead to feelings of loneliness and isolation, particularly for elderly people who may lack regular social contact. This social isolation has been linked to various health problems, including depression, cognitive decline, and even premature mortality. Furthermore, the trend towards single-person households contributes to increased housing costs and environmental degradation, as resources are used less efficiently than in shared accommodations. There are also economic implications, as single people must bear all household expenses without the economies of scale that come from sharing.

In my assessment, while living alone can be beneficial for some individuals, particularly those who actively choose this lifestyle and maintain strong social connections, it is not inherently positive or negative. The key factors are the reasons for choosing to live alone and the extent to which individuals maintain meaningful relationships with others. A balanced approach would involve recognizing that living alone is not suitable for everyone and ensuring that those who do live alone have access to community support and social opportunities.

To conclude, the increase in single-person households reflects broader social trends and individual preferences, and its impact depends largely on how it is experienced and managed. Rather than viewing living alone as inherently good or bad, we should focus on creating societies where people can make informed choices about their living arrangements and receive adequate support regardless of their household composition.""",
        overall_band=7.0,
        breakdown=BandBreakdown(
            vocabulary=7.0,
            coherence=7.0,
            grammar=7.0,
            task_response=7.0
        ),
        strengths=[
            "Balanced analysis of advantages and disadvantages",
            "Excellent range of complex sentence structures",
            "Good use of hedging and qualification",
            "Thoughtful conclusion that goes beyond simple summary"
        ],
        weaknesses=[
            "Essay is quite long - some trimming would improve it",
            "Could include more contemporary examples",
            "Some paragraphs are denser than others"
        ],
        notes="Mature and nuanced response showing good critical thinking skills"
    ),
]


# =============================================================================
# BAND 8 ESSAYS (5 essays)
# =============================================================================

BAND_8_ESSAYS = [
    GoldenEssay(
        essay_id="band8_education_01",
        topic="Education: Some people say that the main environmental problem of our time is the loss of particular species of plants and animals. Others say that there are more important environmental problems. Discuss both these views and give your own opinion.",
        question_type="discussion",
        essay_text="""The accelerating rate of species extinction is undoubtedly one of the most pressing environmental challenges we face, yet it coexists with other environmental threats of comparable or greater urgency. This essay will examine both perspectives before offering a considered view.

Those who argue that biodiversity loss represents our paramount environmental concern make several compelling points. The extinction of species is irreversible in a way that many other forms of environmental damage are not; once a species is lost, it cannot be recovered. Furthermore, biodiversity underpins ecosystem services upon which human civilization depends: pollination, water purification, soil fertility, and climate regulation are all maintained by diverse biological communities. The interconnected nature of ecosystems means that the loss of keystone species can trigger cascading effects throughout entire food webs, with consequences that are difficult to predict but potentially catastrophic. In this sense, species loss can be seen as fundamentally threatening the planet's capacity to sustain life.

However, others maintain that different environmental problems warrant equal or greater attention. Climate change, for instance, represents an existential threat that transcends individual species and affects the planetary system as a whole. Rising temperatures, ocean acidification, and increasingly severe weather events threaten human societies and ecosystems across the globe. Similarly, air and water pollution cause millions of premature deaths annually, particularly in developing countries, representing an immediate humanitarian crisis. These advocates argue that while species extinction is tragic and significant, it may not always be visible or immediate in its impacts, whereas climate change and pollution cause tangible suffering in the present.

In my opinion, while biodiversity loss is undoubtedly a matter of profound concern, I believe that climate change currently represents the most urgent environmental challenge. This is not to diminish the importance of protecting species, but rather to recognize that climate change has the potential to accelerate biodiversity loss dramatically while simultaneously threatening human food security, water supplies, and political stability. Effective environmental policy must address multiple threats simultaneously, but if limited resources require prioritization, tackling climate change may yield the greatest overall benefit.

To conclude, although I recognize the critical importance of preserving biodiversity, I believe that climate change deserves pride of place among environmental priorities at this critical juncture.""",
        overall_band=8.0,
        breakdown=BandBreakdown(
            vocabulary=8.0,
            coherence=8.0,
            grammar=8.0,
            task_response=8.0
        ),
        strengths=[
            "Excellent command of complex vocabulary used accurately and appropriately",
            "Superb paragraph development with each point thoroughly explored",
            "Sophisticated use of cohesive devices",
            "Nuanced argumentation that acknowledges the strength of opposing views"
        ],
        weaknesses=[
            "Could include more concrete examples of specific species or ecosystems",
            "Some readers might find the conclusion somewhat hedged"
        ],
        notes="Excellent Band 8 response with sophisticated vocabulary and argument development"
    ),
    GoldenEssay(
        essay_id="band8_technology_01",
        topic="Technology: It is important to limit the amount of money that is spent on international sporting events. Instead, that money should be spent on more essential things like education and healthcare. To what extent do you agree or disagree?",
        question_type="opinion",
        essay_text="""The question of how public resources should be allocated between major sporting events and fundamental social services is a matter of legitimate debate. While I agree that essential services like education and healthcare warrant generous funding, I disagree with the premise that spending on international sporting events should be significantly curtailed.

The argument for redirecting sporting expenditure towards education and healthcare rests on the undoubted importance of these services. Access to quality education and healthcare are fundamental determinants of individual wellbeing and societal progress. Governments have a primary obligation to ensure that these basic needs are met before expenditure on discretionary pursuits. In many countries, indeed, educational and healthcare infrastructure remains inadequate, and additional investment could yield substantial improvements in human welfare.

However, the assumption that sporting expenditure necessarily comes at the expense of essential services is flawed. First, much of the spending on major sporting events generates economic returns through tourism, job creation, and infrastructure development that benefit the broader economy. The 2012 London Olympics, for example, left a lasting legacy of improved transport links and sporting facilities. Second, international sporting events can generate significant intangible benefits, including national pride, social cohesion, and the promotion of healthy lifestyles. Third, the notion that we must choose between sporting excellence and social welfare is a false dichotomy; well-governed societies can pursue multiple objectives simultaneously.

Furthermore, there is an argument that sporting investment may indirectly benefit education and healthcare. Sporting events can inspire young people to pursue physical activity and potentially careers in sports science or medicine. International competitions also foster diplomatic relationships and soft power that may yield long-term political and economic benefits.

In conclusion, while I acknowledge the importance of ensuring adequate funding for education and healthcare, I do not believe that limiting expenditure on international sporting events is either necessary or desirable. A more sophisticated approach would involve ensuring that such events are organized efficiently, deliver genuine value for money, and complement rather than compete with investment in essential social services.""",
        overall_band=8.0,
        breakdown=BandBreakdown(
            vocabulary=8.0,
            coherence=8.0,
            grammar=8.0,
            task_response=8.0
        ),
        strengths=[
            "Excellent counter-argument structure",
            "Strong thesis that is defended consistently",
            "Good use of evidence and examples",
            "Complex sentence structures used effectively"
        ],
        weaknesses=[
            "The essay could be more decisive in its final paragraph",
            "More recent examples would strengthen the argument"
        ],
        notes="Very strong response with mature argumentation"
    ),
    GoldenEssay(
        essay_id="band8_cities_01",
        topic="Cities: Some people think that new buildings should be built in a traditional style to suit their surroundings. Others think that modern buildings are acceptable. Discuss both views and give your own opinion.",
        question_type="discussion",
        essay_text="""The tension between architectural tradition and modernist innovation has long exercised urban planners and communities alike. While traditional architecture can preserve cultural heritage and aesthetic harmony, there are also compelling arguments for contemporary design. This essay will examine both perspectives.

Those who advocate for traditional architectural styles in new buildings emphasize the importance of visual coherence and cultural continuity. Cities develop their distinctive character over time through the accumulation of architectural styles, and new buildings that deviate sharply from established norms can disrupt the visual harmony that residents find pleasing and identity-forming. Traditional architecture also connects present inhabitants with their historical heritage, providing a tangible link to the past that can foster community pride and belonging. Furthermore, traditional building methods and materials may be more sustainable and better suited to local climatic conditions than imported modernist techniques.

However, proponents of modern architecture present equally persuasive arguments. First, architecture must respond to contemporary needs, and modern buildings often incorporate functional advantages such as improved natural lighting, energy efficiency, and space optimization that traditional designs cannot match. Second, undifferentiated traditionalism can lead to sterility and a lack of architectural progress; cities that have attempted to freeze their built environment in amber have sometimes become frozen in time themselves, unable to adapt to changing circumstances. Third, imposing traditional styles can be seen as paternalistic, reflecting the preferences of planners rather than offering genuine choice to developers and inhabitants.

In my view, the optimal approach lies in thoughtful integration rather than rigid adherence to either extreme. This might involve encouraging contemporary architects to engage sensitively with local architectural traditions, using traditional materials or motifs in innovative ways, and ensuring that new developments respect scale, proportion, and context while not merely copying historical precedents. Some cities have successfully implemented design guidelines that achieve this balance, preserving character while allowing architectural evolution.

To conclude, while the visual and cultural arguments for traditional architecture are not without merit, I believe that a more nuanced approach that combines respect for heritage with openness to innovation produces the most vibrant and livable urban environments.""",
        overall_band=8.0,
        breakdown=BandBreakdown(
            vocabulary=8.0,
            coherence=8.0,
            grammar=8.0,
            task_response=8.0
        ),
        strengths=[
            "Excellent balance of analysis and personal opinion",
            "Insightful discussion that goes beyond superficial arguments",
            "Strong paragraph unity with each point clearly developed",
            "Sophisticated vocabulary used precisely"
        ],
        weaknesses=[
            "More visual examples of specific buildings or cities would enhance the argument",
            "The conclusion could be slightly more assertive"
        ],
        notes="Outstanding response demonstrating genuine intellectual engagement"
    ),
    GoldenEssay(
        essay_id="band8_work_01",
        topic="Work: Some people believe that job satisfaction is more important than job security. Others think that people should always prioritize job security over satisfaction. Discuss both views and give your own opinion.",
        question_type="discussion",
        essay_text="""The relative merits of job satisfaction and job security have been debated extensively in economic and psychological literature. This essay will explore both perspectives before offering a reasoned assessment.

Proponents of job satisfaction as the primary consideration argue that fulfilling work is essential for psychological wellbeing and personal fulfillment. Humans spend a substantial proportion of their lives in work, and dissatisfaction in this sphere can have profound negative effects on mental health, relationships, and overall quality of life. Furthermore, workers who find their jobs meaningful tend to be more productive, innovative, and committed to their employers, potentially benefiting organizations as well as individuals. In contrast, a secure but soul-crushing job may lead to stagnation, resentment, and ultimately burnout.

Those who prioritize job security, however, make valid counterpoints. Economic instability, particularly in an era of globalization and technological disruption, makes employment security increasingly precious. Without stable income, individuals cannot plan for the future, support their families, or meet basic needs. Moreover, job security provides not just financial but also psychological benefits, reducing anxiety and providing a foundation from which to pursue other life goals. Many people, particularly those with dependents or other responsibilities, may reasonably prefer the certainty of ongoing employment over the uncertainty of following their passions.

In my opinion, while both considerations are important, job security should generally take precedence for most people in most circumstances. This is primarily because the psychological costs of economic insecurity are substantial and can undermine the very satisfaction that one might seek through career changes. However, I also believe that the dichotomy is somewhat false; with careful planning and skills development, individuals can often find ways to enhance both job satisfaction and security simultaneously. Furthermore, job satisfaction itself is not fixed, and people may find meaning in different aspects of their work at different stages of their lives.

To conclude, while job satisfaction is undoubtedly valuable, I believe that job security provides the stable foundation upon which other life satisfactions can be built. Rather than viewing these goals as opposed, the wisest career strategy is to pursue both through continuous learning, networking, and adaptive planning.""",
        overall_band=8.0,
        breakdown=BandBreakdown(
            vocabulary=8.0,
            coherence=8.0,
            grammar=8.0,
            task_response=8.0
        ),
        strengths=[
            "Excellent analysis of both sides with genuine evaluation",
            "Strong academic vocabulary used appropriately throughout",
            "Logical progression of arguments",
            "Conclusion offers a nuanced synthesis"
        ],
        weaknesses=[
            "Some arguments could be supported with more empirical evidence",
            "The introduction could be slightly more engaging"
        ],
        notes="Strong intellectual framework with consistent and logical argumentation"
    ),
    GoldenEssay(
        essay_id="band8_society_01",
        topic="Society: The rise of social media has changed the way people interact with each other. Is this a positive or negative development?",
        question_type="advantage_disadvantage",
        essay_text="""The transformative impact of social media on human interaction is undeniable, and whether this represents a positive or negative development is a matter of considerable debate. In my assessment, while social media has undoubtedly brought significant benefits, its overall impact on human relationships is more ambiguous and warrants critical examination.

On the positive side, social media has revolutionized communication in numerous beneficial ways. It has enabled people to maintain relationships across geographical distances with unprecedented ease, allowing families separated by migration to stay connected and old friends to remain in touch. Furthermore, social media has provided platforms for marginalized voices to be heard, facilitating social movements and political mobilization that would otherwise be difficult to organize. During the COVID-19 pandemic, for instance, social media became a lifeline for many isolated individuals and enabled remote work and education to continue. Additionally, these platforms have created new opportunities for commerce, creativity, and information sharing.

However, the negative implications of social media for human interaction are equally significant and should not be dismissed. Research has increasingly documented the ways in which heavy social media use is associated with increased rates of anxiety, depression, and loneliness, particularly among young people. The curated, performative nature of online presentation can foster unhealthy social comparison and undermine authentic connection. Moreover, social media algorithms that prioritize engagement often amplify divisive, sensationalist content, potentially polarizing societies and undermining shared discourse. The quality of information on these platforms is highly variable, and misinformation can spread rapidly, with serious consequences for public health and democratic governance.

In weighing these considerations, I believe that the impact of social media depends fundamentally on how it is used. Used mindfully and in moderation, these platforms can enhance rather than replace traditional forms of social interaction. However, the current business models of social media companies, which depend on maximizing user engagement, create structural incentives that often undermine healthy use patterns.

To conclude, while social media has undoubtedly transformed human interaction in profound ways, characterizing this as simply positive or negative obscures a more complex reality. The challenge for individuals, communities, and policymakers is to harness the benefits of these powerful communication tools while mitigating their harms through thoughtful regulation, digital literacy education, and individual mindfulness about our relationship with these platforms.""",
        overall_band=8.0,
        breakdown=BandBreakdown(
            vocabulary=8.0,
            coherence=8.0,
            grammar=8.0,
            task_response=8.0
        ),
        strengths=[
            "Excellent critical analysis that avoids oversimplification",
            "Strong synthesis of research and logical argument",
            "Good balance of positive and negative considerations",
            "Sophisticated conclusion that offers practical recommendations"
        ],
        weaknesses=[
            "More specific examples of social media impacts would strengthen the essay",
            "Some readers might find the concluding paragraph slightly prescriptive"
        ],
        notes="Mature and balanced response demonstrating sophisticated critical thinking"
    ),
]


# =============================================================================
# BAND 9 ESSAYS (5 essays)
# =============================================================================

BAND_9_ESSAYS = [
    GoldenEssay(
        essay_id="band9_education_01",
        topic="Education: Some people say that the purpose of education is to prepare individuals to be useful to society. Others say that the purpose of education is to achieve personal fulfillment. Discuss both these views and give your own opinion.",
        question_type="discussion",
        essay_text="""The fundamental purposes of education have been debated by philosophers and policymakers for centuries, and the tension between preparing individuals for societal contribution and enabling personal fulfillment remains a central pedagogical concern. This essay will examine both perspectives, arguing that while these goals may appear distinct, they are in fact deeply interconnected.

Those who emphasize education's role in preparing individuals for societal utility present compelling arguments. Education transmits the knowledge, skills, and values necessary for communities to function and progress. Without education, individuals would lack the competencies required for employment, civic participation, and responsible citizenship. Moreover, societies have invested in education systems precisely because educated populations generate economic growth, innovation, and social stability. From this perspective, education is inherently instrumental, valued primarily for what it enables individuals to contribute to collective welfare.

However, those who prioritize personal fulfillment identify equally important considerations. Human flourishing encompasses not merely economic productivity but also psychological wellbeing, creative expression, and the pursuit of meaning. An educational system that treats individuals merely as future workers or citizens fails to recognize the intrinsic value of learning and intellectual development. Furthermore, education that neglects personal interests and passions may prove less effective in developing the engaged, motivated learners who become the most valuable contributors to society. Perhaps most fundamentally, individuals have diverse talents and aspirations, and a one-size-fits-all approach to education cannot accommodate this richness.

In my assessment, the dichotomy between societal utility and personal fulfillment is ultimately false. Far from being opposed, these goals are mutually reinforcing. Individuals who pursue education that engages their interests and develops their talents are likely to become more motivated, innovative, and productive contributors to society than those whose education is purely instrumental. Conversely, education that produces economically productive but intellectually stunted individuals may generate human capital while failing to produce the engaged, thoughtful citizens that flourishing societies require.

To conclude, I believe that the most effective educational approaches integrate both perspectives, recognizing that education serves individuals best when it engages their interests and develops their whole person, while also serving societies best when it produces engaged, innovative, and fulfilled citizens capable of addressing complex challenges.""",
        overall_band=9.0,
        breakdown=BandBreakdown(
            vocabulary=9.0,
            coherence=9.0,
            grammar=9.0,
            task_response=9.0
        ),
        strengths=[
            "Exceptional command of complex vocabulary used with precision",
            "Sophisticated argumentation that demonstrates intellectual depth",
            "Excellent paragraph development with each idea thoroughly explored",
            "Seamless integration of analysis and personal opinion"
        ],
        weaknesses=[],
        notes="Outstanding response that demonstrates mastery of all assessment criteria"
    ),
    GoldenEssay(
        essay_id="band9_technology_01",
        topic="Technology: The development of artificial intelligence is likely to have a profound impact on many aspects of human life. Some people welcome this development while others are concerned about the consequences. Discuss both these views and give your own opinion.",
        question_type="discussion",
        essay_text="""Artificial intelligence represents perhaps the most significant technological transformation of our era, with implications that extend far beyond the technological sphere into economic, social, and ethical domains. While some embrace this development with enthusiasm, others harbor serious reservations. This essay will examine both perspectives before offering a balanced assessment.

Those who welcome the development of artificial intelligence typically emphasize its transformative potential for human welfare. AI systems can process vast quantities of data and identify patterns beyond human cognitive capacity, enabling breakthroughs in fields ranging from medical diagnosis to climate modeling. In healthcare, AI-assisted diagnosis can detect diseases earlier and more accurately than human clinicians alone. In addressing global challenges such as climate change, AI can optimize energy systems, accelerate scientific research, and improve agricultural productivity. Furthermore, AI has the potential to liberate humans from tedious, repetitive labor, freeing time for more creative, fulfilling activities. Proponents argue that, like previous technological revolutions, the AI transformation will ultimately generate more opportunities than it displaces.

However, skeptics raise concerns that are equally deserving of serious consideration. The economic implications of widespread AI adoption are potentially destabilizing, as automation threatens to eliminate vast categories of employment faster than new jobs can be created, potentially exacerbating inequality. There are also profound ethical questions about the accountability of AI systems, particularly in high-stakes domains such as autonomous weapons, criminal justice, and healthcare. The concentration of AI capabilities in a small number of technology companies or nation-states raises geopolitical concerns. Perhaps most fundamentally, there are genuine uncertainties about whether sufficiently advanced AI systems can be reliably controlled or aligned with human values, with potentially catastrophic consequences.

In my opinion, while the potential benefits of AI are enormous, the concerns of skeptics are well-founded and should not be dismissed. This is not a reason for wholesale rejection of AI development, but rather a compelling argument for careful governance, robust research into AI safety, and inclusive dialogue about the values that should guide technological development. The choices we make now about how to develop and deploy AI will shape its impact for generations.

To conclude, I believe that the development of AI is both promising and concerning, and that our response should be neither uncritical enthusiasm nor reflexive alarm, but rather the serious, sustained engagement that a technology of such transformative potential demands.""",
        overall_band=9.0,
        breakdown=BandBreakdown(
            vocabulary=9.0,
            coherence=9.0,
            grammar=9.0,
            task_response=9.0
        ),
        strengths=[
            "Exceptional range and precision of vocabulary",
            "Superbly structured argumentation",
            "Excellent synthesis of complex ideas",
            "Mature and balanced perspective"
        ],
        weaknesses=[],
        notes="Exemplary response demonstrating full mastery at Band 9 level"
    ),
    GoldenEssay(
        essay_id="band9_environment_01",
        topic="Environment: The best way to solve environmental problems caused by developed countries is to put a high tax on goods produced in those countries. To what extent do you agree or disagree?",
        question_type="opinion",
        essay_text="""The proposition that environmental problems caused by developed countries can best be addressed through imposing high taxes on their goods is one that warrants careful analysis. While such measures have a role to play, I believe that a multifaceted approach is necessary to address the complex environmental challenges we face.

The case for environmental taxes on goods from developed countries rests on the polluter-pays principle, which holds that those responsible for environmental damage should bear the costs of remediation. Developed countries have historically contributed disproportionately to global environmental problems, including climate change and ocean pollution, while their populations have enjoyed high living standards built on resource-intensive economic models. Tariffs on their exports could internalize these environmental externalities and create incentives for cleaner production. Furthermore, such measures could provide developing countries with resources to adapt to climate change and protect their own environments.

However, there are significant limitations to this approach. First, trade measures of this kind risk being counterproductive, potentially harming the very developing economies they are intended to protect by reducing export revenues and limiting market access. Second, environmental problems are often transboundary in nature and cannot be addressed through bilateral trade measures alone; global challenges like climate change require coordinated international action. Third, high tariffs may simply lead to production shifting to countries with even weaker environmental standards, a phenomenon known as carbon leakage, rather than genuinely reducing environmental impact. Finally, such measures may be seen as protectionist and undermine the international cooperation that is essential for addressing global environmental challenges.

In my view, while environmental tariffs can contribute to sustainable trade, they should form part of a broader environmental policy framework rather than being treated as a panacea. This framework should include international agreements on emissions reductions, technology transfer to developing countries, investment in clean energy infrastructure, and support for sustainable development. Only through such comprehensive approaches can we hope to address environmental problems effectively while maintaining economic equity.

To conclude, I disagree with the proposition that high taxes on goods from developed countries represent the best solution to environmental problems. While the polluter-pays principle has merit, environmental challenges require multilateral solutions that address root causes rather than relying on trade measures that may prove inadequate or counterproductive.""",
        overall_band=9.0,
        breakdown=BandBreakdown(
            vocabulary=9.0,
            coherence=9.0,
            grammar=9.0,
            task_response=9.0
        ),
        strengths=[
            "Outstanding command of sophisticated vocabulary and concepts",
            "Excellent analysis of policy implications",
            "Well-balanced argumentation that acknowledges complexity",
            "Strong conclusion that synthesizes the discussion"
        ],
        weaknesses=[],
        notes="Excellent response demonstrating comprehensive understanding of the issues"
    ),
    GoldenEssay(
        essay_id="band9_culture_01",
        topic="Culture: Some people believe that visitors to other countries should follow local customs and behaviors. Others disagree and say that the host country should accept different cultures. Discuss both these views and give your own opinion.",
        question_type="discussion",
        essay_text="""The question of how individuals should navigate cultural differences when visiting foreign countries sits at the intersection of ethics, anthropology, and international relations. While some advocate for cultural assimilation and others for multicultural tolerance, I believe that a balanced approach recognizing both the value of cultural respect and the legitimacy of cultural diversity is most appropriate.

Those who argue that visitors should follow local customs and behaviors make several important points. First, respecting local traditions demonstrates acknowledgment of one's position as a guest and reflects basic courtesy towards hosts. When we enter another cultural context, we implicitly accept certain social contracts, and adapting our behavior to local norms is part of honoring those commitments. Furthermore, cultural practices are often deeply embedded in social relationships and religious traditions, and insensitive behavior can cause genuine offense or harm. In extreme cases, ignorance of local customs can even constitute legal violations, as tourists have occasionally discovered to their cost.

However, those who advocate for host country acceptance of different cultures also present compelling arguments. Cultural exchange has historically been a powerful driver of social progress, with exposure to foreign ideas and practices challenging parochialism and fostering mutual understanding. Furthermore, the expectation that visitors should completely assimilate places an unfair burden on those from radically different cultural backgrounds, particularly when visiting countries with greater economic and political power. The history of colonialism has left legacies of cultural imperialism that continue to shape international relations, and rejecting such hierarchies is essential for building genuine multicultural communities.

In my opinion, the most ethical approach lies between these extremes. Visitors should make genuine efforts to understand and respect local customs, recognizing that cultural sensitivity is a form of hospitality reciprocated. However, hosts should also demonstrate openness to different cultural practices, particularly when these cause no harm and reflect deeply held values of their practitioners. Neither wholesale assimilation nor unrestricted relativism serves human flourishing; what is needed isdialogue, mutual learning, and the development of shared norms where possible while respecting irreducible differences.

To conclude, I believe that both cultural respect and multicultural acceptance have important roles to play in navigating our diverse world. The key lies in fostering intercultural competence among travelers while creating host societies that are genuinely welcoming of difference.""",
        overall_band=9.0,
        breakdown=BandBreakdown(
            vocabulary=9.0,
            coherence=9.0,
            grammar=9.0,
            task_response=9.0
        ),
        strengths=[
            "Exceptional analytical framework",
            "Excellent use of academic register and sophisticated vocabulary",
            "Superb integration of theoretical perspectives",
            "Nuanced conclusion that offers practical guidance"
        ],
        weaknesses=[],
        notes="Outstanding intellectual engagement demonstrating mastery of the topic"
    ),
    GoldenEssay(
        essay_id="band9_society_01",
        topic="Society: In many countries, the amount of crime is increasing. Some people think that all criminals should be put in prison. Others think that there are better alternative ways to deal with criminals. Discuss both these views and give your own opinion.",
        question_type="discussion",
        essay_text="""The appropriate response to crime is a question that has occupied legal philosophers and policymakers for centuries, and the tension between punitive and rehabilitative approaches remains central to contemporary criminal justice debates. While incarceration serves important functions, I believe that a balanced approach incorporating alternative methods is more effective in reducing crime while upholding justice.

Those who advocate for imprisonment as the primary response to criminal behavior present legitimate concerns. Incarceration serves important purposes of incapacitation, removing dangerous individuals from society and preventing them from reoffending during their sentence. It also provides a clear expression of societal condemnation that affirms shared values and norms. For victims of crime and their families, the knowledge that offenders have been punished can provide a sense of justice being done. Furthermore, the certainty of imprisonment may serve as a deterrent, particularly for potential offenders who weigh the risks and benefits of criminal activity.

However, those who advocate for alternative approaches raise equally important considerations. Rates of recidivism in many prison systems are alarmingly high, suggesting that incarceration alone does little to address the underlying causes of criminal behavior. Prison can sometimes serve as a finishing school for crime, introducing offenders to networks and techniques that increase rather than decrease their future criminality. Moreover, imprisonment is enormously expensive, consuming resources that might more effectively be devoted to crime prevention, victim support, or rehabilitation programs. Most fundamentally, the goal of criminal justice should be not merely punishment but the reduction of harm, and alternative approaches such as restorative justice, community service, and rehabilitation programs may better serve this goal in many cases.

In my opinion, while incarceration must remain available for serious and violent offenses where public safety demands it, the overuse of imprisonment for less serious crimes is counterproductive and wasteful. A more sophisticated criminal justice system would reserve prison for dangerous offenders while developing effective alternative responses for others. This should include investment in rehabilitation programs, restorative justice approaches that bring victims and offenders together, and efforts to address the root causes of criminal behavior such as poverty, education disadvantage, and mental illness.

To conclude, I believe that the best approach to dealing with criminals combines the legitimate functions of imprisonment with well-designed alternative methods. A criminal justice system that focuses solely on punishment misses the opportunity to reduce harm and reintegrate offenders into society as productive citizens.""",
        overall_band=9.0,
        breakdown=BandBreakdown(
            vocabulary=9.0,
            coherence=9.0,
            grammar=9.0,
            task_response=9.0
        ),
        strengths=[
            "Excellent analysis drawing on multiple perspectives",
            "Sophisticated vocabulary used with great precision",
            "Strong paragraph development with clear argumentation",
            "Balanced conclusion that synthesizes the discussion"
        ],
        weaknesses=[],
        notes="Excellent response demonstrating comprehensive understanding of criminal justice issues"
    ),
]


# =============================================================================
# Complete Golden Dataset
# =============================================================================

GOLDEN_DATASET: list[GoldenEssay] = (
    BAND_6_ESSAYS +
    BAND_7_ESSAYS +
    BAND_8_ESSAYS +
    BAND_9_ESSAYS
)


def get_essays_by_band(target_band: float) -> list[GoldenEssay]:
    """Get all essays at or near a specific band score."""
    tolerance = 0.5
    return [
        essay for essay in GOLDEN_DATASET
        if abs(essay.overall_band - target_band) <= tolerance
    ]


def get_essays_by_question_type(question_type: str) -> list[GoldenEssay]:
    """Get all essays of a specific question type."""
    return [
        essay for essay in GOLDEN_DATASET
        if essay.question_type == question_type
    ]


def get_sample(size: int, seed: int = 42) -> list[GoldenEssay]:
    """Get a random sample of essays for evaluation."""
    import random
    random.seed(seed)
    return random.sample(GOLDEN_DATASET, min(size, len(GOLDEN_DATASET)))
