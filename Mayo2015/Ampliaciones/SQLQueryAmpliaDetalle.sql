Select top 5 cCodZona,* from KPYHDetCliDes

select cCodEstRef,cMotCamPla,* from KPYDCreRefina
where cMotCamPla = '8' and cCodEstRef = 'R'

select top 5 *  from KPYMSolicitud  A
where A.cCodMotSol = '3'  AND cCodEstSol = 'B' AND cCodSitSol = 'I'

		select cCodEstRef from KPYDCreRefina
		group by cCodEstRef

		select * from kpytmotcampla
		select A.cCodSitSol
		from KPYMSolicitud A
		group by A.cCodSitSol


		select * from KPYTMotSolici where cCodMotSol = '3' 
		select * from KPYTEstSolCre WHERE cCodEstSol = 'B'
		SELECT * FROM KPYTSitSolici WHERE cCodSitSol = 'I'

		SELECT	nNumCont = ROW_NUMBER() OVER(ORDER BY cCtaCreRef),
					cCtaCreRef , cCtaCreAnt , YEAR(B.dFecDesCre), B.dFecDesCre
			FROM KPYMSolicitud  A
				INNER JOIN KPYMCRECONVEN B
					ON A.cCodSolCre = B.cCodSolCre 
				INNER JOIN KPYDCreRefina C
					ON A.cCodSolCre = C.cCodSolCre 
			WHERE --cCodClient  = @lcCodCliente 
				--AND 
					A.cCodMotSol = '3'    
				AND A.cCodEstSol = 'B'
				AND A.cCodSitSol = 'I'
				AND C.cCodEstRef = 'R'
				AND YEAR(B.dFecDesCre) =  YEAR(GETDATE()) 	
				--(22,325 row(s) affected)


		select top 5 CCODESTCUO,*  FROM KPYDPLANPAGCRE	
		SELECT cCodUltPla , * 
		FROM GenMCreCli (nolock) 
		WHERE ccodCtaCre = '107002102001135723' --@x_cCodCtaCre 


				--- PORCENTAJE DE PAGO                  
					SELECT --@lnPorPagCuo = 
							SUM( CASE WHEN CCODESTCUO = 'P' THEN 1 
								 ELSE 0 
								 END)*100.00/COUNT(*) as 'Calculo'
								 --,*
					FROM KPYDPLANPAGCRE	
					WHERE	CCODCTACRE = '107002102001135723' -- @x_cCodCtaCre
							AND CCODPLAPAG = '001' -- dbo.KPY_CodPlaAct_fx(@x_cCodCtaCre)
-----------------------------------------------------------------------------------------

	--drop table #CURDetCliDes
	CREATE TABLE #CURDetCliDes
	(cCodUsuAna CHAR(6),
	cCodUsuCar CHAR(6),
	cCodCtaCre CHAR(18))

	--01
		INSERT INTO #CURDetCliDes
		SELECT 	cCodUsuAna=DES.cCodUsuAna, cCodUsuCar=DES.cCodUsuCar,
			cCodCtaCre=DES.cCodCtaCre
		FROM KPYHDetCliDes DES  WITH (NOLOCK) 
		INNER JOIN KPYTCTARELCLI PTE  WITH (NOLOCK) 
				ON DES.cCodCtaCre = PTE.cCodCtaCre
		WHERE DES.cCodTipCar = 'AMP'
			--AND DES.cCodPeriod	  =	@x_ccodPeriod
			AND DES.cCodEstCar	IN ('A','C')				
			--AND DES.ccodoficin= '002'--@x_cCodOficin
			--AND DES.cCodTipMon LIKE @x_cCodTipMon	
			AND PTE.cCodAplica = 'KPY'
			AND PTE.cCodEstCta = 'F'
		GROUP BY DES.cCodUsuAna, DES.cCodUsuCar,
				DES.cCodCtaCre
		ORDER BY DES.cCodCtaCre	
	
	--02
	-- drop table #CURDATA
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

	--03 SE FILTRA POR LAS CUOTAS VENCIDAS
	--drop table #CURDATADOC
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

	--04  SE FILTAR CLIENTES QUE TIENE CALIFICACIÓN NORMAL Y SE EXTRE SU PORCENTAJE
		-- drop table #CURDATARCC
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

	--05 EXTRAEMOS EL PROMEDIO DE DIAS VENCIDOS
	 -- drop table #CURPROMEDIOS
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

		SELECT * FROM #CURDATARCC

	  --06  SE EXTRAE LOS DATOS DEL AVAL

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

	--07
	-- Drop table #DetAna
	SELECT B.ccodusuadm	 
	INTO #DetAna
	FROM #CURDATARCC A
		INNER JOIN ADMMUSUARIO B
			ON A.cCodUsuAna = B.CCODUSUADM
	--WHERE B.CCODOFIADM = '002' --@x_cCodOficin
	GROUP BY B.ccodusuadm	
	ORDER BY ccodusuadm 

	--08
	SELECT A.cCodUsuAdm, A.cNomUsuAdm, A.cComiteUsu--,cNumTelPer=rtrim(B.cNumTelPer) ,B.cCodTipTel
	INTO #DetAna1
	FROM ADMMUSUARIO A
		INNER JOIN #DetAna 
				ON A.cCodUsuAdm = #DetAna.ccodusuadm
		--LEFT JOIN sipdtelefonoper B  WITH (NOLOCK) 
				--ON A.ccodusuadm = B.CCODPERSON

	--09 RETORNA LOS LOS NÚMEROS CELULARES DE LOS ANALISTAS

		SELECT cCodUsuAdm, cNomUsuAdm, cComiteUsu,
			CEI=ISNULL([CEI],'No Reg.'),RPM=ISNULL([RPM],'No Reg.')
			INTO #DetAna2
			FROM (SELECT cCodUsuAdm, cNomUsuAdm, cComiteUsu--,cNumTelPer,cCodTipTel
				FROM #DetAna1) P
			PIVOT 
			(MAX(cNumTelPer)
			FOR cCodTipTel IN ([CEI],[RPM]))AS PVT
		ORDER BY ccodusuadm

	--10 final

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