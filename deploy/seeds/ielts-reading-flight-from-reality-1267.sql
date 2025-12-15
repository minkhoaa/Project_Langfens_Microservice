BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-flight-from-reality-1267'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-flight-from-reality-1267';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-flight-from-reality-1267';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-flight-from-reality-1267';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c9d6b805-eefb-5456-b7a1-ecea3f3287da', 'ielts-reading-flight-from-reality-1267', $t$Flight from reality$t$, $md$## Flight from reality

Nguồn:
- Test: https://mini-ielts.com/1267/reading/flight-from-reality
- Solution: https://mini-ielts.com/1267/view-solution/reading/flight-from-reality$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e4073476-e619-5203-95d6-77360a0355c2', 'c9d6b805-eefb-5456-b7a1-ecea3f3287da', 1, $t$Reading — Flight from reality$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Flight from reality

Mobiles are barred, but passengers can lap away on their laptops to their hearts’ content. Is one really safer than the other? In the US, a Congressional subcommittee grilled airline representatives and regulators about the issue last month. But the committee heard that using cellphones in planes may indeed pose a risk albeit a slight one. This would seem to vindicate the treatment of Manchester oil worker Neil Whitehouse, who was sentenced last summer to a year in jail by a British court for refusing to turn off his mobile phone on a flight home from Madrid. Although he was only typing a message to be sent on landing not actually making a call, the court decided that hems putting the flight at risk.

A

The potential for problems is certainly there. Modern airliners are packed with electronic devices that control the plane and handle navigation and communications. Each has to meet stringent safeguards to make sure it doesn’t emit radiation that would interfere with other devices in the plane-standards that passengers’ personal electronic devices don’t necessarily meet. Emissions from inside the plane could also interfere with sensitive antennae on the fixed exterior.

B

But despite running a number of studies, Boeing, Airbus and various government agencies haven’t been able to find clear evidence of problems caused by personal electronic devices, including mobile phones. “We’ve done our own studies. We’ve found cellphones actually have no impact on the navigation system,” says Maryanne Greczyn, a spokeswoman for Airbus Industries of North America in Herndon, Virginia, Not do they affect other critical systems, she says The only impact Airbus found? “Sometimes when a passenger is starting or finishing a phone call, the pilot hears a wry slight beep in the headset,” she says.

C

The best evidence yet of a problem comes from a report released this year by Britain’s Civil Aviation Authority. Its researchers generated simulated cellphone transmissions inside two Boeing aircraft. They concluded that the transmissions could create signals at a power and frequency that would not affect the latest equipment, but exceeded the safety threshold established in 1984 and might, therefore, affect some of the older equipment on board. This doesn’t mean “mission critical” equipment such as the navigation system and flight controls. But the devices that could be affected, such as smoke detectors and fuel level indicators, could still create serious problems for the flight crew if they malfunction.

D

Many planes still use equipment certified to the older standards, says Dan Hawkes, head of avionics at the CAA’s Safely Regulation Croup. The CAA study doesn’t prove the equipment will actually fail when subjected to the signals but does show there’s a danger. “We’ve taken some of the uncertainty out of these beliefs,” he says Another study later this year will see if the cellphone signals actually cause devices to fail.

E

In 1996, RTCA, a consultant hired by the Federal Aviation Administration in the US to conduct tests, determined that potential problems from personal electronic devices were “low”. Nevertheless, it recommended a ban on their use during “critical” periods of flight, such as take-off and landing. RTCA didn’t actually test cellphones, but nevertheless recommended their wholesale ban on flights, But if “better safe than sorry” is the current policy, it’s applied inconsistently, according to Marshall Cross, the chairman of Mega Wave Corporation, based in Boylston, Massachusetts. Why are cellphones outlawed when no one considers a ban on laptops? “It’s like most things in life. The reason is a little bit technical, a little bit economic and a little bit political,” says Cross.

F

