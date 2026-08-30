%==============================================================================
% CAAES — CSE Academic Advising Expert System
% Knowledge base: domain facts (entities, properties, sample student records)
%==============================================================================

:- dynamic student/1.
:- dynamic passed/2.
:- dynamic declared_gpa/2.
:- dynamic student_year/2.
:- dynamic student_interest/2.
:- dynamic grade/3.
:- discontiguous passed/2.
:- discontiguous grade/3.

%------------------------------------------------------------------------------
% Departments
%------------------------------------------------------------------------------
department(computer_engineering).
department(mathematics).
department(applied_physics).
department(general_studies).

%------------------------------------------------------------------------------
% Career tracks and related interests / industries
%------------------------------------------------------------------------------
career_track(software_engineering).
career_track(artificial_intelligence).
career_track(cybersecurity).
career_track(networks_systems).
career_track(data_science).

interest(software).
interest(ai).
interest(security).
interest(networks).
interest(data).
interest(embedded).
interest(web).
interest(research).

track_interest(software_engineering, software).
track_interest(software_engineering, web).
track_interest(artificial_intelligence, ai).
track_interest(artificial_intelligence, research).
track_interest(artificial_intelligence, data).
track_interest(cybersecurity, security).
track_interest(cybersecurity, networks).
track_interest(networks_systems, networks).
track_interest(networks_systems, embedded).
track_interest(data_science, data).
track_interest(data_science, ai).

industry(software_firms).
industry(telecom).
industry(banking).
industry(mining_tech).
industry(healthcare_it).
industry(research_labs).

track_industry(software_engineering, software_firms).
track_industry(software_engineering, banking).
track_industry(artificial_intelligence, research_labs).
track_industry(artificial_intelligence, healthcare_it).
track_industry(cybersecurity, banking).
track_industry(cybersecurity, mining_tech).
track_industry(networks_systems, telecom).
track_industry(networks_systems, mining_tech).
track_industry(data_science, banking).
track_industry(data_science, healthcare_it).

%------------------------------------------------------------------------------
% Courses: course(Code, Title, Credits, Level)
%------------------------------------------------------------------------------
course(ce101, 'Introduction to Computing', 3, 100).
course(ce102, 'Computer Programming I', 3, 100).
course(ce103, 'Discrete Mathematics', 3, 100).
course(ce104, 'Computer Programming II', 3, 100).
course(ce105, 'Digital Logic Fundamentals', 3, 100).
course(ce106, 'Introduction to Engineering', 2, 100).
course(ma101, 'Calculus I', 3, 100).
course(ma102, 'Calculus II', 3, 100).
course(ph101, 'Applied Physics', 3, 100).
course(en101, 'Communication Skills', 2, 100).

course(ce201, 'Data Structures', 3, 200).
course(ce202, 'Object-Oriented Programming', 3, 200).
course(ce203, 'Computer Organization', 3, 200).
course(ce204, 'Database Systems', 3, 200).
course(ce205, 'Operating Systems', 3, 200).
course(ce206, 'Data Communication', 3, 200).
course(ce207, 'Software Engineering I', 3, 200).
course(ce208, 'Web Technologies', 3, 200).
course(ma201, 'Linear Algebra', 3, 200).
course(ma202, 'Probability and Statistics', 3, 200).

course(ce301, 'Algorithms', 3, 300).
course(ce302, 'Computer Networks', 3, 300).
course(ce303, 'Theory of Computation', 3, 300).
course(ce304, 'Software Engineering II', 3, 300).
course(ce305, 'Artificial Intelligence', 3, 300).
course(ce306, 'Information Security', 3, 300).
course(ce307, 'Programming Languages', 3, 300).
course(ce308, 'Embedded Systems', 3, 300).
course(ce309, 'Human-Computer Interaction', 3, 300).
course(ce310, 'Mini Project', 3, 300).
course(ce311, 'Machine Learning Fundamentals', 3, 300).
course(ce312, 'Cloud Computing', 3, 300).

