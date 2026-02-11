--USE SOFCMACHYO_201503
--Delete from #TMP_CREMICRO
--Drop table #TMP_CREMICRO
--Select * from #TMP_CREMICRO
--use SOFCMACHYO_DIARIO_MANIANA
		SELECT * into #TMP_CREMICRO FROM  (
		--CLIENTES DESERTORES creditos microempresa : #TMP_CREMICRO
		SELECT --TOP 900000
			/*
			ROW_NUMBER() 
			OVER(PARTITION BY CLI.cCodCliente 
					ORDER BY CRE.dFecDesCre ) AS Secuencia,
			*/
			--Datos del Cliente
			CLIM.cCodSbs AS 'COD_SBS1'
			,CLIM.cNroDocIde as 'NroDocumento1'

			,CLI.cCodCliente AS 'CODIGO_CLIENTE'
			,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	
			,C.cDirCliente AS 'Direccion_Cliente' 
			,isnull(C.cDirCliRef,'') as 'Direccion_Referencia_Cliente'
			,DEP.cNomDepart AS 'Departamento_Cliente'
			,pro.cNomProvin AS 'Provincia_Cliente'
			,dis.cNomDistri AS 'Distrito_Cliente'
			,isnull(CLIM.cNroTelPer,'') AS 'Nro_Telefono_Personal'

			--DATOS DEL CREDITO
			,CRE.cCodCtaCre AS 'CODIGO_CREDITO' --smalldatetime, 
			--,CONVERT(smalldatetime ,CRE.dFecDesCre, 103 ) as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
			,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
			,isnull(CRE.dFecCulCre,'') as 'Fecha_Culminacion_Credito'--FECHA DE CULMINACION DEL CREDITO
			--,round(avg(cast(nDiaVenCuo as float)),0) as 'Promedio_Nro_Dias_Atraso'
			--,CRE.nDiaAtrCre as 'Nro_Dias_Atraso_Cuota'
			--,CRE.nDiaAtrAcu as 'Nro_Dias_Atraso_Acumulado'
			--,CRE.nDiaAtrMax as 'Nro_Dias_Atraso_Maximo'

			,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
			,case CRE.cCodTipMon 
			 When '1' then 'SOLES'
			 WHEN '2' THEN 'DOLARES'
			 END as 'MONEDA'
			,CRE.nMonCapPag as 'CAPITAL_PAGADO' 
			,(CRE.nMonCapDes - CRE.nMonCapPag)  AS 'SALDO_CAPITAL'
			,CRE.nSalCapDia AS 'SALDO_CAPITAL_AL_DIA'
			,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
			 ,STC.cDesTipCre AS 'TIPO_DE_CREDITO'
			 ,CRE.cCodTipCre
			 ,STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
			 ,PROD.cDesProduct AS 'PRODUCTO' 
			 ,CRE.cCodProduc
			 ,SPRO.cDesSubPro AS 'SUBPRODUCTO'
			 ,CRE.cCodSubPro	 

			 --DATOS AGENCIA
			,O.cDesOficin AS 'NOMBRE_AGENCIA'
			,O.cCodOficin
			,O.cDirOficin AS 'DIRECCION_AGENCIA' 	
			,DEP1.cNomDepart AS 'Departamento_Agencia'			 
			,pro1.cNomProvin AS 'Provincia_Agencia' 
			,dis1.cNomDistri as 'Distrito_Agencia'
			,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'
			,CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
			,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA 	
	
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
	
			inner JOIN [sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna
			INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin
			INNER JOIN [KPYDPRODUCTO] PROD
					ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
			INNER JOIN [KPYDSUBPRODUC] SPRO
					ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
					AND CRE.cCodProduc =  SPRO.cCodProduc
			INNER JOIN [KPYTSUBTIPCRE] STC
					ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
					ON EC.cEstCreCon = CRE.cEstCreCon
	
			--UBIGEO DEL CLIENTE
			LEFT JOIN CMACHYOCLI_MANIANA.DBO.[CLIMDirecc] C
					ON CLI.cCodCliente = C.cCodCliente AND C.bDirPredet = 1	 
			INNER JOIN [GenTDepartame] dep
					ON DEP.cCodDepart = C.cCodDepart
			INNER JOIN [GentProvincia] pro
					ON pro.cCodProvin = C.cCodProvin and pro.cCodDepart = C.cCodDepart 
			INNER JOIN [GentDistrito] dis
					ON dis.cCodDistri = C.cCodDistri and DIS.cCodProvin = C.cCodProvin 
					and dis.cCodDepart = C.cCodDepart
		
			---UBIGEO DEL CREDITO
			INNER JOIN [GenTDepartame] dep1
				ON DEP1.cCodDepart = O.cCodDepart
			INNER JOIN [GentProvincia] pro1
				ON pro1.cCodProvin = O.cCodProvin and pro1.cCodDepart = O.cCodDepart 
			INNER JOIN [GentDistrito] dis1
				ON dis1.cCodDistri = O.cCodDistri and dis1.cCodProvin = O.cCodProvin 
					and dis1.cCodDepart = O.cCodDepart
			
			INNER JOIN [GentZona] zo
				ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
				and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
			INNER JOIN [Gentofizonas] goz
				ON goz.cCodOficin = O.cCodOficin
			INNER JOIN [GentZonas] zon
				ON goz.nCodZona = zon.nCodZona	

			--calificacion rcc
			/*
			INNER join [HYO00410].URIESGOS.dbo.[URIRCCMAE808] A 
				ON A.CCODSBS collate SQL_Latin1_General_CP1_CI_AS = CLIM.cCodSbs
			INNER JOIN [HYO00410].URIESGOS.dbo.[URIRCCSAL808] B
				ON A.CCODSBS = B.CCODSBS
			INNER JOIN [HYO00410].URIESGOS.dbo.[GENCODSBSEMPSISFIN] EMP
				ON B.CCODEMP = EMP.ccodempsisfin
				*/
		WHERE CRE.cEstCreCon = 'G' --ESTADO DEL CREDITO ES VIGENTE F
			  --and CRE.cEstCreCon not in  ('F','H','I','E')
			  --and STC.cCodTipCre in ('02','03','12','13') 
			  --and STC.cCodTipCre in ('02') --cDesTipCre : CRÉDITOS A MICROEMPRESAS
			  --and STC.cCodTipCre in ('03') --cDesTipCre : CONSUMO                                           
			  --and STC.cCodTipCre in ('12') --cDesTipCre : CRÉDITO A MEDIANAS EMPRESAS
			  --and STC.cCodTipCre in ('13') --cDesTipCre : CRÉDITO A PEQUEÑA EMPRESAS
			  --and B.CCALEMP = '0'
			  --and CRE.nDiaAtrCre <= 10 --'Nro_Dias_Atraso_Cuota'
			  --and round(avg(cast(nDiaVenCuo as float)),0) <= 10 --'Promedio_Nro_Dias_Atraso'
			  AND ZON.nCodZona = '2' --AND goz.nCodZona = '2' 	  
			  --and CLI.cCodCliente = '107011669073'--'107015172485' 
			  --and CRE.dFecDesCre = (select max(CRE01.dFecDesCre) from [KPYMCRECONVEN] CRE01
					--					INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENMCRECLI] CLI01 
					--							ON CLI01.cCodCtaCre = CRE01.cCodCtaCre
					--				WHERE  CLI01.cCodCliente = '107010000050') 
					--				--2013-10-04 00:00:00.000
			  --and CRE.cCodOficin = '012'
		) AS Tmp

