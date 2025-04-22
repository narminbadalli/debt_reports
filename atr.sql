SELECT
  ROUND(
    SUM(weighted_days) / NULLIF(SUM(weighted_amount), 0)/365,
    2
  ) AS avg_refixing_days_total
FROM (
  -- Sabit faizli kreditlər üçün
  SELECT
    SUM((pmt.d_sch - TRUNC(TO_DATE('01-JAN-2024', 'DD-MON-YYYY'))) * (pmt.amt * fx.local_base_rate)) AS weighted_days,
    SUM(pmt.amt * fx.local_base_rate) AS weighted_amount
  FROM
    dmfasrpt.sch_debt_serv_pmts pmt
  JOIN loan_tranches loan
    ON pmt.lo_no = loan.loan_id AND pmt.tra_no = loan.tranche_no
  LEFT JOIN (
    SELECT r1.cu_code, r1.d_eff, r1.local_base_rate
    FROM dmfasrpt.exch_rates r1
    WHERE (r1.cu_code, r1.d_eff) IN (
      SELECT cu_code, MAX(d_eff)
      FROM dmfasrpt.exch_rates
      GROUP BY cu_code, d_eff
    )
  ) fx
    ON fx.cu_code = loan.tranche_currency
    AND fx.d_eff = (
      SELECT MAX(r2.d_eff)
      FROM dmfasrpt.exch_rates r2
      WHERE r2.cu_code = loan.tranche_currency
      AND r2.d_eff <= pmt.d_sch
    )
  WHERE
    loan.status = 'ACTIVE'
    AND loan.debt_source = 'EXTERNAL'
    AND loan.public_guarantee = 'NON-GUARANTEED'
    AND loan.interest_classification = 'FIXED RATE(S)'
    AND pmt.cd_trns_typ = '11'
    AND pmt.d_pmt_sch >= TO_DATE('01-JAN-2024', 'DD-MON-YYYY')

  UNION ALL

  -- Dəyişkən faizli kreditlər üçün
  SELECT
    (MIN(pmt.d_sch) - TRUNC(TO_DATE('01-JAN-2024', 'DD-MON-YYYY'))) * SUM(pmt.amt_unpaid * fx.local_base_rate) AS weighted_days,
    SUM(pmt.amt_unpaid * fx.local_base_rate) AS weighted_amount
  FROM
    dmfasrpt.sch_debt_serv_pmts pmt
  JOIN loan_tranches loan
    ON pmt.lo_no = loan.loan_id AND pmt.tra_no = loan.tranche_no
  LEFT JOIN (
    SELECT r1.cu_code, r1.d_eff, r1.local_base_rate
    FROM dmfasrpt.exch_rates r1
    WHERE (r1.cu_code, r1.d_eff) IN (
      SELECT cu_code, MAX(d_eff)
      FROM dmfasrpt.exch_rates
      GROUP BY cu_code, d_eff
    )
  ) fx
    ON fx.cu_code = loan.tranche_currency
    AND fx.d_eff = (
      SELECT MAX(r2.d_eff)
      FROM dmfasrpt.exch_rates r2
      WHERE r2.cu_code = loan.tranche_currency
      AND r2.d_eff <= pmt.d_sch
    )
  WHERE
    loan.status = 'ACTIVE'
    AND loan.debt_source = 'EXTERNAL'
    AND loan.public_guarantee = 'NON-GUARANTEED'
    AND loan.interest_classification = 'VARIABLE RATE(S)'
    AND pmt.cd_trns_typ = '11'
    AND pmt.d_sch >= TRUNC(TO_DATE('01-JAN-2024', 'DD-MON-YYYY'))
  GROUP BY loan.loan_id, loan.tranche_no
);