course(ce401, 'Compiler Design', 3, 400).
course(ce402, 'Distributed Systems', 3, 400).
course(ce403, 'Data Mining', 3, 400).
course(ce404, 'Mobile Computing', 3, 400).
course(ce405, 'Cybersecurity', 3, 400).
course(ce406, 'Final Year Project I', 3, 400).
course(ce407, 'Final Year Project II', 3, 400).
course(ce408, 'Professional Practice', 2, 400).
course(ce409, 'Entrepreneurship', 2, 400).
course(ce410, 'Advanced Databases', 3, 400).
course(ce411, 'Computer Graphics', 3, 400).
course(ce412, 'Internet of Things', 3, 400).
course(ce474, 'Logic of Computer Science', 3, 400).

%------------------------------------------------------------------------------
% Course offering semester: first | second | both
%------------------------------------------------------------------------------
offered(ce101, first).
offered(ce102, first).
offered(ce103, first).
offered(ce104, second).
offered(ce105, second).
offered(ce106, first).
offered(ma101, first).
offered(ma102, second).
offered(ph101, first).
offered(en101, second).

offered(ce201, first).
offered(ce202, first).
offered(ce203, first).
offered(ce204, second).
offered(ce205, second).
offered(ce206, second).
offered(ce207, second).
offered(ce208, first).
offered(ma201, first).
offered(ma202, second).

offered(ce301, first).
offered(ce302, first).
offered(ce303, first).
offered(ce304, second).
offered(ce305, first).
offered(ce306, second).
offered(ce307, second).
offered(ce308, first).
offered(ce309, second).
offered(ce310, second).
offered(ce311, second).
offered(ce312, first).

offered(ce401, first).
offered(ce402, first).
offered(ce403, second).
offered(ce404, first).
offered(ce405, second).
offered(ce406, first).
offered(ce407, second).
offered(ce408, first).
offered(ce409, second).
offered(ce410, first).
offered(ce411, second).
offered(ce412, second).
offered(ce474, first).

%------------------------------------------------------------------------------
% Department ownership
%------------------------------------------------------------------------------
course_department(ce101, computer_engineering).
course_department(ce102, computer_engineering).
course_department(ce103, computer_engineering).
course_department(ce104, computer_engineering).
course_department(ce105, computer_engineering).
course_department(ce106, computer_engineering).
course_department(ma101, mathematics).
course_department(ma102, mathematics).
course_department(ph101, applied_physics).
course_department(en101, general_studies).
course_department(ce201, computer_engineering).
course_department(ce202, computer_engineering).
course_department(ce203, computer_engineering).
course_department(ce204, computer_engineering).
course_department(ce205, computer_engineering).
course_department(ce206, computer_engineering).
course_department(ce207, computer_engineering).
course_department(ce208, computer_engineering).
course_department(ma201, mathematics).
course_department(ma202, mathematics).
course_department(ce301, computer_engineering).
course_department(ce302, computer_engineering).
course_department(ce303, computer_engineering).
course_department(ce304, computer_engineering).
course_department(ce305, computer_engineering).
course_department(ce306, computer_engineering).
course_department(ce307, computer_engineering).
course_department(ce308, computer_engineering).
course_department(ce309, computer_engineering).
course_department(ce310, computer_engineering).
course_department(ce311, computer_engineering).
course_department(ce312, computer_engineering).
course_department(ce401, computer_engineering).
course_department(ce402, computer_engineering).
course_department(ce403, computer_engineering).
course_department(ce404, computer_engineering).
course_department(ce405, computer_engineering).
course_department(ce406, computer_engineering).
course_department(ce407, computer_engineering).
course_department(ce408, computer_engineering).
course_department(ce409, general_studies).
course_department(ce410, computer_engineering).
course_department(ce411, computer_engineering).
course_department(ce412, computer_engineering).
course_department(ce474, computer_engineering).

%------------------------------------------------------------------------------
% Core vs elective
%------------------------------------------------------------------------------
core_course(ce101).
core_course(ce102).
core_course(ce103).
core_course(ce104).
core_course(ce105).
core_course(ce106).
core_course(ma101).
core_course(ma102).
core_course(ph101).
core_course(en101).
core_course(ce201).
core_course(ce202).
core_course(ce203).
core_course(ce204).
core_course(ce205).
core_course(ce206).
core_course(ce207).
core_course(ma201).
core_course(ma202).
core_course(ce301).
core_course(ce302).
core_course(ce303).
core_course(ce304).
core_course(ce310).
core_course(ce406).
core_course(ce407).
core_course(ce408).
core_course(ce474).

