use SOFCMACHYO_201503
/*
CREATE PROCEDURE [dbo].[KPY_RepCreDesExc_SP]
	@x_cCodOficin VARCHAR(3),
	@x_dFecIniRep DATETIME,
	@x_dFecFinRep DATETIME

AS
SET NOCOUNT ON

IF @x_cCodOficin = '*'
	SET @x_cCodOficin = '%'
	*/
SELECT	G.cDesEstExc
	,	A.cNumDocInf
	,	M.cCodCliente
	,	M.cNomCliente
	,	cCodCtaCre = ISNULL(D.cCodCtaCre,'')
	,	cDescriEst = ISNULL(cDescriEst,'')
	,	cDesTipMon = ISNULL(F.cDesTipMon,'')
	,	nMonCapDes = ISNULL(D.nMonCapDes,0.00)
	,	cDesValReg = H.cDesEvaVal + ' ' + J.cOperadApl + ' ' + B.cValParam + CASE WHEN ISNULL(I.cDesEvaVal,'') = '' 
																				  THEN '' 
																			      ELSE ' de ' + ISNULL(I.cDesEvaVal,'')
																		     END
	,	B.cValCliente
	,	cJusExcCre = CONVERT(VARCHAR(250),REPLACE(ISNULL(RTRIM(LTRIM(A.cJusExcCre)),''),CHAR(10),'-'))
	,	A.cCodUsuSol, B.cCodUsuApr, B.dFecAprExc
	,	ISNULL(D.dFecDesCre,'')		AS	dFecDesCre
	,	ISNULL(K.cDesOficin,'')		AS	cDesOficin
	,	cDesTipExc = RTRIM(ISNULL(L.cDesTipExc,''))
	,	cDesNorReg =  'Artículo ' + RTRIM(H.cCodArtReg) + ' - Item ' + H.cCodIteReg
	,	ISNULL(O.cDesMotSol,'')		AS	cDesMotSol
	,	CAST('' AS VARCHAR(50))	AS	CDESRELCTA
	,	CAST('' AS CHAR(5))		AS	CCODGARANT
	,	CAST('' AS VARCHAR(50))	AS	MONEDAGAR
	,	CAST(0.00 AS NUMERIC(14,2))	AS	VALGAR
	,	CAST(0.00 AS CHAR)	AS	NMONAMPGAR
	,	ISNULL(M.cNroDocIde,'')		AS	cNroDocIde
	,	ISNULL(M.cNroDocTri,'')		AS	cNroDocTri
	,	ISNULL(Q.cDesClaCar,'')		AS	cDesClaCar
