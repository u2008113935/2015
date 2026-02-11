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
/*
Se solicita el listado en Excel de operaciones que han sido otorgadas por excepciones en los
últimos 6 meses , la información debe estar actualizada al el 31 de Marzo del 2015, el cual 
debe contener los siguientes campos: 
CODIGO SBS, DNI, NOMBRE DEL DEUDOR, TIPO DE EXCEPCION,
NIVEL DE APROBACION, MONTO OTORGADO,FECHA DE APROBACION
*/

SELECT	
		M.cCodSbs 	
	,	M.cCodCliente
	,	ISNULL(M.cNroDocIde,M.cNroDocTri) AS 'NroDocumento'
	,	M.cNomCliente

	--,	cDesTipExc = RTRIM(ISNULL(L.cDesTipExc,''))
	,	cDesValReg = H.cDesEvaVal + ' ' + J.cOperadApl + ' ' + B.cValParam + CASE WHEN ISNULL(I.cDesEvaVal,'') = '' 
																				  THEN '' 
																			      ELSE ' de ' + ISNULL(I.cDesEvaVal,'')
																		     END
	,	cJusExcCre = CONVERT(VARCHAR(250),REPLACE(ISNULL(RTRIM(LTRIM(A.cJusExcCre)),''),CHAR(10),'-'))
	,	A.cCodUsuSol, P001.cNomPerson as 'Nombre_SOLICITO', P002.cDesCarPer as 'cargo_solicito'
	,	B.cCodUsuApr, P01.cNomPerson as 'NOMBRE_APROBO', P02.cDesCarPer	as 'cargo_aprobo'
	,	nMonCapDes = ISNULL(D.nMonCapDes,0.00)
	,	cDesTipMon = ISNULL(F.cDesTipMon,'')
	,	ISNULL(D.dFecDesCre,'')	AS	dFecDesCre
	,	B.dFecAprExc
	,	D.cCodCtaCre
	,   E.cDescriEst AS 'ESTADO_DEL_CREDITO'
	,	ISNULL(K.cDesOficin,'')		AS	cDesOficin			
	,	A.cNumDocInf
	,	G.cDesEstExc
	/*
	,	cDesNorReg =  'Artículo ' + RTRIM(H.cCodArtReg) + ' - Item ' + H.cCodIteReg			
	,	cCodCtaCre = ISNULL(D.cCodCtaCre,'')
	,	cDescriEst = ISNULL(cDescriEst,'')		
	,	B.cValCliente
			
	,	ISNULL(O.cDesMotSol,'')		AS	cDesMotSol
	,	CAST('' AS VARCHAR(50))	AS	CDESRELCTA
	,	CAST('' AS CHAR(5))		AS	CCODGARANT
	,	CAST('' AS VARCHAR(50))	AS	MONEDAGAR
	,	CAST(0.00 AS NUMERIC(14,2))	AS	VALGAR
	,	CAST(0.00 AS CHAR)	AS	NMONAMPGAR	
	,	ISNULL(Q.cDesClaCar,'')		AS	cDesClaCar
	*/
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

	INNER JOIN SIPMPERSONAL P001
		ON P001.cCodPerson = A.cCodUsuSol
	INNER JOIN SIPTCARGOPER P002
		ON P002.cCodGruPer = P001.cCodGruPer 

	INNER JOIN SIPMPERSONAL P01
		ON P01.cCodPerson = B.cCodUsuApr
	INNER JOIN SIPTCARGOPER P02
		ON P02.cCodGruPer = P01.cCodGruPer 

WHERE --C.cCodOficin LIKE @x_cCodOficin
	--AND
	 B.cEstExepCre	=	'B'	-- HABILITADO
	AND D.dFecDesCre >= '2014-10-01'
	AND D.dFecDesCre <= '2015-03-31'		
	AND S.nNumExep IS NULL
ORDER BY D.dFecDesCre --C.cCodOficin, cNomCliente	

Select * from #CUREXCCRE
--(2168 row(s) affected)
drop table #CUREXCCRE

--*********************************INDEXANDO****************************************************
--CREATE NONCLUSTERED INDEX #CUREXCCRE_cNumDocInf_IXN ON #CUREXCCRE(cNumDocInf)
CREATE NONCLUSTERED INDEX #CUREXCCRE_cCodCliente_IXN ON #CUREXCCRE(cCodCliente)
--CREATE NONCLUSTERED INDEX #CUREXCCRE_cCodCtaCre_IXN ON #CUREXCCRE(cCodCtaCre)
--------------------****************************************************************************
SELECT P01.cCodGruPer,P02.cDesCarPer,P01.cCodPerson,* 
		FROM SIPMPERSONAL P01
			INNER JOIN SIPTCARGOPER P02 ON P01.cCodGruPer = P02.cCodGruPer
		WHERE P01.cCodPerson = 'TCENTE'
		
		SELECT TOP 1 * FROM SIPTCARGOPER P02 WHERE P02.cCodGruPer = 'JNR'
