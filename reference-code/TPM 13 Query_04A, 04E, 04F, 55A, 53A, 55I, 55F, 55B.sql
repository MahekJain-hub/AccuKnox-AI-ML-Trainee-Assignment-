SELECT
    TRIM(d.accounting_code) AS accounting_code,
    COALESCE(TRIM(d.product_type), TRIM(v.sgsart)) AS product_type,
    TRIM(txt.LTXKURZ) AS text,
    flow.position_curr AS position_currency,
    COALESCE(NULLIF(TRIM(d.security_id), ''), NULLIF(TRIM(v.ranl), '')) AS id_number,
    TRIM(anla.xalkz) AS short_name,
    TRIM(anla.xallb) AS long_name,
    LEFT(TRIM(anla.xallb), 40) AS long_name_part1,
    TRIM(v.zusr03) AS loan_reg_no_rbi,
    COALESCE(NULLIF(TRIM(d.security_account), ''), NULLIF(TRIM(v.rldepo), ''), 
             NULLIF(TRIM(cp.security_account), '')) AS securities_account,
    TRIM(d.deal_number) AS transaction,
    TRIM(d.portfolio) AS portfolio_position,
    flow.flownumber AS transaction_flow,
    TRIM(td.xldepo) AS securities_account_id,
    TRIM(flow.flowtype) AS transaction_type,
    CASE TRIM(trans.booking_state)
        WHEN '2' THEN 'F'
        WHEN '1' THEN 'S'
        ELSE trans.booking_state
    END AS posting_status,
    CASE
        WHEN trans.trldate IS NULL OR trans.trldate IN ('', '00000000') THEN NULL
        ELSE TO_DATE(trans.trldate, 'yyyyMMdd')
    END AS treasury_ledger_date,
    TRIM(flow.flowtype) AS update_type_1,
    COALESCE(TRIM(flowtext.dis_flowtypetext), TRIM(flow.flowtype)) AS update_type_2,
    flow.units AS units,
    CASE
        WHEN TRIM(flow.position_curr) = 'JPY' THEN flow.position_amt * 100
        ELSE flow.position_amt
    END AS amount_position_curr,
    flow.valuation_amt AS amount_valuation_curr,
    flow.valuation_curr AS valuation_currency,
    CASE TRIM(trans.bustranscat)
        WHEN '2400' THEN 'Accrual/deferral'
        WHEN '2401' THEN 'Accrual/deferral reset'
        WHEN '8000' THEN 'Valuation'
        WHEN '8001' THEN 'Reset valuation'
        WHEN '1011' THEN 'Interest'
        WHEN '2020' THEN 'Charge / Tax'
        WHEN '9000' THEN 'Derived business transaction'
        WHEN '2010' THEN 'Securities account transfer'
        WHEN '1016' THEN 'Installment Repayment'
        WHEN '2004' THEN 'Issue: Redemption'
        WHEN '1010' THEN 'Repayment to be paid (liability)'
        WHEN '2003' THEN 'Issue: Placement'
        WHEN '1009' THEN 'Payment / Borrowing (liability)'
        WHEN '1014' THEN 'Unscheduled Repayment (Liability)'
        ELSE TRIM(trans.bustranscat)
    END AS bustrans_cat_name,
    CASE
        WHEN flow.calculation_date IS NULL OR flow.calculation_date IN ('', '00000000') THEN NULL
        ELSE TO_DATE(flow.calculation_date, 'yyyyMMdd')
    END AS calculation_date,
    CASE
        WHEN flow.due_date IS NULL OR flow.due_date IN ('', '00000000') THEN NULL
        ELSE TO_DATE(flow.due_date, 'yyyyMMdd')
    END AS due_date,
    CASE
        WHEN flow.calc_begin IS NULL OR flow.calc_begin IN ('', '00000000') THEN NULL
        ELSE TO_DATE(flow.calc_begin, 'yyyyMMdd')
    END AS calculation_from,
    TRIM(v.rportb) AS portfolio_name,
    CASE
        WHEN flow.calc_end IS NULL OR flow.calc_end IN ('', '00000000') THEN NULL
        ELSE TO_DATE(flow.calc_end, 'yyyyMMdd')
    END AS calculation_to,
    po.atage AS number_of_days,
    TRIM(po.sbasis) AS base_days_method,
    po.bbasis AS base_amount,
    TRIM(po.szbmeth) AS int_calc_method,
    po.abastage AS no_of_days_in_period,
    TRIM(po.skalidwt) AS interest_calendar,
    CASE
        WHEN po.pkond IS NULL THEN NULL
        WHEN po.pkond = 0 THEN 'Floating rate'
        ELSE 'Fixed rate'
    END AS floating_fixed_rate_1,
    po_rate.rate_type AS floating_fixed_rate_2