elective(ce208, web_group).
elective(ce305, ai_group).
elective(ce306, security_group).
elective(ce307, languages_group).
elective(ce308, embedded_group).
elective(ce309, hci_group).
elective(ce311, ai_group).
elective(ce312, systems_group).
elective(ce401, languages_group).
elective(ce402, systems_group).
elective(ce403, data_group).
elective(ce404, web_group).
elective(ce405, security_group).
elective(ce409, professional_group).
elective(ce410, data_group).
elective(ce411, graphics_group).
elective(ce412, embedded_group).

%------------------------------------------------------------------------------
% Direct prerequisites: prerequisite(Course, RequiredCourse)
%------------------------------------------------------------------------------
prerequisite(ce102, ce101).
prerequisite(ce104, ce102).
prerequisite(ce105, ce101).
prerequisite(ma102, ma101).
prerequisite(ce201, ce104).
prerequisite(ce202, ce104).
prerequisite(ce203, ce105).
prerequisite(ce204, ce104).
prerequisite(ce205, ce203).
prerequisite(ce206, ce203).
prerequisite(ce207, ce202).
prerequisite(ce208, ce104).
prerequisite(ma201, ma102).
prerequisite(ma202, ma102).
prerequisite(ce301, ce201).
prerequisite(ce302, ce206).
prerequisite(ce303, ce103).
prerequisite(ce303, ce201).
prerequisite(ce304, ce207).
prerequisite(ce305, ce301).
prerequisite(ce305, ma202).
prerequisite(ce306, ce205).
prerequisite(ce306, ce302).
prerequisite(ce307, ce202).
prerequisite(ce308, ce203).
prerequisite(ce309, ce207).
prerequisite(ce310, ce207).
prerequisite(ce310, ce204).
prerequisite(ce311, ce305).
prerequisite(ce312, ce205).
prerequisite(ce312, ce302).
prerequisite(ce401, ce303).
prerequisite(ce401, ce307).
prerequisite(ce402, ce205).
prerequisite(ce402, ce302).
prerequisite(ce403, ce204).
prerequisite(ce403, ce311).
prerequisite(ce404, ce208).
prerequisite(ce404, ce302).
prerequisite(ce405, ce306).
prerequisite(ce406, ce310).
prerequisite(ce407, ce406).
prerequisite(ce410, ce204).
prerequisite(ce411, ce201).
prerequisite(ce411, ma201).
prerequisite(ce412, ce308).
prerequisite(ce412, ce302).
prerequisite(ce474, ce303).

%------------------------------------------------------------------------------
% Course–interest tags (used for career / elective matching)
%------------------------------------------------------------------------------
course_interest(ce102, software).
course_interest(ce104, software).
course_interest(ce201, software).
course_interest(ce202, software).
course_interest(ce204, data).
course_interest(ce207, software).
course_interest(ce208, web).
course_interest(ce301, software).
course_interest(ce302, networks).
course_interest(ce303, research).
course_interest(ce304, software).
course_interest(ce305, ai).
course_interest(ce306, security).
course_interest(ce307, software).
course_interest(ce308, embedded).
course_interest(ce309, web).
course_interest(ce311, ai).
course_interest(ce311, data).
course_interest(ce312, networks).
course_interest(ce401, software).
course_interest(ce402, networks).
course_interest(ce403, data).
course_interest(ce404, web).
course_interest(ce405, security).
course_interest(ce410, data).
course_interest(ce411, software).
course_interest(ce412, embedded).
course_interest(ce474, research).
course_interest(ce474, ai).

%------------------------------------------------------------------------------
% Skills developed by courses
%------------------------------------------------------------------------------
skill(programming).
skill(problem_solving).
skill(systems_thinking).
skill(data_modelling).
skill(security_awareness).
skill(research_writing).
skill(project_management).
skill(statistics).