--(374,310 row(s) affected) zona centro
--(136,137 row(s) affected) zona selva central
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #TMP_CREMICRO_COD_CLIENTE_IXN ON #TMP_CREMICRO(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #TMP_CREMICRO_COD_SBS1_IXN ON #TMP_CREMICRO(COD_SBS1)
CREATE NONCLUSTERED INDEX #TMP_CREMICRO_CODIGO_CREDITO_IXN ON #TMP_CREMICRO(CODIGO_CREDITO)
--------------------****************************************************************************
--DROP TABLE #TMP_CREMICRO
--DELETE #TMP_CREMICRO

SELECT * FROM #TMP_CREMICRO 

	SELECT * into #CREMICRO FROM  ( SELECT TOP 1 * FROM #TMP_CREMICRO) AS Tmp01

	SELECT * FROM #CREMICRO 
	DELETE FROM #CREMICRO
	--drop table #CREMICRO

	-----------OBTENIENDO EL ULTIMO CREDITO CANCELADO-----------
--CURSOR #TMP_CREMICRO
Declare @codcli varchar(16), @codcred varchar(18)
Declare cCremicro CURSOR FOR
	SELECT distinct CODIGO_CLIENTE FROM #TMP_CREMICRO (NOLOCK)--order by CODIGO_CLIENTE
OPEN cCremicro
FETCH cCremicro into @codcli
WHILE (@@FETCH_STATUS=0)
BEGIN
		INSERT INTO #CREMICRO 
			 
					SELECT 	* FROM  #TMP_CREMICRO (NOLOCK) 		
					WHERE CODIGO_CLIENTE = @codcli --''--'107010000050'--'107010000050' 
						  and Fecha_Desembolso_Credito = (select max(Fecha_Desembolso_Credito)--
															from #TMP_CREMICRO  (NOLOCK)														
															WHERE CODIGO_CLIENTE = @codcli ) --'' --'107010000050') --@codcli )--'107010000050') 04/10/2013																					
FETCH cCremicro INTO @codcli
END
CLOSE cCremicro
DEALLOCATE cCremicro

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #CREMICRO_COD_CLIENTE_IXN ON #CREMICRO(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #CREMICRO_COD_SBS1_IXN ON #CREMICRO(COD_SBS1)
CREATE NONCLUSTERED INDEX #CREMICRO_CODIGO_CREDITO_IXN ON #CREMICRO(CODIGO_CREDITO)
--------------------****************************************************************************
--DELETE FROM #CREMICRO
		SELECT * FROM #CREMICRO 
			where cCodOficin = '012'

		-- ZONA LIMA NORTE
		-- ZONA CENTRO ORIENTE
		-- zona selva central
		-- --ZONA LIMA SUR
		--(138,789 row(s) affected) --zona centro

	SELECT * into #CREMICROCANC FROM  ( SELECT TOP 1 * FROM #CREMICRO) AS Tmp02
	SELECT * FROM #CREMICROCANC
	DELETE FROM #CREMICROCANC
	--drop table #CREMICROCANC

-------SOLO CANCELADOS---------
--CURSOR #TMP_CREMICRO
Declare @codcli1 varchar(16)
Declare cCremicroCan CURSOR FOR
	SELECT CODIGO_CLIENTE FROM #CREMICRO (NOLOCK) --WHERE CODIGO_CLIENTE IN ('107010001025','107015172485')
