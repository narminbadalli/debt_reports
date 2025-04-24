SELECT
     loan.LOAN_ID,
     loan.TRANCHE_CURRENCY,
     TO_CHAR(proj.D_SCH, 'YYYY') AS YEAR,
     sum(case when name.NAME='PRINCIPAL REPAID' then proj.AMT else 0 END) AS PRINCIPAL,
     sum(case when name.NAME='INTEREST PAID' then proj.AMT else 0 END) AS INTEREST
FROM
     DMFASRPT.SCH_DEBT_SERV_PMTS proj INNER JOIN DMFASRPT.LOAN_TRANCHES loan ON proj.LO_NO = loan.LOAN_ID
     AND proj.TRA_NO = loan.TRANCHE_NO
     INNER JOIN DMFASRPT.CD_NMS name ON proj.CD_TRNS_TYP = name.CD_CODE
     AND proj.CG_TRNS_TYP = name.CG_NO
WHERE
     name.LA_ID = '1'
    AND loan.STATUS = 'ACTIVE'
    AND loan.DEBT_SOURCE = 'EXTERNAL'
GROUP BY
     loan.LOAN_ID,
     loan.TRANCHE_CURRENCY,
     proj.D_SCH, 'YYYY'
HAVING
     TO_CHAR(proj.D_SCH, 'YYYY') >= '2025'
ORDER BY
     proj.D_SCH ASC
