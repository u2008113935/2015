		-- DROP TABLE #TMP_CREMICRO
		SELECT * into #TMP_CREMICRO FROM  (
		--CLIENTES DESERTORES creditos microempresa : #TMP_CREMICRO
		SELECT 
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
			,CRE.cCodCtaCre AS 'CODIGO_CREDITO' 		
			,left(cast(CRE.dFecDesCre as date),10) as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
			,left(cast(CRE.dFecCulCre as date),10) as 'Fecha_Culminacion_Credito'--FECHA DE CULMINACION DEL CREDITO		

			,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
			,case CRE.cCodTipMon 
			 When '1' then 'SOLES'
			 WHEN '2' THEN 'DOLARES'
			 END as 'MONEDA'
			,CRE.nMonCapPag as 'CAPITAL_PAGADO' 
			,(CRE.nMonCapDes - CRE.nMonCapPag)  AS 'SALDO_CAPITAL'
			,CRE.nSalCapDia AS 'SALDO_CAPITAL_AL_DIA'
			
			,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
			,CRE.cCodTipCre
			,STC.cDesTipCre AS 'TipoCredito'
			,STC.cDesSubTip AS 'SubTipoCredito'
			,CRE.cCodProduc
			,STC.cDesProCre AS 'ProductoCrediticio' 
			,CRE.cCodSubPro	
			,STC.cDesSubcRE AS 'SubProductoCrediticio' 				 

			 --DATOS AGENCIA
			,O.cDesOficin AS 'NOMBRE_AGENCIA'
			,O.cCodOficin
			,ZON.nCodZona, ZON.cDesZona	
			,CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
			,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA 	
	
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
	
			inner JOIN [sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna			
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
			
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona	
				
		WHERE CRE.cEstCreCon = 'G' 	 
			  AND ZON.nCodZona IN  ('2','6') 	  			  			  

		) AS Tmp

		-- (38,1083 row(s) affected) Centro
		-- (846,183 row(s) affected) TODAS LAS ZONAS

		-- (958,008 row(s) affected)
		--*********************************INDEXANDO****************************************************
		CREATE NONCLUSTERED INDEX #TMP_CREMICRO_COD_CLIENTE_IXN ON #TMP_CREMICRO(CODIGO_CLIENTE)
		CREATE NONCLUSTERED INDEX #TMP_CREMICRO_COD_SBS1_IXN ON #TMP_CREMICRO(COD_SBS1)
		CREATE NONCLUSTERED INDEX #TMP_CREMICRO_CODIGO_CREDITO_IXN ON #TMP_CREMICRO(CODIGO_CREDITO)
		--------------------****************************************************************************
		/*
		Select NOMBRE_AGENCIA, cCodOficin
		from #TMP_CREMICRO
		group by NOMBRE_AGENCIA, cCodOficin
		*/
		--01 OBTENIENDO EL ULTIMO CREDITO CANCELADO
		SELECT * into #CREMICRO FROM  ( SELECT TOP 1 * FROM #TMP_CREMICRO) AS Tmp01

		--SELECT * FROM #CREMICRO 
		DELETE FROM #CREMICRO
		-- Drop table #CREMICRO

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

			--*********************************INDEXANDO*****************************************
			CREATE NONCLUSTERED INDEX #CREMICRO_CODIGO_CLIENTE_IXN ON #CREMICRO(CODIGO_CLIENTE)
			CREATE NONCLUSTERED INDEX #CREMICRO_COD_SBS1_IXN ON #CREMICRO(COD_SBS1)
			CREATE NONCLUSTERED INDEX #CREMICRO_CODIGO_CREDITO_IXN ON #CREMICRO(CODIGO_CREDITO)
			--------------------*****************************************************************
			/*
				Select NOMBRE_AGENCIA, cCodOficin
				from #CREMICRO
				group by NOMBRE_AGENCIA, cCodOficin
			*/

			--02 SOLO CANCELADOS
			SELECT * into #CREMICROCANC FROM  ( SELECT TOP 1 * FROM #CREMICRO) AS Tmp02
			--SELECT * FROM #CREMICROCANC
			DELETE FROM #CREMICROCANC
				-- Drop table #CREMICROCANC

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

	--*********************************INDEXANDO************************************************
	CREATE NONCLUSTERED INDEX #CREMICROCANC_CODIGO_CLIENTE_IXN ON #CREMICROCANC(CODIGO_CLIENTE)
	CREATE NONCLUSTERED INDEX #CREMICROCANC_COD_SBS1_IXN ON #CREMICROCANC(COD_SBS1)
	CREATE NONCLUSTERED INDEX #CREMICROCANC_CODIGO_CREDITO_IXN ON #CREMICROCANC(CODIGO_CREDITO)
	--------------------************************************************************************
			-- select * from #CREMICROCANC
	--03 PROMEDIO DE DIAS DE ATRASO
			ALTER TABLE #CREMICROCANC
			ADD PromDiaAtr INT

			--------------VERIFICANDO DUPLICADOS-------------------------------------------
			/*
			Select NOMBRE_AGENCIA, cCodOficin
			from #CREMICROCANC
			group by NOMBRE_AGENCIA, cCodOficin

			select * from #CREMICROCANC  

			Select CODIGO_CREDITO, COUNT(CODIGO_CREDITO) 
			from #CREMICROCANC
			GROUP BY CODIGO_CREDITO
			HAVING COUNT(CODIGO_CREDITO)>1

			select * from #CREMICROCANC
			WHERE CODIGO_CREDITO='107001021000007302'

			Select CODIGO_CLIENTE, COUNT(CODIGO_CLIENTE) 
			from #CREMICROCANC
			GROUP BY CODIGO_CLIENTE
			HAVING COUNT(CODIGO_CLIENTE)>1

			select * from #CREMICROCANC WHERE CODIGO_CLIENTE ='107010064833'
			------------------------------------------------------------------------------
			*/

			SELECT * into #CREMICROCANCX from (Select TOP 1 * from #CREMICROCANC) AS tmp
			DELETE FROM #CREMICROCANCX
			-- Select * from #CREMICROCANCX
			-- Drop table #CREMICROCANCX

			-----------CURSOR REGISTROS UNICOS----------------------------------------
			Declare @ccodcredxx varchar(18)
			--Set @ccodcredxx='107001021000007302'
			
			Declare cRegUnicos CURSOR FOR	
			SELECT distinct CODIGO_CREDITO FROM #CREMICROCANC (NOLOCK) 
				--WHERE CODIGO_CREDITO='107001021000007302'				
			OPEN cRegUnicos
				FETCH cRegUnicos into @ccodcredxx
				WHILE (@@FETCH_STATUS=0)
				BEGIN
			
				INSERT INTO #CREMICROCANCX
					SELECT distinct * FROM #CREMICROCANC (NOLOCK) 
					WHERE CODIGO_CREDITO = @ccodcredxx				
			
				FETCH cRegUnicos INTO @ccodcredxx
				END
				CLOSE cRegUnicos
				DEALLOCATE cRegUnicos

			------------------------------------------------------------------------------
			/*
					Select CODIGO_CREDITO, COUNT(CODIGO_CREDITO) 
					from #CREMICROCANCX
					GROUP BY CODIGO_CREDITO
					HAVING COUNT(CODIGO_CREDITO)>1

					select * from #CREMICROCANCX
					WHERE CODIGO_CREDITO='107001021000007302'

					Select CODIGO_CLIENTE, COUNT(CODIGO_CLIENTE) 
					from #CREMICROCANCX
					GROUP BY CODIGO_CLIENTE
					HAVING COUNT(CODIGO_CLIENTE)>1

					Select * from #CREMICROCANCX WHERE CODIGO_CLIENTE ='107010064833'
			*/
	--*********************************INDEXANDO*****************************************
	CREATE NONCLUSTERED INDEX #CREMICROCANCX_CODIGO_CLIENTE_IXN ON #CREMICROCANCX(CODIGO_CLIENTE)
	CREATE NONCLUSTERED INDEX #CREMICROCANCX_COD_SBS1_IXN ON #CREMICROCANCX(COD_SBS1)
	CREATE NONCLUSTERED INDEX #CREMICROCANCX_CODIGO_CREDITO_IXN ON #CREMICROCANCX(CODIGO_CREDITO)
	--------------------*****************************************************************

	--	SELECT * FROM #CREMICROCANCX 

		----------UPDATE DIAS NEGATIVOS----------------------------------------------------
						ALTER TABLE #CREMICROCANCX
						ALTER COLUMN PromDiaAtr NUMERIC (10,2)						

						ALTER TABLE #CREMICROCANCX
						ADD Sec int	

						--	SELECT * FROM #CREMICROCANCX ORDER BY SEC
						
		-----------------INSERTANDO LA SECUENCIA---------------------------------------------
		Declare @total int, @sec int, @codcli char(12)
		--Set @total = (Select count(*) FROM #tab02)
		Set @sec =  1
		
				Declare cSec CURSOR FOR	
					Select CODIGO_CLIENTE from #CREMICROCANCX (NOLOCK) 	
					Order by CODIGO_CLIENTE

					OPEN cSec
					FETCH cSec into @codcli
					WHILE (@@FETCH_STATUS=0)
					BEGIN	
					
					--While (@sec < @total)
					--Begin
						UPDATE #CREMICROCANCX
						SET Sec = @sec		
						Where CODIGO_CLIENTE = @codcli

						Set @sec =  @sec + 1
					--End

				FETCH cSec INTO @codcli
				END
				CLOSE cSec
				DEALLOCATE cSec		
	--------------------------------------------------------------------------------------------

				----------------CRUCE CON PLAN PAGOS---------------------------------------------
				-- DROP TABLE #CREMICROCANCXX
				Select * into #CREMICROCANCXX from (	
					SELECT A.* 
						  ,PcCodCtaCre=B.cCodCtaCre,B.cNumCuoPla,B.NDIAVENCUO, B.cCodPlaPag 
					FROM #CREMICROCANCX A
						INNER JOIN [KPYDPLANPAGCRE] B
							ON A.CODIGO_CREDITO = B.cCodCtaCre
					GROUP BY B.cCodCtaCre,B.cNumCuoPla,B.NDIAVENCUO, B.cCodPlaPag 
						,A.COD_SBS1, A.NroDocumento1, A.CODIGO_CLIENTE, A.NOMBRE_CLIENTE	
						,A.Direccion_Cliente, A.Direccion_Referencia_Cliente, A.Departamento_Cliente
						,A.Provincia_Cliente, A.Distrito_Cliente, A.Nro_Telefono_Personal
						,A.CODIGO_CREDITO, A.Fecha_Desembolso_Credito, A.Fecha_Culminacion_Credito
						,A.MONTO_DESEMBOLSADO, A.MONEDA, A.CAPITAL_PAGADO, A.SALDO_CAPITAL
						,A.SALDO_CAPITAL_AL_DIA, A.ESTADO_DEL_CREDITO, A.cCodTipCre, A.TipoCredito
						,A.SubTipoCredito, A.cCodProduc, A.ProductoCrediticio, A.cCodSubPro
						,A.SubProductoCrediticio, A.NOMBRE_AGENCIA, A.cCodOficin, A.nCodZona
						,A.cDesZona, A.COD_ANALISTA, A.NOMBRE_ANALISTA, A.PromDiaAtr, A.Sec
					HAVING B.cCodPlaPag  = MAX (B.cCodPlaPag)
					--ORDER BY CCODCLIENTE 	
					) AS tmp
					
					-- (3,202,286 row(s) affected)
					-- (	

					ALTER TABLE #CREMICROCANCXX
					ALTER COLUMN NDIAVENCUO NUMERIC (10,2)

	--*****************************INDEXANDO****************************************************
	CREATE NONCLUSTERED INDEX #CREMICROCANCXX_CODIGO_CLIENTE_IXN ON #CREMICROCANCXX(CODIGO_CLIENTE)
	CREATE NONCLUSTERED INDEX #CREMICROCANCXX_CODIGO_CREDITO_IXN ON #CREMICROCANCXX(CODIGO_CREDITO)			
	CREATE NONCLUSTERED INDEX #CREMICROCANCXX_Sec_IXN ON #CREMICROCANCXX(Sec)		
	CREATE NONCLUSTERED INDEX #CREMICROCANCXX_NDIAVENCUO_IXN ON #CREMICROCANCXX(NDIAVENCUO)	
	--------------------*************************************************************************
			------------ACTUALIZANDO LOS NEGATIVOS A 0-------------------------------------------
				UPDATE #CREMICROCANCXX
				SET NDIAVENCUO = 0
				WHERE NDIAVENCUO < 0

		-----------CURSOR PROMEDIO DE DIAS DE ATRASO----------------------------------------
			Declare @ccodcred varchar(18), @promdiaatr NUMERIC (10, 2)
			--set @ccodcred = '107016101000146483'
			Declare cDiaAtraso CURSOR FOR	
			SELECT distinct CODIGO_CREDITO FROM #CREMICROCANCXX (NOLOCK) 	

			OPEN cDiaAtraso
				FETCH cDiaAtraso into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				set @promdiaatr =  	
					(Select 
					avg (P.NDIAVENCUO)
					from #CREMICROCANCXX P
					where P.CODIGO_CREDITO = @ccodcred
						AND cCodPlaPag in  
							(select max(cCodPlaPag) from #CREMICROCANCXX (NOLOCK)
								where CODIGO_CREDITO = @ccodcred))																																																	

				--if @diaatr <= 8
				--begin 			

				UPDATE #CREMICROCANCXX
				SET PromDiaAtr = @promdiaatr
				WHERE CODIGO_CREDITO = @ccodcred
				
				--END

				FETCH cDiaAtraso INTO @ccodcred
				END
				CLOSE cDiaAtraso
				DEALLOCATE cDiaAtraso
			-------------------------------------------------------------------------------

			-- select * from #CREMICROCANCXX order by Sec

			--04 UN SOLO CREDITO
			-- DROP TABLE #CREMICROCANCXXX
			Select * into #CREMICROCANCXXX from 
			(SELECT top 1 *	FROM #CREMICROCANCXX ) as tmp
			DELETE FROM #CREMICROCANCXXX
			-- SELECT * FROM #CREMICROCANCXXX

			------------------------CURSOR SOLO UN CREDITO -----------------------------------
			Declare @codclie01 char(12), @codcred01 char(18)			  		
			
			Declare cFiltraDeser CURSOR FOR	
				Select distinct CODIGO_CREDITO from #CREMICROCANCXX (NOLOCK) 					

			OPEN cFiltraDeser
				FETCH cFiltraDeser into @codcred01
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				Insert Into #CREMICROCANCXXX
					Select top 1
					*
					from #CREMICROCANCXX 
					where CODIGO_CREDITO = @codcred01																		

				FETCH cFiltraDeser INTO @codcred01
				END
				CLOSE cFiltraDeser
				DEALLOCATE cFiltraDeser

		------------------------------------------------------------------------------
		/*
		SELECT * FROM #CREMICROCANCXXX ORDER BY SEC

		SELECT NOMBRE_AGENCIA,cCodOficin 
		FROM #CREMICROCANCXXX 
		GROUP BY NOMBRE_AGENCIA,cCodOficin
		ORDER BY cCodOficin
		*/

	--05 SELECCIONANDO LOS CREDITOS CON PROMEDIO DE DIAS DE ATRASO <= 8	
		-- DROP TABLE #CREMICROCANCXXXX
		SELECT * INTO #CREMICROCANCXXXX FROM
			(SELECT * FROM #CREMICROCANCXXX WHERE PromDiaAtr < 9 ) as tmp
				-- (160,032 row(s) affected)
		
		/*
		Select * FROM #CREMICROCANCXXXX ORDER BY SEC

		SELECT NOMBRE_AGENCIA,cCodOficin 
		FROM #CREMICROCANCXXXX 
		GROUP BY NOMBRE_AGENCIA,cCodOficin
		ORDER BY cCodOficin
		*/

	--*****************************INDEXANDO****************************************************
	CREATE NONCLUSTERED INDEX #CREMICROCANCXXXX_CODIGO_CLIENTE_IXN ON #CREMICROCANCXXXX(CODIGO_CLIENTE)
	CREATE NONCLUSTERED INDEX #CREMICROCANCXXXX_CODIGO_CREDITO_IXN ON #CREMICROCANCXXXX(CODIGO_CREDITO)			
	CREATE NONCLUSTERED INDEX #CREMICROCANCXXXX_COD_SBS1_IXN ON #CREMICROCANCXXXX(COD_SBS1)			
	CREATE NONCLUSTERED INDEX #CREMICROCANCXXXX_NroDocumento1_IXN ON #CREMICROCANCXXXX(NroDocumento1)			
	--------------------*************************************************************************
	
		---COMPLETANDO NroDoc NULL 	  
		-- SELECT * FROM #CREMICROCANCXXXX where NroDocumento1 IS NULL 

		 ------------CURSOR COMPLETANDO nro doc null-----------
		 Declare @ccodcli01 varchar(12)
				Declare cNrodocd CURSOR FOR							
					 SELECT CODIGO_CLIENTE FROM #CREMICROCANCXXXX (NOLOCK)  
					 where NroDocumento1 IS NULL					
				OPEN cNrodocd
				FETCH cNrodocd into @ccodcli01
				WHILE (@@FETCH_STATUS=0)
				BEGIN										
					UPDATE #CREMICROCANCXXXX
					SET NroDocumento1 = (SELECT cNroDocTri 
										 FROM  CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES]
										 WHERE cCodCliente = @ccodcli01)
					WHERE CODIGO_CLIENTE = @ccodcli01
				FETCH cNrodocd INTO @ccodcli01
				END
				CLOSE cNrodocd
				DEALLOCATE cNrodocd
		---------------------------------------------------
		---*************COMPLETANDO COD SBS NULL **********************------
			--SELECT * FROM #CREMICROCANCXXXX where COD_SBS1 IS NULL 			
				UPDATE #CREMICROCANCXXXX				
				SET COD_SBS1 = '0000000001'
				where COD_SBS1 IS NULL 	

			 -- SELECT * FROM #CREMICROCANCXXXX where COD_SBS1 = '' 		
				UPDATE #CREMICROCANCXXXX				
				SET COD_SBS1 = '0000000002'
				where COD_SBS1 = '' 

		------------------------VERIFICANDO----------------		  
		/*
			SELECT * FROM #CREMICROCANCXXXX where NroDocumento1 IS NULL --0
			SELECT * FROM #tmpv02
			SELECT * FROM #CREMICROCANCXXXX

		*/

	--08 EXPORTANDO LA DATA
		  /*
		  SELECT nCodZona,cDesZona FROM #CREMICROCANCXXXX 
		  GROUP BY nCodZona,cDesZona		  
		  
		  SELECT * FROM #CREMICROCANCXXXX 
		  --WHERE nCodZona = 5
		  Order by Sec 
		  */
	--09 CANTIDAD ENTIDADES
	/*
			select top 5 * from CRICMACHYO_DIARIO.DBO.urirccmae --CCLAFIN
			select top 5 * from CRICMACHYO_DIARIO.DBO.urirccsal --CCALEMP
			select top 5 * from CRICMACHYO_DIARIO.DBO.urirccmifi
	*/
	------------------------------------CURSOR ---------------------------------------------
		/*
			
			SELECT * FROM #CREMICROCANCXXXX
			WHERE Fecha_Culminacion_Credito >= '2015-11-01'


		*/
			/*
			ALTER TABLE #CREMICROCANCXXXX
				DROP COLUMN RCC_SET2014 ,RCC_OCT2014 ,RCC_NOV2014 , RCC_DIC2014 ,RCC_ENE2015 ,RCC_FEB2015 
			*/
			--06 SE ADICIONA COLUMNA PARA RCC

		ALTER TABLE #CREMICROCANCXXXX
			ADD RCC_ULTIMO VARCHAR(12), DeudaTotal NUMERIC(14,4), CantEnt INT

		Declare @codsbs varchar(10) , @cali varchar(15), @nroentidades int, @deudat money
		Declare cCursor98 CURSOR FOR
			
			select distinct COD_SBS1 
			from #CREMICROCANCXXXX 
			where COD_SBS1 != '' 
					AND  COD_SBS1 NOT IN ('0000000002','0000000001')
					--AND Fecha_Culminacion_Credito >= '2015-11-01'

		OPEN cCursor98
		FETCH cCursor98 into @codsbs
		WHILE (@@FETCH_STATUS=0)
		BEGIN
		  set @cali = (select CCLAFIN
					   from CRICMACHYO_DIARIO.DBO.urirccmae
					   where CCODSBS = @codsbs)		
		  set @nroentidades = (select NCANENT
					   from CRICMACHYO_DIARIO.DBO.urirccmae
					   where CCODSBS = @codsbs)

		 set @deudat = (Select sum(NSALDOS)
					from CRICMACHYO_DIARIO.DBO.urirccsal  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update #CREMICROCANCXXXX 			 										
		  Set RCC_ULTIMO = @cali
		  where COD_SBS1 = @codsbs

		  Update #CREMICROCANCXXXX 			 										
		  Set CantEnt = @nroentidades
		  where COD_SBS1 = @codsbs

		  Update #CREMICROCANCXXXX 			 										
		  Set DeudaTotal = @deudat
		  where COD_SBS1 = @codsbs

		FETCH cCursor98 INTO @codsbs
		END
		CLOSE cCursor98
		DEALLOCATE cCursor98
------------------------------------------------------------------------------------

		SELECT 
			COD_SBS1,	NroDocumento1,	CODIGO_CLIENTE,	NOMBRE_CLIENTE,	Direccion_Cliente,
			Direccion_Referencia_Cliente,	Departamento_Cliente,	Provincia_Cliente,
			Distrito_Cliente,	Nro_Telefono_Personal,	CODIGO_CREDITO,	Fecha_Desembolso_Credito,
			Fecha_Culminacion_Credito,	MONTO_DESEMBOLSADO,	MONEDA,	CAPITAL_PAGADO	SALDO_CAPITAL,
			ESTADO_DEL_CREDITO,	TipoCredito,	SubTipoCredito,	
			ProductoCrediticio, SubProductoCrediticio,	NOMBRE_AGENCIA,		cDesZona,
			COD_ANALISTA,	NOMBRE_ANALISTA,	PromDiaAtr,	CantEnt, DeudaTotal,
			RCC_ULTIMO =				
				CASE 
					WHEN RCC_ULTIMO = '0' THEN 'NORMAL'
					ELSE 'NO REGISTRA'
					END
		INTO #CREMICROCANCXXXXX
		FROM #CREMICROCANCXXXX 
		WHERE COD_SBS1 != '' 
				AND  COD_SBS1 NOT IN ('0000000002','0000000001')
				--AND Fecha_Culminacion_Credito >= '2015-11-01'
				AND CantEnt IS NOT NULL
				AND RCC_ULTIMO IS NOT NULL
				AND DeudaTotal IS NOT NULL
				AND RCC_ULTIMO = '0'
				--AND NOMBRE_AGENCIA LIKE '%AG%REAL%HUANUCO%'

		SELECT * 
		FROM #CREMICROCANCXXXXX

	/*
		
		DROP TABLE #TMP_CREMICRO
		DROP TABLE #CREMICROCANCXXXX
		DROP TABLE #CREMICROCANCXXX
		DROP TABLE #CREMICROCANCXX
		DROP TABLE #CREMICROCANCX
		DROP TABLE #CREMICROCANC
		DROP TABLE #TMP_CREMICRO
		DROP TABLE #CREMICROCANCXXXXX


	*/