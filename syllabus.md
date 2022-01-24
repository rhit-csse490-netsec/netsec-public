---
title: Syllabus
layout: post
readtime: true
date: Thu Jan 20 22:31:16 2022 
---


> The only truly secure system is one that is powered off, cast in a block of
  concrete and sealed in a lead-lined room with armed guards - and even then I
  have my doubts.
  <div style="text-align:right;">Eugene H. Spafford </div>


# Course Description

This course serves as an introduction to the basic concepts of network security
with an emphasis on practical and research skills. Topics include denial of
service attacks and defenses, authentication, key distribution, message
authentication, access control, protocol security, Tor, and security standards.
The course will provide a review of basic network design, the end-to-end
principle, and basic cryptography. Prerequisites: CSSE 230. 

# Informal Description

It was a dark and stormy night, Heimdallr, the guardian of the gods, kept a
watchful eye on the Bifrost bridge. “Could it be tonight? Would Loki do it? I
can feel it coming. Ragnarok”, said Heimdallr to himself. Thoughts of carnage
and destruction occupied his ever-observing head. He had a disturbing feeling in
his gut that something was going to happen tonight, and he needed to let the
gods know about it.

And finally, there it was, he could see it on the horizon: the giant head of the
wolf, Fenrir, alongside his father, the deceiver Loki. Hel, the goddess of the
underworld, can be seen leading the army of the dead. “It is time, I must send a
message to Odin and the gods to prepare for the final battle”, said Heimdallr. 

As he was typing the message on his iPhone 13Pro, a thought popped into his
head: “How can I tell Odin without anyone intercepting the message”? Loki was
known to have hired a band of hackers to support his war efforts. Furthermore,
how can Odin know that it was Heimdallr who wrote the message?  How could he
stop Loki’s script kiddies from impersonating him in an email or a message? How
can he make sure that the tunnel to Asgard was safe and not under attack? A
moment of panic took over Heimdallr, **how can he send sensitive information on
an untrusted network?**

In this course, we will set up to help the Norse gods by exploring how Heimdallr
can send a private message, in a world that is increasingly public and under
attack. We will take a look at this problem from two perspectives: (1) Loki’s
perspective, who is trying to intercept and exploit any messages sent to the
Gods, and (2) Heimdallr and the gods’ perspective, who are trying to secure
their messages from Loki’s army. 

Just like Heimdallr (who rocks an Instagram profile with thousands of followers)
and the gods, we find ourselves today in a society that increasingly puts trust
in the Internet, a network that is not worthy of that trust. The Internet was
designed with the end-to-end principle in mind; push the complexity into the
endpoints as much as possible, keeping the intermediary nodes (core routers,
switches, etc.) as simple as possible. This is great and all, but it renders the
medium of communication unreliable and untrustworthy. Malicious actors can
intercept traffic, change network packets, and masquerade as other users or as
Internet authorities. The process of ensuring private communication over an
untrusted network is the main topic of this class. 

# Learning Objectives

Our main purpose in this class is to help the Norse gods defeat Loki's army in
the Cyberwar. Therefore, upon successful completion of this class, you will be
able to:

- identify security vulnerabilities in network protocols and exploit them in a
controlled environment,
- actively engage in the design and protection of network components,
- conduct a literature review on current topics in network security, and
- work in a team to produce a small-scale research project with an accompanying
paper. 
- Finally, feel good about yourself because you helped the gods protect Asgard
and fend off Loki's attacks. (Maybe they'll write songs about you one day).

# Instructor

- Mohammad Noureddine, aka Asgard's Chief Information-Security Officer
- The command and control center is in Midgard (or Earth), located in Moench
  Hall, office F214.
- Homing pigeons can be sent to noureddi `at` rose-hulman `dot` edu, or via
  Microsoft Teams.  

## Welcome Statement

I am very excited to have the opportunity to offer this class and can't wait to
meet you and get to know you. I hope that throughout the class, you will see me
as part of your support team. I strive to offer you a welcoming environment
where you can get help on course content, homework, or anything else really.
Studies conducted by me in my office show that coming to office hours increases
your chances of success.

## Office Hours

I am more than happy to have you stop by my office, ask questions, and have
discussions. If my office door is open, feel free to walk in and start a
conversation. Topics I enjoy are: Norse mythology (duh!), computer security,
philosophy, economics and econmic equality, and the NBA. I also make a kickass
cup of coffee using high quality coffee beans, feel free to ask me more about
that. 

