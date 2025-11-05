SELECT
    CaseNumber,
    PanNumber,
    DoctorName,
    CONCAT(PatientFirst, ' ', PatientLast) AS PatientName,
    CAST(ShipDate AS DATE) AS ShipDate,
    CAST(HoldDate AS DATE) AS HoldDate,
    HoldStatus,
    HoldReason,
    CASE
        WHEN HoldReason LIKE '%(AFU)%' THEN 'AFU'
        WHEN HoldReason LIKE '%(ZFU)%' THEN 'ZFU'
        WHEN HoldReason LIKE '%(EFU)%' THEN 'EFU'
        ELSE NULL
    END AS [TYPE],

    -- FU Date with 6-month sliding window
    CASE
        WHEN HoldReason LIKE '%(AFU)%' OR HoldReason LIKE '%(ZFU)%' OR HoldReason LIKE '%(EFU)%' THEN
            (
                SELECT TOP 1 candidate_date
                FROM (
                    SELECT 
                        TRY_CAST(mmdd + '/' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE) AS date_this_year,
                        TRY_CAST(mmdd + '/' + CAST(YEAR(GETDATE()) + 1 AS VARCHAR(4)) AS DATE) AS date_next_year
                    FROM (
                        SELECT value AS mmdd
                        FROM STRING_SPLIT(
                            SUBSTRING(
                                HoldReason,
                                CHARINDEX('(' + 
                                    CASE
                                        WHEN HoldReason LIKE '%(AFU)%' THEN 'AFU'
                                        WHEN HoldReason LIKE '%(ZFU)%' THEN 'ZFU'
                                        WHEN HoldReason LIKE '%(EFU)%' THEN 'EFU'
                                    END + ')', HoldReason) + 5,
                                8000
                            ),
                            ' '
                        )
                        WHERE TRY_CAST(value + '/' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE) IS NOT NULL
                    ) AS dates
                ) AS candidates
                CROSS APPLY (
                    VALUES 
                        (date_this_year, ABS(DATEDIFF(DAY, date_this_year, GETDATE()))),
                        (date_next_year,  ABS(DATEDIFF(DAY, date_next_year,  GETDATE())))
                ) AS v(candidate_date, days_from_today)
                WHERE candidate_date IS NOT NULL
                  AND (
                    candidate_date BETWEEN DATEADD(MONTH, -3, CAST(GETDATE() AS DATE))
                                       AND DATEADD(MONTH,  3, CAST(GETDATE() AS DATE))
                    OR candidate_date > GETDATE()  -- allow future FU dates
                  )
                ORDER BY days_from_today
            )
        ELSE NULL
    END AS [FU Date]

FROM dbo.cases
WHERE
    [Status] = 'On Hold'
    AND LTRIM(RTRIM(PANNumber)) LIKE '7%'
    AND HoldStatus IN ('Waiting on Scan(s)', 'How to Proceed')
ORDER BY [FU Date] ASC;