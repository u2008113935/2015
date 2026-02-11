sp_helptext KPY_DetCliAmpVisTod_sp
/*************************************************************************************************************************                                        
*	Objetivo : Detalla los clientes aptos para ampliacion para visitas por promotores	
*	2010-11-26		ASALAZ			Se modifico a la calificación al 100% Normal.
*	Sintaxis de ejemplo:  
*
*********************************************************************************************************************************************************/  

CREATE PROCEDURE dbo.KPY_DetCliAmpVisTod_sp
	@x_ccodPeriod CHAR(7),
	@x_ccodDepart VARCHAR(2),
	@x_ccodProvin VARCHAR(2),
	@x_ccodDistri VARCHAR(2),
	@x_ccodZona   VARCHAR(3),
	@x_ccodTipCre VARCHAR(2),
	@x_ccodProduc VARCHAR(2),
	@x_ccodSubPro VARCHAR(2),
	@x_nMonMinDes NUMERIC(14,2),
	@x_ntipcamfij NUMERIC(14,4),
	@x_cCodOficin CHAR(3),
	@x_cCodEstCar CHAR(1),
	@x_nCuoVenIni INT,
	@x_nCuoVenFin INT,
	@x_cCodTipMon CHAR(1)
AS 

SET NOCOUNT ON 

CREATE TABLE #CURDetCliDes
	(cCodUsuAna CHAR(6),
	cCodUsuCar CHAR(6),
	cCodCtaCre CHAR(18))

CREATE NONCLUSTERED INDEX IX_#CURDetCliDes ON #CURDetCliDes(cCodctaCre)	

IF @x_cCodEstCar = '%'
	
	INSERT INTO #CURDetCliDes
	SELECT 	cCodUsuAna=DES.cCodUsuAna, cCodUsuCar=DES.cCodUsuCar,
			cCodCtaCre=DES.cCodCtaCre
	FROM KPYHDetCliDes DES  WITH (NOLOCK) 
		INNER JOIN KPYTCTARELCLI PTE  WITH (NOLOCK) 
				ON DES.cCodCtaCre = PTE.cCodCtaCre
	WHERE DES.cCodTipCar = 'AMP'
			--AND DES.cCodPeriod	  =	@x_ccodPeriod
			AND DES.cCodEstCar	IN ('A','C')
						
			--AND DES.cCodDepart LIKE @x_ccodDepart 
			--AND DES.cCodProvin LIKE @x_ccodProvin
			--AND DES.cCodDistri LIKE @x_ccodDistri
			--AND DES.cCodZona   LIKE @x_ccodZona
			--AND DES.cCodTipCre LIKE @x_ccodTipCre
			--AND DES.cCodProduc LIKE @x_ccodProduc
			--AND DES.cCodSubPro LIKE @x_ccodSubPro
			--AND DES.nMonCapDes >= CASE 
								--	WHEN DES.ccodtipmon = '1' 
									--	THEN @x_nMonMinDes 
										--ELSE @x_nMonMinDes/@x_ntipcamfij 
									--END
			AND DES.ccodoficin= '002'--@x_cCodOficin
			--AND DES.cCodTipMon LIKE @x_cCodTipMon	
			AND PTE.cCodAplica = 'KPY'
			AND PTE.cCodEstCta = 'F'
	GROUP BY DES.cCodUsuAna, DES.cCodUsuCar,
			DES.cCodCtaCre
	ORDER BY DES.cCodCtaCre		

