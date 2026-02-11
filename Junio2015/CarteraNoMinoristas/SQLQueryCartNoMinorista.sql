	/*
	Criterio:
		datos al cierre del mes de Mayo 2015 
		Solo créditos mediana empresa, grande empresa y IFI's
	Campos: 
	NOMBRE_CLIENTE COD_CUENTA COD_CLIENTE FECHA_DESEMBOLSO MONEDA MONTO_DESEMBOL
	PLAZO_dias TEM TEA 
	SALDO_CAPITAL SALDO_CONVER 
		ACTIVIDAD GIRO_NEGOCIO 
	TIPO_CREDITO	SUBTI_CRE PRO_CREDI SUB_PROCRE 
		MODALIDAD
	SALDO_VENCIDO 
		SALDO_CONVEVEN
	CLASE_PER FECHA_SOLICITUD FECHA_SOLRIESGO 
	OFICINA ZONA ANALISTA_ACTUAL
	TOTAL_EXCP CALIFICACION ENTIDADES cDescriEst DIAS_ATRASO 
	*/

	/*
	Select 
			dFecTipCam,nTipCamFij
	From GENTTipCambio Where dFecTipCam = '2015-06-01 00:00:00.000'
	*/

	Declare @TipCam as float
	Set @TipCam = (	Select nTipCamFij
					From GENTTipCambio Where dFecTipCam = '2015-06-01 00:00:00.000')

	-- drop table #tmpv01
	SELECT * into #tmpv01 FROM  (
		Select 		
			--Datos del Cliente	
			CLIM.cCodSbs
			,CLI.cCodCliente AS 'CodigoCliente'	
			,CLIM.cNomCliente AS 'NombreCliente'	
			,CASE WHEN CLIM.cNroDocIde IS NOT NULL THEN 'PERSONA NATURAL'
			 WHEN CLIM.cNroDocTri IS NOT NULL THEN 'PERSONA JURIDICA'
			 END AS 'ClasePersona'				
			
			-- DATOS DEL CREDITO
			,CRE.cCodCtaCre AS 'CodigoCredito'	
			,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 ,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 ,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 								
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,TEM = CRE.nTasIntCom 
			,NroCuotas = CRE.nNumCuoApr
			,PlazoDias = CRE.nNumDiaApr
			--,TEA = ((power((1 + CRE.nTasIntCom), CRE.nNumCuoApr) ) -1 )* 100    --TCEA = ((1+tm)n -1)*100
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,case cre.cCodTipMon
			when '1' then (CRE.nMonCapDes - CRE.nMonCapPag) 
			when '2' then ((CRE.nMonCapDes - CRE.nMonCapPag) * @TipCam)
			end AS 'SaldoenSoles'
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'						
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'					
			,CRE.nDiaAtrCre
			,MontoSaldoVencido = isnull(CRE.nMonSalVen,0)		
			
			,C.cCodSolCre , left(cast(C.dFecSolCre as date),10) as 'FechaSolicitud'
											
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'	
			
			,O.cCodOficin, O.cDesOficin	
			,ZON.nCodZona, ZON.cDesZona	

		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_201504.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna	
		
			INNER JOIN KPYMSolicitud C	(NOLOCK)
				ON cre.cCodSolCre = C.cCodSolCre 

		WHERE CRE.cCodTipCre IN ('05','06','07','08','09','10','11','12')
			and CRE.cEstCreCon in ('F','H','G')				
		--ORDER BY cEstCreCon 			
			 ) as tmp99

	   /*
		SELECT cCodTipCre, cDesTipCre
		FROM [KPYTSUBTIPCRE] STC
		WHERE STC.lEstado = '1'
		GROUP BY cCodTipCre, cDesTipCre
		
			--AND cCodTipCre IN ('10','11','12')

		select *  from [KPYDPLANPAGCRE] where cCodCtaCre = '107001011000004003'

		


		SELECT TOP 1 *  FROM [HYO00402].CRICMACHYO_DIARIO.DBO.URIRCCSAL

		SELECT count(distinct CCODEMP)--CCODSBS,CCODEMP,	CCTACON  
		FROM [HYO00402].CRICMACHYO_DIARIO.DBO.URIRCCSAL
		where CCODSBS =  '0072245555'
			and left(CCTACON,4) 
					in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
		
				

		SELECT TOP 1 *  FROM [HYO00402].CRICMACHYO_DIARIO.DBO.urirccmae

		SELECT *  FROM [HYO00402].CRICMACHYO_DIARIO.DBO.urirccmae
		where CCODSBS = '0072245555'


		FROM KPYMEXCCRE A	(NOLOCK)
	INNER JOIN KPYDEXEPCRE B	(NOLOCK)
		ON A.cCodSolCre = B.cCodSolCre 
	INNER JOIN KPYMSolicitud C	(NOLOCK)
		ON A.cCodSolCre = C.cCodSolCre 


		select top 1 * from KPYMEXCCRE 
		select top 1 * FROM KPYDEXEPCRE
		SELECT TOP 1 * FROM KPYMSolicitud

		*/


			/*
			-- Calificacion SBS
			,U.CCLAFIN, CantEntidades = count(distinct UU.CCODEMP)

						
			inner join [HYO00402].CRICMACHYO_DIARIO.DBO.urirccmae U				
				on U.ccodsbs = clim.cCodSbs
			inner join [HYO00402].CRICMACHYO_DIARIO.DBO.URIRCCSAL UU
				on UU.CCODSBS = clim.cCodSbs  
					and left(UU.CCTACON,4) 
					in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
			*/
					

		/*
		SELECT nDiaVenCuo, * FROM [KPYDPLANPAGCRE] (NOLOCK)
		wHERE cCodCtaCre = '107002102008653721'
			and cCodPlaPag in 
				(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
					where cCodCtaCre = '107002102008653721')
			-- -459

		select * from [KPYMCRECONVEN]
		where cCodCtaCre = '107002102008653721'
		--nDiaAtrCre
		*/

		Select * from #tmpv01 -- (1,089 row(s) affected) 		


		Alter Table #tmpv01
		Add Calificacion int, CantEntidades int

		------------------------CURSOR CALIFICACION CANT ENTIDADES -----------------------------------
		Declare @ccodsbs varchar(20), @Calificacion int, @CantEntidades int
		        			
			Declare cCaliSBS CURSOR FOR	
				select distinct cCodSbs from #tmpv01 (NOLOCK) 	

			OPEN cCaliSBS
				FETCH cCaliSBS into @ccodsbs
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @Calificacion = (SELECT CCLAFIN  
										FROM [HYO00402].CRICMACHYO_DIARIO.DBO.urirccmae
										where CCODSBS = @ccodsbs ) 

				set @CantEntidades =	( select count (distinct CCODEMP )
										  from [HYO00402].CRICMACHYO_DIARIO.DBO.URIRCCSAL 
										  where CCODSBS = @ccodsbs  
											and left(CCTACON,4) 
											in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))	
									
				UPDATE #tmpv01
				SET Calificacion = @Calificacion
				WHERE cCodSbs = @ccodsbs	

				UPDATE #tmpv01
				SET CantEntidades = @CantEntidades
				WHERE cCodSbs = @ccodsbs									

				FETCH cCaliSBS INTO @ccodsbs
				END
				CLOSE cCaliSBS
				DEALLOCATE cCaliSBS

	----------------VERIFICANDO---------------------------
	SELECT * FROM #tmpv01


	SELECT * FROM #tmpv01 where Calificacion is null
	
	/*
	Update 	#tmpv01 
	Set Calificacion = 0
	where Calificacion is null
	*/

	/*
	SELECT * FROM #tmpv01
	WHERE CodigoCliente = '107010066390'
			and cCodSolCre = '0070070210'
	
	
		select top 1 * from KPYMEXCCRE 

		select * from KPYMEXCCRE 
		WHERE cCodSolCre = '0070070210'

		select TOP 1 * FROM KPYDEXEPCRE

		select cEstExepCre,* FROM KPYDEXEPCRE
		WHERE cCodSolCre = '0070070210'
			AND cEstExepCre	=	'B'

		SELECT TOP 1 * FROM KPYMSolicitud
		--INNER JOIN KPYDEXEPCRE B	(NOLOCK)
				--ON CRE.cCodSolCre = B.cCodSolCre 
			--inner join KPYMEXCCRE A	(NOLOCK)
				--on A.cCodSolCre = B.cCodSolCre 

		*/

		Alter table #tmpv01
		add Cantexcep int

		------------------------CURSOR CANT EXCEPCIONES -----------------------------------
		Declare @cCodSolCre varchar(20), @Cantexcep int
		        			
			Declare cExcep CURSOR FOR	
				select cCodSolCre from #tmpv01 (NOLOCK) 	

			OPEN cExcep
				FETCH cExcep into @cCodSolCre
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @Cantexcep = (	select count(*) from KPYMEXCCRE 
									WHERE cCodSolCre = @cCodSolCre ) 				
									
				UPDATE #tmpv01
				SET Cantexcep = @Cantexcep
				WHERE cCodSolCre = @cCodSolCre									

				FETCH cExcep INTO @cCodSolCre
				END
				CLOSE cExcep
				DEALLOCATE cExcep

	----------------VERIFICANDO---------------------------
	SELECT * FROM #tmpv01
	--where --Cantexcep = ''
		--	cCodSolCre = '0070070210'
	Order by CodigoCliente