--==========================================================================================================================================================
--	GARANTIA
--==========================================================================================================================================================
DECLARE @dFecIniFil DATETIME = '20130601'

SELECT	
		E.cCodSbs 
	,	B.CCODCLIENT
	,   ISNULL(E.cNroDocIde,E.cNroDocTri) aS	cNroDocIde
	,	E.CNOMCLIENTE
	,	cDesNorReg =  'Artículo ' + RTRIM(ISNULL(K.cCodArtReg,'')) + ' - Item ' + K.cCodIteReg
	,	CJUSEXCCRE = CONVERT(VARCHAR(250),REPLACE(ISNULL(LTRIM(RTRIM(cJusExcCre)),''),CHAR(10),'-'))
	,	J.CCODUSUSOL, P001.cNomPerson as 'Nombre_SOLICITO', P002.cDesCarPer as 'cargo_solicito'
	,	CCODUSUAPR = ISNULL(A.cCodUsuApr,'') , P01.cNomPerson as 'NOMBRE_APROBO'
					, P02.cDesCarPer	as 'cargo_aprobo'
	,	NMONCAPDES	=	ISNULL(nMonCapDes,B.nMonAprCre)
	,	MONEDAGAR	=	MG.cDesTipMon
	,	ISNULL(D.dFecDesCre,'')		AS	dFecDesCre
	--,	DFECSOLEXC = CONVERT(DATE,J.dFecSolExc)
	,	DFECAPREXC = CONVERT(DATE,A.dFecAprExc)
	,	CCODCTACRE	=	ISNULL(D.cCodCtaCre,'')
	,   I.cDescriEst AS 'ESTADO_DEL_CREDITO'
	,	ISNULL(cDesOficin,'')	AS	cDesOficin
	,	J.cNumDocInf
	,	ISNULL(EE.cDesEstExc,'')	AS	cDesEstExc

	/*
		DISTINCT
		K.cDesParCre + CASE WHEN K.cNombrePar = 'nMonAmpGar' 
							THEN CASE WHEN ISNULL(A.CCODTIPAMP,'F') = 'F' 
									THEN ' - MONTO' 
									ELSE ' - PORCENTAJE' 
									END  
							ELSE '' 
						END AS cDesParCre	
	,	CDESCRIEST	=	ISNULL(cDescriEst,'')
	,	MONEDA		=	ISNULL(L.cDesTipMon,'')	
	,	TITGAR = A.cCodCliente
	,	F.CNOMCLIENTE AS CNOMCLIGAR
	,	ISNULL(CDESRELCTA, '')		AS	CDESRELCTA
	,	A.CCODGARANT	
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
	,	cDesTipExc = RTRIM(ISNULL(cDesTipExc,''))		
	,	ISNULL(O.cDesMotSol,'')		AS	cDesMotSol	
	--,	ISNULL(E.cNroDocIde,'')		AS	cNroDocIde
	--,	ISNULL(E.cNroDocTri,'')		AS	cNroDocTri
	,	ISNULL(Q.cDesClaCar,'')		AS	cDesClaCar
	*/
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

	INNER JOIN SIPMPERSONAL P001
		ON P001.cCodPerson = J.CCODUSUSOL
	INNER JOIN SIPTCARGOPER P002
		ON P002.cCodGruPer = P001.cCodGruPer 

	INNER JOIN SIPMPERSONAL P01
		ON P01.cCodPerson = A.cCodUsuApr
	INNER JOIN SIPTCARGOPER P02
		ON P02.cCodGruPer = P01.cCodGruPer 

WHERE	--B.cCodOficin LIKE @x_cCodOficin
		--AND 
		A.cCodEstExc	=	'B'	-- HABILITADO
		--AND D.dFecDesCre BETWEEN @x_dFecIniRep AND @x_dFecFinRep
		AND D.dFecDesCre >= '2014-10-01'
		AND D.dFecDesCre <= '2015-03-31'	
		AND B.cCodEstSol NOT IN ('R','X')
		AND A.cNombrePar <> 
				CASE WHEN CAST(J.dFecSolExc AS DATE) >= @dFecIniFil THEN 'lHabSGNOG' 
				ELSE 'XXXXX' END		
-------------------------------------------------
select * from #CurTabla 
--(58481 row(s) affected)
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
drop table #CUREXCCRE
drop table #CurTabla
