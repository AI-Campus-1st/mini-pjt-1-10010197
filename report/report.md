## 미니 프로젝트 1 보고서

#### 1. **분석 배경과 핵심 방향** 
    - 왜 이 주제인가, 무엇을 알고 싶었는가
    생활에 밀접한 주제를 분석하고 싶어 서치하던 중 해당 기사를 발견하고 결론에 주목하였다.
    이 같은 차이는 지역 특성에 따른 것으로 분석된다. 인구가 많은 도시는 상업시설이나 민간 건물 화장실 이용 비중이 높았다. ([출처] 경기신문 (https://www.kgnews.co.kr/news/article.html?no=905844))
    인구수에 비례하지 않고 



#### 2. **데이터 소개** 
    — 사용 데이터, 출처, 기준시점, 규모, 선정 이유
    1. 공중화장실정보 https://file.localdata.go.kr/file/public_restroom_info/info
    2026.06
    공중화장실정보 데이터는 국민의 위생상의 편의와 복지증진을 위해 공중이 이용하도록 국가, 지방자치단체, 법인 또는 개인이 설치하는 화장실에 대한 데이터로 화장실명, 소재지 주소 및 남녀·장애인·어린이용 위생시설 수, 개방시간 등 기본 이용 등의 데이터를 제공합니다.
    - 공공데이터 제공 표준 기준, 지자체에서 관리하는 공중화장실정보 화장실명, 주소, 개방시간 등을 제공
    2. 행정안전부_지역별(행정동) 성별 연령별 주민등록 인구수 https://www.data.go.kr/data/15097972/fileData.do
    2026.06.30
    행정동(읍면동)별 성별 연령별 주민등록 인구에 대한 데이터로, 행정동은 주민들이 거주하는 지역을 행정 능률과 주민 편의를 위하여 구분한 행정구역 단위를 말합니다.

#### 3. **가설** 
    — 3~5개, 각각 "무엇으로 어떻게 검증할 것인가"까지
    1. 등록인구 대비 화장실 밀도가 유독 낮은 지역은, 실제로는 오피스/상업지구·관광지일 가능성이 높을 것이다.
    2. 공중화장실 수뿐만 아니라 화장실 내부의 변기 공급량도 지역별로 차이가 있을 것이다.
    3. 고령 인구가 많을수록 장애인 대변기수의 비율이 높을 것이다.
    4. 영유아 인구가 많을수록 기저귀 교환대가 많을 것이다.

#### 4. **데이터 처리 과정** 
    — 스키마 설계 근거, 전처리 판단(결측·이상치를 어떻게 왜 처리했는지), 조인 키 설계
   
    
    전처리 판단 : 두 데이터의 조인키인 주소 중 '시,도' 와 '구' 단위의 문자열을 통합하여 사용하고자 하였다. (공공화장실 데이터 - 세부 주소, 인구현황 데이터) 
                전처리 과정에서 '구'를 기준으로 '압구정' 등의 '구'가 포함된 단어나 오타, 띄어쓰기 여부 등이 처리 과정에 영향을 미쳤다. 
                또한 2026년 7월자로 인천의 구역명, 
    조인키 : 시+구로 판별




#### 5. **분석 결과** 
    — 가설별로 결과와 근거 수치 (SQL/코드 포함)
    1. 인구 대비 공중화장실 수는 지역별로 차이가 있을 것이다.
    
    
    2. 공중화장실 수뿐만 아니라 화장실 내부의 변기 공급량도 지역별로 차이가 있을 것이다.
    결과: 시군구별 인구 1만 명당 화장실 변기 수는 1.49개에서 1,022.23개까지 큰 차이를 보였으며, 지역별 화장실 변기수 밀도에 상당한 격차가 존재하는 것으로 나타났다.
    +-------------------+-------------------+-------------------+------------------+
    | min_seats_per_10k | avg_seats_per_10k | max_seats_per_10k | max_min_diff_pct |
    +-------------------+-------------------+-------------------+------------------+
    |              1.49 |            217.34 |           1022.23 |         68683.00 |
    +-------------------+-------------------+-------------------+------------------+
    ```sql

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
    ```



    3. 결과:고령 인구가 많을수록 장애인 대변기수의 비율은 비례하지 않았다.


        +------------------------+--------------+------------------------+
        | elderly_group          | region_count | avg_disabled_ratio_pct |
        +------------------------+--------------+------------------------+
        | 고령인구 비율 20% 미만    |           64 |                  13.68 |
        | 고령인구 비율 20% 이상    |          184 |                  12.42 |
        +------------------------+--------------+------------------------+

        **SQL/CODE**
        
        ``` sql
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
        ```



    4. 영유아 인구와 기저귀 교환대 수는 비례하지 않았다.
    +-----------------------+--------------+-----------------+
    | child_group           | region_count | avg_diaper_rate |
    +-----------------------+--------------+-----------------+
    | 유아인구 비율 5% 미만 |          239 |           18.72 |
    | 유아인구 비율 5% 이상 |            9 |           13.50 |
    +-----------------------+--------------+-----------------+
    ```sql
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
    ```







#### 6. **해석과 인사이트** 
    — 본인의 언어로. 예상과 달랐던 부분 포함

#### 7. **한계와 다음 단계** 
    — 데이터의 한계, 검증 못 한 것, 더 하고 싶은 것
    데이터의 한계
    공공화장실에만 국한되어 해당 지역의 인프라나 접근성등을 고려할 수 없는 점

#### 8. **(선택) 심화 확장 결과** 
    — 시각화 / 쿼리 최적화 (x)

#### 9. **AI 활용 기록**
    - cvs의 문자열 전처리 과정 중 주소의 시+군 normalize 과정 
