# This is a file of project-wide settings.
.projectseed <- 220131;
GOOGLE_EMAIL <- 'YOURNAME@google.com';
PROJECTID <- 'mimiciii-6203-2022';
SQLQUERY00 <- sprintf('SELECT *
                      FROM `%s.initial_characterization.mp_allpatients`
                      WHERE age >= 18',PROJECTID);
