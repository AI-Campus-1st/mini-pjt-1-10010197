USE toilet_db;

-- 기본 데이터 확인
SELECT *
FROM tb_toilet
LIMIT 10;

-- 지역별 화장실 수
SELECT
    sido,
    sigungu,
    COUNT(*) AS toilet_count
FROM tb_toilet
GROUP BY sido, sigungu;

-- JOIN 전
SELECT COUNT(*) AS before_join
FROM tb_toilet;

-- INNER JOIN 후
SELECT COUNT(*) AS after_join
FROM tb_toilet t
INNER JOIN tb_population p
    ON t.sido = p.sido
   AND t.sigungu = p.sigungu;

-- JOIN 결과 매칭/비매칭 확인
SELECT
    COUNT(*) AS total_toilet,
    COUNT(p.sigungu) AS matched,
    COUNT(*) - COUNT(p.sigungu) AS unmatched
FROM tb_toilet t
LEFT JOIN tb_population p
    ON t.sido = p.sido
   AND t.sigungu = p.sigungu;

---------------------------------
-- 메인 가설: 인구 대비 화장실 변기수 밀도가 지역별로 차이가 있는가?(단위: 개수/10000명)

SELECT
    t.sido,
    t.sigungu,
    COUNT(*) AS toilet_count,
    SUM(t.total_seats) AS total_seats,
    p.total_pop,
    ROUND(SUM(t.total_seats) * 10000.0 / p.total_pop, 2) AS seats_per_10k
FROM tb_toilet t
JOIN tb_population p ON t.sido = p.sido AND t.sigungu = p.sigungu
GROUP BY t.sido, t.sigungu, p.total_pop
ORDER BY seats_per_10k DESC;


----------------------------------------------
-- 하위 가설 1: 고령인구 비율이 높은 지역일수록 장애인용 변기 비율도 높은가?
SELECT

    t.sido,
    t.sigungu,
    COUNT(*) AS toilet_count,
    SUM(t.disabled_seats) AS disabled_seats,
    ROUND(p.elderly_pop * 100.0 / p.total_pop, 1) AS elderly_ratio_pct,
    ROUND(SUM(t.disabled_seats) * 10000.0 / p.total_pop, 2) AS disabled_seats_per_10k
FROM tb_toilet t
JOIN tb_population p ON t.sido = p.sido AND t.sigungu = p.sigungu
GROUP BY t.sido, t.sigungu, p.elderly_pop, p.total_pop
HAVING COUNT(*) >= 10
ORDER BY elderly_ratio_pct DESC;
------------------------------------------------
-- 하위 가설 2: 유아인구 비율이 높은 지역일수록 기저귀교환대 설치율도 높은가?
SELECT
    t.sido,
    t.sigungu,
    COUNT(*) AS toilet_count,
    ROUND(AVG(t.has_diaper_table) * 100, 1) AS diaper_rate_pct,
    ROUND(p.child_pop * 100.0 / p.total_pop, 1) AS child_ratio_pct
FROM tb_toilet t
JOIN tb_population p ON t.sido = p.sido AND t.sigungu = p.sigungu
GROUP BY t.sido, t.sigungu, p.child_pop, p.total_pop
HAVING COUNT(*) >= 10
ORDER BY child_ratio_pct DESC;
