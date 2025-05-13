SELECT SUM(dso.AMT_CU_USD) AS payment,
  p_type.NAME              AS payment_type,
  source.NAME              AS p_source
FROM DMFASRPT.DEBT_SERV_OPERS dso
INNER JOIN LOAN_TRANCHES lt
ON dso.LO_NO   = lt.LOAN_ID
AND dso.TRA_NO = lt.TRANCHE_NO
INNER JOIN DMFASRPT.CD_NMS p_type
ON dso.CG_TRNS_TYP = p_type.CG_NO
AND p_type.CD_CODE = dso.CD_TRNS_TYP
INNER JOIN DMFASRPT.CD_NMS source
ON dso.CG_MEDIUM   = source.CG_NO
AND source.CD_CODE = dso.CD_MEDIUM
WHERE dso.D_SCH    > '01-JAN-2023'
AND lt.DURATION   IN ('MEDIUM/LONG-TERM', 'SHORT-TERM')
AND p_type.LA_ID   = '1'
AND source.LA_ID   = '1'
AND lt.STATUS      = 'ACTIVE'
AND lt.DEBT_SOURCE = 'EXTERNAL'
GROUP BY p_type.NAME,
  source.NAME
ORDER BY
source.NAME
