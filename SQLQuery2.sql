Select *
From CricketProject .dbo.Worldcup


--Looking at percentage of toss winners going on to win the match
SELECT 
    Venue, 
    _1st_Team, 
    _2nd_Team, 
    Toss_Winning, 
    Toss_Decision, 
    Winners,
    CASE 
        WHEN Toss_Winning = Winners THEN 1
        ELSE 0
    END AS toss_equals_match_winner
FROM 
    CricketProject.dbo.Worldcup
WHERE 
    Winners != 'rain';  


WITH counts AS (
    SELECT 
        COUNT(*) AS total_matches_with_result,
        SUM(CASE 
                WHEN Toss_Winning = Winners THEN 1
                ELSE 0
            END) AS toss_winner_wins
    FROM 
        CricketProject.dbo.Worldcup
	WHERE 
        Winners != 'rain'  
)
SELECT 
    toss_winner_wins,
    total_matches_with_result,
    (toss_winner_wins * 100.0 / total_matches_with_result) AS toss_winner_win_percentage
FROM 
    counts;





-- Looking at Toss winners choosing batting vs choosing fielding and winning the match percentage

WITH decision_wins AS (
    SELECT 
        Toss_Decision,
        COUNT(*) AS total_decision_matches,
        SUM(CASE 
                WHEN Toss_Winning = Winners THEN 1
                ELSE 0
            END) AS decision_wins
    FROM 
        CricketProject.dbo.Worldcup
	WHERE
        Winners != 'Rain'  -- Exclude rows where the winner is 'rain'
    GROUP BY 
        Toss_Decision
),
percentages AS (
    SELECT
        Toss_Decision,
        total_decision_matches,
        decision_wins,
        (decision_wins * 100.0 / total_decision_matches) AS win_percentage
    FROM
        decision_wins
)
SELECT
    Toss_Decision,
    total_decision_matches,
    decision_wins,
    win_percentage
FROM
    percentages;



--Look at how different venues affected run score
WITH inning_runs AS (
    SELECT
        Venue,
        AVG(CASE WHEN Inning = 1 THEN Runs ELSE NULL END) AS avg_runs_first_inning,
        AVG(CASE WHEN Inning = 2 THEN Runs ELSE NULL END) AS avg_runs_second_inning
    FROM (
        SELECT
            Venue,
            1 AS Inning,
            First_Innings_Score AS Runs
        FROM
            CricketProject.dbo.Worldcup
        WHERE
            First_Innings_Score IS NOT NULL
        
        UNION ALL

        SELECT
            Venue,
            2 AS Inning,
            Second_Innings_Score AS Runs
        FROM
            CricketProject.dbo.Worldcup
        WHERE
            Second_Innings_Score IS NOT NULL
    ) AS runs_per_inning
    GROUP BY
        Venue
)
SELECT
    Venue,
    avg_runs_first_inning,
    avg_runs_second_inning
FROM
    inning_runs;


--Looking at if a score was successfully chased or not
WITH chase_results AS (
    SELECT
        _1st_Team AS Batting_Team,
        _2nd_Team AS Bowling_Team,
        First_Innings_Score AS Target,
        First_Innings_Score AS Score_Chased,
        CASE
            WHEN Second_Innings_Score >= First_Innings_Score THEN 'Successful Chase'
            ELSE 'Successful Defense'
        END AS Match_Result
    FROM
        CricketProject.dbo.Worldcup
    WHERE
        Winners != 'rain'  -- Exclude rows where the result was 'rain'
)
SELECT
    Match_Result,
    COUNT(*) AS Number_of_Matches
FROM
    chase_results
GROUP BY
    Match_Result;


--Average wickets per innings
WITH innings_wickets AS (
    SELECT
        Venue,
        _1st_Team AS Team,
        Fall_of_wickets_First_Innings AS Wickets
    FROM
        CricketProject.dbo.Worldcup
    WHERE
        Fall_of_wickets_First_Innings IS NOT NULL

    UNION ALL

    SELECT
        Venue,
        _2nd_Team AS Team,
        Fall_of_wickets_Second_Innings AS Wickets
    FROM
        CricketProject.dbo.Worldcup
    WHERE
        Fall_of_wickets_Second_Innings IS NOT NULL
)
SELECT
    Venue,
    AVG(Wickets) AS Average_Wickets
FROM
    innings_wickets
GROUP BY
    Venue;