ELSE

	INSERT INTO #CURDetCliDes

	SELECT 	cCodUsuAna=DES.cCodUsuAna, cCodUsuCar=DES.cCodUsuCar,
		cCodCtaCre=DES.cCodCtaCre
	FROM KPYHDetCliDes DES   WITH (NOLOCK) 
		INNER JOIN KPYTCTARELCLI PTE  WITH (NOLOCK) 
				ON DES.cCodCtaCre = PTE.cCodCtaCre
	WHERE DES.cCodTIpCar	   = 'AMP'
			AND cCodPeriod	   = @x_ccodPeriod
			AND cCodEstCar	   = @x_cCodEstCar
			AND DES.cCodDepart LIKE @x_ccodDepart 
			AND DES.cCodProvin LIKE @x_ccodProvin
			AND DES.cCodDistri LIKE @x_ccodDistri
			AND DES.cCodZona   LIKE @x_ccodZona
			AND DES.cCodTipCre LIKE @x_ccodTipCre
			AND DES.cCodProduc LIKE @x_ccodProduc
			AND DES.cCodSubPro LIKE @x_ccodSubPro
			AND DES.nMonCapDes >= CASE 
									WHEN DES.ccodtipmon = '1' 
										THEN @x_nMonMinDes 
										ELSE @x_nMonMinDes/@x_ntipcamfij 
									END
			AND DES.ccodoficin= @x_cCodOficin
			AND DES.cCodTipMon LIKE @x_cCodTipMon	
			AND PTE.cCodAplica = 'KPY'
			AND PTE.cCodEstCta = 'F'
	GROUP BY DES.cCodUsuAna, DES.cCodUsuCar,
			DES.cCodCtaCre		
	ORDER BY DES.cCodCtaCre		

		
-- SE FILTRA POR LAS CUOTAS VENCIDAS

SELECT 	DES.cCodUsuAna, DES.cCodUsuCar,
		B.cCodCliente,  C.cCodCtaCre,nCuoVen = COUNT(C.cCodEstCuo),cNumCuoPla = MIN(cNumCuoPla)
INTO #CURDATA
FROM #CURDetCliDes DES 
	INNER JOIN GENMCRECLI B  WITH (NOLOCK) 
		ON DES.cCodctaCre = B.cCodctaCre
	INNER JOIN KPYDPLANPAGCRE C  WITH (NOLOCK) 
		ON B.cCodctaCre = C.cCodctaCre
			AND B.CCODULTPLA = C.CCODPLAPAG
			AND C.cCodEstCuo = 'E'
GROUP BY DES.cCodUsuAna, DES.cCodUsuCar,
		 B.cCodCliente, C.cCodCtaCre
HAVING COUNT(C.cCodEstCuo) BETWEEN '1' and '1000'-- @x_nCuoVenIni AND @x_nCuoVenFin
ORDER BY C.CCODCTACRE

CREATE NONCLUSTERED INDEX IX_#CURDATA ON #CURDATA(cCodctaCre)		

-- SE FILTRA POR LAS CUOTAS VENCIDAS

SELECT DES.cCodUsuAna,  DES.cCodUsuCar,DES.cCodCliente, DES.cCodCtaCre, CRE.cCodTipMon,
       DES.nCuoVen, DES.cNumCuoPla,'CNRODOCID' = CASE WHEN ccodclaper <> '1' 
	                								THEN CLI.cnrodoctri
					                				ELSE CLI.cnrodocide
					                			 END,
		CLI.cNomCliente, CLI.cDirDomCli, CLI.cCodDepDom, CLI.cCodProDom,
		CLI.cCodDisDom,  CLI.cCodZonDom, ccodclaper, EX.cCodExpCli,
		nSalCap = (CRE.NMONCAPDES - CRE.NMONCAPPAG),
	    CRE.cCodTipCre,CRE.cCodProduc,CRE.cCodSubPro,
	    CRE.nNumCuoApr,CRE.NDIAATRCRE,cCodUsuAnaCre = CRE.cCodUsuAna,
	    CVALSCOSTR = CASE WHEN D.CVALSCOSTR='' OR D.CVALSCOSTR IS NULL
													THEN '-1'
													ELSE D.CVALSCOSTR
											  END,
		CRE.nMoncapdes,
		TELDOMCLI=CLI.cNroTelDom,
		TELPERCLI=CLI.cNroTelPer
INTO #CURDATADOC
FROM #CURDATA DES
	INNER JOIN KPYMCRECONVEN CRE  WITH (NOLOCK) 
		ON DES.cCodctaCre = CRE.cCodctaCre
	INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMCLIENTE CLI WITH (NOLOCK) 
			ON DES.CCODCLIENTE = CLI.CCODCLIENTE
	LEFT JOIN CMACHYOCLI_MANIANA.DBO.CLIDEXPEDIENTE EX  WITH (NOLOCK)    
			ON DES.CCODCLIENTE = EX.CCODCLIENT
				AND EX.lConEstado = 1
				AND EX.CTIPEXPCLI='K' 
	LEFT JOIN KPYMSCOCLISTRA D
		ON DES.CCODCLIENTE = D.CCODCLIENTE
