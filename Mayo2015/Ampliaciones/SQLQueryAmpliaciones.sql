sp_helptext KPY_LisValCreAmp_sp

/************************************************************************************************
*     Objetivo					:  Valida si un credito es apto para que se  pueda  ampliar  
*     Sintaxis de ejemplo:  	  

	DECLARE @x_cResVal VARCHAR(5) , @X_CNOMANA CHAR(100) ,@X_CnomOfi char(100)
	Exec KPY_LisValCreAmp_sp
			@x_cCodCtaCre	= '107004101005053993',
			@x_cResValAmp	= @x_cResVal OUTPUT ,
			@X_cNomAnaCre   = @X_CNOMANA OUTPUT ,
			@x_cDesOficin   = @X_CnomOfi OUTPUT 
	SELECT @x_cResVal, @X_CNOMANA,	@X_CnomOfi	

*************************************************************************************************/

CREATE PROCEDURE KPY_LisValCreAmp_sp
	 @x_cCodCtaCre CHAR(18) ,
	 @x_cResValAmp VARCHAR(15) OUTPUT,
	 @X_cNomAnaCre CHAR(200) OUTPUT ,
	 @x_cDesOficin CHAR(100 )OUTPUT 
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @IDOC			INT,			@lnTipValida	INT = 2, 
			@lXMLCur		XML,			@lnnumCrecmac	INT ,	
			@lccodIde		VARCHAR(20),	@lnNumEntFin	INT, 
			@lcCodCliente	CHAR(12),		@lnNumCreVig	INT, 
			@lnCreBloRef	INT,			@lcCodMotSol	CHAR(1)= '3',
			@lnPlaDiaCre	INT ,			@lcCodDocIde	VARCHAR(30),
			@lcResult		VARCHAR (8000), @lXMLCurExc		XML,
			@lnSalGasRef	NUMERIC(14,4),	@lnMonRefCre	NUMERIC(14,4),
			@lcCodMonSol	CHAR(1),		@lcIndOpiRef	CHAR(2),
			@lnMonAprSol	NUMERIC (14,4),
			---- REPROGRAMACION
			@lcCodCtaCre	CHAR(18),		@lnNumRepCre	NUMERIC (14,2),
			@lnAtrCuo		INT,			@lnAtrPro		NUMERIC(14,4),
			@lnCapPag		NUMERIC(14,4),	@lSaldoInt		NUMERIC(14,4),
			@lSaldoMor 		NUMERIC(14,4),	@lSalGasRep		NUMERIC(14,4),
			@lcCodTipCre	CHAR(2),		@lcCodModCre	CHAR(2),
			@lcEstCreCon	CHAR(1),		@lnNumCuoApr	INT,
			@lcCodTipRep	CHAR(1),		@lcCodOficin	CHAR(3),
			----- AMPLIACION	
			@lnCont			INT	 = 1,		@lnNumReg		INT	,
			@lnNumAmpCre	INT = 1,		@lcCodCtaAmp	CHAR(18) ,
			@lnPorPagCuo	NUMERIC (14,2),	@lnProAtrCuoPag	NUMERIC (14,2),
			@lnAtrCuoPag	INT,			@lnNumCreVen	INT,
			@lcCalCreCli	CHAR(1),		@lnNumDoc		VARCHAR(15),
			@lcClaPer		CHAR(1),		@lcCodSubPro	CHAR(2),
			@lcCodTipDes	CHAR(2),		@lcCodProduc	CHAR(2),
			@lcCodSolCre	CHAR(10),		@lcOpiTipCre	CHAR(2),
			@lcOpiEndCli	CHAR(2),		@lnTipCam		NUMERIC(14,4),
			@lSalRCC		NUMERIC(14,4),	@lnMonSolSol	NUMERIC(14,4),
			@lnMonSolDol	NUMERIC(14,4),	@lcCtaCreAmp	CHAR(18),
			@lnSalCre		NUMERIC(14,4),	@lnMonEndFin	NUMERIC(14,4),
			@lnPlaMesCre	NUMERIC (14,4),	@lcCodTotPro	CHAR(6),
			@lnVenAnuCli	NUMERIC(14,2),	@lnNumCreSol	INT,
			@lcCtaAmp		CHAR(18) , 		@lnRepCuoBal	INT,
			@lcCodTipEva	CHAR(2),		@lnSalIntFec 	NUMERIC(14,4),
			@lnNumEvaSol	INT				
			--Req.

			SELECT @lnNumEvaSol = COUNT(*) 
			FROM KPYDEVASOLICI A
				  INNER JOIN KPYMSolicitud B
						ON A.cCodSolCre = B.cCodSolCre
				  INNER JOIN KPYMCRECONVEN C
					ON B.cCodSolCre = C.cCodSolCre
			WHERE C.cCodCtaCre = @x_cCodCtaCre
			--

			DECLARE @CURCtaAmp TABLE (	nNumCont INT, 
										cCtaCreRef CHAR (18),
										cCtaCreAnt CHAR(18)  
									 )
									 
			SELECT @lnTipCam = cvalvarapl 
			FROM ADMMVARIABLE
			WHERE ccodoficin = '001'
					AND CNOMVARAPL = 'gnTipCamFij'				

			SELECT
				@X_cNomAnaCre  = B.cNomPerson  ,
				@x_cDesOficin  = C.cDesOficin 
			FROM KPYMCRECONVEN A
				INNER JOIN SIPMPersonal B
					ON A.cCodUsuAna = B.cCodPerson 
				INNER JOIN GENTOficinas C
					ON A.cCodOficin = C.cCodOficin 	
			WHERE A.cCodCtaCre = @x_cCodCtaCre 
						

			SELECT 
					@lcCodMotSol = '3',
					@lcCodCliente = B.cCodCliente ,
					@lnPlaDiaCre = nNumCuoApr*nNumDiaApr, 	
					@lnPlaMesCre = (nNumCuoApr*nNumDiaApr+nNumDiaGra)/30 ,							
					@lcCodTipCre = cCodTipCre,			
					@lcCodProduc = cCodProduc,  
					@lcCodSubPro = cCodSubPro , 
					@lcCodModCre = cCodModCre, 
					@lnNumCuoApr = nNumCuoApr,
					@lnMonAprSol = (nMonCapDes - nMonCapPag) *	CASE 
																	WHEN cCodTipMon = 1 THEN 1
																	ELSE @lnTipCam
																END,
					@lcCodMonSol = cCodTipMon			
			FROM KPYMCRECONVEN A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaCre = B.cCodCtaCre 
			WHERE A.cCodCtaCre = @x_cCodCtaCre	
				

			SELECT	@lcCodDocIde =	CASE 
										WHEN ccodclaper = '1' THEN cNroDocIde
										ELSE cNroDocTri
									END 
			FROM CMACHYOCLI_MANIANA..climclientes 
			WHERE cCodCliente = @lcCodCliente
						
			SET @lnVenAnuCli = DBO.KPY_DevNivVenCli_fx (@lcCodCliente)		

