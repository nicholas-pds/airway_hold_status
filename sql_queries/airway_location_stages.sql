/* Product Categories */
WITH ProductCategories AS (
    SELECT
        ca.CaseID,
        ca.CaseNumber,
        pr.Category
    FROM dbo.Cases AS ca
        LEFT JOIN dbo.CaseProducts AS cp
            ON ca.CaseID = cp.CaseID
        LEFT JOIN dbo.Products AS pr
            ON cp.ProductID = pr.ProductID
    WHERE
        ca.Status IN ('In Production', 'On Hold')   -- Added On Hold
        -- ca.Status IN ('On Hold')
        AND pr.Category IS NOT NULL
        AND pr.Category IN (
            'Metal', 'Clear', 'Wire Bending', 'Marpe',
            'Hybrid', 'E2 Expanders', 'Lab to Lab', 'Airway'
        )
),

/* Case Location – One Row Per CaseNumber (Unique) */
RankedCases AS (
    SELECT
        ca.CaseNumber AS [Case Number],
        ca.PanNumber AS [Pan Number],
        ct.Task AS [Last Task Completed],
        ct.CompleteDate AS [Last Scan Time],
        pc.Category AS [Category],
        CAST(ca.ShipDate AS DATE) AS [Ship Date],
        ca.LastLocationID,
        cll.[Description] AS [Last Location],
        ca.[Status],
        CAST(ca.DueDate AS DATE) AS [Due Date],
        ca.LocalDelivery,
        ROW_NUMBER() OVER (
            PARTITION BY ca.CaseNumber
            ORDER BY
                CASE WHEN ct.CompleteDate IS NULL THEN 1 ELSE 0 END,
                ct.CompleteDate DESC,
                ct.CaseID DESC
        ) AS rn
    FROM dbo.Cases AS ca
        INNER JOIN dbo.CaseTasks AS ct
            ON ca.CaseID = ct.CaseID
        LEFT JOIN dbo.CaseLogLocations AS cll
            ON ca.LastLocationID = cll.ID
        LEFT JOIN ProductCategories AS pc
            ON ca.CaseID = pc.CaseID
    WHERE
        ca.Status IN ('In Production', 'On Hold')   -- Added On Hold
        -- WHERE ca.Status IN ('On Hold')
)

SELECT
    [Case Number],
    [Pan Number],
    [Ship Date],
    [Status],
    [Category],
    [Last Location],
    [Last Task Completed],
    [Last Scan Time],
    [LocalDelivery],
    [Due Date]
FROM RankedCases
WHERE rn = 1
ORDER BY [Case Number];