/*
SELECT TOP 10 * 
FROM kpydComaprCre
where dFecRegApr >= '2014-03-01'
	and dFecRegApr <= '2015-03-31'
order by dFecRegApr
*/
-- Drop table #TMP_CREDNOMIN
SELECT * into #TMP_CREDNOMIN FROM  (
Select --top 1 * 
	ROW_NUMBER() 
	OVER(PARTITION BY CRE.cCodTipCre 
			ORDER BY AP.dFecRegApr ) AS Secuencia
	,CRE.cCodCtaCre	,CRE.cCodSolCre	,CRE.nMonCapDes 
	,case CRE.cCodTipMon 
	 When '1' then 'SOLES'
	 WHEN '2' THEN 'DOLARES'
	 END as 'MONEDA' 
	,CRE.cCodTipCre, STC.cDesTipCre, STC.cDesSubTip, STC.cDesProCre, STC.cDesSubCre, AP.dFecRegApr
	,EC.cDescriEst , CRE.cCodConven, CAM.dFecRegCon, CAM.cDesConven, A.nNumExcCre
from [kpymcreconven] CRE (NOLOCK)
		INNER JOIN kpydComaprCre AP 
			ON CRE.cCodSolCre = AP.cCodSolCre
			AND AP.dFecRegApr >= '2014-03-01' and AP.dFecRegApr <= '2015-03-31'
		INNER JOIN [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
		INNER JOIN KPYTEstCreCon EC 
			ON EC.cEstCreCon = CRE.cEstCreCon
		LEFT JOIN KPYMConvenios CAM
			ON CRE.cCodConven =  CAM.cCodConven
				AND CAM.dFecRegCon >= '2014-02-25 09:36:05.580' 
				and CAM.dFecRegCon <= '2015-03-31 12:39:27.880'
		
		LEFT JOIN KPYMSolicitud C	(NOLOCK)
			ON C.cCodSolCre = CRE.cCodSolCre --AND CRE.cEstCreCon	 <> 'X'	
					--AND	CRE.dFecDesCre IS NOT NULL
		left JOIN 	KPYMEXCCRE A (NOLOCK)
			ON A.cCodSolCre = C.cCodSolCre 
		--inner JOIN KPYDEXEPCRE B	(NOLOCK)
			--ON A.cCodSolCre = B.cCodSolCre and B.cEstExepCre = 'B'			
where CRE.cCodTipCre IN ('02','03','13') 
		
) AS tmp

--(242,459 row(s) affected)
Select * from #TMP_CREDNOMIN (NOLOCK) 
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #TMP_CREDNOMIN_cCodCtaCre_IXN ON #TMP_CREDNOMIN (cCodCtaCre)
CREATE NONCLUSTERED INDEX #TMP_CREDNOMIN_cCodSolCre_IXN ON #TMP_CREDNOMIN (cCodSolCre)

--------------------****************************************************************************
---01 CONSOLIDADO
Select cCodTipCre,cDesTipCre,COUNT(cCodSolCre) AS 'Cant_Aprob' 
	,sum(nMonCapDes) as 'Monto_Aprob', MONEDA
from #TMP_CREDNOMIN (NOLOCK)
group by cCodTipCre,cDesTipCre, MONEDA
order by cCodTipCre

---02 POR CAMPAÑA
Select cCodTipCre,cDesTipCre
		,cDesConven
		,COUNT(cCodSolCre) AS 'Cant_Aprob' 
	,sum(nMonCapDes) as 'Monto_Aprob', MONEDA
from #TMP_CREDNOMIN (NOLOCK)
WHERE cDesConven IS NOT NULL
group by cCodTipCre,cDesTipCre,cDesConven, MONEDA
order by cCodTipCre

---03 POR EXCEPCION
Select cCodTipCre,cDesTipCre,COUNT(cCodSolCre) AS 'Cant_Aprob' 
	,sum(nMonCapDes) as 'Monto_Aprob', MONEDA
from #TMP_CREDNOMIN (NOLOCK)
WHERE nNumExcCre IS NOT NULL
group by cCodTipCre,cDesTipCre, MONEDA
order by cCodTipCre


Select * 
from #TMP_CREDNOMIN (NOLOCK) 




----------------DETALLES----------------
--select *  from KPYTESTCRECON 

select * from KPYMConvenios
where dFecRegCon >= '2014-02-25 09:36:05.580' and dFecRegCon <= '2015-03-31 12:39:27.880'
order by dFecRegCon 

SELECT cCodConven,*
FROM KPYMConvenios 
WHERE cCodEstCon = 'A'
      AND cDesConven LIKE '%CAMPAÑA%'

select top 5 cCodConven
from KPYMCRECONVEN 

select CRE.cCodCtaCre, CRE.cCodConven, CAM.cCodConven, CAM.dFecRegCon, CAM.cDesConven 
from KPYMCRECONVEN CRE (NOLOCK)
	INNER JOIN KPYMConvenios CAM
		ON CRE.cCodConven =  CAM.cCodConven
where CAM.dFecRegCon >= '2014-02-25 09:36:05.580' and CAM.dFecRegCon <= '2015-03-31 12:39:27.880'
order by CAM.dFecRegCon 

------------EXCEPCIONES----------
SELECT TOP 3 *
FROM KPYMEXCCRE A	(NOLOCK)

SELECT TOP 3 *
FROM KPYDEXEPCRE B	(NOLOCK)
WHERE B.cEstExepCre	=	'B'

SELECT TOP 5 * 
FROM KPYMEXCCRE A (NOLOCK)
	INNER JOIN KPYDEXEPCRE B	(NOLOCK)
		ON A.cCodSolCre = B.cCodSolCre 
	INNER JOIN KPYMSolicitud C	(NOLOCK)
		ON A.cCodSolCre = C.cCodSolCre 
	LEFT JOIN KPYMCRECONVEN D	(NOLOCK)
		ON C.cCodSolCre = D.cCodSolCre AND D.cEstCreCon	 <> 'X'	
					AND	D.dFecDesCre IS NOT NULL

SELECT TOP 5 * 
FROM KPYMEXCCRE A (NOLOCK)
	INNER JOIN KPYDEXEPCRE B	(NOLOCK)
		ON A.cCodSolCre = B.cCodSolCre 
	INNER JOIN KPYMSolicitud C	(NOLOCK)
		ON A.cCodSolCre = C.cCodSolCre 
	LEFT JOIN KPYMCRECONVEN D	(NOLOCK)
		ON C.cCodSolCre = D.cCodSolCre AND D.cEstCreCon	 <> 'X'	
					--AND	D.dFecDesCre IS NOT NULL
WHERE B.cEstExepCre	=	'B'	-- HABILITADO