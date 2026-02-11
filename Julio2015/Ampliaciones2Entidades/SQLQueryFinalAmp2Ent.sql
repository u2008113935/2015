	
	--01 LISTA DE créditos vigentes para ampliar 		

		-- drop table #t01
	SELECT * into #t01 FROM (
		SELECT  --@lnNumCreVig = COUNT(*)
			CLIM.cNomCliente, CLIM.cCodSbs, CLIM.cCodCliente
			,ISNULL(cNroDocIde,cNroDocTri) AS 'NroDocumento',CRE.cCodCtaCre
			,MontoDesem = CRE.nMonCapDes
			,case CRE.cCodTipMon
				when '1' then 'SOLES'
				when '2' then 'DOLARES'
				end AS 'Moneda'
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'	
			,CRE.cCodTipCre, STC.cDesTipCre AS 'TipoCredito'
			,STC.cDesSubTip AS 'SubTipoCredito', CRE.cCodProduc
			, STC.cDesProCre AS 'ProductoCrediticio',CRE.cCodSubPro	
			,STC.cDesSubcRE AS 'SubProductoCrediticio',EC.cDescriEst AS 'EstadoCredito'			
			,dFecDesCre=left(cast(CRE.dFecDesCre as date),10)
			,O.cCodOficin, O.cDesOficin, ZON.nCodZona, ZON.cDesZona
			,CRE.cCodUsuAna AS 'CodigoAnalista', SP.cNomPerson AS 'NombreAnalista'
			,R.CCLAFIN, CRE.nDiaAtrCre, CuotasAprob=CRE.nNumCuoApr		
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente	
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'	
			INNER JOIN [KPYTEstCreCon] EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona
			INNER JOIN CRICMACHYO_DIARIO.DBO.urirccmae R
				ON R.CCODSBS = CLIM.cCodSbs
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna	
		WHERE CRE.cEstCreCon = 'F'
			AND ZON.nCodZona = '4' --LIMA NORTE
			AND R.CCLAFIN = '0'
			and left(cast(CRE.dFecDesCre as date),10) <= '2015-06-30'
			and STC.cDesSubcRE != 'MIVIVIENDA' -- CrediCasa con RRHH unico ampliar				
			and STC.cDesSubcRE != 'ADELANTO DE SUELDO'	
			and	STC.cDesSubcRE != 'AGROPECUARIO'	
			and	STC.cDesSubcRE != 'PROMOTOR INMOBILIARIO'
		) AS tmp
		-- (20,386 row(s) affected)
		-- (17,479 row(s) affected) fecha proceso: 01/09/2015

		/*
		nDiaAtrCre	int(4)	Nro. Dias de Atraso Cuota
		nDiaAtrAnt	int(4)	Nro. Dias de Atraso Anterior
		nDiaAtrAcu	int(4)	Nro. Dias de Atraso Acumulado
		nDiaAtrMax	int(4)	Nro. Dias de Atraso Máximo
		*/
		-- Select * from [GentZonas] ZON
		-- Select top 1 * from CRICMACHYO_DIARIO.DBO.urirccmae R
		--02 CALCULANDO EL PROCENTAJE DE CUOTAS PARA AMPLIAR-----------
	/*
	Select nDiaAtrCre,*
	from #t01
	WHERE cCodCtaCre ='107047101000676598' --'107046101000683561'--'107041101001233116'

	Select cCodTipCre,TipoCredito, SubTipoCredito,cCodProduc,ProductoCrediticio,cCodSubPro
		,SubProductoCrediticio
	from #t01
	Group By cCodTipCre,TipoCredito, SubTipoCredito,cCodProduc,ProductoCrediticio,cCodSubPro
		,SubProductoCrediticio
	*/

	--02 agregando columnas
	ALTER TABLE #t01
	Add CuotaPag INT, CuotaPend INT, Porcentaje INT, DiasPromAtr INT
	--Drop column CuotaPag , CuotaPend , Porcentaje ,DiasPromAtr 


	SELECT * into #t02 FROM  ( SELECT * FROM #t01) AS Tmp98
	-- DELETE FROM #t02
	-- drop table #t02
	/*
	SELECT * FROM #t02
	where cCodCtaCre='107074101000043441'-- '107038101000625031'
	*/
	
	--*********************************INDEXANDO****************************************************
	CREATE NONCLUSTERED INDEX #t02_cCodCtaCre_IXN ON #t02(cCodCtaCre)
	CREATE NONCLUSTERED INDEX #t02_cCodSbs_IXN ON #t02(cCodSbs)	
	--------------------****************************************************************************
	/*
		--PRUEBAS PLAN DE PAGOS
		-----------------------------------------------------------------------------------
		Declare @codcred char(18), @MoraPromedio numeric(4,2), @CuotPag  numeric(4,2)
		, @CuotPend numeric(4,2),@CuotAprob int, @Porc numeric(4,2)
		Set @codcred ='107038101000921991' --'107039101001117071' --'107039101001915613' --'107074101000043441'--'107038101000625031'
		
		set @CuotAprob =(select CuotasAprob from #t02 where cCodCtaCre=@codcred) 
		set @CuotPag = (select count(cNumCuoPla) from [KPYDPLANPAGCRE] 
									where cCodCtaCre = @codcred and cCodEstCuo = 'P'
									AND cCodPlaPag in 
									(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
										WHERE cCodCtaCre = @codcred))		
		select CuotAprob=@CuotAprob
		select CuotPag=@CuotPag

		if @CuotPag > 0
		begin

		set @MoraPromedio = 
		(SELECT avg(case when nDiaVenCuo < 0.00 then 0 
				else CAST(nDiaVenCuo AS numeric(4,2)) end)
		FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
		WHERE cCodCtaCre = @codcred AND cCodPlaPag 
					in (select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
						WHERE cCodCtaCre = @codcred))															
				
		set @CuotPend = ( @CuotAprob - @CuotPag )				
			
		set @Porc = CAST(((@CuotPag * 100)/ @CuotAprob ) AS numeric(4,2))

		end 
		else if @CuotPag is null
		begin
			set @MoraPromedio = 0
			set @CuotPag = 0
			set @CuotPend = @CuotAprob
			set @Porc = 0		
		end 


		select MoraPromedio=@MoraPromedio
		select CuotPag=@CuotPag
		select CuotPend=@CuotPend
		select Porc=@Porc
		select CuotasAprob=@CuotAprob 
		-------------------------------------------------------------------------------------
		
		SELECT  cCodCtaCre,cCodPlaPag,cNumCuoPla,cCodDesemb,dFecVenPag,dFecPagCuo,cCodEstCuo
			,cCodEstPla,cCodEstDes
			,nDiaVenCuo=case when nDiaVenCuo < 0 then 0 else nDiaVenCuo end 
		FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
		WHERE cCodCtaCre = @codcred AND cCodPlaPag 
					in (select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
						WHERE cCodCtaCre = @codcred)
		ORDER BY cNumCuoPla							
	*/

	-- 03 LLENAR CAMPOS 	
	------------------------CURSOR-----------------------------------
		Declare @ccodcred varchar(18), @CuotaPag INT, @CuotaPend INT, 
		        @Porcentaje INT , @DiasPromAtr INT, @CuotasAprob int 		
			
			Declare cAmpl CURSOR FOR	
				select cCodCtaCre from #t02 (NOLOCK) 	

			OPEN cAmpl
				FETCH cAmpl into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @CuotasAprob=(select CuotasAprob from #t02 where cCodCtaCre=@ccodcred)
				set @CuotaPag = 
						(select count(cNumCuoPla) from [KPYDPLANPAGCRE] 
									where cCodCtaCre = @ccodcred and cCodEstCuo = 'P'
									AND cCodPlaPag in 
									(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
										WHERE cCodCtaCre = @ccodcred))

				if @CuotaPag >= 0
				begin
				
				set @DiasPromAtr = 
					(SELECT avg(case when nDiaVenCuo < 0 then 0 
						else nDiaVenCuo  end)
					FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
					WHERE cCodCtaCre = @ccodcred AND cCodPlaPag 
							in (select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
								WHERE cCodCtaCre = @ccodcred))													
								
				set @CuotaPend = (@CuotasAprob - @CuotaPag )						
								
				set @Porcentaje = ((@CuotaPag * 100)/ @CuotasAprob)
				
				end 
				else if @CuotaPag is null
				begin
					set @DiasPromAtr = 0
					set @CuotaPag = 0
					set @CuotaPend = @CuotasAprob
					set @Porcentaje = 0
				end

				UPDATE #t02
				SET DiasPromAtr = @DiasPromAtr
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

					SET @DiasPromAtr = 0
					SET @CuotaPag = 0
					SET @CuotaPend = 0
					SET @Porcentaje = 0 					
				
				FETCH cAmpl INTO @ccodcred
				END
				CLOSE cAmpl
				DEALLOCATE cAmpl

	----------------VERIFICANDO---------------------------
	
	/*
	SELECT * FROM #t02
		-- ((20,386 row(s) affected)

	SELECT * FROM #t02
	where CuotaPag = 0
		-- (1,794 row(s) affected)

	SELECT * FROM #t02
	where CuotaPag !=0
		-- (18,592 row(s) affected)

	SELECT * FROM CRICMACHYO_DIARIO.DBO.URITTipCredit
	SELECT * FROM CRICMACHYO_DIARIO.DBO.urirccmae R WHERE cCodSbs='0088093658'
	SELECT * FROM CRICMACHYO_DIARIO.DBO.[urirccsal] B WHERE cCodSbs='0088093658'
	*/

	--04 OBTENER SOLO CLIENTES CAJA HYO QUE TENGAN CREDITOS MAX. 2 ENTIDADES,INCLUIDO CAJA HYO 
		--TOTALIDAD CLIENTE CAJA HYO EN URI
		-- Drop table #ClieCaja
		SELECT * into #ClieCaja FROM (
		Select CCODSBS , CCODEMP
			--, CantEnt=count(distinct A.CCODEMP) -- left(A.CCTACON,4) as 'Cuenta'				
		from CRICMACHYO_DIARIO.DBO.[urirccsal] A (nolock)						
		where --count(distinct A.CCODEMP)= 2
			CCODEMP = '00107' --(EXCLUSIVOS DE LA Caja Huancayo)				
			and left(CCTACON,4) 
				in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')			
		--group by A.CCODSBS, A.CCODEMP, A.CCTACON
		--order by CCODSBS
				) as tmp
	
		/*
		--ESTOS CLIENTES TIENEN CREDITOS CON LA CAJA Y CON OTRAS ENTIDADES
		SELECT * FROM #ClieCaja WHERE CCODSBS= '0012397321' -- '0094199034'

		select * 
		from CRICMACHYO_DIARIO.DBO.[urirccsal] A (nolock)	
		where CCODSBS= '0012397321'--'0094199034'--'0102520726'
			and left(A.CCTACON,4) 
					in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')	
		*/
		
		--SE TIENE QUE SELECCIONAR SOLO LOS QUE TIENEN 2 ENTIDADES		
		-- Drop table #ClieCaja
		SELECT * FROM #ClieCaja
		--(201,762 row(s) affected)
			
		--CLIENTES AGRUPADOS
		-- Drop table #ClieAgr
		SELECT * into #ClieAgr FROM (
			select CCODSBS,CCODEMP 
			from CRICMACHYO_DIARIO.DBO.[urirccsal] A (nolock)	
			where CCODSBS in (SELECT CCODSBS FROM #ClieCaja)
				and left(A.CCTACON,4) 
					in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')	
			group by CCODSBS,CCODEMP 
			) as tmp
			--order by ccodsbs
				--(338,552 row(s) affected) agrupados
				--(376,915 row(s) affected) desagrupado
			
			/*	
			Select * from #ClieAgr
			Where CCODSBS= '0012397321'
			*/

			-- drop table #ClieAgrEnt
		SELECT * into #ClieAgrEnt FROM (
			Select ccodsbs,CantEnt=count(ccodemp)
			from #ClieAgr
			group by ccodsbs--,ccodemp 
			--having  count(ccodemp)<=2
		) as tmp
			--order by cCodsbs
				-- (194,537 row(s) affected) sin filtro count(ccodemp)<=2
				-- ( 57,058 row(s) affected) con filtro count(ccodemp)=2
				-- (157,781 row(s) affected) con filtro count(ccodemp)<=2
			Select * from #ClieAgrEnt 			
			order by CCODSBS
			

	--05 cruzando con cant de ent

	SELECT * FROM [#t02] A WHERE CuotaPag != 0

		--ALTER TABLE #t02
		--ADD 
		--DROP COLUMN CantEnt 
	-- DROP TABLE #t03
	SELECT * INTO #t03 FROM (SELECT * FROM #t02 WHERE CuotaPag != 0) as tmp
		-- (18,592 row(s) affected)
		-- (17,456 row(s) affected)

		Select * from #t03

		-- Drop table #t04
	SELECT * into #t04 FROM (
	Select A.* , CantEnt=ISNULL(B.CantEnt,0)
	from [#t03] A
		LEFT JOIN [#ClieAgrEnt] B
			ON A.cCodSbs = B.CCODSBS
	) AS tmp
		-- (18,592 row(s) affected)

		Select * from #t04 where CantEnt = 0 order by dFecDesCre
			-- (77 row(s) affected) no tienen porque sacaron credito en junio-2015
			
				/*
				select * 
				from CRICMACHYO_DIARIO.DBO.[urirccsal] A (nolock)	
				where CCODSBS= '0012397321' --'0094199034'--'0102520726'
					and left(A.CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
				*/

		Select * from #t04    

	--*********************************INDEXANDO****************************************************
	CREATE NONCLUSTERED INDEX #t04_cCodCtaCre_IXN ON #t04(cCodCtaCre)
	CREATE NONCLUSTERED INDEX #t04_cCodSbs_IXN ON #t04(cCodSbs)	
	--------------------****************************************************************************
						
	--Por Creditos Empresariales		
	Select * from #t04
	where DiasPromAtr <= 6 and Porcentaje >= 40
		and cCodTipCre in ('02','11','12','13') 
		and cCodCliente != '107021169417' -- CLIENTE CREDI VIP
	order by cDesOficin					

		--CrediVip Empresa.
	select * from #t04 
	where Porcentaje >= 50 and DiasPromAtr <= 6
		and ((cCodTipCre = '02' and cCodSubPro = '02')
		or (cCodTipCre = '11' and cCodSubPro = '02')
		or (cCodTipCre = '12' and cCodSubPro = '02')
		or (cCodTipCre = '13' and cCodSubPro = '02'))
		-- cNomCliente	cCodSbs		cCodCliente
		-- BOZELT SAC	0124042003	107021169417

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
	Select * from #t04 
	WHERE DiasPromAtr <= 6
		AND cCodTipCre = '04'
	Order by cDesOficin	
	
	
	Select * from #t04
	where DiasPromAtr <= 6 AND Porcentaje >= 40
		and ((cCodTipCre = '03'  AND cCodSubPro != '06')
		    AND (cCodTipCre = '03' and cCodSubPro != '01')
			and (cCodTipCre = '03' and SubProductoCrediticio not like '%convenio%elegible%'))
	order by cDesOficin	

	-------------------------------------------------------------------------------------------
	--Grupo de Creditos
	Select cCodTipCre from #t04
	group by cCodTipCre