When my office door is closed, I am generally prepping for class or in a
meeting. Feel free to knock on my door and we can quickly chat about possible
meeting times. 

If you feel you'd like to schedule an appointment with me, you can use [this
calendly link](https://calendly.com/mnoureddine/office-hours) to get on my
calendar; you'll have a reserved slot on my calendar. 

# Textbook

This is no required textbook for this class, I have found the eventually I end
up creating content for class that is based on an amalgamation of content from
textbooks, papers, YouTube videos, blog posts, and so on. I will try as much as
possible to make the course self-contained when it comes to the material that
are publicly available.

## Recommended textbook

However, there must be a resource that shines away from the competition; in this
case, it is "Internet Security: A Hands-on Approach" by Wengliang Du. This is a
great textbook that covers must of what we will go through in this class in a
way that covers both theory and practice, so I recommend that you purchase a
copy of this book and keep it with you for later-on reference in your career.

> [Du, Wengliang, "Internet Security: A Hands-on Approach", 2nd Edition,
  2019](https://www.amazon.com/gp/product/1733003916?ref=ppx_pt2_dt_b_prod_image)


## Supplemental textbook(s)

In addition to the above textbook, I used the following list of references to
design the course material:

- [Zave, Pamela, and Jennifer Rexford. "Patterns and Interactions in Network
Security." ACM Computing Surveys (CSUR) 53.6 (2020): 1-37.](https://dl.acm.org/doi/pdf/10.1145/3417988?casa_token=QX4l42HmCnQAAAAA:I6tqA4MwoDt0_dqROuUBh7z-uYNYTkkGMcdyIPNPmaVoRyAeziusxywD2lMObUNdp1WaFrfUxgw)
- [Perlman, Radia, Charlie Kaufman, and Mike Speciner. Network security: private
communication in a public world. Pearson Education,
2002.](https://www.pearson.com/us/higher-education/program/Kaufman-Network-Security-Private-Communication-in-a-Public-World-2nd-Edition/PGM188104.html)
- [Stallings, William. Network Security Essentials: Applications and Standards,
6/e. Pearson Education,  2017](https://www.pearson.com/us/higher-education/program/Stallings-Network-Security-Essentials-Applications-and-Standards-6th-Edition/PGM337626.html)
- [Forshaw, James. Attacking network protocols: a hacker's guide to capture,
analysis, and exploitation. No Starch Press, 2017.](https://www.google.com/books/edition/Attacking_Network_Protocols/EVv6DwAAQBAJ?hl=en&gbpv=0)

# Course format

Meetings for the guardians of Asgard will take place on Earth, in O159, at the
unfortunate time of 8:00 am in the morning (well, what better way to start your
day than by thinking about security).  This class will consist of in-class
lectures as well as research paper discussions and presentations. 

Depending on the number of students in the class, we will designate some days of
the week as paper-reading days. In these days, you will have the floor and teach
us about a specific topic in network security. 

# Grading

As this is an upper-level class, we will not be having exams. Instead, we will
heavily rely on active hands-on labs where you will write exploits and defenses.
You will work in a team on a small-scale research project in topics related to
network security (Yes, I will reluctantly accept projects that use machine
learning techniques to detect and defend against maclicious attacks). 

## Grading breakdown

| Item                  | Weight |
| :-------------------- | :----- |
| Paper Presentation    | 25%    |
| Homeworks and Labs    | 30%    |
| Project               | 40%    |
| Participation         | 5%     |

# A statement on mental health

I know that as students, you are dealing with a lot of stress, often a lack of
sleep, and sometimes social isolation (especially in the COVID times). It is
easy to neglect your mental (and physical) health and lose yourself in the
vortex of pressure. Spoken from experience, it is important for you to *make
time* for yourself, both mentally and physically. Therefore, if at any point
during the quarter, you feel that you are in need of help, please reach out to
the [office of health
services](https://www.rose-hulman.edu/campus-life/student-services/wellness-and-health-services/health-services/index.html)
or [the student counseling
center](https://www.rose-hulman.edu/campus-life/student-services/wellness-and-health-services/counseling-services/index.html).
Also, if you feel comfortable, you can reach out to me so I can help you
devise a plan to tackle your coursework for CSSE 332. 