WHERE ccodclaper IS NOT NULL
	AND RTRIM(LTRIM(ccodclaper))!= ''
ORDER BY CNRODOCID,ccodclaper

CREATE NONCLUSTERED INDEX IX_#CURDATADOC ON #CURDATADOC(CNRODOCID, ccodclaper)

-- SE FILTAR CLIENTES QUE TIENE CALIFICACIÓN NORMAL Y SE EXTRE SU PORCENTAJE

SELECT cCodUsuAna, cCodUsuCar, cCodCliente, cCodCtaCre,nCuoVen,CNRODOCID,cNomCliente,
       cDirDomCli, cCodDepDom, cCodProDom, cCodDisDom, cCodZonDom, ccodclaper,
       RCC.NPORCAL0,cCodExpCli,nSalCap, cCodTipMon,nNumCuoApr,cNumCuoPla,
       A.cCodTipCre,A.cCodProduc,A.cCodSubPro,A.NDIAATRCRE,A.CVALSCOSTR,cCodUsuAnaCre,
       A.nMoncapdes,A.TELDOMCLI,A.TELPERCLI
INTO #CURDATARCC
FROM #CURDATADOC A
	LEFT JOIN CRICMACHYO_DIARIO.dbo.URIRCCMAE AS RCC  WITH (NOLOCK) 
		ON A.CNRODOCID  = RCC.CNUDOCI
WHERE ccodclaper = 1
	AND ((RCC.CCLAFIN = '0'
			AND RCC.nporcal0 = 100) OR RCC.CNUDOCI IS NULL)
UNION 
SELECT cCodUsuAna, cCodUsuCar, cCodCliente, cCodCtaCre,nCuoVen,CNRODOCID,cNomCliente,
       cDirDomCli, cCodDepDom, cCodProDom, cCodDisDom, cCodZonDom, ccodclaper,
       RCC.NPORCAL0,cCodExpCli,nSalCap, cCodTipMon,nNumCuoApr,cNumCuoPla,
       A.cCodTipCre,A.cCodProduc,A.cCodSubPro,A.NDIAATRCRE,A.CVALSCOSTR,cCodUsuAnaCre,
       A.nMoncapdes,A.TELDOMCLI,A.TELPERCLI
FROM #CURDATADOC A
	LEFT JOIN CRICMACHYO_DIARIO.dbo.URIRCCMAE AS RCC  WITH (NOLOCK) 
		ON A.CNRODOCID  = RCC.cnudotr
WHERE ccodclaper <> 1
		AND ((RCC.CCLAFIN = '0'
			AND RCC.nporcal0 = 100) OR RCC.cnudotr IS NULL)
ORDER BY CCODCTACRE

CREATE NONCLUSTERED INDEX IX_#CURDATARCC ON #CURDATARCC(cCodctaCre)



-- EXTRAEMOS EL PROMEDIO DE DIAS VENCIDOS

SELECT A.CCODCTACRE,B.cCodLinCre,
	   nProDiasVen= SUM( CASE WHEN C.NDIAVENCUO < 0.00 
									       THEN 0.00 
										   ELSE C.NDIAVENCUO 
									  END)/COUNT(C.cnumcuopla)
INTO #CURPROMEDIOS
FROM #CURDATARCC A
	INNER JOIN GENMCRECLI B  WITH (NOLOCK) 
		ON A.cCodctaCre = B.cCodctaCre	
	INNER JOIN KPYDPLANPAGCRE C  WITH (NOLOCK) 
		ON B.cCodctaCre = C.cCodctaCre
			AND B.CCODULTPLA = C.CCODPLAPAG			
GROUP BY A.CCODCTACRE,B.cCodLinCre
ORDER BY A.CCODCTACRE

	-- SELECT * FROM #CURDATARCC

CREATE NONCLUSTERED INDEX IX_#CURPROMEDIOS ON #CURPROMEDIOS(cCodctaCre)

