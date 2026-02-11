	
SELECT  cCodTipCre,
		DescripCre	=  
			CASE 
				WHEN cCodTipCre =  '02' THEN 'MICROEMPRESAS'
				WHEN cCodTipCre =  '03' THEN 'CONSUMO'
				WHEN cCodTipCre =  '04' THEN 'HIPOTECARIOS'
				WHEN cCodTipCre =  '09' THEN 'EMP SIST FINAN'						
				WHEN cCodTipCre =  '12' THEN 'MEDIANA EMPRESA'						
				WHEN cCodTipCre =  '13' THEN 'PEQUEÑIA EMPRESA'												
			END,
		cCodGruPerCoord	=
			CASE 
				WHEN cCodTipCre =  '02' THEN 'CME'
				WHEN cCodTipCre =  '03' THEN 'CDC'
				WHEN cCodTipCre =  '04' THEN '088'
				WHEN cCodTipCre =  '09' THEN 'CNM'						
				WHEN cCodTipCre =  '12' THEN 'CNM'						
				WHEN cCodTipCre =  '13' THEN 'CME'												
			END,
		cCodGruPerAnalista	=
			CASE 
				WHEN cCodTipCre =  '02' THEN '094'				
				WHEN cCodTipCre =  '03' THEN ''
				WHEN cCodTipCre =  '04' THEN 'ACH'
				WHEN cCodTipCre =  '09' THEN '091'						
				WHEN cCodTipCre =  '12' THEN '091'						
				WHEN cCodTipCre =  '13' THEN '094'												
			END
	INTO #curDetProd
FROM [KPYTSUBTIPCRE] 				
WHERE  lEstado = '1' AND cCodTipCre IN ('02','03','04','09','12','13')		
GROUP BY cCodTipCre

INSERT INTO #curDetProd
VALUES ('LE','LEASING','CDL','')

/*
	DROP TABLE #curDetProd

	SELECT * FROM #curDetProd

*/

SELECT	A.cCodPerson, B.cCodGruPer,	B.cDesCarPer	
	--INTO #curDetCoord
FROM SIPMPersonal A
	INNER JOIN SIPTCargoPer B
		ON B.cCodGruPer =	A.cCodGruPer
WHERE B.cCodGruPer IN ('088','CDC','CDL','CME','CNM')						

SELECT	A.cCodPerson, B.cCodGruPer,	B.cDesCarPer	
	INTO #curDetAnalista
FROM SIPMPersonal A
	INNER JOIN SIPTCargoPer B
		ON B.cCodGruPer =	A.cCodGruPer
WHERE B.cCodGruPer IN ('ACH','094','091','ACC')

/*
	DROP TABLE #curDetCoord
	SELECT * FROM #curDetCoord

	DROP TABLE #curDetAnalista
	SELECT * FROM #curDetAnalista

*/

SELECT	A.cCodPerson, CodAnalista	=	ISNULL(C.cCodPerson,''), B.cCodTipCre, B.DescripCre		
FROM #curDetCoord A
	INNER JOIN #curDetProd B
		ON B.cCodGruPerCoord =	A.cCodGruPer
	LEFT JOIN #curDetAnalista C
		ON C.cCodGruPer = B.cCodGruPerAnalista
ORDER BY A.cCodPerson

/*
		SELECT  cCodTipCre,
		DescripCre	=  
			CASE 
				WHEN cCodTipCre =  '02' THEN 'MICROEMPRESAS'
				WHEN cCodTipCre =  '03' THEN 'CONSUMO'
				WHEN cCodTipCre =  '04' THEN 'HIPOTECARIOS'
				WHEN cCodTipCre =  '09' THEN 'EMP SIST FINAN'						
				WHEN cCodTipCre =  '12' THEN 'MEDIANA EMPRESA'						
				WHEN cCodTipCre =  '13' THEN 'PEQUEÑIA EMPRESA'												
			END,
		cCodGruPerCoord	=
			CASE 
				WHEN cCodTipCre =  '02' THEN 'JCRIOL'
				WHEN cCodTipCre =  '03' THEN 'JZURIT'
				WHEN cCodTipCre =  '04' THEN 'WSANTI'
				WHEN cCodTipCre =  '09' THEN 'JPOMAP'						
				WHEN cCodTipCre =  '12' THEN 'JPOMAP'						
				WHEN cCodTipCre =  '13' THEN 'JCRIOL'												
			END,
		cCodGruPerAnalista	=
			CASE 
				WHEN cCodTipCre =  '02' THEN 'FHUAMA'				
				WHEN cCodTipCre =  '03' THEN ''
				WHEN cCodTipCre =  '04' THEN 'DCERVA'
				WHEN cCodTipCre =  '09' THEN 'JQUERE'						
				WHEN cCodTipCre =  '12' THEN 'JQUERE'						
				WHEN cCodTipCre =  '13' THEN 'FHUAMA'												
			END
	--INTO #curDetProd
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] 				
WHERE  lEstado = '1' AND cCodTipCre IN ('02','03','04','09','12','13')		
GROUP BY cCodTipCre

INSERT INTO #curDetProd
VALUES ('LE','LEASING','BGUERR','')

SELECT	A.cCodPerson, B.cCodGruPer,	B.cDesCarPer	
	--INTO #curDetCoord
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.SIPMPersonal A
	INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.SIPTCargoPer B
		ON B.cCodGruPer =	A.cCodGruPer
WHERE B.cCodGruPer IN ('088','CDC','CDL','CME','CNM')						

SELECT	A.cCodPerson, B.cCodGruPer,	B.cDesCarPer	
	--INTO #curDetAnalista
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.SIPMPersonal A
	INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.SIPTCargoPer B
		ON B.cCodGruPer =	A.cCodGruPer
WHERE B.cCodGruPer IN ('ACH','094','091','ACC')

SELECT	A.cCodPerson, --CodAnalista	=	ISNULL(C.cCodPerson,''), 
		B.cCodTipCre, B.DescripCre		
	--INTO #curDetProdCoordAn
FROM #curDetCoord A
	INNER JOIN #curDetProd B
		ON B.cCodGruPerCoord COLLATE SQL_Latin1_General_CP1_CI_AS =	A.cCodGruPer
	--LEFT JOIN #curDetAnalista C
		--ON C.cCodGruPer COLLATE SQL_Latin1_General_CP1_CI_AS	  = B.cCodGruPerAnalista
ORDER BY A.cCodPerson


*/