course_skill(ce102, programming).
course_skill(ce104, programming).
course_skill(ce201, problem_solving).
course_skill(ce204, data_modelling).
course_skill(ce205, systems_thinking).
course_skill(ce207, project_management).
course_skill(ce301, problem_solving).
course_skill(ce306, security_awareness).
course_skill(ce310, project_management).
course_skill(ce311, statistics).
course_skill(ce405, security_awareness).
course_skill(ce406, research_writing).
course_skill(ce474, problem_solving).
course_skill(ma202, statistics).

%------------------------------------------------------------------------------
% Lecturers (illustrative)
%------------------------------------------------------------------------------
lecturer(ce101, 'Dr. Mensah').
lecturer(ce201, 'Dr. Boateng').
lecturer(ce204, 'Prof. Owusu').
lecturer(ce301, 'Dr. Amoah').
lecturer(ce305, 'Prof. Asante').
lecturer(ce306, 'Dr. Sarpong').
lecturer(ce310, 'Dr. Darko').
lecturer(ce405, 'Dr. Sarpong').
lecturer(ce474, 'Dr. Appiah').
lecturer(ma202, 'Dr. Adjei').

%------------------------------------------------------------------------------
% Policy thresholds and credit limits
%------------------------------------------------------------------------------
standing_threshold(first_class, 3.60).
standing_threshold(second_upper, 3.00).
standing_threshold(second_lower, 2.50).
standing_threshold(third_class, 2.00).
standing_threshold(warning, 1.50).

min_credits_per_semester(12).
max_credits_per_semester(21).
recommended_credits(good_standing, 18).
recommended_credits(warning, 15).
recommended_credits(probation, 12).

graduation_credit_minimum(120).
min_electives_required(4).
fyp_credit_minimum(90).
internship_credit_minimum(54).
honors_gpa(3.60).
good_standing_gpa(2.00).
warning_gpa(1.50).

year_level(1, 100).
year_level(2, 200).
year_level(3, 300).
year_level(4, 400).

grade_point('A', 4.00).
grade_point('B+', 3.50).
grade_point('B', 3.00).
grade_point('C+', 2.50).
grade_point('C', 2.00).
grade_point('D+', 1.50).
grade_point('D', 1.00).
grade_point('E', 0.00).
grade_point('F', 0.00).

%------------------------------------------------------------------------------
% Sample students (used by query mode, forward-inference demo, and tests)
%------------------------------------------------------------------------------
student(ama).
student(kwame).
student(akosua).
student(kofi).
student(yaw).
student(abena).
student(kojo).
student(efua).

student_year(ama, 3).
student_year(kwame, 2).
student_year(akosua, 4).
student_year(kofi, 2).
student_year(yaw, 1).
student_year(abena, 3).
student_year(kojo, 4).
student_year(efua, 2).

student_interest(ama, ai).
student_interest(ama, research).
student_interest(kwame, software).
student_interest(kwame, web).
student_interest(akosua, data).
student_interest(kofi, software).
student_interest(yaw, software).
student_interest(abena, security).
student_interest(abena, networks).
student_interest(kojo, software).
student_interest(efua, data).

declared_gpa(kofi, 1.70).
declared_gpa(yaw, 3.20).
declared_gpa(efua, 2.80).

% Ama — strong year-3 student targeting AI
passed(ama, ce101).
passed(ama, ce102).
passed(ama, ce103).
passed(ama, ce104).
passed(ama, ce105).
passed(ama, ce106).
passed(ama, ma101).
passed(ama, ma102).
passed(ama, ph101).
passed(ama, en101).
passed(ama, ce201).
passed(ama, ce202).
passed(ama, ce203).
passed(ama, ce204).
passed(ama, ce205).
passed(ama, ce206).
passed(ama, ce207).
passed(ama, ma201).
passed(ama, ma202).

grade(ama, ce101, 'A').
grade(ama, ce102, 'A').
grade(ama, ce103, 'A').
grade(ama, ce104, 'B+').
grade(ama, ce105, 'A').
grade(ama, ce201, 'A').
grade(ama, ce202, 'B+').
grade(ama, ce204, 'A').
grade(ama, ce301, 'B+').
grade(ama, ma202, 'A').