-- SE EXTRAE LOS DATOS DEL AVAL

SELECT CUR.CCODCTACRE,CUR.CCODLINCRE,
	  cNomAval = cnomcliente,
	  cAvalDir = CDIRDOMCLI, A.cdesRelCta,cNroTelPer = ISNULL(MAX(CA.cNroTelPer),''),CNROTELDOM=ISNULL(MAX(CNROTELDOM),''),
	  ccodclaper,GL.ccodcliente,GL.ccodrelcta,
	  'CNRODOCID' = CASE WHEN ccodclaper <> '1' 
	                		THEN MAX(CA.cnrodoctri)
					    	ELSE MAX(CA.cnrodocide)
					END,
	CA.cCodConyug
INTO #CURAVALES0
FROM #CURPROMEDIOS CUR
	LEFT JOIN KPYDGARLINCRE GL  WITH (NOLOCK) 
		ON CUR.cCodLinCre = GL.cCodLinCre
		AND ccodestgar <> 'X'
	INNER JOIN CMACHYOCLI_MANIANA..CLIMCLIENTE CA  WITH (NOLOCK) 
		ON GL.ccodcliente = CA.ccodcliente	
	INNER JOIN GENTTipRelCta A  WITH (NOLOCK) 
		ON GL.ccodrelcta = A.ccodrelcta			
GROUP BY CUR.CCODCTACRE,CUR.CCODLINCRE,
	    cNomCliente,
	    CDIRDOMCLI, A.cdesRelCta,ccodclaper ,GL.ccodcliente,GL.ccodrelcta,CA.cCodConyug
ORDER BY CNRODOCID, ccodclaper

CREATE NONCLUSTERED INDEX IX_#CURAVALES0 ON #CURAVALES0(CNRODOCID, ccodclaper) 


-- EXTRAER CONYUGES
INSERT INTO #CURAVALES0
SELECT A.CCODCTACRE,A.CCODLINCRE,
	  cNomAval = CA.cnomcliente,
	  cAvalDir = CA.CDIRDOMCLI,
	  cdesRelCta = LEFT(LTRIM(ISNULL(A.cdesRelCta,'')),3)+ ' CONY',
	  cNroTelPer=ISNULL(CA.cNroTelPer,''),
	  CNROTELDOM=ISNULL(CA.CNROTELDOM,''),
	  CA.ccodclaper,
	  CA.ccodcliente,
	  ccodrelcta = ISNULL(A.ccodrelcta,''),
	  'CNRODOCID' = CASE WHEN CA.ccodclaper <> '1' 
	                		THEN CA.cnrodoctri
					    	ELSE CA.cnrodocide
					END,
	  CA.cCodConyug
FROM #CURAVALES0 A
	INNER JOIN CMACHYOCLI_MANIANA..CLIMCLIENTE CA  WITH (NOLOCK) 
		ON A.cCodConyug = CA.ccodcliente				
	INNER JOIN GENTTipRelCta B  WITH (NOLOCK) 
		ON A.ccodrelcta = B.ccodrelcta	
WHERE A.cCodConyug IS NOT NULL
		AND A.ccodrelcta NOT IN ('O')
ORDER BY CNRODOCID, ccodclaper  



-- EXTRAE LOS DATOS DE CALIFICACIÓN DEL RCC	        

SELECT CUR.CCODCTACRE,CUR.CCODLINCRE,CUR.cNomAval,CUR.cAvalDir,CUR.cdesRelCta,CUR.cNroTelPer,CUR.CNROTELDOM,
       nCalPorRccAva = ISNULL(CASE WHEN CUR.ccodclaper = 1
										THEN
											CASE
												WHEN RCCN.cclafin = 0 THEN RCCN.nporcal0
												WHEN RCCN.cclafin = 1 THEN RCCN.nporcal1
												WHEN RCCN.cclafin = 2 THEN RCCN.nporcal2
												WHEN RCCN.cclafin = 3 THEN RCCN.nporcal3
												WHEN RCCN.cclafin = 4 THEN RCCN.nporcal4
											END
										ELSE
											CASE

												WHEN RCCJ.cclafin = 1 THEN RCCJ.nporcal1
												WHEN RCCJ.cclafin = 2 THEN RCCJ.nporcal2
												WHEN RCCJ.cclafin = 3 THEN RCCJ.nporcal3
												WHEN RCCJ.cclafin = 4 THEN RCCJ.nporcal4
											END
															END,0.00)

