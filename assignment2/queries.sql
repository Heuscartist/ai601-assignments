
-- 1. Monthly Active Users by Region
SELECT 
    year, 
    month, 
    region, 
    COUNT(DISTINCT user_id) AS active_users
FROM fact_user_actions
GROUP BY year, month, region
ORDER BY year DESC, month DESC;

-- 2. Top 5 Categories by Play Count
SELECT 
    c.category, 
    COUNT(*) AS play_count
FROM fact_user_actions f
JOIN dim_content c 
ON f.content_id = c.content_id
WHERE f.action = 'play'
GROUP BY c.category
ORDER BY play_count DESC
LIMIT 5;

-- 3. Average Session Length Per Week
SET hive.auto.convert.join=false;

SELECT 
    year, 
    weekofyear(event_time) AS week, 
    AVG(length) AS avg_session_length
FROM fact_user_actions f
JOIN dim_content c 
ON f.content_id = c.content_id
GROUP BY year, weekofyear(event_time)
ORDER BY year DESC, week DESC;

-- 4. Daily Engagement Metrics
SELECT 
    year, 
    month, 
    day, 
    COUNT(DISTINCT user_id) AS daily_active_users, 
    COUNT(*) AS total_interactions
FROM fact_user_actions
GROUP BY year, month, day
ORDER BY year DESC, month DESC, day DESC;

-- 5. Most Popular Content by Play Count
SELECT 
    c.title, 
    COUNT(*) AS play_count
FROM fact_user_actions f
JOIN dim_content c 
ON f.content_id = c.content_id
WHERE f.action = 'play'
GROUP BY c.title
ORDER BY play_count DESC
LIMIT 10;

-- 6. Device Usage Distribution
SELECT 
    device, 
    COUNT(*) AS total_actions
FROM fact_user_actions
GROUP BY device
ORDER BY total_actions DESC;

