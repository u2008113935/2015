
DECLARE @x_cCodUsuAna CHAR(6) = '',
		@x_dFecIniPro DATETIME = '2015.04.01',
		@x_dFecFin DATETIME = '2015.04.30'

SELECT      A.cCodOficin, A.cCodUsuAna, A.cCodCtaCre, A.cCodtipMon, A.cCodConven,
            B.cCodCliente, A.cCodTipCre, dFecDesCre, nMonCapDes, cIndNueRep, cIndNueRepCre = cIndNueRep
      INTO #CurNueRep
      FROM KPYMCreConven A WITH (NOLOCK)
            INNER JOIN GENMCreCli B WITH (NOLOCK)
                  ON A.cCodCtaCre = B.cCodCtaCre
      WHERE DFECDESCRE BETWEEN @x_dFecIniPro AND @x_dFecFin

UPDATE #CurNueRep
      SET cIndNueRep = 'N'
      WHERE cIndNueRep = 'P'
 


SELECT B.cCodCliente, cNumCreVig = COUNT(*)
      INTO #curCliNueExp
      FROM #CurNueRep A
            INNER JOIN GENMCrecli B WITH (NOLOCK)
                  ON A.cCodCliente = B.cCodCliente
            INNER JOIN KPYMCRECONVEN C WITH (NOLOCK)
                  ON B.cCodCtaCre = C.cCodCtaCre
                        AND cEstCreCon IN ('F','H','I')
      GROUP BY B.cCodCliente
      HAVING COUNT(*) > 1
 
SELECT B.cCodCliente, dFecUltCre = MAX(dFecCulCre)
      INTO #curCliNue
      FROM #CurNueRep A
            INNER JOIN GENMCrecli B WITH (NOLOCK)
                  ON A.cCodCliente = B.cCodCliente
            INNER JOIN KPYMCRECONVEN C WITH (NOLOCK)
                  ON B.cCodCtaCre = C.cCodCtaCre
                        AND cEstCreCon = 'G'
            LEFT JOIN #curCliNueExp D
                  ON A.cCodCliente = D.cCodCliente
      WHERE D.cCodCliente IS NULL
      GROUP BY B.cCodCliente, A.dFecDesCre
      HAVING DATEDIFF(DAY,MAX(dFecCulCre),A.dFecDesCre) > 365
      
UPDATE #CurNueRep
      SET cIndNueRep = 'N'
      FROM #CurNueRep A
            INNER JOIN #curCliNue B
                  ON A.cCodCliente = B.cCodCliente
 


DECLARE @nValorUIT NUMERIC(14,4)
SELECT      @nValorUIT = CAST(cValVarApl AS NUMERIC(9,4))
      FROM ADMMVariable
            WHERE cNomVarApl = 'gnValorUIT'
                  AND cCodOficin = '001'
 
DECLARE @x_nTipCamFij NUMERIC(14,4)
SELECT @x_nTipCamFij= cValVarApl 
FROM admmvariable 
WHERE cNomVarApl = 'GNTIPCAMFIJ'
      AND ccodigoapl = 'ADM'
      AND ccodOficin = '001'
      
UPDATE A
      SET cIndNueRep = 'R'
      FROM #CurNueRep A
            LEFT JOIN KPYMConvenios B
                  ON    A.cCodConven = B.cCodConven
                        AND B.cCodTipGru = 'A'
                        AND B.cCodEstCon = 'A'
      WHERE A.cCodTipCre = '01'
            AND B.cCodConven IS NULL     
            AND (A.nMonCapDes * CASE WHEN A.cCodTipMon = '1' then 1 else @x_nTipCamFij END) < 10 * @nValorUIT         
 
 
 
 
SELECT d.ccodoficin, cdesoficin,
         year(dfecdescre)as año  ,month(dfecdescre) as mes ,
         sum(case when cIndNueRep = 'N' AND cIndNueRepCre = 'n' then 1 else 0 end) as totnue,
         sum(case when cIndNueRep = 'N' AND cIndNueRepCre = 'p' then 1 else 0 end) as totpre,
         sum(case when cIndNueRep = 'N' AND cIndNueRepCre = 'r' then 1 else 0 end) as totrep,
         sum(case when cIndNueRep = 'R' AND cIndNueRepCre = 'N' then 1 else 0 end) as RepNue
      FROM #CurNueRep A
            INNER JOIN CMACHYOCLI..CLIMClientes B
                  ON A.cCodCliente = B.cCodCliente
            INNER JOIN GENTMoneda C
                  ON A.cCodTipMon = C.cCodTipMon     
            inner join GENTOficinas d
                        on a.cCodOficin = d.cCodOficin
group by d.ccodoficin,cdesoficin,year(dfecdescre),month(dfecdescre)
ORDER BY d.ccodoficin,cdesoficin,year(dfecdescre),month(dfecdescre)
 
 
 
DROP TABLE #CurNueRep
DROP TABLE #curCliNue
DROP TABLE #curCliNueExp