INTO #CURAVALES
FROM #CURAVALES0 AS CUR
	LEFT JOIN CRICMACHYO.dbo.URIRCCMAE AS RCCN  WITH (NOLOCK) 
		ON	RCCN.CNUDOCI IS NOT NULL
			AND LTRIM(RTRIM(RCCN.CNUDOCI)) != ''
			AND CUR.CNRODOCID  = RCCN.CNUDOCI
			AND CUR.ccodclaper = 1
	LEFT JOIN CRICMACHYO.dbo.URIRCCMAE AS RCCJ  WITH (NOLOCK) 	
		ON 	RCCJ.CNUDOCI IS NOT NULL
			AND LTRIM(RTRIM(RCCJ.CNUDOCI)) != ''
			AND CUR.CNRODOCID  = RCCJ.cnudotr
			AND CUR.ccodclaper <> 1		
WHERE CUR.CNRODOCID  IS NOT NULL
			AND LTRIM(RTRIM(CUR.CNRODOCID))  != ''
			AND CUR.ccodclaper IS NOT NULL			
			AND LTRIM(RTRIM(CUR.ccodclaper))  != ''
ORDER BY CCODCTACRE  

CREATE NONCLUSTERED INDEX IX_#CURAVALES ON #CURAVALES(CCODCTACRE)    
	  
SELECT B.ccodusuadm	 
--INTO #DetAna
FROM #CURDATARCC A
	INNER JOIN ADMMUSUARIO B
		ON A.cCodUsuAna = B.CCODUSUADM
WHERE B.CCODOFIADM = '002' --@x_cCodOficin
GROUP BY B.ccodusuadm	
ORDER BY ccodusuadm 
CREATE NONCLUSTERED INDEX IX_#DetAna ON #DetAna (ccodusuadm)			

	  

		

SELECT A.cCodUsuAdm, A.cNomUsuAdm, A.cComiteUsu,cNumTelPer=rtrim(B.cNumTelPer) ,B.cCodTipTel

INTO #DetAna1

FROM ADMMUSUARIO A

	INNER JOIN #DetAna 

		ON A.cCodUsuAdm = #DetAna.ccodusuadm

	LEFT JOIN sipdtelefonoper B  WITH (NOLOCK) 

		ON A.ccodusuadm = B.CCODPERSON

CREATE NONCLUSTERED INDEX IX_#DetAna1 ON #DetAna1 (cCodUsuAdm)			

--RETORNA LOS LOS NÚMEROS CELULARES DE LOS ANALISTAS

