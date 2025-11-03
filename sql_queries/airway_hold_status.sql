SELECT 
    CaseNumber,
    PanNumber,
    DoctorName,
    CONCAT(PatientFirst, ' ', PatientLast) AS PatientName,
    CAST(ShipDate AS DATE) AS ShipDate,
    CAST(HoldDate AS DATE) AS HoldDate,
    HoldStatus,
    HoldReason,

    -- Extract the TYPE (AFU, ZFU, or EFU)
    CASE 
        WHEN HoldReason LIKE '%(AFU)%' THEN 'AFU'
        WHEN HoldReason LIKE '%(ZFU)%' THEN 'ZFU'
        WHEN HoldReason LIKE '%(EFU)%' THEN 'EFU'
        ELSE NULL
    END AS [TYPE],

    -- Extract first date after the TYPE marker and add year
    CASE 
        WHEN HoldReason LIKE '%(AFU)%' OR HoldReason LIKE '%(ZFU)%' OR HoldReason LIKE '%(EFU)%' THEN
            (SELECT TOP 1 
                CASE 
                    -- If the date with current year is in the past, use next year
                    WHEN TRY_CAST(value + '/' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE) < CAST(GETDATE() AS DATE)
                    THEN TRY_CAST(value + '/' + CAST(YEAR(GETDATE()) + 1 AS VARCHAR(4)) AS DATE)
                    -- Otherwise use current year
                    ELSE TRY_CAST(value + '/' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
                END
             FROM STRING_SPLIT(
                 SUBSTRING(
                     HoldReason, 
                     CASE 
                         WHEN HoldReason LIKE '%(AFU)%' THEN CHARINDEX('(AFU)', HoldReason) + 5
                         WHEN HoldReason LIKE '%(ZFU)%' THEN CHARINDEX('(ZFU)', HoldReason) + 5
                         WHEN HoldReason LIKE '%(EFU)%' THEN CHARINDEX('(EFU)', HoldReason) + 5
                     END,
                     LEN(HoldReason)
                 ),
                 ' '
             )
             WHERE TRY_CAST(value + '/' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE) IS NOT NULL
            )
        ELSE NULL
    END AS [FU Date]

FROM dbo.cases 
WHERE 
    [Status] = 'On Hold'
    AND LTRIM(RTRIM(PANNumber)) LIKE '7%'
    AND HoldStatus IN ('Waiting on Scan(s)', 'How to Proceed')
ORDER BY 
    [FU Date] ASC;  -- Oldest FU Date first