The company wrote a report for the FAA in 1998 saying it is possible to build an on-board system that can detect dangerous signals from electronic devices. But Cross’s personal conclusion is that mobile phones aren’t the real threat. “You’d have to stretch things pretty far to figure out how a cellphone could interfere with a plane’s systems,” he says. Cellphones transmit in ranges of around 400, 800 or 1800 megahertz. Since no important piece of aircraft equipment operates at those frequencies, the possibility of interference is very low, Cross says. The use of Computers and electronic game systems is much more worrying, lie says. They can generate very strong signals at frequencies that could interfere with plane electronics, especially if a mouse is attached {the wire operates as an antenna or if their built-in shielding is somehow damaged. Some airlines are even planning to put sockets for laptops in seatbacks.

G

There’s fairly convincing anecdotal evidence that some personal electronic devices have interfered with systems. Aircrew on one flight found that the autopilot was being disconnected, and narrowed the problem down to a passenger’s portable computer. They could actually watch the autopilot disconnect when they switched the computer on. Boeing bought the computer, took it to the airline’s labs and even tested it on an empty flight. But as with every other reported instance of interference, technicians were unable to replicate the problem.

H

Some engineers, however, such as Bruce Donham of Boeing, say that common sense suggests phones are more risky than laptops. “A device capable of producing a strong emission is not as safe as a device which does not have any intentional emission,” lie says. Nevertheless, many experts think it’s illogical that cellphones are prohibited when computers aren’t. Besides, the problem is more complicated than simply looking at power and frequency. In the air, the plane operates in a soup of electronic emissions, created by its own electronics and by ground-based radiation. Electronic devices in the cabin-especially those emitting a strong signal-can behave unpredictably, reinforcing other signals, for instance, or creating unforeseen harmonics that disrupt systems.

I

Despite the Congressional subcommittee hearings last month, no one seems to be working seriously on a technical solution that would allow passengers to use their phones. That’s mostly because no one -besides cellphone users themselves-stands to gain a lot if the phones are allowed in the air. Even the cellphone companies don’t want it. They are concerned that airborne signals could cause problems by flooding a number of the networks’ base stations at once with the same signal This effect, called bigfooting, happens because airborne cellphone signals tend to go to many base stations at once, unlike land calls which usually go to just one or two stations. In the US, even if FAA regulations didn’t prohibit cellphones in the air, Federal Communications Commission regulations would.

J

Possible solutions might be to enhance airliners’ electronic insulation or to fit detectors which warned flight staff when passenger devices were emitting dangerous signals. But Cross complains that neither the FAA, the airlines nor the manufacturers are showing much interest in developing these. So despite Congressional suspicions and the occasional irritated (or jailed) mobile user, the industry’s “better safe than sorry” policy on mobile phones seems likely to continue. In the absence of firm evidence that the international airline industry is engaged in a vast conspiracy to overcharge its customers, a delayed phone call seems a small price to pay for even the tiniest reduction in the chances of a Plane Crash. But you’ll still be allowed to use your personal computer during a flight. And while that remains the case, airlines can hardly claim that logic has prevailed.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0d7b3c1f-9974-56c6-a215-f8d0b678651e', 'e4073476-e619-5203-95d6-77360a0355c2', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
The would-be risk surely exists, since the avionic systems on modern aircraft are used to manage flight and deal with
1
Those devices are designed to meet the safety criteria which should be free from interrupting
2
or interior emission. The personal use of a mobile phone may cause the sophisticated
3
outside of the plane to dysfunction. Though definite interference in piloting devices has not been scientifically testified, the devices such as those which detect
4
or indicate fuel load could be affected.

The would-be risk surely exists, since the avionic systems on modern aircraft are used to manage flight and deal with 1 ____ Those devices are designed to meet the safety criteria which should be free from interrupting 2 ____ or interior emission. The personal use of a mobile phone may cause the sophisticated 3 ____ outside of the plane to dysfunction. Though definite interference in piloting devices has not been scientifically testified, the devices such as those which detect 4 ____ or indicate fuel load could be affected.$md$, NULL, ARRAY['.*navigation.*and.*communications.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('331649d3-b9d1-5e23-913e-40e6dc9f9f9b', 'e4073476-e619-5203-95d6-77360a0355c2', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
The would-be risk surely exists, since the avionic systems on modern aircraft are used to manage flight and deal with
1
Those devices are designed to meet the safety criteria which should be free from interrupting
2
or interior emission. The personal use of a mobile phone may cause the sophisticated
3
outside of the plane to dysfunction. Though definite interference in piloting devices has not been scientifically testified, the devices such as those which detect
4
or indicate fuel load could be affected.

The would-be risk surely exists, since the avionic systems on modern aircraft are used to manage flight and deal with 1 ____ Those devices are designed to meet the safety criteria which should be free from interrupting 2 ____ or interior emission. The personal use of a mobile phone may cause the sophisticated 3 ____ outside of the plane to dysfunction. Though definite interference in piloting devices has not been scientifically testified, the devices such as those which detect 4 ____ or indicate fuel load could be affected.$md$, NULL, ARRAY['.*navigation.*and.*communications.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d73d64f6-7663-5515-a5b1-c715f3130f35', 'e4073476-e619-5203-95d6-77360a0355c2', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
The would-be risk surely exists, since the avionic systems on modern aircraft are used to manage flight and deal with
1
Those devices are designed to meet the safety criteria which should be free from interrupting
2
or interior emission. The personal use of a mobile phone may cause the sophisticated
3
outside of the plane to dysfunction. Though definite interference in piloting devices has not been scientifically testified, the devices such as those which detect
4
or indicate fuel load could be affected.

The would-be risk surely exists, since the avionic systems on modern aircraft are used to manage flight and deal with 1 ____ Those devices are designed to meet the safety criteria which should be free from interrupting 2 ____ or interior emission. The personal use of a mobile phone may cause the sophisticated 3 ____ outside of the plane to dysfunction. Though definite interference in piloting devices has not been scientifically testified, the devices such as those which detect 4 ____ or indicate fuel load could be affected.$md$, NULL, ARRAY['.*navigation.*and.*communications.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f8a68050-7333-59e6-90bd-9827b15eb2fb', 'e4073476-e619-5203-95d6-77360a0355c2', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
The would-be risk surely exists, since the avionic systems on modern aircraft are used to manage flight and deal with
1
Those devices are designed to meet the safety criteria which should be free from interrupting
2
or interior emission. The personal use of a mobile phone may cause the sophisticated
3
outside of the plane to dysfunction. Though definite interference in piloting devices has not been scientifically testified, the devices such as those which detect
4
or indicate fuel load could be affected.

The would-be risk surely exists, since the avionic systems on modern aircraft are used to manage flight and deal with 1 ____ Those devices are designed to meet the safety criteria which should be free from interrupting 2 ____ or interior emission. The personal use of a mobile phone may cause the sophisticated 3 ____ outside of the plane to dysfunction. Though definite interference in piloting devices has not been scientifically testified, the devices such as those which detect 4 ____ or indicate fuel load could be affected.$md$, NULL, ARRAY['.*navigation.*and.*communications.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('54f37c8f-db34-5ba7-9c26-c6b21e4c71bc', 'e4073476-e619-5203-95d6-77360a0355c2', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Use the information in the passage to match the Organization (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
5-9
on your answer sheet.
A
British Civil Aviation Authority
B
Maryanne Greczyn
C
RTCA
D
Marshall Cross
E
Boeing company
5
Mobile usages should be forbidden in specific fame.
6
Computers are more dangerous than cell phones.
7
Finding that the mobile phones pose little risk on flight’s navigation devices.
8
The disruption of laptops is not as dangerous as cellphones.
9
The mobile signal may have an impact on earlier devices.

5 ____ Mobile usages should be forbidden in specific fame.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35636365-e3b8-5e0d-8664-529a780ac5c5', '54f37c8f-db34-5ba7-9c26-c6b21e4c71bc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c92a0d1e-d9e5-5b52-a4c5-6525ed4d82b6', '54f37c8f-db34-5ba7-9c26-c6b21e4c71bc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51fad91d-7107-5657-ad5e-4b60d51d9602', '54f37c8f-db34-5ba7-9c26-c6b21e4c71bc', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fc79766-fff6-595c-9af2-8c69824e48a3', '54f37c8f-db34-5ba7-9c26-c6b21e4c71bc', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc574667-06d9-5cf9-9284-8482e65b2dff', '54f37c8f-db34-5ba7-9c26-c6b21e4c71bc', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('98c3410b-462e-5c5d-a560-c24abd5164d8', 'e4073476-e619-5203-95d6-77360a0355c2', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Use the information in the passage to match the Organization (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
5-9
on your answer sheet.
A
British Civil Aviation Authority
B
Maryanne Greczyn
C
RTCA
D
Marshall Cross
E
Boeing company
5
Mobile usages should be forbidden in specific fame.
6
Computers are more dangerous than cell phones.
7
Finding that the mobile phones pose little risk on flight’s navigation devices.
8
The disruption of laptops is not as dangerous as cellphones.
9
The mobile signal may have an impact on earlier devices.

6 ____ Computers are more dangerous than cell phones.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb8ce263-2347-5a3b-96a7-334d8f176e05', '98c3410b-462e-5c5d-a560-c24abd5164d8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8c7dd10-6a0a-5b88-b887-ade7f15731cc', '98c3410b-462e-5c5d-a560-c24abd5164d8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15e52a71-53ad-543d-9807-82d95f210a16', '98c3410b-462e-5c5d-a560-c24abd5164d8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79d0cf7d-ba00-505f-8d09-a2e0a4e50c0a', '98c3410b-462e-5c5d-a560-c24abd5164d8', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e93f304-d015-5245-a2c0-552cc0e3a1f8', '98c3410b-462e-5c5d-a560-c24abd5164d8', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1a686cce-9314-581c-adb6-349b80df2b88', 'e4073476-e619-5203-95d6-77360a0355c2', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Use the information in the passage to match the Organization (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
5-9
on your answer sheet.
A
British Civil Aviation Authority
B
Maryanne Greczyn
C
RTCA
D
Marshall Cross
E
Boeing company
5
Mobile usages should be forbidden in specific fame.
6
Computers are more dangerous than cell phones.
7
Finding that the mobile phones pose little risk on flight’s navigation devices.
8
The disruption of laptops is not as dangerous as cellphones.
9
The mobile signal may have an impact on earlier devices.

7 ____ Finding that the mobile phones pose little risk on flight’s navigation devices.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2389be4-5a81-5f6b-86a9-7011af1a5f59', '1a686cce-9314-581c-adb6-349b80df2b88', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e9f8178-4b97-51ab-8069-6ff731422aa0', '1a686cce-9314-581c-adb6-349b80df2b88', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31d99977-a953-50f9-a93b-46791ea7467b', '1a686cce-9314-581c-adb6-349b80df2b88', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebf3e1c9-3349-59cd-9e04-f5578c8edddc', '1a686cce-9314-581c-adb6-349b80df2b88', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02da4156-97e5-5119-9ef0-07034831ad3d', '1a686cce-9314-581c-adb6-349b80df2b88', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9be7a6be-740d-5fd4-a345-b63d0fd911fd', 'e4073476-e619-5203-95d6-77360a0355c2', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Use the information in the passage to match the Organization (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
5-9
on your answer sheet.
A
British Civil Aviation Authority
B
Maryanne Greczyn
C
RTCA
D
Marshall Cross
E
Boeing company
5
Mobile usages should be forbidden in specific fame.
6
Computers are more dangerous than cell phones.
7
Finding that the mobile phones pose little risk on flight’s navigation devices.
8
The disruption of laptops is not as dangerous as cellphones.
9
The mobile signal may have an impact on earlier devices.

8 ____ The disruption of laptops is not as dangerous as cellphones.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d905c427-91d4-5b83-a5ea-4fd977d5e45c', '9be7a6be-740d-5fd4-a345-b63d0fd911fd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cbfa630-779e-5355-b53c-1e41a61b9b19', '9be7a6be-740d-5fd4-a345-b63d0fd911fd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0446547-b1df-5293-be45-4c17cb254d4a', '9be7a6be-740d-5fd4-a345-b63d0fd911fd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31e87ae1-849a-5ed4-ab87-cbf99cf5e199', '9be7a6be-740d-5fd4-a345-b63d0fd911fd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de2d7f6c-c6b6-5f02-9fe9-6098a4eaa2fa', '9be7a6be-740d-5fd4-a345-b63d0fd911fd', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e5ded506-34de-51f8-8bd9-6345e53616c4', 'e4073476-e619-5203-95d6-77360a0355c2', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Use the information in the passage to match the Organization (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
5-9
on your answer sheet.
A
British Civil Aviation Authority
B
Maryanne Greczyn
C
RTCA
D
Marshall Cross
E
Boeing company
5
Mobile usages should be forbidden in specific fame.
6
Computers are more dangerous than cell phones.
7
Finding that the mobile phones pose little risk on flight’s navigation devices.
8
The disruption of laptops is not as dangerous as cellphones.
9
The mobile signal may have an impact on earlier devices.

9 ____ The mobile signal may have an impact on earlier devices.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af6e8506-45e0-5a9f-b06a-5492e1267d31', 'e5ded506-34de-51f8-8bd9-6345e53616c4', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37e9a873-1ad2-50a4-a22e-41cb4e2332c2', 'e5ded506-34de-51f8-8bd9-6345e53616c4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cde5237e-8e62-5e50-a7d0-bd28c4b4ba77', 'e5ded506-34de-51f8-8bd9-6345e53616c4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52617da7-eefc-58e6-a1d3-20541b0f57e0', 'e5ded506-34de-51f8-8bd9-6345e53616c4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('213103be-2232-5c01-80ae-b5ac9aa4aec8', 'e5ded506-34de-51f8-8bd9-6345e53616c4', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5e6439fd-9ea9-5ebe-bb9d-c1f283056b7b', 'e4073476-e619-5203-95d6-77360a0355c2', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Almost all scientists accept that cellphones have higher emission than that of personal computers.
11
Some people believe that radio emission will interrupt the equipment on the plane.
12
The signal interference-detecting device has not yet been developed because they are in priority for neither administrative department nor offer an economic incentive.
13
FAA initialed open debate with Federal Communications Commission.

10 ____ Almost all scientists accept that cellphones have higher emission than that of personal computers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87f7fc42-1b72-5691-9015-e4e09ac11da0', '5e6439fd-9ea9-5ebe-bb9d-c1f283056b7b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('432acda6-101d-5d09-8bbc-cb7cae682ecd', '5e6439fd-9ea9-5ebe-bb9d-c1f283056b7b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a5821d6-b44c-5a34-a1cb-f4cfca17d768', '5e6439fd-9ea9-5ebe-bb9d-c1f283056b7b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5a9733ed-0206-51dc-baf9-3192547af608', 'e4073476-e619-5203-95d6-77360a0355c2', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Almost all scientists accept that cellphones have higher emission than that of personal computers.
11
Some people believe that radio emission will interrupt the equipment on the plane.
12
The signal interference-detecting device has not yet been developed because they are in priority for neither administrative department nor offer an economic incentive.
13
FAA initialed open debate with Federal Communications Commission.

11 ____ Some people believe that radio emission will interrupt the equipment on the plane.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08aa7506-1c38-5afa-aa62-3293dc5dc90c', '5a9733ed-0206-51dc-baf9-3192547af608', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c9f3dcc-ff7f-5974-91ab-a45a7ca75f75', '5a9733ed-0206-51dc-baf9-3192547af608', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99247cd7-9e2b-5295-8516-42ca5cf8c876', '5a9733ed-0206-51dc-baf9-3192547af608', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('05a9e662-d047-50d3-b774-8c77119d8b7d', 'e4073476-e619-5203-95d6-77360a0355c2', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Almost all scientists accept that cellphones have higher emission than that of personal computers.
11
Some people believe that radio emission will interrupt the equipment on the plane.
12
The signal interference-detecting device has not yet been developed because they are in priority for neither administrative department nor offer an economic incentive.
13
FAA initialed open debate with Federal Communications Commission.

12 ____ The signal interference-detecting device has not yet been developed because they are in priority for neither administrative department nor offer an economic incentive.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d3b2e07-48b8-5c4a-b74c-ddba2ad47668', '05a9e662-d047-50d3-b774-8c77119d8b7d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90dd8a79-7c39-5b66-9efd-163883f90912', '05a9e662-d047-50d3-b774-8c77119d8b7d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4baf449d-0947-5507-b529-d7ff6844b28c', '05a9e662-d047-50d3-b774-8c77119d8b7d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa631366-4d2d-5963-a387-b4c01eebb28c', 'e4073476-e619-5203-95d6-77360a0355c2', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Almost all scientists accept that cellphones have higher emission than that of personal computers.
11
Some people believe that radio emission will interrupt the equipment on the plane.
12
The signal interference-detecting device has not yet been developed because they are in priority for neither administrative department nor offer an economic incentive.
13
FAA initialed open debate with Federal Communications Commission.

13 ____ FAA initialed open debate with Federal Communications Commission.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e22c531-a8af-531a-a126-e221eaead2fc', 'aa631366-4d2d-5963-a387-b4c01eebb28c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ba3348f-594b-5288-ae1d-57ceeb5d61b7', 'aa631366-4d2d-5963-a387-b4c01eebb28c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ca02408-87fc-50e1-96ce-54f2098a5d3f', 'aa631366-4d2d-5963-a387-b4c01eebb28c', 3, $md$NOT GIVEN$md$, true);

COMMIT;