% Kwame — year-2 software-oriented, completed level 100
passed(kwame, ce101).
passed(kwame, ce102).
passed(kwame, ce103).
passed(kwame, ce104).
passed(kwame, ce105).
passed(kwame, ce106).
passed(kwame, ma101).
passed(kwame, ma102).
passed(kwame, ph101).
passed(kwame, en101).

grade(kwame, ce101, 'B').
grade(kwame, ce102, 'B+').
grade(kwame, ce104, 'B').
grade(kwame, ma101, 'C+').
grade(kwame, ma102, 'C+').

% Akosua — near-graduation year-4 student
passed(akosua, ce101).
passed(akosua, ce102).
passed(akosua, ce103).
passed(akosua, ce104).
passed(akosua, ce105).
passed(akosua, ce106).
passed(akosua, ma101).
passed(akosua, ma102).
passed(akosua, ph101).
passed(akosua, en101).
passed(akosua, ce201).
passed(akosua, ce202).
passed(akosua, ce203).
passed(akosua, ce204).
passed(akosua, ce205).
passed(akosua, ce206).
passed(akosua, ce207).
passed(akosua, ce208).
passed(akosua, ma201).
passed(akosua, ma202).
passed(akosua, ce301).
passed(akosua, ce302).
passed(akosua, ce303).
passed(akosua, ce304).
passed(akosua, ce305).
passed(akosua, ce310).
passed(akosua, ce311).
passed(akosua, ce406).
passed(akosua, ce408).
passed(akosua, ce474).

grade(akosua, ce301, 'B').
grade(akosua, ce303, 'B+').
grade(akosua, ce310, 'A').
grade(akosua, ce406, 'B+').
grade(akosua, ce474, 'A').

% Kofi — struggling year-2 student (low declared GPA)
passed(kofi, ce101).
passed(kofi, ce102).
passed(kofi, ce106).
passed(kofi, ma101).
passed(kofi, en101).

grade(kofi, ce101, 'C').
grade(kofi, ce102, 'D+').
grade(kofi, ma101, 'D').

% Yaw — new year-1 student, only CE101 so far
passed(yaw, ce101).
grade(yaw, ce101, 'B+').

% Abena — year-3 networks/security
passed(abena, ce101).
passed(abena, ce102).
passed(abena, ce103).
passed(abena, ce104).
passed(abena, ce105).
passed(abena, ce106).
passed(abena, ma101).
passed(abena, ma102).
passed(abena, ph101).
passed(abena, en101).
passed(abena, ce201).
passed(abena, ce202).
passed(abena, ce203).
passed(abena, ce204).
passed(abena, ce205).
passed(abena, ce206).
passed(abena, ce207).
passed(abena, ma201).
passed(abena, ma202).

grade(abena, ce206, 'A').
grade(abena, ce205, 'B+').
grade(abena, ce203, 'A').

% Kojo — year-4 missing some cores (cannot yet graduate)
passed(kojo, ce101).
passed(kojo, ce102).
passed(kojo, ce103).
passed(kojo, ce104).
passed(kojo, ce105).
passed(kojo, ce106).
passed(kojo, ma101).
passed(kojo, ma102).
passed(kojo, ph101).
passed(kojo, en101).
passed(kojo, ce201).
passed(kojo, ce202).
passed(kojo, ce203).
passed(kojo, ce204).
passed(kojo, ce205).
passed(kojo, ce206).
passed(kojo, ce207).
passed(kojo, ma201).
passed(kojo, ma202).
passed(kojo, ce301).
passed(kojo, ce302).
passed(kojo, ce304).
passed(kojo, ce310).
passed(kojo, ce406).

grade(kojo, ce301, 'C+').
grade(kojo, ce310, 'B').
grade(kojo, ce406, 'B').

% Efua — year-2 data-oriented, completed level 100
passed(efua, ce101).
passed(efua, ce102).
passed(efua, ce103).
passed(efua, ce104).
passed(efua, ce105).
passed(efua, ce106).
passed(efua, ma101).
passed(efua, ma102).
passed(efua, ph101).
passed(efua, en101).

grade(efua, ce103, 'A').
grade(efua, ma102, 'B+').
grade(efua, ce104, 'B').