OPEN cCremicroCan
FETCH cCremicroCan into @codcli1
WHILE (@@FETCH_STATUS=0)
BEGIN
		IF NOT EXISTS 
				(	Select EC.cDescriEst--,CRE.cEstCreCon, CLI.cCodCliente, CRE.cCodCtaCre
					FROM [KPYMCRECONVEN] CRE (NOLOCK)
							INNER JOIN [GENMCRECLI] CLI 
								ON CLI.cCodCtaCre = CRE.cCodCtaCre
							INNER JOIN KPYTEstCreCon EC 
								ON EC.cEstCreCon = CRE.cEstCreCon
					where CLI.cCodCliente = @codcli1--'107015172485' --'107015172485'
							and CRE.cEstCreCon in  ('F','H','I','E')
							)
			BEGIN 
			INSERT INTO #CREMICROCANC 			 					
					SELECT 	* FROM  #CREMICRO (NOLOCK) 		
					WHERE CODIGO_CLIENTE = @codcli1 			
			END	 					

FETCH cCremicroCan INTO @codcli1
END
CLOSE cCremicroCan
DEALLOCATE cCremicroCan
-----------------------------------------------------------------------------------
--select EC.cDescriEst,CRE.cEstCreCon, CLI.cCodCliente, CRE.cCodCtaCre
--FROM [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
--		INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENMCRECLI] CLI 
--			ON CLI.cCodCtaCre = CRE.cCodCtaCre
--		INNER JOIN KPYTEstCreCon EC 
--			ON EC.cEstCreCon = CRE.cEstCreCon
--where CLI.cCodCliente IN ('107015172485','107010001025')
--		and CRE.cEstCreCon in  ('F','H','I','E')