INTO #CUREXCCRE
FROM KPYMEXCCRE A	(NOLOCK)
	INNER JOIN KPYDEXEPCRE B	(NOLOCK)
		ON A.cCodSolCre = B.cCodSolCre 
	INNER JOIN KPYMSolicitud C	(NOLOCK)
		ON A.cCodSolCre = C.cCodSolCre 
	INNER JOIN CMACHYOCLI..CLIMClientes M	(NOLOCK)
		ON C.cCodClient = M.cCodCliente 
	LEFT JOIN KPYMCRECONVEN D	(NOLOCK)
		ON C.cCodSolCre = D.cCodSolCre AND D.cEstCreCon	 <> 'X'	
					AND	D.dFecDesCre IS NOT NULL
	LEFT JOIN KPYTEstCreCon E	(NOLOCK)
		ON D.cEstCreCon = E.cEstCreCon 
	LEFT JOIN GENTMoneda F	(NOLOCK)
		ON D.cCodTipMon = F.cCodTipMon 
	INNER JOIN KPYTEstSolExc G	(NOLOCK)
		ON G.cCodEstExc = B.cEstExepCre 
	INNER JOIN GENTParEvaVal H 	(NOLOCK)
		ON B.nTipValida = H.nTipValida 
		AND B.cNombrePar = H.cParEvaVal
		AND H.cCodTipApl = 'KPY'
		AND H.lEstEvaVal = 1
	LEFT JOIN GENTParEvaVal I	(NOLOCK)
		ON B.nTipValida = I.nTipValida 
		AND B.cCamAfePar  = I.cParEvaVal
		AND I.cCodTipApl = 'KPY'
		AND I.lEstEvaVal = 1
	INNER JOIN GENDValidaOpe J		(NOLOCK)
		ON J.cCodTipApl = 'KPY'	
		AND J.nTipValida = B.nTipValida 
		AND J.nNumValida = B.nNumValida 
		AND J.nNumDetVal = B.nNumDetVal 
	INNER JOIN GENTOficinas K	(NOLOCK)
		ON C.cCodOficin = K.cCodOficin 
	INNER JOIN GENTTipExc L	(NOLOCK)
		ON H.cCodTipExc = L.cCodTipExc
		AND L.lEstTipExc = 1
	LEFT JOIN KPYDSusExeCre S	(NOLOCK)
		ON B.nNumExep = S.nNumExep
		AND S.cCodTipSus != '0'
	INNER JOIN KPYTMotSolici O	(NOLOCK)
		ON o.cCodMotSol = C.cCodMotSol
	LEFT JOIN KPYTClaCarter Q
		ON Q.cCodClaCar	=	D.cCodClaCar
WHERE --C.cCodOficin LIKE @x_cCodOficin
	--AND
	 B.cEstExepCre	=	'B'	-- HABILITADO
	--AND D.dFecDesCre BETWEEN @x_dFecIniRep AND @x_dFecFinRep		
	AND S.nNumExep IS NULL
ORDER BY C.cCodOficin, cNomCliente	

select * from #CUREXCCRE
--(38456 row(s) affected)
drop table #CUREXCCRE
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #CUREXCCRE_cNumDocInf_IXN ON #CUREXCCRE(cNumDocInf)
CREATE NONCLUSTERED INDEX #CUREXCCRE_cCodCliente_IXN ON #CUREXCCRE(cCodCliente)
CREATE NONCLUSTERED INDEX #CUREXCCRE_cCodCtaCre_IXN ON #CUREXCCRE(cCodCtaCre)
--------------------****************************************************************************

--==========================================================================================================================================================
--	GARANTIA
--==========================================================================================================================================================
DECLARE @dFecIniFil DATETIME = '20130601'