----------------------------------------------------------------

			DECLARE @DetPerInt	TABLE	(ccodIde VARCHAR(20), ccodclaper CHAR(1))
			DECLARE @CreTar		TABLE	(cCodEmp CHAR(5))
			DECLARE @detcreRcc	TABLE	(ncanent INT, cCodEmp CHAR(5), cNomIfi VARCHAR(256),
										 cnomcli VARCHAR(280))			

			SET @lcCtaAmp = @x_cCodCtaCre
			SELECT @lnNumCrecmac = COUNT(*)
			FROM kpymcreconven A 
				INNER JOIN GENMCreCli B
					ON A.ccodctacre = B.ccodctacre
			WHERE B.cCodCliente = @lcCodCliente
				AND cestcrecon LIKE '[FHI]'	
				AND A.ccodtipcre + A.cCodProduc + A.cCodSubPro NOT IN('030306','030316','030414','030513')
				AND cCodModCre NOT IN  ('05','06')
				AND A.cCodCtaCre != @lcCtaAmp	
				

			SELECT @lnNumCreSol = COUNT(*)
			FROM KPYMCRECONVEN 
			WHERE cCodCtaCre = @x_cCodCtaCre
					AND (	cCodtipcre + cCodProduc + cCodSubPro IN ('030306','030316','030414','030513')
					OR cCodModCre  IN  ('05','06') 
						)						

			SET @lnNumCrecmac =		ISNULL(@lnNumCrecmac,0) + CASE 
																	WHEN ISNULL(@lnNumCreSol,0) > 0 THEN 0
																	ELSE  1
																END																														
			--- Número de créditos vigentes para Refinanciar, ampliar o reprogramar																
			SELECT @lnNumCreVig = COUNT(*)
			FROM kpymcreconven A 
			INNER JOIN GENMCreCli B
				ON A.ccodctacre = B.ccodctacre
			WHERE B.cCodCliente = @lcCodCliente
				AND cEstCreCon LIKE '[FH]'

			INSERT @DetPerInt
			SELECT	CASE WHEN ccodclaper = '1' 
						THEN cNroDocIde
						ELSE cNroDocTri
					END as ccodIde, ccodclaper
			FROM CMACHYOCLI_MANIANA..climclientes A 
			WHERE cCodCliente = @lcCodCliente

			SELECT @lccodIde = RTRIM(LTRIM(ISNULL(ccodIde,'')))
			FROM @DetPerInt

			INSERT INTO @CreTar(cCodEmp)
			SELECT DISTINCT cCodEmp
			FROM CRICMACHYO_DIARIO..URIRCCMAE MAE 
				INNER JOIN cricmachyo_diario..URIRCCSAL DET
					ON MAE.cCodSbs = DET.cCodSbs
				INNER JOIN @DetPerInt per
					ON MAE.CNUDOCI = per.ccodIde
			WHERE LEFT(DET.CCTACON,2) + '0' + SUBSTRING(DET.CCTACON,4,1)= '7205'
				AND ccodclaper = '1' 
				AND MAE.CTIDOCI = '1'
				AND cCodEmp <> '00107' 
	

			INSERT INTO @CreTar(cCodEmp)
			SELECT DISTINCT cCodEmp
			FROM CRICMACHYO_DIARIO..URIRCCMAE MAE 
				INNER JOIN CRICMACHYO_DIARIO..URIRCCSAL DET
					ON MAE.cCodSbs = DET.cCodSbs
				INNER JOIN @DetPerInt per
					ON MAE.cnudotr = per.ccodIde
			WHERE LEFT(DET.CCTACON,2) + '0' + SUBSTRING(DET.CCTACON,4,1)= '7205'
				AND ccodclaper <> '1'
				AND cCodEmp <> '00107' 	


			INSERT INTO @detcreRcc
				(NCANENT, cCodEmp, cNomIfi, cnomcli)
			SELECT DISTINCT NCANENT, DET.cCodEmp, cNomIfi, cnomcli
			FROM CRICMACHYO_DIARIO..URIRCCMAE MAE 
				INNER JOIN CRICMACHYO_DIARIO..URIRCCSAL DET
					ON MAE.cCodSbs = DET.cCodSbs
				LEFT JOIN  CRICMACHYO_DIARIO..URIRCCMIFI IFI
					ON DET.ccodemp = IFI.cCodIfi
				INNER JOIN @CreTar TAR
					ON DET.CCODEMP = TAR.CCODEMP
				INNER JOIN @DetPerInt per
					ON MAE.CNUDOCI = per.ccodIde
			WHERE ccodclaper = '1' 
				AND MAE.CTIDOCI = '1'
				AND DET.cCodEmp <> '00107' 
				AND DET.NSALDOS > 0
				AND CCTACON like '14_1__02%'
				

			INSERT INTO @detcreRcc
				(NCANENT, cCodEmp, cNomIfi, cnomcli)
			SELECT DISTINCT NCANENT, DET.cCodEmp, cNomIfi, cnomcli
			FROM CRICMACHYO_DIARIO..URIRCCMAE MAE 
				INNER JOIN cricmachyo..URIRCCSAL DET
					ON MAE.cCodSbs = DET.cCodSbs
				LEFT JOIN  cricmachyo..URIRCCMIFI IFI
					ON DET.ccodemp = IFI.cCodIfi
				INNER JOIN @CreTar TAR
					ON DET.CCODEMP = TAR.CCODEMP
				INNER JOIN @DetPerInt per
					ON MAE.cnudotr = per.ccodIde
			WHERE ccodclaper <> '1'
				AND DET.cCodEmp <> '00107' 
				AND DET.NSALDOS > 0
				AND CCTACON like '14_1__02%'	
	

			INSERT INTO @detcreRcc
				(NCANENT, cCodEmp, cNomIfi, cnomcli)
			SELECT DISTINCT NCANENT, cCodEmp, cNomIfi, cnomcli
			FROM CRICMACHYO_DIARIO..URIRCCMAE MAE 
			INNER JOIN CRICMACHYO_DIARIO..URIRCCSAL DET
				ON MAE.cCodSbs = DET.cCodSbs
			INNER JOIN @DetPerInt per
				ON MAE.CNUDOCI = per.ccodIde
			LEFT JOIN  CRICMACHYO_DIARIO..URIRCCMIFI IFI
				ON DET.ccodemp = IFI.cCodIfi
			WHERE	ccodclaper = '1' 
				AND cCodEmp <> '00107' 
				AND LEFT(DET.CCTACON,2) + '0' + SUBSTRING(DET.CCTACON,4,1) NOT IN ('7205','8109','8404')
				AND MAE.CTIDOCI = '1'

												
			INSERT INTO @detcreRcc
			SELECT DISTINCT NCANENT, cCodEmp, cNomIfi, cnomcli
			FROM CRICMACHYO_DIARIO..URIRCCMAE MAE 
			INNER JOIN CRICMACHYO_DIARIO..URIRCCSAL DET
				ON MAE.cCodSbs = DET.cCodSbs
			INNER JOIN @DetPerInt per
				ON MAE.cnudotr = per.ccodIde
			LEFT JOIN  CRICMACHYO_DIARIO..URIRCCMIFI IFI
				ON DET.ccodemp = IFI.cCodIfi
			WHERE	ccodclaper <> '1'
					AND cCodEmp <> '00107' 
					AND LEFT(DET.CCTACON,2) + '0' + SUBSTRING(DET.CCTACON,4,1) NOT IN ('7205','8109','8404')	
																		

			SELECT @lnNumEntFin = COUNT(DISTINCT cCodEmp)	
			FROM @DetCreRcc				
			----- REFINANCIADO	
				-- Número de créditos bloqueados para Refinanciar

			SELECT @lnCreBloRef = COUNT(*)
			FROM kpymcreconven A 
			INNER JOIN GENMCreCli B
				ON A.ccodctacre = B.ccodctacre
			WHERE B.cCodCliente = @lcCodCliente
				AND cEstCreCon LIKE '[FHI]'
				AND lconbloque = 1			
				-- Saldo de Gasto

			SELECT  
					@lnSalGasRef = ISNULL(SUM(B.nMonGasPro - B.nMonGasPag),0),
					@lnMonRefCre = ISNULL(SUM(B.nMonCapDes - B.nMonCapPag + B.nMonIntFec - B.nMonIntPag + B.nMonMorPro - B.nMonMorPag),0)
			FROM  KPYMCRECONVEN B           
			WHERE cCodCtaCre =  @x_cCodCtaCre            
			GROUP BY cCodCtaCre				
				

			-- PARA OPINION DE GERENCIA DE RIESGOS
			SET @lcIndOpiRef = 'NO'	
			--	----- FIN DE REFINANCIADO			

			----- REPROGRAMACION

			SELECT   @lcCodTipRep = '',
					 @lcCodCtaCre = ''				

			SELECT	@lcEstCreCon = cEstCreCon,			
					@lcCodSolCre = cCodSolCre,
					@lcCodTotPro = cCodTipCre + cCodProduc + cCodSubPro 
			FROM KPYMCRECONVEN  
			WHERE cCodCtaCre = @x_cCodCtaCre
			
			SELECT @lnNumRepCre = COUNT(*) 
			FROM KPYDCREREFINA
			WHERE	cmotcampla = '2'
					AND cCtaCreRef	= @x_cCodCtaCre
					AND CCODESTREF	= 'R'
					AND CINDPREPAG != 'S'


			SELECT @lnRepCuoBal = COUNT(*) 
			FROM KPYDCREREFINA
			WHERE cmotcampla = '2'
				AND cCtaCreRef	= @lcCodCtaCre
				AND CCODESTREF	= 'R'
				AND CINDPREPAG != 'S'
				AND cCodTipRep = '3'		
						

			SELECT	@lnAtrCuo = MAX(ndiavencuo),
					@lnAtrPro = SUM(CASE 
										WHEN ndiavencuo < 0 THEN 0.00 
										ELSE ndiavencuo 
									END)/COUNT (a.ccodctacre) 
			FROM KPYMCreConven A
				INNER JOIN genmcrecli B
					ON a.ccodctacre = b.ccodctacre
				INNER JOIN kpydplanpagcre C
					ON a.ccodctacre = c.ccodctacre
						AND b.ccodultpla = c.ccodplapag
			WHERE	cEstCreCon = 'F' 
					AND a.ccodctacre = @x_cCodCtaCre
			GROUP BY a.ccodctacre	

			SELECT	@lnCapPag = SUM(c.nMonCapPag ),
					@lSaldoInt = SUM(CASE 
										WHEN C.nMonIntFec - c.nMonIntPag < 0 THEN  C.nMonIntPro - c.nMonIntPag
										ELSE C.nMonIntFec - c.nMonIntPag
									  END ),		
					@lSaldoMor = SUM( c.nMonMorpro-c.nMonMorPag),
					@lSalGasRep = SUM( c.nMonGasPro-c.nMonGasPag)
			FROM kpymcreconven AS a 
				INNER JOIN genmcrecli AS b
					ON a.ccodctacre = b.ccodctacre
				INNER JOIN kpydplanpagcre AS c
					ON a.cCodCtaCre = c.cCodCtaCre
						AND b.ccodultpla = c.ccodplapag
			WHERE	cEstCreCon = 'F' 	
					AND cCodEstCuo ='E' 
					AND a.ccodctacre = @x_cCodCtaCre
			GROUP BY a.ccodctacre
					

			SELECT @lcCodOficin = cCodOficin
			FROM KPYMCRECONVEN
			WHERE cCodCtaCre = @x_cCodCtaCre

			--- FIN DE REPORGRAMACION					

			-- variacion

			SELECT @lnSalIntFec = (a.nMonIntFec - a.nMonIntPag)
			FROM kpymcreconven AS a 
				INNER JOIN genmcrecli AS b
					ON a.ccodctacre = b.ccodctacre
			WHERE	cEstCreCon = 'F' 	
					AND a.ccodctacre = @x_cCodCtaCre								

			-- fin de variacion

			

			--- AMPLIACIÓN

			SELECT @lcCodCtaAmp = @x_cCodCtaCre 	
							

			--- NUMERO DE AMPLIACIONES ---		 
			INSERT @CURCtaAmp             
			SELECT	nNumCont = ROW_NUMBER() OVER(ORDER BY cCtaCreRef),
					cCtaCreRef , cCtaCreAnt 
			FROM KPYMSolicitud  A
				INNER JOIN KPYMCRECONVEN B
					ON A.cCodSolCre = B.cCodSolCre 
				INNER JOIN KPYDCreRefina C
					ON A.cCodSolCre = C.cCodSolCre 
			WHERE --cCodClient  = @lcCodCliente 
				--AND 
					cCodMotSol = '3'    
				AND cCodEstSol = 'B'
				AND cCodSitSol = 'I'
				AND cCodEstRef = 'R'
				AND YEAR(B.dFecDesCre) =  YEAR(GETDATE()) 				

			SELECT @lnNumReg = COUNT(*) 
			FROM @CURCtaAmp
	
			WHILE  @lnCont <= @lnNumReg
			BEGIN
				SELECT @lcCodCtaAmp =  cCtaCreAnt
				FROM @CURCtaAmp
				WHERE cCtaCreRef =  @lcCodCtaAmp 
				IF @@ROWCOUNT > 0
					SELECT @lnNumAmpCre = @lnNumAmpCre + 1		
				SET @lnCont = @lnCont + 1
			END
			--- FIN NUMERO DE AMPLIACIONES ---				 			

			--- PORCENTAJE DE PAGO                  
			SELECT @lnPorPagCuo = SUM(	CASE 
											WHEN CCODESTCUO = 'P' THEN 1 
											ELSE 0 
										END)*100.00/COUNT(*)
			FROM KPYDPLANPAGCRE	
			WHERE	CCODCTACRE = @x_cCodCtaCre
					AND CCODPLAPAG = dbo.KPY_CodPlaAct_fx(@x_cCodCtaCre)
			-------

			--- PORMEDIO DE ATRASO DE CUOTAS PAGADAS
			SELECT	@lnProAtrCuoPag = ROUND(SUM(	CASE 
														   WHEN NDIAVENCUO < 0.00 THEN 0.00 
														   ELSE NDIAVENCUO 
													 END)/COUNT(cnumcuopla),0)
			FROM kpymcreconven A (NOLOCK) 
				INNER JOIN genmcrecli B (NOLOCK)
					  ON A.ccodctacre = B.ccodctacre
				INNER JOIN KPYDPLANPAGCRE C (NOLOCK)
					  ON A.ccodctacre = C.ccodctacre
							AND B.ccodultpla = C.ccodplapag
			WHERE	cEstcreCon = 'F'
					AND (CCODESTCUO = 'P' OR (CCODESTCUO = 'E' AND NDIAVENCUO > 0.00))
					AND ccodcliente = @lcCodCliente                    					
					
			 --- ATRASO DE CUOTAS PAGADAS

			SELECT @lnAtrCuoPag = MAX(ndiavencuo)
			FROM KPYMCRECONVEN KPY
				INNER JOIN GENMCRECLI GEN
					ON kpy.ccodctacre = gen.ccodctacre
				INNER JOIN KPYDPlanPagCre PPG
					ON kpy.ccodctacre = ppg.ccodctacre
						AND gen.ccodultpla = ppg.ccodplapag
			WHERE	cCodEstCuo = 'P'
					AND ccodcliente = @lcCodCliente
					AND kpy.cEstCreCon LIKE '[FHI]'
			 ----	 

			 --- NUMERO DE CREDITOS VENCIDOS

			SELECT @lnNumCreVen = COUNT(*)
			FROM KPYMCRECONVEN 
				INNER JOIN GENMCRECLI
				   ON KPYMCRECONVEN.cCodCtaCre = GENMCRECLI.cCodCtaCre
			WHERE cCodCliente = @lcCodCliente
				  AND NDIAATRCRE > 0
				  AND CESTCRECON = 'F'