FROM `rilenm_prd`.`fca_silver`.`sap_rp2_trlt_flow_view` flow
    LEFT JOIN `rilenm_prd`.`fca_silver`.`sap_rp2_trlt_transaction_view` trans
        ON flow.transaction_oid = trans.os_guid AND flow.mandt = trans.mandt
    INNER JOIN `rilenm_prd`.`fca_silver`.`sap_rp2_trlt_position_view` pos
        ON flow.position_oid = pos.os_guid AND flow.mandt = pos.mandt
    INNER JOIN `rilenm_prd`.`fca_silver`.`sap_rp2_dift_pos_ident` d
        ON pos.identifier_oid = d.os_guid AND pos.mandt = d.mandt
        AND d.company_code = 'RIL' 
        AND d.product_type IN ('04A', '04E', '04F', '55A', '53A', '55I', '55F', '55B', '55J') 
        AND d.context = 'TRL'
    LEFT JOIN `rilenm_prd`.`fca_silver`.`sap_rp2_trdc_dflowtype_t` flowtext
        ON TRIM(flow.flowtype) = TRIM(flowtext.dis_flowtype) 
        AND flowtext.mandt = '610' AND flowtext.spras = 'E'
    LEFT JOIN `rilenm_prd`.`log_silver`.`sap_rp2_tzpat` txt
        ON TRIM(d.product_type) = TRIM(txt.GSART) 
        AND txt.MANDT = '610' AND txt.SPRAS = 'E'
    -- Modified vtbfha join to handle both security_id and deal_number
    LEFT JOIN (
        SELECT * FROM `rilenm_prd`.`fca_silver`.`sap_rp2_vtbfha_view`
        WHERE mandt = '610' AND bukrs = 'RIL'
        QUALIFY ROW_NUMBER() OVER (PARTITION BY TRIM(ranl), TRIM(bukrs) ORDER BY rfha) = 1
    ) v ON (
        -- Try security_id first (for old product types)
        (TRIM(d.security_id) IS NOT NULL AND TRIM(d.security_id) != '' 
         AND TRIM(d.security_id) = TRIM(v.ranl))
        OR
        -- Fall back to deal_number (for new product types)
        (TRIM(d.deal_number) IS NOT NULL AND TRIM(d.deal_number) != '' 
         AND TRIM(d.deal_number) = TRIM(v.rfha))
    ) AND TRIM(d.company_code) = TRIM(v.bukrs)
    LEFT JOIN `rilenm_prd`.`fca_silver`.`sap_rp2_vwpanla` anla
        ON TRIM(v.ranl) = TRIM(anla.ranl) AND anla.mandt = '610'
    LEFT JOIN (
        SELECT * FROM `rilenm_prd`.`fca_silver`.`sap_rp2_vtbfhapo_view` WHERE mandt = '610'
        QUALIFY ROW_NUMBER() OVER (PARTITION BY TRIM(rfha), TRIM(bukrs), TRIM(rfhazu) 
                                   ORDER BY dcrdat DESC, tcrtim DESC) = 1
    ) po ON TRIM(v.rfha) = TRIM(po.rfha) AND TRIM(v.bukrs) = TRIM(po.bukrs) 
         AND TRIM(po.rfhazu) = LPAD(CAST(flow.flownumber AS STRING), 5, '0')
    LEFT JOIN (
        SELECT rfha, bukrs,
            CASE WHEN TRIM(skoart) IN ('1200','1202','1203','1208','1209','1212','1213') 
                 THEN 'Fixed rate'
                 WHEN TRIM(skoart) IN ('1120','1121','1122','1123','1124','1130','1131','1140') 
                 THEN 'Floating rate'
                 ELSE 'Other' END AS rate_type
        FROM `rilenm_prd`.`fca_silver`.`sap_rp2_vtbfhapo_view` 
        WHERE mandt = '610' AND TRIM(skoart) != '0000'
        QUALIFY ROW_NUMBER() OVER (PARTITION BY rfha, bukrs ORDER BY rfhazu) = 1
    ) po_rate ON TRIM(v.rfha) = TRIM(po_rate.rfha) AND TRIM(v.bukrs) = TRIM(po_rate.bukrs)
    LEFT JOIN `rilenm_prd`.`log_silver`.`sap_rp2_twd01_view` td
        ON TRIM(d.security_account) = TRIM(td.rldepo) 
        AND TRIM(d.company_code) = TRIM(td.bukrs) AND td.mandt = '610'
    LEFT JOIN `rilenm_prd`.`fca_silver`.`sap_rp2_trst_claspos_view` cp
        ON TRIM(d.security_id) = TRIM(cp.security_id) 
        AND TRIM(d.company_code) = TRIM(cp.company_code) 
        AND TRIM(d.security_account) = TRIM(cp.security_account)
    LEFT JOIN (
        SELECT * FROM `rilenm_prd`.`fca_silver`.`sap_rp2_trst_clasflo_view`
        QUALIFY ROW_NUMBER() OVER (PARTITION BY TRIM(claspos_guid), TRIM(trd_bustransid), trd_flownr 
                                   ORDER BY position_date DESC) = 1
    ) cf ON TRIM(cp.os_guid) = TRIM(cf.claspos_guid) 
         AND TRIM(trans.bustransid) = TRIM(cf.trd_bustransid) 
         AND CAST(cf.trd_flownr AS STRING) = CAST(flow.flownumber AS STRING)
WHERE flow.mandt = '610'
  AND (trans.trldate IS NOT NULL OR flow.trldate IS NOT NULL)
  AND ((trans.trldate != '00000000' AND trans.trldate IS NOT NULL) 
       OR (flow.trldate != '00000000' AND flow.trldate IS NOT NULL))
  AND (COALESCE(TO_DATE(trans.trldate, 'yyyyMMdd'), TO_DATE(flow.trldate, 'yyyyMMdd')) 
       BETWEEN [START_DATE] AND [END_DATE])
  AND trans.bustransstate = 'U'
  AND TRIM(trans.booking_state) IN ('1', '2')
  AND (
      (TRIM(trans.bustranscat) = '1011' AND flow.flowtype IN ('SAM7000', 'SAM7002', 'MM1200-'))
      OR
      (TRIM(trans.bustranscat) = '2020')
      OR
      (TRIM(trans.bustranscat) NOT IN ('1011', '2020') AND trans.bustranscat IS NOT NULL)
  )
ORDER BY COALESCE(TO_DATE(trans.trldate, 'yyyyMMdd'), TO_DATE(flow.trldate, 'yyyyMMdd')), 
         TRIM(d.deal_number), flow.flownumber