SELECT	DISTINCT
		K.cDesParCre + CASE WHEN K.cNombrePar = 'nMonAmpGar' 
							THEN CASE WHEN ISNULL(A.CCODTIPAMP,'F') = 'F' 
									THEN ' - MONTO' 
									ELSE ' - PORCENTAJE' 
									END  
							ELSE '' 
						END AS cDesParCre
	,	J.cNumDocInf
	,	B.CCODCLIENT
	,	E.CNOMCLIENTE
	,	CCODCTACRE	=	ISNULL(D.cCodCtaCre,'')
	,	CDESCRIEST	=	ISNULL(cDescriEst,'')
	,	MONEDA		=	ISNULL(L.cDesTipMon,'')
	,	NMONCAPDES	=	ISNULL(nMonCapDes,B.nMonAprCre)
	,	TITGAR = A.cCodCliente
	,	F.CNOMCLIENTE AS CNOMCLIGAR
	,	ISNULL(CDESRELCTA, '')		AS	CDESRELCTA
	,	A.CCODGARANT
	,	MONEDAGAR	=	MG.cDesTipMon
	,	VALGAR =	CASE 
						WHEN G.cCodTipMon = '1' THEN G.nMonTasGar * nTipCamGar 
						ELSE G.nMonTasGar 
					END
	,	NMONAMPGAR = CASE WHEN ISNULL(A.cCodTipAmp,'F') = 'F' THEN
						CAST(CAST(CASE 
							WHEN G.cCodTipMon = '1' THEN nMonAmpGar * nTipCamGar 
							ELSE A.nMonAmpGar 
						END AS NUMERIC(14,2)) AS CHAR)
					ELSE
						LTRIM(RTRIM(CAST(ISNULL(A.nPorAmpGar,0.00) AS CHAR))) + ' %'					 
					END 
	,	CJUSEXCCRE = CONVERT(VARCHAR(250),REPLACE(ISNULL(LTRIM(RTRIM(cJusExcCre)),''),CHAR(10),'-'))
	,	J.CCODUSUSOL
	,	CCODUSUAPR = ISNULL(A.cCodUsuApr,'')
	,	DFECSOLEXC = CONVERT(DATE,J.dFecSolExc)
	,	DFECAPREXC = CONVERT(DATE,A.dFecAprExc)
	,	ISNULL(cDesOficin,'')	AS	cDesOficin
	,	cDesTipExc = RTRIM(ISNULL(cDesTipExc,''))
	,	cDesNorReg =  'Artículo ' + RTRIM(ISNULL(K.cCodArtReg,'')) + ' - Item ' + K.cCodIteReg
	,	ISNULL(D.dFecDesCre,'')		AS	dFecDesCre
	,	ISNULL(O.cDesMotSol,'')		AS	cDesMotSol
	,	ISNULL(EE.cDesEstExc,'')	AS	cDesEstExc
	,	ISNULL(E.cNroDocIde,'')		AS	cNroDocIde
	,	ISNULL(E.cNroDocTri,'')		AS	cNroDocTri
	,	ISNULL(Q.cDesClaCar,'')		AS	cDesClaCar
INTO #CurTabla
FROM dbo.KPYDAMPGARCRE A	(NOLOCK)
	INNER JOIN KPYMSolicitud B	(NOLOCK)
		ON A.cCodSolCre = B.cCodSolCre
	LEFT JOIN GENMCreCli C	(NOLOCK)
		ON B.cCodLinCre = C.cCodLinCre		
	LEFT JOIN KPYMCRECONVEN D	(NOLOCK)
		ON C.cCodCtaCre = D.cCodCtaCre
		AND D.cCodSolCre = B.cCodSolCre
		AND D.cEstCreCon <> 'X'	AND	D.dFecDesCre IS NOT NULL
	INNER JOIN CMACHYOCLI..CLIMClientes E	(NOLOCK)
		ON B.cCodClient = E.cCodCliente
	INNER JOIN CMACHYOCLI..CLIMClientes F	(NOLOCK)
		ON A.CCODCLIENTE = F.cCodCliente
	INNER JOIN CMACHYOCLI..CLIMGarCliente G	(NOLOCK)
		ON A.cCodCliente = G.cCodCliente
		AND A.cCodGarCli = G.cCodGarCli
	INNER JOIN GENTTipRelCta H	(NOLOCK)
		ON H.cCodRelCta = cCodRelGar
	LEFT JOIN KPYTEstCreCon I	(NOLOCK)
		ON D.cEstCreCon = I.cEstCreCon
	INNER JOIN KPYMEXCCRE J	(NOLOCK)
		ON J.cCodSolCre  = A.cCodSolCre 
	INNER JOIN KPYTDESPARCRE K		(NOLOCK)
		ON A.cNombrePar = K.cNombrePar
	INNER JOIN GENTMoneda L	(NOLOCK)
		ON G.cCodTipMon = L.cCodTipMon
	INNER JOIN GENTMoneda MG	(NOLOCK)
		ON MG.cCodTipMon = G.cCodTipMon
	INNER JOIN GENTOficinas M	(NOLOCK)
		ON B.cCodOficin = M.cCodOficin 
	INNER JOIN GENTTipExc N	(NOLOCK)
		ON N.cCodTipExc = K.cCodTipExc
		AND N.lEstTipExc = 1
	INNER JOIN KPYTMotSolici O	(NOLOCK)
		ON O.cCodMotSol = B.cCodMotSol
	INNER JOIN KPYTEstSolExc EE	(NOLOCK)
		ON EE.cCodEstExc = A.cCodEstExc 
	LEFT JOIN KPYTClaCarter Q	(NOLOCK)
		ON Q.cCodClaCar	=	D.cCodClaCar