--	 -----		
			 --- CALIFICACION DEL CLIENTE
			 SELECT     @lnNumDoc = CASE WHEN ccodclaper = '1'
										 THEN cNroDocIde
										 ELSE cNroDocTri
									END,
						@lcClaPer = cCodClaPer
			FROM CMACHYOCLI_MANIANA..climclientes cli 
				  where ccodcliente = @lcCodCliente

			IF @lcClaPer = '1'
			BEGIN
				SELECT @lcCalCreCli = cClaFin
				FROM CRICMACHYO_DIARIO..URIRCCMAE
				WHERE	cNuDoCi = @lnNumDoc
						AND (cTiDoci = '1' OR cTiDoci ='')				

				-- ENDEUDAMIENTO RCC									

				SELECT @lSalRCC = SUM(B.nSaldos)
				FROM CRICMACHYO_DIARIO..URIRCCMAE A WITH (NOLOCK)
					INNER JOIN CRICMACHYO_DIARIO..URIRCCSAL B WITH (NOLOCK)
						ON A.cCodSBS = B.cCodSBS		
				WHERE	cNuDoCi = @lnNumDoc
						AND LEFT(B.CCTACON,2)+'0'+SUBSTRING(B.CCTACON,4,1) IN (	'1401','1403',
																				'1404', '1405',
																				'1406', '7101',
																				'7102', '7103',
																				'7104', '8103')
						AND B.CCODEMP <> '00107'
						AND SUBSTRING(CCTACON,5,2)!='04'
						AND A.CTIDOCI = '1'
			END			
			ELSE 
			BEGIN
				SELECT @lcCalCreCli = cClaFin
				FROM CRICMACHYO_DIARIO..URIRCCMAE
				WHERE cNuDoTr = @lnNumDoc				

				-- ENDEUDAMIENTO RCC				
				SELECT  @lSalRCC =  SUM(B.nSaldos)
				FROM CRICMACHYO..URIRCCMAE A WITH (NOLOCK)
					INNER JOIN CRICMACHYO..URIRCCSAL B WITH (NOLOCK)
						ON A.cCodSBS = B.cCodSBS		
				WHERE	cNuDoTr = @lnNumDoc
						AND LEFT(B.CCTACON,2)+'0'+SUBSTRING(B.CCTACON,4,1) IN (	'1401','1403',
																				'1404', '1405',
																				'1406', '7101',
																				'7102', '7103',
																				'7104', '8103')
						AND B.CCODEMP <> '00107'
						AND SUBSTRING(CCTACON,5,2)!='04'
			END		
	
			SELECT	@lnMonSolDol =	(nMonCapDes - nMonCapPag) / CASE 
																	WHEN cCodTipMon = 2 THEN 1
																	ELSE @lnTipCam
																END,
					@lnMonSolSol =  (nMonCapDes - nMonCapPag) * CASE
																	WHEN cCodTipMon = 1 THEN 1
																	ELSE @lnTipCam
																END
			FROM KPYMCRECONVEN 
			WHERE	cCodCtaCre  = @x_cCodCtaCre
					AND CCODTIPCRE != '04'		
					

			SELECT @lcCtaCreAmp = cCtaCreRef
			FROM KPYDCreRefina 
			WHERE cCtaCreRef  = @x_cCodCtaCre			

			SELECT @lnSalCre = SUM((A.NMONCAPDES - A.NMONCAPPAG)*	CASE 
																WHEN A.CCODTIPMON = '1' THEN 1
																ELSE @lnTipCam
															END )
			FROM KPYMCRECONVEN A
					INNER JOIN GENMCRECLI B
						ON A.CCODCTACRE = B.CCODCTACRE 
					LEFT JOIN KPYDCreRefina C
						ON a.cCodCtaCre = C.cctacreant
							AND a.cCodCtaCre = @x_cCodCtaCre
				WHERE	B.CCODCLIENTE = @lcCodCliente
						AND A.CESTCRECON IN ('F','H','I')
						AND A.CCODTIPCRE != '04'
						AND C.cCtaCreAnt IS NULL

			SELECT @lnMonEndFin = ROUND(ISNULL(@lnMonSolSol,0.00) + ISNULL(@lnSalCre,0.00) + ISNULL(@lSalRCC,0.00),2,2)	
						
						
			SET @lcOpiTipCre = 'NO'		
			SET @lcOpiEndCli = 'NO'							        		

				--- DESTINO DE CREDITO
				SELECT @lcCodTipDes = cCodTipDes
			    FROM KPYDTipDesCre
			    WHERE	cCodTipDes IN ('15','17','18','20','21')
						AND CCODSOLCRE = @lcCodSolCre
				 ----
				 

		--- FIN DE AMPLIACIÓN			

			---- TIPO DE EVALUACION	

			SELECT @lcCodTipEva = cCodTipEva
			FROM KPYMCRECONVEN A
				INNER JOIN KPYMSolicitud B
					ON A.cCodSolCre = B.cCodSolCre 
				INNER JOIN KPYDEVASOLICI C
					ON B.cCodSolCre = C.cCodSolCre 
				INNER JOIN KpyMEvaClient D
					ON C.nNumEvaMes = D.nNumEvaMes 					
			WHERE A.cCodCtaCre = @x_cCodCtaCre			

			SET @lcCodTipEva = ISNULL(@lcCodTipEva,'')
			---			

			--- CURSOR DE PARAMETROS A VALIDAR DEL CLIENTE #CurParCli
			SELECT	cCodSolCre =	'',
					cCodMotSol =	@lcCodMotSol,
					nMonAprSol =	@lnMonAprSol,
					nNumCreVig =	@lnNumCreVig,	
					nCreCmacHyo =	@lnnumCrecmac,
					nNumEntFinEnd =	CASE 
										WHEN @lnNumCrecmac > 0 THEN ISNULL(@lnNumEntFin,0) + 1																			
										ELSE ISNULL(@lnNumEntFin,0) 
									END,
					nNumMaxCreVig = @lnnumCrecmac,
					nPlaDiaCre  =	@lnPlaDiaCre,
					cCodDocIde	=	ISNULL(@lcCodDocIde,''),
					-- REFINANCIADO
					cCodMonSol =	@lcCodMonSol,
					nMonRefCre =	ISNULL(@lnMonRefCre,0.00),
					cOpiRefCre =	@lcIndOpiRef ,           
					nCreBloRef = 	@lnCreBloRef,
					nSalGasCre =	ISNULL(@lnSalGasRef,0.00),
					-- REPROGRAMACION
					cCodTipCre = ISNULL(@lcCodTipCre,''), 
					cCodModCre = ISNULL(@lcCodModCre,''), 
					cEstCreCon = ISNULL(@lcEstCreCon,''),
					cCodTipRep = ISNULL(@lcCodTipRep,''),
					nNumRepCre = @lnNumRepCre ,
					nAtrCuoCre = ISNULL(@lnAtrCuo,0.00),		
					nMorProCre = ISNULL(@lnAtrPro,0.00),
					nNumCuoApr = ISNULL(@lnNumCuoApr,0),
					nPagCapCuo = ISNULL(@lnCapPag,0.00),
					nSalIntCuo = ISNULL(@lSaldoInt,0.00), 
					nSalMorCuo = ISNULL(@lSaldoMor,0.00),
					nSalGasCuo = ISNULL(@lSalGasRep,0.00),
					-- AMPLIACION
					cCalCliCar = ISNULL(@lcCalCreCli,'0'),
					nMonAmpSol = ISNULL(@lnMonSolSol,0.00),         
					nMonEndFin = ISNULL(@lnMonEndFin,0.00),         
					cCodTipCreVal = ISNULL(@lcCodTipCre,''),		
					cCodProduc = ISNULL(@lcCodProduc,''),	
					cCodSubPro = ISNULL(@lcCodSubPro,'') ,	
					nNumAmpCre = @lnNumAmpCre,
					nPorPagCuo = ISNULL(@lnPorPagCuo,0.00), 
					nProAtrCuoPag = ISNULL(@lnProAtrCuoPag,0.00),
					nAtrCuoPag = ISNULL(@lnAtrCuoPag,0.00),
					nNumCreVen = @lnNumCreVen,
					cCalCreCli =CASE 
									WHEN ISNULL(@lcCalCreCli,'0') <= '1' THEN ISNULL(@lcCalCreCli,'0')  
									ELSE '0' 
								END ,
					cCalRieCli =CASE 
									WHEN ISNULL(@lcCalCreCli,'0') > '1' THEN ISNULL(@lcCalCreCli,'0')  
									ELSE '0' 
								END ,
					cOpiTipCre = @lcOpiTipCre,        
					cOpiEndCli = @lcOpiEndCli,
					cCodTipDes = ISNULL(@lcCodTipDes,'00'),
					cCodTotPro = ISNULL(@lcCodTotPro,''),
					nVenAnuCli = ISNULL(@lnVenAnuCli,0.00),
					cIndTipPer = ISNULL(@lcClaPer,'0'),
					nRatRepAge = 0,
					nRepCuoBal = ISNULL(@lnRepCuoBal,0),
					cCodTipEva = @lcCodTipEva,
					nSalIntFec = ISNULL(@lnSalIntFec,0),
					cTipCarFia = '1',
					cOpiCarFia = 'NO',
					cCodOficin = ISNULL(@lcCodOficin,'002'),
					nNumEvaSol = ISNULL(@lnNumEvaSol,0)
			INTO #CurParCli	
			--	--------------------------------------------------------------	
			
				-- SE CREA LA TABLA DE POSIBLES EXCEPCIONES #CurParExc Y QUE TIENE QUE TENER LA MISMA ESTRUCTURA QUE LA TABLA #CurParCli

	CREATE TABLE #CurParExc  (	cCodSolCre CHAR(10),		cCodMotSol char(1),			nMonAprSol NUMERIC(14,4),	nNumCreVig INT,				
								nCreCmacHyo INT,			nNumEntFinEnd INT ,			nNumMaxCreVig INT,			nPlaDiaCre INT,				
								cCodDocIde VARCHAR(20),		cCodMonSol CHAR(1),			nMonRefCre  NUMERIC(14,4) ,	cOpiRefCre CHAR(2),			
								nCreBloRef INT ,			nSalGasCre NUMERIC(14,4),	cCodTipCre CHAR(2),			cCodModCre  CHAR(2) , 		
								cEstCreCon CHAR(1) ,		cCodTipRep CHAR(1) ,		nNumRepCre  NUMERIC (14,2),	nAtrCuoCre NUMERIC(14,4) ,	
								nMorProCre NUMERIC(14,4),	nNumCuoApr NUMERIC(14,4),	nPagCapCuo  NUMERIC(14,4) ,	nSalIntCuo  NUMERIC(14,4) ,	
								nSalMorCuo  NUMERIC(14,4),	nSalGasCuo NUMERIC(14,4),	cCalCliCar	CHAR(1),		nMonAmpSol  NUMERIC(14,4) , 
								nMonEndFin   NUMERIC(14,4),	cCodTipCreVal CHAR (2),		cCodProduc  CHAR (2),		cCodSubPro CHAR (2),		
								nNumAmpCre INT,				nPorPagCuo NUMERIC(14,2),	nProAtrCuoPag NUMERIC(14,2),nAtrCuoPag NUMERIC(14,2),	
								nNumCreVen INT,				cCalCreCli CHAR(1),			cCalRieCli CHAR(1),			cOpiTipCre CHAR(2),			
								cOpiEndCli CHAR(2),			cCodTipDes CHAR(2),			cCodTotPro CHAR(6),			nVenAnuCli NUMERIC (14,2)  ,
								cIndTipPer CHAR(1),         nRatRepAge NUMERIC (14,2),	nRepCuoBal INT,				cCodTipEva CHAR(2),
								nSalIntFec NUMERIC(14,4),	cTipCarFia CHAR(1),			cOpiCarFia CHAR(2),			cCodOficin CHAR(3),
								nNumEvaSol INT
							)		
						
									
			DECLARE @lcCodUsuAdm varchar(10), 
			@lcsql NVARCHAR (MAX)							

			SELECT @lcCodUsuAdm  = '#CUR'+cCodUsuAdm 
			FROM ADMMUSUARIO
			WHERE cCodUsuWin = RTRIM ( REPLACE(SUSER_NAME(),'CMACHYO\','') )				
			SET @lcsql = 'CREATE TABLE '+ @lcCodUsuAdm  +' (	cCodMotSol char(1),			nMonAprSol NUMERIC(14,4),	nNumCreVig INT,				
																nCreCmacHyo INT,			nNumEntFinEnd INT ,			nNumMaxCreVig INT,			nPlaDiaCre INT,				
																cCodDocIde VARCHAR(20),		cCodMonSol CHAR(1),			nMonRefCre  NUMERIC(14,4) ,	cOpiRefCre CHAR(2),			
																nCreBloRef INT ,			nSalGasCre NUMERIC(14,4),	cCodTipCre CHAR(2),			cCodModCre  CHAR(2) , 		
																cEstCreCon CHAR(1) ,		cCodTipRep CHAR(1) ,		nNumRepCre  NUMERIC (14,2),	nAtrCuoCre NUMERIC(14,4) ,	
																nMorProCre NUMERIC(14,4),	nNumCuoApr NUMERIC(14,4),	nPagCapCuo  NUMERIC(14,4) ,	nSalIntCuo  NUMERIC(14,4) ,	
																nSalMorCuo NUMERIC(14,4),	nSalGasCuo NUMERIC(14,4),	cCalCliCar	CHAR(1),		nMonAmpSol  NUMERIC(14,4) , 
																nMonEndFin NUMERIC(14,4),	cCodTipCreVal CHAR (2),		cCodProduc  CHAR (2),		cCodSubPro CHAR (2),		
																nNumAmpCre INT,				nPorPagCuo NUMERIC(14,2),	nProAtrCuoPag NUMERIC(14,2),nAtrCuoPag NUMERIC(14,2),	
																nNumCreVen INT,				cCalCreCli CHAR(1),			cCalRieCli CHAR(1),			cOpiTipCre CHAR(2),			
																cOpiEndCli CHAR(2),			cCodTipDes CHAR(2),			cCodTotPro CHAR(6),			nVenAnuCli NUMERIC (14,2),
																cIndTipPer CHAR(1),         nRatRepAge NUMERIC (14,2),	nRepCuoBal INT,				cCodTipEva CHAR(2),
																nSalIntFec NUMERIC(14,4),	cTipCarFia CHAR(1),			cOpiCarFia CHAR(2),			cCodOficin CHAR(3),
																nNumEvaSol INT
														 )'

															
			--- SP DE PIVOT  (DEPENDE DEL CURSOR #CurParExc PARA SU LLENADO DE PARAMETROS DE EXCEPCION)			
			EXEC KPY_PvtParExcCre_sp	
					@x_cCodSolCre = @x_cCodCtaCre ,
					@x_cNomTabPar = @lcCodUsuAdm,
					@x_cSenSQL = @lcsql																											

				CREATE TABLE #CUROPE  (		cCodMotSol char(1),			nMonAprSol NUMERIC(14,4),	nNumCreVig INT,				
											nCreCmacHyo INT,			nNumEntFinEnd INT ,			nNumMaxCreVig INT,			nPlaDiaCre INT,				
											cCodDocIde VARCHAR(20),		cCodMonSol CHAR(1),			nMonRefCre  NUMERIC(14,4) ,	cOpiRefCre CHAR(2),			
											nCreBloRef INT ,			nSalGasCre NUMERIC(14,4),	cCodTipCre CHAR(2),			cCodModCre  CHAR(2) , 		
											cEstCreCon CHAR(1) ,		cCodTipRep CHAR(1) ,		nNumRepCre NUMERIC (14,2),	nAtrCuoCre NUMERIC(14,4) ,	
											nMorProCre NUMERIC(14,4),	nNumCuoApr NUMERIC(14,4),	nPagCapCuo  NUMERIC(14,4) ,	nSalIntCuo  NUMERIC(14,4) ,	
											nSalMorCuo  NUMERIC(14,4),	nSalGasCuo NUMERIC(14,4),	cCalCliCar	CHAR(1),		nMonAmpSol  NUMERIC(14,4) , 
											nMonEndFin   NUMERIC(14,4),	cCodTipCreVal CHAR (2),		cCodProduc  CHAR (2),		cCodSubPro CHAR (2),		
											nNumAmpCre INT,				nPorPagCuo NUMERIC(14,2),	nProAtrCuoPag NUMERIC(14,2),nAtrCuoPag NUMERIC(14,2),	
											nNumCreVen INT,				cCalCreCli CHAR(1),			cCalRieCli CHAR(1),			cOpiTipCre CHAR(2),			
											cOpiEndCli CHAR(2),			cCodTipDes CHAR(2),			cCodTotPro CHAR(6),			nVenAnuCli NUMERIC (14,2),
											cIndTipPer CHAR(1),         nRatRepAge NUMERIC (14,2),	nRepCuoBal INT,				cCodTipEva CHAR(2),
											nSalIntFec NUMERIC(14,4),	cTipCarFia CHAR(1),			cOpiCarFia CHAR(2),			cCodOficin CHAR(3),
											nNumEvaSol INT
										)
							
					CREATE TABLE #CURTMP  (		cCodMotSol char(1),			nMonAprSol NUMERIC(14,4),	nNumCreVig INT,				
												nCreCmacHyo INT,			nNumEntFinEnd INT ,			nNumMaxCreVig INT,			nPlaDiaCre INT,				
												cCodDocIde VARCHAR(20),		cCodMonSol CHAR(1),			nMonRefCre  NUMERIC(14,4) ,	cOpiRefCre CHAR(2),			
												nCreBloRef INT ,			nSalGasCre NUMERIC(14,4),	cCodTipCre CHAR(2),			cCodModCre  CHAR(2) , 		
												cEstCreCon CHAR(1) ,		cCodTipRep CHAR(1) ,		nNumRepCre NUMERIC (14,2),	nAtrCuoCre NUMERIC(14,4) ,	
												nMorProCre NUMERIC(14,4),	nNumCuoApr NUMERIC(14,4),	nPagCapCuo  NUMERIC(14,4) ,	nSalIntCuo  NUMERIC(14,4) ,	
												nSalMorCuo  NUMERIC(14,4),	nSalGasCuo NUMERIC(14,4),	cCalCliCar	CHAR(1),		nMonAmpSol  NUMERIC(14,4) , 
												nMonEndFin   NUMERIC(14,4),	cCodTipCreVal CHAR (2),		cCodProduc  CHAR (2),		cCodSubPro CHAR (2),		
												nNumAmpCre INT,				nPorPagCuo NUMERIC(14,2),	nProAtrCuoPag NUMERIC(14,2),nAtrCuoPag NUMERIC(14,2),	
												nNumCreVen INT,				cCalCreCli CHAR(1),			cCalRieCli CHAR(1),			cOpiTipCre CHAR(2),			
												cOpiEndCli CHAR(2),			cCodTipDes CHAR(2),			cCodTotPro CHAR(6),			nVenAnuCli NUMERIC (14,2),
												cIndTipPer CHAR(1),		    nRatRepAge NUMERIC (14,2),	nRepCuoBal INT,				cCodTipEva CHAR(2),
												nSalIntFec NUMERIC(14,4),	cTipCarFia CHAR(1),			cOpiCarFia CHAR(2),			cCodOficin CHAR(3),
												nNumEvaSol INT
											)																									

				INSERT #CUROPE	
				SELECT	cCodMotSol = A.cCodMotSol,
						nMonAprSol = A.nMonAprSol,
						nNumCreVig = A.nNumCreVig,	
						nCreCmacHyo = A.nCreCmacHyo,
						nNumEntFinEnd = A.nNumEntFinEnd,
						nNumMaxCreVig = A.nNumMaxCreVig,
						nPlaDiaCre = A.nPlaDiaCre,
						cCodDocIde = A.cCodDocIde ,
						--- REFINANCIACION
						cCodMonSol = A.cCodMonSol,
						nMonRefCre = A.nMonRefCre,		
						cOpiRefCre = A.cOpiRefCre,
						nCreBloRef = A.nCreBloRef,
						nSalGasCre = A.nSalGasCre,
						--- REPROGRAMACION
						cCodTipCre = A.cCodTipCre, 
						cCodModCre = A.cCodModCre, 
						cEstCreCon = A.cEstCreCon,
						cCodTipRep = A.cCodTipRep,
						nNumRepCre = A.nNumRepCre,
						nAtrCuoCre = A.nAtrCuoCre,
						nMorProCre = A.nMorProCre,
						nNumCuoApr = A.nNumCuoApr,
						nPagCapCuo = A.nPagCapCuo,
						nSalIntCuo = A.nSalIntCuo,
						nSalMorCuo = A.nSalMorCuo,
						nSalGasCuo = A.nSalGasCuo,
						--- AMPLIACION
						cCalCliCar = A.cCalCliCar,          
						nMonAmpSol = A.nMonAmpSol,          
						nMonEndFin = A.nMonEndFin,
						cCodTipCreVal = A.cCodTipCreVal,
						cCodProduc = A.cCodProduc,
						cCodSubPro = A.cCodSubPro,
						nNumAmpCre = A.nNumAmpCre,
						nPorPagCuo = A.nPorPagCuo,
						nProAtrCuoPag = A.nProAtrCuoPag,
						nAtrCuoPag = A.nAtrCuoPag,
						nNumCreVen = A.nNumCreVen,
						cCalCreCli = A.cCalCreCli,
						cCalRieCli = A.cCalRieCli,
						cOpiTipCre = A.cOpiTipCre,
						cOpiEndCli = A.cOpiEndCli,
						cCodTipDes = A.cCodTipDes,
						cCodTotPro = A.cCodTotPro,
						nVenAnuCli = A.nVenAnuCli,
						cIndTipPer = A.cIndTipPer,
						nRatRepAge = A.nRatRepAge,
						nRepCuoBal = A.nRepCuoBal,
						cCodTipEva = A.cCodTipEva,
						nSalIntFec = A.nSalIntFec,
						cTipCarFia = A.cTipCarFia,
						cOpiCarFia = A.cOpiCarFia,
						cCodOficin = A.cCodOficin,
						nNumEvaSol = A.nNumEvaSol 
				FROM #CurParCli A					
			-- VALIDACION DE PARAMETROS
			EXECUTE GEN_ValGenPar_SP 
					@x_cCodTipApl	= 'KPY',
					@x_nTipValida	= @lnTipValida, 
					@x_cResVal		= @x_cResValAmp OUTPUT	,
					@x_XMLCur		= @lXMLCur OUTPUT											
			DECLARE @CurMsjFin	TABLE (	cmenval varchar(120),ccodtipapl char(3),ntipvalida int,
										nnumvalida int,nnumdetval int,
										ccodcameva varchar(200),coperadapl varchar(3),
										cvalcameva varchar(245),cCamAfecta VARCHAR(200),
										cValCamAfe VARCHAR(200),lindreqexc bit,
										cCodAreVisBue CHAR(3), cCodGruPer CHAR(3)
										)		

			EXEC sp_xml_preparedocument @iDoc OUTPUT, @lXMLCur

				INSERT @CurMsjFin

				SELECT	cmenval,ccodtipapl,ntipvalida ,
						nnumvalida ,nnumdetval,ccodcameva,
						coperadapl ,cvalcameva,ccamafecta,
						cvalcamafe ,lindreqexc,
						ccodarevisbue ,ccodgruper 
				FROM OPENXML(@iDoc, 'datos/row', 1)

				WITH (	cmenval varchar(120),ccodtipapl char(3),ntipvalida int,
						nnumvalida int,nnumdetval int,ccodcameva varchar(200),
						coperadapl varchar(3),cvalcameva varchar(245),ccamafecta varchar(200),
						cvalcamafe varchar(200),lindreqexc bit,ccodarevisbue char(3),ccodgruper char(3)
					)

			EXEC sp_xml_removedocument @idoc	

			----- TABLA PARA ALMACENAR VALORES DEL CLIENTE PARA UNA POSIBLE EXCEPCION

			CREATE TABLE #CURREGDAT (cCampo VARCHAR(200),cValCli VARCHAR(200))				

			CREATE  TABLE #CurMsjFin(	cmenval varchar(120),ccodtipapl char(3),ntipvalida int,
								nnumvalida int,nnumdetval int,
								ccodcameva varchar(200),coperadapl varchar(3),
								cvalcameva varchar(245),cCamAfecta VARCHAR(200),
								cValCamAfe VARCHAR(200),lindreqexc bit,
								cCodAreVisBue CHAR(3), cCodGruPer CHAR(3), 
								cValCli VARCHAR(200)
								)

								

			----- SP DE UNPIVOT PARA OBTENER LOS VALORES DEL CLIENTE (DEPENDE DE LOS CURSORES #CURREGDAT 
			----	Y #CUROPE PARA SU LLENADO DE LOS VALORES DEL CLIENTE)				

			EXEC KPY_UnPvtParCreCli_sp	
					@x_cNomTabPar = @lcCodUsuAdm,
					@x_cSenSQL = @lcsql													

			INSERT #CurMsjFin (	cmenval ,ccodtipapl ,ntipvalida ,nnumvalida ,nnumdetval ,
								ccodcameva ,coperadapl ,cvalcameva ,cCamAfecta,cValCamAfe ,
								lindreqexc ,cCodAreVisBue , cCodGruPer , cValCli
							)							
			SELECT A.* ,cValCli
			FROM @CurMsjFin A
				LEFT JOIN #CURREGDAT B
					ON 	cCampo = ccodcameva 				

			select *
			from #CurMsjFin				

		------
			DROP TABLE #CUROPE
			DROP TABLE #CURTMP
			DROP TABLE #CurParExc
			DROP TABLE #CurParCli
			DROP TABLE #CURREGDAT
			

END
--******************************************************************************************************************