--Secuencia	COD_SBS1	NroDocumento1	CODIGO_CLIENTE	NOMBRE_CLIENTE	Direccion_Cliente	Direccion_Referencia_Cliente	Departamento_Cliente	Provincia_Cliente	Distrito_Cliente	Nro_Telefono_Personal	Clasificacion_del_Cliente	CODIGO_CREDITO	Fecha_Desembolso_Credito	Fecha_Culminacion_Credito	Nro_Dias_Atraso_Cuota	MONTO_DESEMBOLSADO	MONEDA	CAPITAL_PAGADO	SALDO_CAPITAL	ESTADO_DEL_CREDITO	TIPO_DE_CREDITO	SUB_TIPO_DE_PRESTAMO	PRODUCTO	SUBPRODUCTO	NOMBRE_AGENCIA	DIRECCION_AGENCIA	Departamento_Agencia	Provincia_Agencia	Distrito_Agencia	Detalle_Zona	Zona	COD_ANALISTA	NOMBRE_ANALISTA	RCC_Enero_2015	RCC_Diciembre_2014_	RCC_Noviembre_2014	RCC_Octubre_2014	RCC_Septiembre_2014	RCC_Agosto_2014
--1	0016495689	20099915            	107010001025	ACEVEDO PEREZ, ANTONIO	AV. FERROCARRIL # 412		JUNIN	HUANCAYO	HUANCAYO	            		107002101003187014	2010-04-07 00:00:00.000	2012-07-06 00:00:00.000	0	15000.00	SOLES	15000.00	0.00	CANCELADO	CRÉDITOS A MICROEMPRESAS	PRESTAMOS	A CUOTA FIJA	EMPRESARIAL 	AG. REAL	CALLE REAL N° 341 - 343	JUNIN	HUANCAYO	HUANCAYO	HUANCAYO                                                                                            	ZONA CENTRO	PLEONA	LEONARDO/SALAZAR,PABLO GILBERT                                                                                          						

	  --select	*
	  --from	KPYTEstCreCon

	  SELECT * FROM #CREMICROCANC 
		where cCodOficin = '012'
	  -- ZONA LIMA NORTE
	  --(34004 row(s) affected) ZONA CENTRO ORIENTE
	  -- zona selva central
	  -- ZONA LIMA SUR
	  --(78,277 row(s) affected) ZONA CENTRO
	  -- DROP TABLE #CREMICROCANC
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #CREMICROCANC_COD_CLIENTE_IXN ON #CREMICROCANC(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #CREMICROCANC_COD_SBS1_IXN ON #CREMICROCANC(COD_SBS1)
CREATE NONCLUSTERED INDEX #CREMICROCANC_CODIGO_CREDITO_IXN ON #CREMICROCANC(CODIGO_CREDITO)
--------------------****************************************************************************
			-- drop table #CREMICROCANC_
			-- drop table #tmp_sacar
			--Sacando los productos indicados de consumo
			--02
			SELECT * into #tmp_sacar FROM  ( 
			Select * from  #CREMICROCANC (NOLOCK)
			Where  (	(cCodTipCre = '03' and cCodProduc in ('03','13') and cCodSubPro in ('07','08','09','13','16'))
				or (cCodTipCre = '11' and cCodProduc = '02' and cCodSubPro = '06' )  )
				--(474 row(s) affected)
			) as tmp02
			
			--(474 row(s) affected)
			SELECT * FROM #tmp_sacar

			--03
			SELECT * into #CREMICROCANC_ FROM  (
					select * 
					from #CREMICROCANC
					where CODIGO_CREDITO not in (Select CODIGO_CREDITO from #tmp_sacar)
			) as tmp02
			--(77803 row(s) affected)

			--------------------VERIFICANDO----------------------
			--04	
		
			select * from #CREMICROCANC_
			Where  (	(cCodTipCre = '03' and cCodProduc in ('03','13') and cCodSubPro in ('07','08','09','13','16'))
							or (cCodTipCre = '11' and cCodProduc = '02' and cCodSubPro = '06' )  )

	-----------************** TEMA CONYUGUE
	--obteniendo data de conyugues
	--02
	-- drop table #tmp_V02
	SELECT * into #tmp_V02 FROM (
		SELECT 
			CPN.cCodConyug, CPN.cCodCliente,CPN.cApePat,CPN.cApeMat,CPN.cNombre
		FROM CMACHYOCLI.dbo.[CLIMPERNAT] CPN (NOLOCK)
		where CPN.cCodConyug in (select CODIGO_CLIENTE from #CREMICROCANC_ (NOLOCK) )
		
	) as tmp98
	--(38,005 row(s) affected)

	--conyugues con credito vigentes
	--03
	-- drop table #tmp_V03
	SELECT * into #tmp_V03 FROM (	
	Select 
			CLIM.cNroDocIde as 'NroDocumento1'
			,CLI.cCodCliente AS 'CODIGO_CLIENTE'
			,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
			,CRE.cCodCtaCre AS 'CODIGO_CREDITO'
			,CRE.cEstCreCon
	from [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
	where CLI.cCodCliente in (select cCodCliente from #tmp_V02)
		and CRE.cEstCreCon IN ('F','H','I')
	
	) as tmp99
	--(6,433 row(s) affected)
	
	--sacando a clientes con conyugues con credito vigentes
	--04
	select * from #tmp_V02 --(38,005 row(s) affected)
	select * from #tmp_V03 --(6433 row(s) affected) --esta considerando q un conyugue puede tener varios creditos.
	-- drop table #tmp_V04 	
	SELECT * into #tmp_V04 FROM (	
	select * from #tmp_V02 X
	where X.cCodCliente in (select Y.CODIGO_CLIENTE from #tmp_V03 Y)
	) as tmp97
	--(5349 row(s) affected)

	--filtrando de la lista de creditos
	--05
	--DROP TABLE #CREMICROCANC_
	select * from #CREMICROCANC_ --(77,803 row(s) affected)
	select * from #tmp_V04 --(5,349 row(s) affected)
	
	-- drop table #CREMICROCANCX
	SELECT * into #CREMICROCANCX FROM (	
	select * from #CREMICROCANC_ X
	where X.CODIGO_CLIENTE not in (select Y.cCodConyug from #tmp_V04 Y)
	) as tmp96
	--(72,458 row(s) affected)
	--(29,724 row(s) affected)

	--*********************** ULTIMA FECHA 
	--15 días  sin relación crediticia con la Caja.
	--Como es al cierre 31-03-2015, cumple.
	--drop table #CREMICROCANCX
	--drop table #tmp_V04
	--drop table #tmp_V02
	--drop table #tmp_V03

---------------------------CREDITOS CON PROMEDIO DE ATRASO <= 8, TABLA PLAN DE PAGOS-----------
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #CREMICROCANCX_COD_CLIENTE_IXN ON #CREMICROCANCX(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #CREMICROCANCX_COD_SBS1_IXN ON #CREMICROCANCX(COD_SBS1)
CREATE NONCLUSTERED INDEX #CREMICROCANCX_CODIGO_CREDITO_IXN ON #CREMICROCANCX(CODIGO_CREDITO)
--------------------****************************************************************************	
	SELECT * FROM #CREMICROCANCX (NOLOCK) 	
	--DROP TABLE #CREMICROCANCX
	
	ALTER TABLE #CREMICROCANCX
	ADD PromDiaAtr int 

	SELECT * into #CREMICROCANC01 FROM  ( SELECT TOP 1 * FROM #CREMICROCANCX) AS Tmp98
	DELETE FROM #CREMICROCANC01
	--DROP TABLE #CREMICROCANC01
	--ALTER TABLE #CREMICROCANC01
	--ADD PromDiaAtr int 
	SELECT * FROM #CREMICROCANCX (NOLOCK) --(72458 row(s) affected)

	SELECT * FROM #CREMICROCANC01  (NOLOCK) 	
	--drop table #CREMICROCANC01			

	--SELECT TOP 10 CODIGO_CREDITO FROM #CREMICROCANC (NOLOCK)

		Declare @ccodcred varchar(18), @diaatr int
		--set @ccodcred = '107016101000146483'
			Declare cDiaAtraso CURSOR FOR	
			SELECT CODIGO_CREDITO FROM #CREMICROCANC (NOLOCK) 	

			OPEN cDiaAtraso
				FETCH cDiaAtraso into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				set @diaatr =  (SELECT round(avg(cast(nDiaVenCuo as float)),0)
								FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
								WHERE PLA.cCodCtaCre = @ccodcred )																																																	

				if @diaatr <= 8
				begin 

				INSERT INTO #CREMICROCANC01
					SELECT * FROM #CREMICROCANCX (NOLOCK) 
					WHERE CODIGO_CREDITO = @ccodcred

				UPDATE #CREMICROCANC01
				SET PromDiaAtr = @diaatr
				WHERE CODIGO_CREDITO = @ccodcred
				
				END

				FETCH cDiaAtraso INTO @ccodcred
				END
				CLOSE cDiaAtraso
				DEALLOCATE cDiaAtraso

----------------VERIFICANDO---------------------------
			
			SELECT * FROM #CREMICROCANC01 (NOLOCK)--DATA FILTRADA
			--(51,878 row(s) affected) ZONA CENTRO 
			--ZONA LIMA NORTE
			--ZONA CENTRO ORIENTE
			--(20560 row(s) affected) zona selva central
			--ZONA LIMA SUR

		--and round(avg(cast(nDiaVenCuo as float)),0) <= 10
		--INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[KPYDPLANPAGCRE] PLA
		--ON PLA.cCodCtaCre = CRE.cCodCtaCre
	
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #CREMICROCANC01_COD_CLIENTE_IXN ON #CREMICROCANC01(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #CREMICROCANC01_COD_SBS1_IXN ON #CREMICROCANC01(COD_SBS1)
CREATE NONCLUSTERED INDEX #CREMICROCANC01_CODIGO_CREDITO_IXN ON #CREMICROCANC01(CODIGO_CREDITO)
--------------------****************************************************************************
	

		--********************************************

		SELECT * FROM #CREMICROCANC01 (NOLOCK)

		ALTER TABLE #CREMICROCANC01
		ADD cEntFin int

		--ALTER TABLE #CREMICROCANC01
		--Drop COLUMN RCC_MAR2014 
		 
		ALTER TABLE #CREMICROCANC01
		ADD RCC_FEB2014 VARCHAR(12)
		--RCC_FEB2014 VARCHAR(12) , RCC_MAR2014 VARCHAR(12) , RCC_ABR2014 VARCHAR(12) 			
		--RCC_MAY2014 VARCHAR(12), RCC_JUN2014 VARCHAR(12) , RCC_JUL2014 VARCHAR(12) , RCC_AGO2014 VARCHAR(12) 			
		--RCC_SET2014 VARCHAR(12), RCC_OCT2014 VARCHAR(12) , RCC_NOV2014 VARCHAR(12) , RCC_DIC2014 VARCHAR(12) 
		--RCC_ENE2015 VARCHAR(12) , RCC_FEB2015 VARCHAR(12) 

		SELECT * FROM #CREMICROCANC01 (NOLOCK)

	  ---*************COMPLETANDO NroDoc NULL **********************------
	  --SELECT * FROM #CREMICROCANC where COD_SBS1 IS NULL --(233 row(s) affected)
	  SELECT * FROM #CREMICROCANC01 where NroDocumento1 IS NULL 
	  --(65 row(s) affected) zona selva central
	  --(105 row(s) affected) --zona lima sur
	  --(1151 row(s) affected) --zona centro

	 -- SELECT TOP 5 * FROM [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
	 -- SELECT CLIM.cCodClaPer FROM [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM GROUP BY CLIM.cCodClaPer
		----1 		2 		3 		4 		5 		6 		7
	 -- SELECT CLIM.cCodTipDocId FROM [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM GROUP BY CLIM.cCodTipDocId
	 -- -- NULL 0 1 2 3 4 5 6 7 8 9
	  --SELECT --top 50 
			----CLIM.cNroDocIde,CLIM.cCodTipDocId,
			--CLIM.cNroDocTri--,* 
	  --FROM [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
	  --where CLIM.cCodCliente = '107012075756'

			--CLIM.cCodClaPer = '3'--'6'--'5'--'3'
		--	--AND CLIM.cCodTipDocId = '6'--'4'--'3'--'2'--'1'


	  --SELECT TOP 3 * FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)
	  
	  --SELECT * FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)
	  --WHERE A.CNUDOCI COLLATE SQL_Latin1_General_CP1_CI_AS  
			--IN  ('19904319')--(SELECT NroDocumento1 FROM #CREMICROCANC where COD_SBS1 IS NULL)
			
	  ------------CURSOR COMPLETANDO nro doc null-----------
	  Declare @ccodcli01 varchar(12)
				Declare cNrodoc CURSOR FOR							
					 SELECT CODIGO_CLIENTE FROM #CREMICROCANC01 (NOLOCK)  
					 where NroDocumento1 IS NULL					
				OPEN cNrodoc
				FETCH cNrodoc into @ccodcli01
				WHILE (@@FETCH_STATUS=0)
				BEGIN										
					UPDATE #CREMICROCANC01
					SET NroDocumento1 = (SELECT cNroDocTri 
										 FROM  CMACHYOCLI.dbo.[CLIMCLIENTES]
										 WHERE cCodCliente = @ccodcli01)
					WHERE CODIGO_CLIENTE = @ccodcli01
				FETCH cNrodoc INTO @ccodcli01
				END
				CLOSE cNrodoc
				DEALLOCATE cNrodoc
		------------------------VERIFICANDO----------------
		  --SELECT * FROM #CREMICROCANC where CODIGO_CLIENTE = '107012075756'
		  SELECT * FROM #CREMICROCANC01 where NroDocumento1 IS NULL --0

		---*************COMPLETANDO COD SBS NULL **********************------
	  SELECT * FROM #CREMICROCANC01 where COD_SBS1 IS NULL 
	  --(233 row(s) affected) zona centro
				UPDATE #CREMICROCANC01				
				SET COD_SBS1 = '0000000001'
				where COD_SBS1 IS NULL 	--

	  SELECT * FROM #CREMICROCANC01 where COD_SBS1 = '' 
	  --(9 row(s) affected) zona lima sur
	  --(168 row(s) affected) zona centro
				UPDATE #CREMICROCANC01				
				SET COD_SBS1 = '0000000002'
				where COD_SBS1 = '' 
				--(168 row(s) affected) zona centro
				--(9 row(s) affected) zona lima sur

		
	--------------------------------------*******************

	  SELECT * FROM #CREMICROCANC01 (NOLOCK) 
	  --ZONA LIMA NORTE
	  --ZONA CENTRO ORIENTE
	  --zona selva central
	  --zona lima sur
	  --(51,878 row(s) affected)zona centro
	  
	  SELECT COD_SBS1 
					FROM #CREMICROCANC01 (NOLOCK) 
					WHERE COD_SBS1 NOT IN ('0000000001','0000000002')	
					--zona lima norte
					--ZONA CENTRO ORIENTE
					--(20,482 row(s) affected) zona selva central 
					--zona lima sur
					--(51,761 row(s) affected) zona centro
				
				--SELECT TOP 5 * FROM [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
				--WHERE CLIM.cCodSbs = '0000000001'  


	  --Update #CREMICROCANC
	  --Set COD_SBS1 = '0070718634'
	  --where COD_SBS1 IS NULL
	
	--------------***************CLIENTES CON MAX 4 IFIS----------
		--SELECT * FROM #CREMICROCANC where COD_SBS1 IS not NULL

		SELECT * FROM #CREMICROCANC01
		
		
		--SELECT * FROM #CREMICROCANC01 where COD_SBS1 = '0053824676'
		
		
		SELECT * into #CREMICROIFIS FROM  ( SELECT TOP 1 * FROM #CREMICROCANC01) AS Tmp03
		SELECT * from #CREMICROIFIS
		DELETE FROM #CREMICROIFIS
		--drop table #CREMICROIFIS
		--ALTER TABLE #CREMICROIFIS
		--ADD cEntFin int 

		---------*******seleccionando agencias------------
		SELECT COD_SBS1 
					FROM #CREMICROCANC01 (NOLOCK) 
					WHERE COD_SBS1 NOT IN ('0000000001','0000000002')	
				

		---------------***********zonas
		SELECT  * 
		FROM #CREMICROCANC01 (NOLOCK) 
		WHERE COD_SBS1 NOT IN ('0000000001','0000000002')
				and cCodOficin  =  '001'
			--and ZONA = 'ZONA CENTRO'
			--AND Departamento_Agencia = 'JUNIN' and Provincia_Agencia = 'HUANCAYO' and Distrito_Agencia='HUANCAYO'
			--and NOMBRE_AGENCIA 
				--				not in ('AG. REAL' , 'OF. PRINCIPAL' )			
											
			--('AG. REAL' , 'OF. PRINCIPAL' ) --(10922 row(s) affected)
			--zona centro sin ag. real ni of. principal (13980 row(s) affected)	

	-----------CURSOR-------------------
				Declare @ccodsbs varchar(12), @cant int
				Declare cClienteIfi CURSOR FOR					
					SELECT COD_SBS1 
					FROM #CREMICROCANC01 (NOLOCK) 
					WHERE COD_SBS1 NOT IN ('0000000001','0000000002')	
						--and cCodOficin = '001'
												
				OPEN cClienteIfi
				FETCH cClienteIfi into @ccodsbs
				WHILE (@@FETCH_STATUS=0)
				BEGIN					
					set @cant =	(	
							SELECT COUNT (DISTINCT B.CCODEMP)							
							FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B  (NOLOCK)			
							WHERE B.CCODSBS = @ccodsbs and B.CCALEMP = '0'
									and LEFT(B.Cctacon, 4) in 
								('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')	
							    )
								
						IF  @cant < = 3 
								
							BEGIN 
							INSERT INTO #CREMICROIFIS		 					
									SELECT 	* FROM #CREMICROCANC01  (NOLOCK) 		
									WHERE COD_SBS1 = @ccodsbs 
									--AND  COD_SBS1 IS not NULL								
							
							Update #CREMICROIFIS
							Set cEntFin = @cant
							WHERE COD_SBS1 = @ccodsbs 	--AND  COD_SBS1 IS not NULL	
							 				
							END	 					

				FETCH cClienteIfi INTO @ccodsbs
				END
				CLOSE cClienteIfi
				DEALLOCATE cClienteIfi

				
-----------------------VERIFICANDO-----------------------------------
			--SELECT * FROM #CREMICROCANC --(196815 row(s) affected)

			SELECT * from #CREMICROIFIS (NOLOCK) 		

			SELECT * from #CREMICROIFIS 
			order by codigo_cliente
		
			
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #CREMICROIFIS_CODIGO_CLIENTE_IXN ON #CREMICROIFIS(CODIGO_CLIENTE)		
CREATE NONCLUSTERED INDEX #CREMICROIFIS_COD_SBS1_IXN ON #CREMICROIFIS(COD_SBS1)		
CREATE NONCLUSTERED INDEX #CREMICROIFIS_CODIGO_CREDITO_IXN ON #CREMICROIFIS(CODIGO_CREDITO)

-----------******************RCC *****************-----------------
			
			--ALTER TABLE #CREMICROIFIS
			--ADD RCC_FEB2014 VARCHAR(12)
			----RCC_FEB2014 VARCHAR(12) , RCC_MAR2014 VARCHAR(12) , RCC_ABR2014 VARCHAR(12) 			
			----RCC_MAY2014 VARCHAR(12), RCC_JUN2014 VARCHAR(12) , RCC_JUL2014 VARCHAR(12) , RCC_AGO2014 VARCHAR(12) 			
			----RCC_SET2014 VARCHAR(12), RCC_OCT2014 VARCHAR(12) , RCC_NOV2014 VARCHAR(12) , RCC_DIC2014 VARCHAR(12) 
			----RCC_ENE2015 VARCHAR(12) , RCC_FEB2015 VARCHAR(12) 


		--delete from #CREMICROFINAL
		--DROP TABLE #CREMICROFINAL
		SELECT * into #CREMICROFINAL FROM  ( SELECT * FROM #CREMICROIFIS) AS Tmp04 
		
		SELECT * FROM #CREMICROIFIS (NOLOCK) 		

		--INSERT INTO #CREMICROFINAL
		--SELECT * FROM #CREMICROIFIS

		--SELECT * from #CREMICROFINAL 
		----(13945 row(s) affected)
		----(10819 row(s) affected)

		--SELECT top 5 * from #CREMICROFINAL 
		--WHERE CODIGO_CLIENTE = '107010613779'--'107010614033'--'107010613779'

		--*********************************INDEXANDO****************************************************
		CREATE NONCLUSTERED INDEX #CREMICROFINAL_CODIGO_CLIENTE_IXN ON #CREMICROFINAL(CODIGO_CLIENTE)	
		CREATE NONCLUSTERED INDEX #CREMICROFINAL_COD_SBS1_IXN ON #CREMICROFINAL(COD_SBS1)	
		CREATE NONCLUSTERED INDEX #CREMICROFINAL_CODIGO_CREDITO_IXN ON #CREMICROFINAL(CODIGO_CREDITO)

		--DROP COLUMN RCC_Agosto_2014
		--RCC_Noviembre_2014--RCC_Diciembre_2014_--RCC_Enero_2015
		--DELETE FROM #CREMICROFINAL
		--drop table #CREMICROFINAL
		SELECT * from #CREMICROFINAL (NOLOCK) 
		WHERE cCodOficin = ''
		--(51,357 row(s) affected) ZONA CENTRO

			---------------*******CURSOR CLASIFICACION RCC****************----------------------------------
				Declare @ccodcliente varchar(12), @feb2015 char(12) , @ene2015 char(12), @dic2014 char(12), @nov2014 char(12) 
				,@oct2014  char(12), @set2014 char(12), @ago2014 char(12), @jul2014 char(12), @jun2014 char(12), @may2014 char(12)
				,@abr2014  char(12), @mar2014 char(12), @feb2014 char(12)
				Declare cClienteRCC CURSOR FOR					
					SELECT CODIGO_CLIENTE
					FROM  #CREMICROFINAL (NOLOCK) 
							WHERE cCodOficin IN  ('057','069','070','071','075')
				OPEN cClienteRCC
				FETCH cClienteRCC into @ccodcliente
				WHILE (@@FETCH_STATUS=0)
				BEGIN		
					--SET @ccodcliente = '107010613779'--'107010614033'

					set @feb2015 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201502'
										AND CCODCLIENTE = @ccodcliente ) 					
					--SELECT @feb2015
					--FEB2015
					IF @feb2015 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_FEB2015 = @feb2015
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	
					ELSE IF @feb2015 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_FEB2015 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				

					--ENE2015
					set @ene2015 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201501'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @ene2015 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_ENE2015 = @ene2015
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @ene2015 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_ENE2015 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END								

					--DIC2014
					set @dic2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201412'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @dic2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_DIC2014 = @dic2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				
					ELSE IF @dic2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_DIC2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END		

					--NOV2014
					set @nov2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201411'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @nov2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_NOV2014 = @nov2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @nov2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_NOV2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END					

					--OCT2014
					set @oct2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201410'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @oct2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_OCT2014 = @oct2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				
					ELSE IF @oct2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_OCT2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	

					--SET2014
					set @set2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201409'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @set2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_SET2014 = @set2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @set2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_SET2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END					

					--AGO2014
					set @ago2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201408'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @ago2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_AGO2014 = @ago2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @ago2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_AGO2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END					

					--JUL2014
					set @jul2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201407'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @jul2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_JUL2014 = @jul2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				
					ELSE IF @jul2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_JUL2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	

					--JUN2014
					set @jun2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201406'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @jun2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_JUN2014 = @jun2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				
					ELSE IF @jun2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_JUN2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	

					--MAY2014
					set @may2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201405'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @may2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_MAY2014 = @may2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @may2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_MAY2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END					

					--ABR2014
					set @abr2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201404'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @abr2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_ABR2014 = @abr2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @abr2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_ABR2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END						


					---MAR2014
					set @mar2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201403'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @mar2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_MAR2014 = @mar2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END				
					ELSE IF @mar2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_MAR2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END	

					--FEB2014
					set @feb2014 = 
								(SELECT Z.CDESQUECARF FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK) 
										INNER JOIN #CREMICROFINAL X  ON X.CODIGO_CLIENTE = Z.CCODCLIENTE
										WHERE CCODFECMES = '201402'
										AND CCODCLIENTE = @ccodcliente ) 					
					IF @feb2014 <> ''
					BEGIN		
								Update #CREMICROFINAL
								Set RCC_FEB2014 = @feb2014
								WHERE CODIGO_CLIENTE = @ccodcliente
					END
					ELSE IF @feb2014 IS NULL
					BEGIN
								Update #CREMICROFINAL
								Set RCC_FEB2014 = 'NO REGISTRA'
								WHERE CODIGO_CLIENTE = @ccodcliente
					END														
				
				FETCH cClienteRCC INTO @ccodcliente
				END
				CLOSE cClienteRCC
				DEALLOCATE cClienteRCC									
			
            -------------------------VALIDANDO----------------------
			
			SELECT * from #CREMICROFINAL (NOLOCK)
			WHERE cCodOficin IN  ('057','069','070','071','075') 
					AND RCC_FEB2015 IN ('NO REGISTRA','NORMAL')	
					AND RCC_ENE2015	IN ('NO REGISTRA','NORMAL')	
					AND RCC_DIC2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_NOV2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_OCT2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_SET2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_AGO2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_JUL2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_JUN2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_MAY2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_ABR2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_MAR2014	IN ('NO REGISTRA','NORMAL')	
					AND RCC_FEB2014 IN ('NO REGISTRA','NORMAL')	
					--AND CODIGO_CLIENTE = '107010399247'

					--drop table #CREMICROFINAL
			
			--(10819 row(s) affected)
			--WHERE CODIGO_CLIENTE = '107013024304'--'107013023419'
			/*
			SELECT * from #CREMICROFINAL WHERE RCC_SET2014 is  null
				--RCC_FEB2015 is null  --201502
				UPDATE #CREMICROFINAL 
				SET RCC_SET2014 = 'NO REGISTRA'
				WHERE RCC_SET2014 is  null
				--RCC_ENE2015 is null
					--RCC_FEB2015 is null 
					--(69129 row(s) affected)
				--(79302 row(s) affected) (79302 row(s) affected)
				--(77142 row(s) affected) (77142 row(s) affected)
				--(74933 row(s) affected) (74933 row(s) affected)
				--(72617 row(s) affected) (72617 row(s) affected)
				--(70803 row(s) affected) (70803 row(s) affected)
			
				
		*/

		-------------TRABAJANDO CON SBS CREADOS
	SELECT * 
	FROM #CREMICROCANC01 (NOLOCK) 
	WHERE COD_SBS1 IN ('0000000001','0000000002')	
	--(401 row(s) affected) zona centro
	--9 row(s) affected) zona lima sur

	----creando tabla para asignar rcc y cantent
		SELECT * into #CREMICROSINSBS FROM  ( SELECT * 	FROM #CREMICROCANC01 (NOLOCK) 
												WHERE COD_SBS1 IN ('0000000001','0000000002')		
		) AS Tmp99

		SELECT * FROM #CREMICROSINSBS
		--(401 row(s) affected)


		--DELETE FROM #CREMICROSINSBS
		--DROP TABLE #CREMICROSINSBS

		--*********************************INDEXANDO****************************************************
		--CREATE NONCLUSTERED INDEX #CREMICROFINAL_CODIGO_CLIENTE_IXN ON #CREMICROFINAL(CODIGO_CLIENTE)	
		--CREATE NONCLUSTERED INDEX #CREMICROFINAL_COD_SBS1_IXN ON #CREMICROFINAL(COD_SBS1)

		--ALTER TABLE #CREMICROSINSBS
		--ADD RCC_FEB2015 VARCHAR(12)
			--RCC_FEB2014 VARCHAR(12) , RCC_MAR2014 VARCHAR(12) , RCC_ABR2014 VARCHAR(12) 			
			--RCC_MAY2014 VARCHAR(12), RCC_JUN2014 VARCHAR(12) , RCC_JUL2014 VARCHAR(12) , RCC_AGO2014 VARCHAR(12) 			
			--RCC_SET2014 VARCHAR(12), RCC_OCT2014 VARCHAR(12) , RCC_NOV2014 VARCHAR(12) , RCC_DIC2014 VARCHAR(12) 
			--RCC_ENE2015 VARCHAR(12) , RCC_FEB2015 VARCHAR(12) 	
		
		------*** ACTUALIZANDO NUEVOS CAMPOS *********************--
		UPDATE #CREMICROSINSBS
		SET cEntFin = 0

		UPDATE #CREMICROSINSBS
		SET RCC_FEB2015 = 'NO REGISTRA'
		
		----------------LISTA FINAL------------
		SELECT * FROM #CREMICROSINSBS (NOLOCK) 
		/*
		WHERE ZONA = 'ZONA CENTRO'
						AND Departamento_Agencia = 'JUNIN' and Provincia_Agencia = 'HUANCAYO' and Distrito_Agencia='HUANCAYO'
						and NOMBRE_AGENCIA --IN ('AG. REAL' , 'OF. PRINCIPAL' )
											NOT IN ('AG. REAL' , 'OF. PRINCIPAL' )
		*/
		
		/*
		-----BD EN EQUIPO LOCAL-
		--SELECT * from HYOSGC09.SGN.dbo.[CREMICROFINAL] FROM  table_test
		SELECT * into HYOSGC09.SGN.sa.[CREMICROFINAL] FROM  
		( SELECT * FROM #CREMICROFINAL) AS Tmp05 --(82126 row(s) affected)

	--******************FILTRANDO POR AGENCIAS----------
	SELECT * FROM #CREMICROFINAL 
	WHERE ZONA = 'ZONA CENTRO' AND Departamento_Agencia = 'JUNIN' and Provincia_Agencia = 'HUANCAYO' and Distrito_Agencia='HUANCAYO'
		and NOMBRE_AGENCIA = 'AG. REAL'
		--AND CODIGO_CLIENTE IN ('107015172485','107010001025')
--ORDER BY CODIGO_CLIENTE


	  --select * from [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYDPRODUCTO] PROD
			----ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
	  --select * from [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYDSUBPRODUC] SPRO
			----ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
			----AND CRE.cCodProduc =  SPRO.cCodProduc
	  --select * from [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYTSUBTIPCRE] STC


--SELECT distinct (CODIGO_CREDITO), *  FROM TMPCLIDESER

--SELECT distinct (COD_SBS1), *  FROM TMPCLIDESER

--DROP TABLE TMPCLIDESER

--INDEXANDO
--CREATE NONCLUSTERED INDEX TMPCLIVIG_COD_SBS1_IXN ON TMPCLIVIG(COD_SBS1)

/*
SELECT TOP 5 *, 
	STC.cDesTipCre AS 'TIPO_DE_CREDITO', STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
*/
*/