WHERE	--B.cCodOficin LIKE @x_cCodOficin
		--AND 
		A.cCodEstExc	=	'B'	-- HABILITADO
		--AND D.dFecDesCre BETWEEN @x_dFecIniRep AND @x_dFecFinRep
		AND B.cCodEstSol NOT IN ('R','X')
		AND A.cNombrePar <> 
				CASE WHEN CAST(J.dFecSolExc AS DATE) >= @dFecIniFil THEN 'lHabSGNOG' 
				ELSE 'XXXXX' END		
-------------------------------------------------
select * from #CurTabla --(58481 row(s) affected)
drop table #CurTabla


		--*********************************INDEXANDO**********************
		CREATE NONCLUSTERED INDEX #CurTabla_cNumDocInf_IXN ON #CurTabla(cNumDocInf)
		CREATE NONCLUSTERED INDEX #CurTabla_cCodCliente_IXN ON #CurTabla(CCODCLIENT)
		CREATE NONCLUSTERED INDEX #CurTabla_cCodCtaCre_IXN ON #CurTabla(cCodCtaCre)
		--****************************************************************************
-------------------------------------------------
SELECT * into #TMP_FINAL FROM  (
SELECT	'CRÉDITOS'	AS	cTipReport
	,	cDesOficin
	,	cDesEstExc
	,	CAST('' AS VARCHAR(50))	AS	cMotivoSol
	,	cCodCliente
	,	cNomCliente
	,	cNroDocIde
	,	cNroDocTri
	,	cDesClaCar	AS	cCalifiCre
	,	cCodCtaCre
	,	cDesTipMon
	,	nMonCapDes
	,	cDescriEst
	,	dFecDesCre
	,	cDesMotSol
	,	cDesValReg
	,	cJusExcCre
	,	CAST(''	AS CHAR(12))	AS	CCODTITGAR
	,	CAST(''	AS VARCHAR(200))	AS	CNOMCLIGAR
	,	CDESRELCTA
	,	CCODGARANT
	,	MONEDAGAR
	,	VALGAR
	,	NMONAMPGAR
	,	cCodUsuSol
	,	cCodUsuApr
	,	dFecAprExc
	,	cDesTipExc
	,	cDesNorReg
FROM #CUREXCCRE
UNION
SELECT  'GARANTÍA'	AS	cTipReport
	,	cDesOficin
	,	cDesEstExc
	,	cDesParCre	AS	cMotivoSol
	,	CCODCLIENT
	,	CNOMCLIENTE	AS	cNomCliente
	,	cNroDocIde
	,	cNroDocTri
	,	cDesClaCar	AS	cCalifiCre
	,	cCodCtaCre
	,	MONEDA	AS	cDesTipMon
	,	nMonCapDes
	,	cDescriEst
	,	dFecDesCre
	,	cDesMotSol
	,	cDesNorReg	AS	cDesValReg
	,	cJusExcCre
	,	TITGAR
	,	CNOMCLIGAR
	,	CDESRELCTA
	,	CCODGARANT
	,	MONEDAGAR
	,	VALGAR
	,	NMONAMPGAR
	,	cCodUsuSol
	,	cCodUsuApr
	,	dFecAprExc
	,	cDesTipExc
	,	cDesNorReg
FROM #CurTabla
--ORDER BY cDesOficin,dFecDesCre

) AS tmp

select * 
from #TMP_FINAL 
ORDER BY cDesOficin,dFecDesCre
--(96864 row(s) affected)

DROP TABLE #TMP_FINAL