SELECT cCodUsuAdm, cNomUsuAdm, cComiteUsu,

	CEI=ISNULL([CEI],'No Reg.'),RPM=ISNULL([RPM],'No Reg.')

	INTO #DetAna2

	FROM (SELECT cCodUsuAdm, cNomUsuAdm, cComiteUsu,cNumTelPer,cCodTipTel

		FROM #DetAna1) P

	PIVOT 

	(MAX(cNumTelPer)

	FOR cCodTipTel IN ([CEI],[RPM]))AS PVT

ORDER BY ccodusuadm

CREATE NONCLUSTERED INDEX IX_#DetAna2 ON #DetAna2(cCodUsuAdm)

	  

SELECT CONVERT(BIT,0) AS lconestado ,CUR.cNomCliente, CUR.cDirDomCli, 
	   CUR.cCodUsuAna,  CUR.cCodUsuCar,
	   CUR.cCodCtaCre,  CUR.CNRODOCID,nSalCap,CUR.cCodUsuAnaCre ,
	   --nSalCapsol = nSalCap * CASE WHEN CUR.cCodTipMon='1' THEN 1 ELSE @x_ntipcamfij END,
	   nSalCap,
	   --ANA.cNomUsuAdm,  
	   CUR.NPORCAL0,MON.cDesTipMon,CUR.cCodTipMon,
	   --lNomUsuAdm=ISNULL(ANA.cNomUsuAdm,'S'),
	   D.cNomDepart,PRO.cnomProvin,DIS.cnomdistri,ZON.cnomzona,
	   CAST(RTRIM(D.cNomDepart)+ '-' +RTRIM(PRO.cnomProvin) + '-' + RTRIM(DIS.cnomdistri) + '-' + RTRIM(ZON.cnomzona) AS VARCHAR(150))AS cUbigeo,
	   --ANA.CEI,ANA.RPM,
	   cCodExpCli,CUR.cCodCliente,CUR.nNumCuoApr,nCuoVen,p.nProDiasVen,cNumCuoPla,
	   --CURAVA.cNomAval,CURAVA.cAvalDir ,CURAVA.cdesRelCta, CURAVA.nCalPorRccAva,CURAVA.cNroTelPer,CURAVA.CNROTELDOM,
	   CNOMESTRAT = UPPER(ISNULL(SC.CNOMESTRAT,'')),
	   CRESPONEST = UPPER(ISNULL(SC.CRESPONEST,'')),
	   CPEREJECUT = UPPER(ISNULL(SC.CPEREJECUT,'')),
	   CUR.nMoncapdes,CUR.TELDOMCLI,CUR.TELPERCLI
	FROM #CURDATARCC CUR
		INNER JOIN #CURPROMEDIOS P  WITH (NOLOCK) 
			ON CUR.CCODCTACRE = P.CCODCTACRE
		--INNER JOIN #DetAna2 ANA
			--ON CUR.ccodusuana = ANA.ccodusuadm
		INNER JOIN GENTMONEDA MON  WITH (NOLOCK) 
			ON CUR.cCodTipMon = MON.cCodTipMon
		LEFT JOIN  GENTDepartame D   WITH (NOLOCK) 
			ON CUR.cCodDepDom = D.cCodDepart
		LEFT JOIN GENTProvincia PRO   WITH (NOLOCK) 
			ON CUR.cCodDepDom = PRO.ccodDepart
				AND CUR.cCodProDom = PRO.cCodProvin
		LEFT JOIN GENTDistrito DIS  WITH (NOLOCK) 
			ON CUR.cCodDepDom = DIS.ccodDepart
				AND CUR.cCodProDom = DIS.cCodProvin
				AND CUR.cCodDisDom = DIS.cCodDistri
		LEFT JOIN GENTZOna ZON  WITH (NOLOCK) 
			ON CUR.cCodDepDom = ZON.ccodDepart
			AND CUR.cCodProDom = ZON.cCodProvin
			AND CUR.cCodDisDom = ZON.cCodDistri
			AND CUR.cCodZonDom = ZON.cCodZona
		--LEFT JOIN #CURAVALES CURAVA
			--ON CUR.CCODCTACRE = CURAVA.CCODCTACRE	
				--AND P.CCODLINCRE = CURAVA.CCODLINCRE		
		LEFT JOIN KPYTSTRATXSCO SC  WITH (NOLOCK) 
			ON CONVERT(NUMERIC(9,2), CUR.CVALSCOSTR) BETWEEN CONVERT(NUMERIC(9,2), SC.CVALMINSCO) 
				AND CONVERT(NUMERIC(9,2), SC.CVALMAXSCO)
				AND CUR.NDIAATRCRE BETWEEN SC.NDIAMINMOR AND SC.NDIAMAXMOR
				AND CUR.CCODTIPCRE = SC.CCODTIPCRE
				AND CUR.CCODPRODUC = SC.CCODPRODUC
				AND CUR.CCODSUBPRO = SC.CCODSUBPRO
ORDER BY CUR.ccodctacre




DROP TABLE #DetAna

DROP TABLE #DetAna1

DROP TABLE #DetAna2

DROP TABLE #CURDATA

DROP TABLE #CURDATADOC

DROP TABLE #CURDATARCC

DROP TABLE #CURDetCliDes

DROP TABLE #CURPROMEDIOS

DROP TABLE #CURAVALES

DROP TABLE #CURAVALES0



------------------------------------------------------------------------------------------------

-- KPY_DetCliAmpVis_sp
