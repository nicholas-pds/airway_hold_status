SELECT 
    CaseNumber,
    PanNumber,
    DoctorName,
    CONCAT(PatientFirst, ' ', PatientLast) AS PatientName,
    CAST(ShipDate AS DATE) AS ShipDate,
    CAST(HoldDate AS DATE) AS HoldDate,
    HoldStatus,
    HoldReason,

    -- Extract first date after "(FU)" in HoldReason
    CASE 
        WHEN HoldReason LIKE '%(FU)%' THEN
            TRY_CAST(
                LTRIM(
                    SUBSTRING(
                        HoldReason,
                        CHARINDEX('(FU)', HoldReason) + 4,
                        20
                    )
                ) AS DATE
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
