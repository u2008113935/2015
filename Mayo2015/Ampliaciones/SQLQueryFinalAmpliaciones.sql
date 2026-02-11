	
		--01 LISTA DE créditos vigentes para ampliar 
		-- drop table #t01
	SELECT * into #t01 FROM (
		SELECT  --@lnNumCreVig = COUNT(*)
			CLIM.cNomCliente, CLIM.cCodSbs, CLIM.cCodCliente, ISNULL(cNroDocIde,cNroDocTri) AS 'NroDocumento'
			,CRE.cCodCtaCre, CRE.cCodTipCre ,STC.cDesTipCre AS 'TipoCredito'
			,STC.cDesSubTip AS 'SubTipoCredito' ,CRE.cCodProduc, STC.cDesProCre AS 'ProductoCrediticio',CRE.cCodSubPro	
			,STC.cDesSubcRE AS 'SubProductoCrediticio',EC.cDescriEst AS 'EstadoCredito'
			,O.cCodOficin, O.cDesOficin, ZON.nCodZona, ZON.cDesZona, R.CCLAFIN
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente	
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'	
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTEstCreCon] EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona
			INNER JOIN CRICMACHYO_DIARIO.DBO.urirccmae R
				ON R.CCODSBS = CLIM.cCodSbs
		WHERE CRE.cEstCreCon = 'F'
				AND ZON.nCodZona = '4'
				AND R.CCLAFIN = '0'

		) AS tmp
		-- (20,165 row(s) affected)

		--02 CALCULANDO EL PROCENTAJE DE CUOTAS PARA AMPLIAR-----------
	Select * from #t01

	ALTER TABLE #t01
	ADD CuotaTotal int , CuotaPag int, CuotaPend int, 
		Porcentaje float , DiasPromAtr int, DiasAtraso int


	SELECT * into #t02 FROM  ( SELECT * FROM #t01) AS Tmp98
	--DELETE FROM #t02
	--drop table #t02
	SELECT * FROM #t02
	
	--*********************************INDEXANDO****************************************************
	CREATE NONCLUSTERED INDEX #t02_cCodCtaCre_IXN ON #t02(cCodCtaCre)
	CREATE NONCLUSTERED INDEX #t02_cCodSbs_IXN ON #t02(cCodSbs)	
	--------------------****************************************************************************
		
		--PRUEBAS PLAN DE PAGOS
		SELECT round(avg(cast(nDiaVenCuo as float)),0)
								FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
			--DiasPromAtr 
		SELECT round(avg(cast(nDiaVenCuo as float)),0) 
		FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
		WHERE cCodCtaCre = '107039101001826527' and cCodEstCuo ='P' 

			--DiasAtraso 
		SELECT nDiaVenCuo
		FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
		WHERE cCodCtaCre = '107039101001826527'
				and cCodEstCuo ='P'
				and cNumCuoPla in (select max(cNumCuoPla) from [KPYDPLANPAGCRE] (NOLOCK)
									WHERE cCodEstCuo ='P' and cCodCtaCre = '107039101001826527')
		
			--CuotaTotal 
		select max(cNumCuoPla)				
		from [KPYDPLANPAGCRE] 
						where cCodCtaCre = '107039101001826527'  

			--CuotaPag 
		select max(cNumCuoPla) from [KPYDPLANPAGCRE] 
		where cCodCtaCre = '107039101001826527' -- @cCodCtaCre  
				and cCodEstCuo = 'P'

			--CuotaPend 
		select count(cNumCuoPla) from [KPYDPLANPAGCRE] 
		where cCodCtaCre = '107039101001826527' -- @cCodCtaCre  
				and cCodEstCuo = 'E'

		select * from [KPYDPLANPAGCRE] 
		where cCodCtaCre = '107039101001826527' -- @cCodCtaCre  
				and cCodEstCuo = 'E'

		
	------------------------CURSOR-----------------------------------
		Declare @ccodcred varchar(18), @CuotaTotal int , @CuotaPag int, @CuotaPend int, 
		        @Porcentaje float , @DiasPromAtr int, @DiasAtraso int		
			
			Declare cDiaAtraso CURSOR FOR	
				select cCodCtaCre from #t02 (NOLOCK) 	

			OPEN cDiaAtraso
				FETCH cDiaAtraso into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @DiasPromAtr = ( SELECT round(avg(cast(nDiaVenCuo as float)),0)
								FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
								WHERE PLA.cCodCtaCre = @ccodcred and cCodEstCuo ='P')

				set @DiasAtraso =	(SELECT nDiaVenCuo
									FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
									WHERE cCodCtaCre = @ccodcred
										and cCodEstCuo ='P'
										and cNumCuoPla in
											 (select max(cNumCuoPla) from [KPYDPLANPAGCRE] (NOLOCK)
											 WHERE cCodEstCuo ='P' and cCodCtaCre = @ccodcred) )
			
				set @CuotaTotal = (select max(cNumCuoPla) from [KPYDPLANPAGCRE] 
									where cCodCtaCre = @ccodcred )
								
				set @CuotaPag = (select max(cNumCuoPla) from [KPYDPLANPAGCRE] 
									where cCodCtaCre = @ccodcred and cCodEstCuo = 'P')

				set @CuotaPend = (select count(cNumCuoPla) from [KPYDPLANPAGCRE] 
									where cCodCtaCre = @ccodcred and cCodEstCuo = 'E')				
			
				set @Porcentaje = ((@CuotaPag * 100)/ @CuotaTotal) 

				UPDATE #t02
				SET DiasPromAtr = @DiasPromAtr
				WHERE cCodCtaCre = @ccodcred	

				UPDATE #t02
				SET DiasAtraso = @DiasAtraso
				WHERE cCodCtaCre = @ccodcred	

				UPDATE #t02
				SET CuotaTotal = @CuotaTotal
				WHERE cCodCtaCre = @ccodcred	

				UPDATE #t02
				SET CuotaPag = @CuotaPag
				WHERE cCodCtaCre = @ccodcred	

				UPDATE #t02
				SET CuotaPend = @CuotaPend
				WHERE cCodCtaCre = @ccodcred

				UPDATE #t02
				SET Porcentaje = @Porcentaje
				WHERE cCodCtaCre = @ccodcred				

				FETCH cDiaAtraso INTO @ccodcred
				END
				CLOSE cDiaAtraso
				DEALLOCATE cDiaAtraso

	----------------VERIFICANDO---------------------------
	SELECT * FROM #t02
		-- (20,165 row(s) affected)
	
  SELECT * into #t03 FROM (
	SELECT * FROM #t02
	where cCodSbs in 
	(
		Select A.CCODSBS --, A.CCODEMP, count(A.CCODEMP) as 'Ent', left(A.CCTACON,4) as 'Cuenta'				
		from CRICMACHYO_DIARIO.DBO.[urirccsal] A (nolock)				
		group by A.CCODSBS, A.CCODEMP, A.CCTACON
		having count(A.CCODEMP)= 1
				and A.CCODEMP = '00107' 
				and left(A.CCTACON,4) 
					in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')			
				and A.CCODSBS not in
					(select CCODSBS from CRICMACHYO_DIARIO.DBO.urirccsal (nolock)
					  where  CCODEMP != '00107' 
						and left(CCTACON,4) in 
						('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))
	) ) as tmp
		-- (8,314 row(s) affected)

	SELECT * FROM #t03

  SELECT * into #t04 FROM (
	SELECT 
		A.cNomCliente, A.cCodSbs, A.cCodCliente, A.NroDocumento, A.cCodCtaCre
		,B.dFecDesCre as 'FecDesembolso', B.nMonCapDes as 'MontoDesem' 
		,case B.cCodTipMon
		when '1' then 'SOLES'
		when '2' then 'DOLARES'
		end AS 'Moneda'
		,(B.nMonCapDes - B.nMonCapPag) AS 'Saldo'						
		, A.cCodTipCre ,A.TipoCredito, A.SubTipoCredito, A.cCodProduc, A.ProductoCrediticio
		, A.cCodSubPro ,A.SubProductoCrediticio, A.EstadoCredito, A.cCodOficin, A.cDesOficin
		, A.nCodZona ,A.cDesZona, A.CCLAFIN, A.CuotaTotal, A.CuotaPag, A.CuotaPend, A.Porcentaje
		, A.DiasPromAtr ,A.DiasAtraso , B.cCodUsuAna AS 'CodigoAnalista'
		, SP.cNomPerson AS 'NombreAnalista'	 
	FROM #t03 A (NOLOCK)
		INNER JOIN [KPYMCRECONVEN] B (NOLOCK)
			ON B.cCodCtaCre = A.cCodCtaCre
		inner JOIN [sipmpersonal] SP 
	        ON SP.cCodPerson = B.cCodUsuAna
		
		) as tmp

	--*********************************INDEXANDO****************************************************
	CREATE NONCLUSTERED INDEX #t04_cCodCtaCre_IXN ON #t04(cCodCtaCre)
	CREATE NONCLUSTERED INDEX #t04_cCodSbs_IXN ON #t04(cCodSbs)	
	--------------------****************************************************************************
	select * from #t04 

	select * from #t04 where Porcentaje is null
	select * from #t04 where DiasAtraso is null 

	Update #t04
	Set DiasAtraso = 0
	Where DiasAtraso is null


	--Por Creditos Empresariales		
	Select * from #t04
	where DiasPromAtr <= 6 and Porcentaje >= 40
		and cCodTipCre in ('02','11','12','13') 
		and cCodCliente != '107021169417'
	order by cDesOficin					

		--CrediVip Empresa.
	select * from #t04 
	where Porcentaje >= 50 and DiasPromAtr <= 6
		and ((cCodTipCre = '02' and cCodSubPro = '02')
		or (cCodTipCre = '11' and cCodSubPro = '02')
		or (cCodTipCre = '12' and cCodSubPro = '02')
		or (cCodTipCre = '13' and cCodSubPro = '02'))
		
		--consumo Personal
	select * from #t04 
	where Porcentaje >= 20 and DiasPromAtr <= 6
		and (cCodTipCre = '03' and cCodSubPro = '01')
	order by cDesOficin	
	
		--consumo plazo fijo 
	select * from #t04 
	where DiasPromAtr <= 6
		and (cCodTipCre = '03' and cCodSubPro = '06')
	order by cDesOficin	

		--consumo convenios
	select * from #t04 
	where DiasPromAtr <= 6
		and (cCodTipCre = '03' and SubProductoCrediticio like '%convenio%elegible%')
	order by cDesOficin	
	
		--HIPOTECA
	select * from #t04 
	WHERE DiasPromAtr <= 6
		AND cCodTipCre = '04'
	order by cDesOficin	

	Select * from #t04
	where DiasPromAtr <= 6 AND Porcentaje >= 40
		and ((cCodTipCre = '03'  AND cCodSubPro != '06')
		    AND (cCodTipCre = '03' and cCodSubPro != '01')
			and (cCodTipCre = '03' and SubProductoCrediticio not like '%convenio%elegible%'))
	order by cDesOficin	

	--Grupo de Creditos
	Select cCodTipCre from #t04
	group by cCodTipCre