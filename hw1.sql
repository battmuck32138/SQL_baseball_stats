DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era)
 AS
 SELECT MAX(era)
 FROM pitching
;


-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people AS p
  WHERE p.weight > 300
;


-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people AS p
  WHERE namefirst LIKE '% %'
;


-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count
  FROM people AS p
  GROUP BY P.birthyear
  ORDER BY p.birthyear ASC
;


-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count
FROM people AS p
GROUP BY P.birthyear
HAVING AVG(height) > 70
ORDER BY p.birthyear ASC
;


-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, h.yearid
  FROM people AS p INNER JOIN halloffame AS h
  ON p.playerid = h.playerid
  Where h.inducted = 'Y'
  ORDER BY h.yearid DESC
;


-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, c.schoolid, h.yearid
  --join all relevent tables together first
  FROM people AS p
  INNER JOIN halloffame AS h
    ON p.playerid = h.playerid
  INNER JOIN collegeplaying AS c
    ON p.playerid = c.playerid
  INNER JOIN schools as s
    ON c.schoolid = s.schoolid
  -- filter and sort after all the relevent tables have been joined
  WHERE s.schoolstate = 'CA' AND h.inducted = 'Y'
  ORDER BY h.yearid DESC, s.schoolid, p.playerid ASC
;


-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, c.schoolid
  FROM people AS p
  INNER JOIN halloffame AS h
    ON p.playerid = h.playerid
  LEFT OUTER JOIN collegeplaying AS c
    ON p.playerid = c.playerid
  WHERE h.inducted = 'Y'
  ORDER BY p.playerid DESC, c.schoolid ASC
;


-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
SELECT p.playerid, p.namefirst, p.namelast, b.yearid,
    CAST(2*b.h2b + 3*b.h3b + 4*b.hr + b.h - b.h2b - b.h3b - b.hr AS FLOAT)
    / CAST(b.ab AS FLOAT)  AS slg
  FROM people AS P
  INNER JOIN batting as b
    ON p.playerid = b.playerid
  WHERE b.ab > 50
  ORDER BY slg DESC, b.yearid, p.playerid ASC
  LIMIT 10
;


-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
SELECT p.playerid, p.namefirst, p.namelast,
    CAST(SUM(2*b.h2b + 3*b.h3b + 4*b.hr + b.h - b.h2b - b.h3b - b.hr) AS FLOAT)
    / CAST(SUM(b.ab) as FLOAT) as lslg
  FROM people as p
  INNER JOIN batting as b
  ON p.playerid = b.playerid
  -- get lifetime summs by grouping on the player and aggregating with sum func
  GROUP BY p.playerid
  HAVING(SUM(b.ab) > 50)  --50 at bats for entire lifetime!
  ORDER BY lslg DESC, playerid ASC
  LIMIT 10
;


-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
--start with a sub-query for all lslg's
WITH tmp AS (
  SELECT p.playerid, p.namefirst, p.namelast,
      CAST(SUM(2*b.h2b + 3*b.h3b + 4*b.hr + b.h - b.h2b - b.h3b - b.hr) AS FLOAT)
      / CAST(SUM(b.ab) as FLOAT) as lslg
    FROM people as p
    INNER JOIN batting as b on b.playerid = p.playerid
    GROUP BY p.playerid
    HAVING(SUM(b.ab) > 50)
  )

-- now I can use my sub-query to answer the question!
SELECT namefirst, namelast, lslg
FROM tmp
WHERE lslg > (SELECT lslg FROM tmp WHERE playerid = 'mayswi01') --number
;


-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
SELECT yearid, MIN(s.salary), MAX(s.salary), AVG(s.salary), stddev(s.salary)
  FROM salaries AS s
  GROUP BY s.yearid
  ORDER BY s.yearid ASC
;


-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS



;


-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  --get the stats that I want: table t
  WITH
  t AS (
    SELECT s.yearid, MIN(s.salary), MAX(s.salary), AVG(s.salary)
    FROM salaries AS s
    GROUP BY s.yearid
  ),  -- don't forget the comma

  -- t1.yearsid = yearsid + 1
  t1 AS (
      SELECT s.yearid + 1 as yearid, MIN(s.salary), MAX(s.salary), AVG(s.salary)
      FROM salaries AS s
      GROUP BY yearid
     )

     -- join t, t1 and I have #s for both yearid and yearid + 1 to work with
     SELECT t.yearid, t.min - t1.min AS mindiff,
                      t.max - t1.max AS maxdiff,
                      t.avg - t1.avg AS avgdiff
     FROM t1 INNER JOIN t ON t1.yearid = t.yearid
     ORDER BY t1.yearid ASC
;


-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
WITH t AS (
  SELECT s.yearid, MAX(s.salary)
  FROM salaries AS s
  WHERE s.yearid = 2000 OR s.yearid = 2001
  GROUP BY s.yearid
)

SELECT s.playerid, p.namefirst, p.namelast, s.salary, s.yearid
FROM people AS p
      INNER JOIN salaries AS s
        ON p.playerid = s.playerid
      INNER JOIN t
        ON s.salary = t.max AND s.yearid = t.yearid
;


-- Question 4v
CREATE VIEW q4v(team, diffAvg)
AS
SELECT a.teamid as team, MAX(salary) - MIN(salary) AS diffAvg
  FROM allstarfull AS a
  NATURAL JOIN salaries AS s
  WHERE a.yearid = 2016
  GROUP BY a.teamid
  ORDER BY a.teamid
;
