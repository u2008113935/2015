			
			/*
				Se solicita se pueda generar una base de datos de clientes potenciales para renovavión , 
				ampliación de sus créditos vigentes teniendo en cosideración los siguientes criterios: 
					- 100% Normal en el sistema como titular 100% Normal en el sistema como aval 
					- Tener un promedio de dias de atraso no mayor a 04 días 
					- Tener endeudamiento en el sistema con 03 instituciones incluida la CMACHYO
					- Haber cancelado mas del 40% de las cuotas programadas en su cronograma de pagos para 
					  créditos Negocio. 
					- Haber cancelado mas del 20% de las cuotas programadas en su cronograma de pagos para 
					  créditos Consumo .

			*/

			-- 1ro LISTA DE créditos vigentes para ampliar 	

			SET LANGUAGE spanish;
				--Tipo cambio a junio 2015
			DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
				set @nTipCambio = (
					SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
						nTipCambio = nTipCamFij
					FROM GENTTipCambio
					WHERE left(cast(dFecTipCam as date),10) ='2015-10-01'				
						)

			----------------------------------------------------------------------------------------			
						
		--  Drop table #tab01
		--  Drop table #tab02
		Select * into #tab01 from (

			Select 		
					ROW_NUMBER() 
					OVER(PARTITION BY CRE.cCodUsuAna
							ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
					,CRE.cCodUsuAna AS 'CodAsesorActual'
					,SP.cNomPerson AS 'NombreAsesorActual'	
					,CLI.cCodCliente AS 'CodigoCliente'		
					,CLIM.cNomCliente AS 'NombreCliente'					
					,CodSBS= CLIM.cCodSbs
					,Telefono = CLIM.cNroTelPer
					,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
					,DireccionReferencia = DC.cDirCliRef
					,ZonaDireccion = Z.cNomZona
					,DIS1.cNomDistri as 'Distrito'		 					 			
					,PRO1.cNomProvin AS 'Provincia' 			
					,DEP1.cNomDepart AS 'Departamento'	
					--Datos del credito			
					,CRE.cCodCtaCre AS 'CodigoCredito'
					,CLI.cCodLinCre			
					,STC.cDesTipCre AS 'TipoCredito'
					,STC.cDesSubTip AS 'SubTipoCredito'			 
					,STC.cDesProCre AS 'ProductoCrediticio' 			 
					,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
					,CRE.nMonCapDes as 'MontoDesembolso' 
					,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
					,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
					,TipoCambio = @nTipCambio
					,MontoDesembolsoenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN CRE.nMonCapDes
						WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
						END					
					,SaldoCapitalenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
						WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
						END								
					,TEM=CRE.nTasintCom	
					,NumeroCuotas=CRE.nNumCuoApr
					,DiasAtraso = CRE.nDiaAtrCre
					,EstadoCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END	
					,CRE.cCodModCre
					,M.cDesModCre
					,CRE.cCodFueIng					 													 
					,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
					,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
					,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
					--,CRE.cEstCreCon
					--,EC.cDescriEst AS 'EstadoCredito'			
					,Oficina = O.cDesOficin										
					,Zona = ZON.cDesZona											
			FROM [KPYMCRECONVEN] CRE (NOLOCK)		
					INNER JOIN [GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre
					INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
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
					--condicion credito 
					 INNER JOIN [KPYTConCredit] D
						ON D.cCondicCon = CLI.cCondicCon			 

					left join HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC				
						on DC.cCodCliente = CLIM.CCODCLIENTE and DC.bDirPredet = '1'
			
					INNER JOIN [GenTDepartame] DEP1
						ON DEP1.cCodDepart = DC.cCodDepart
					INNER JOIN [GentProvincia] PRO1
						ON pro1.cCodProvin = DC.cCodProvin and pro1.cCodDepart = DC.cCodDepart
					INNER JOIN [GentDistrito] DIS1
						ON dis1.cCodDistri = DC.cCodDistri	 and dis1.cCodProvin = DC.cCodProvin 
							and dis1.cCodDepart = DC.cCodDepart					
			
					INNER JOIN GENTZona Z
						ON Z.cCodZona = DC.cCodZona 
							and Z.cCodDepart = DC.cCodDepart
							and Z.cCodProvin = DC.cCodProvin
							and Z.cCodDistri = DC.cCodDistri						 								
					inner join KPYTModCredit M
						on M.cCodModCre = CRE.cCodModCre					

				WHERE CRE.cEstCreCon in ('F')															
					and CRE.nDiaAtrCre <= 30
										
					and STC.cDesSubcRE != 'ADELANTO DE SUELDO'	
					and	STC.cDesSubcRE != 'AGROPECUARIO'	
					
					and STC.cDesSubcRE != 'MIVIVIENDA' -- CrediCasa con RRHH unico ampliar				
					and	STC.cDesSubcRE != 'PROMOTOR INMOBILIARIO'					
					and	STC.cDesSubcRE != 'TRABAJADORES'					
					and	STC.cDesSubcRE != 'MICONSTRUCCION'					
					and STC.cDesProCre != 'PRESTAMOS DEL FONDO MIVIVIENDA'

					and CRE.cCodModCre not in ('02','05','06')
					and CLI.cCondicCon = '01'
				
						) as tmp


					/*
						Select * from #tab01
					*/

					CREATE NONCLUSTERED INDEX #tab01_CodigoCliente_IXN ON #tab01(CodigoCliente)
					CREATE NONCLUSTERED INDEX #tab01_CodigoCredito_IXN ON #tab01(CodigoCredito)	
					CREATE NONCLUSTERED INDEX #tab01_CodSBS_IXN ON #tab01(CodSBS)
					
			
		--  DROP TABLE #sbs01

		Select * into #sbs01 from (
				Select A.CCODSBS, A.CAPEPAT, A.CAPEMAT, A.CAPECAS,A.CPRINOM,A.CSEGNOM,A.CNUDOCI, A.NCANENT
					,A.NPORCAL0, A.NPORCAL1, A.NPORCAL2, A.NPORCAL3, A.NPORCAL4, A.CCLAFIN
					,B.CCODEMP, B.CTIPCRE, B.CCTACON, B.NSALDOS, B.CCALEMP				
					,C.cCodIFI, C.cNomIFI
				From [HYO00402].CRICMACHYO_DIARIO.dbo.urirccmae A	
					INNER JOIN [HYO00402].CRICMACHYO_DIARIO.dbo.urirccsal B	
						ON A.CCODSBS = B.CCODSBS
					inner join [HYO00402].CRICMACHYO_DIARIO.dbo.URIRCCMIFI C	
						on C.cCodIFI = B.cCodEmp and C.lConEstado = 1	
				Where LEFT(B.Cctacon, 4) 
						in ('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')					
					and A.CCODSBS 
						in (Select distinct(CodSBS) from #tab01 )	
					--and B.CCALEMP = 0  
					and A.CCLAFIN = 0	
				--Order by A.CCODSBS
				) as tmp

			CREATE NONCLUSTERED INDEX #sbs01_CCODSBS_IXN ON #sbs01(CCODSBS)

		/*
			Select * from #sbs01
			Order By CCODSBS
		*/
			--  DROP TABLE #sbs02
			Select * into #sbs02 from (Select top 1 * from #sbs01) as tmp
			Delete from #sbs02			


	--03 INSERTANDO UN SOLO CREDITO
	------------------------CURSOR SOLO UN CREDITO -----------------------------------
		Declare @CCODSBS char(10)			  		
			
			Declare cCursor01 CURSOR FOR	
			
			Select distinct CCODSBS from #sbs01 (NOLOCK) 					

			OPEN cCursor01
			FETCH cCursor01 into @CCODSBS
			WHILE (@@FETCH_STATUS=0)
			BEGIN	

			Insert Into #sbs02
				
				Select top 1 					
					*
				from #sbs01
				where CCODSBS = @CCODSBS																			
				
			FETCH cCursor01 INTO @CCODSBS
			END
			CLOSE cCursor01
			DEALLOCATE cCursor01

		-----------------------------------------------------------------------------
			
		CREATE NONCLUSTERED INDEX #sbs02_CCODSBS_IXN ON #sbs02(CCODSBS)

		/*
				Select * from #sbs02
				Order By CCODSBS

				Select CCODSBS,count(CCODSBS) from #sbs02
				Group By CCODSBS
				Having count(CCODSBS) > 1
				Order By CCODSBS
		*/

			--  drop table #tab02
			SELECT * into #tab02 from (
					Select A.* 
						,CantEnt = B.NCANENT, CalifSBS = 
													Case B.CCLAFIN
													When '0' then 'NORMAL' 
													ELSE 'NO REGISTRA' END 			
					From #tab01 A
						INNER join #sbs02 B
							on A.CodSBS = B.cCodSBS
					--Order By CodigoCliente
						) as tmp

			
		/*
				Select * from #tab02
				-- Where CodigoCliente = '107022326790'
				Order By CodigoCliente

				Select CodigoCliente,count(CodigoCliente)
				From #tab02
				Group By CodigoCliente
				Having count(CodigoCliente) > 1
				Order By CodigoCliente desc

				SELECT A.* 				
				FROM [#tab02] A
		*/

			CREATE NONCLUSTERED INDEX #tab02_CodigoCliente_IXN ON #tab02(CodigoCliente)
			CREATE NONCLUSTERED INDEX #tab02_CodigoCredito_IXN ON #tab02(CodigoCredito)	
							

		----------------CRUCE CON el PLANPAGOS--------------------------------------------------------
		-- Drop table #tab03
		Select * into #tab03 from (	
			SELECT A.* 
				  ,PcCodCtaCre=B.cCodCtaCre,B.cCodPlaPag,B.cNumCuoPla,B.dFecVenPag,B.dFecPagCuo,B.NDIAVENCUO
				  ,B.cCodEstCuo 
			FROM [#tab02] A
				INNER JOIN [KPYDPLANPAGCRE] B
					ON A.CodigoCredito = B.cCodCtaCre
			GROUP BY B.cCodCtaCre,B.cCodPlaPag,B.cNumCuoPla,B.dFecVenPag,B.dFecPagCuo,B.NDIAVENCUO,B.cCodEstCuo 
				,A.Secuencia, A.CodAsesorActual, A.NombreAsesorActual, A.CodigoCliente, A.NombreCliente, A.CodSBS
				,A.Telefono,A.DireccionDomicilio, A.DireccionReferencia, A.ZonaDireccion, A.Distrito, A.Provincia
				,A.Departamento,A.CodigoCredito, A.cCodLinCre, A.TipoCredito, A.SubTipoCredito, A.ProductoCrediticio
				,A.SubProductoCrediticio, A.MontoDesembolso, A.SaldoCapital, A.Moneda, A.TipoCambio	
				,A.MontoDesembolsoenSoles, A.SaldoCapitalenSoles, A.TEM, A.NumeroCuotas, A.DiasAtraso
				,A.EstadoCredito, A.cCodModCre, A.cDesModCre, A.cCodFueIng, A.FechaDesembolsoCredito, A.Anio
				,A.Mes, A.NombreMes, A.Oficina, A.Zona, A.CantEnt, A.CalifSBS				
			--HAVING B.cCodPlaPag  = MAX (B.cCodPlaPag)
			--ORDER BY CCODCLIENTE 	
			) AS tmp		

				------------ACTUALIZANDO LOS NEGATIVOS A 0-----
				UPDATE #tab03
				SET NDIAVENCUO = 0
				WHERE NDIAVENCUO < 0

				--02 agregando columnas
				ALTER TABLE #tab03
				Add CuotaPag decimal(10,5), CuotaPend decimal(10,5), Porcentaje decimal(10,5)
				, DiasPromAtr decimal(10,5), CuotaMax decimal (10,5)
				--Drop column CuotaPag , CuotaPend , Porcentaje ,DiasPromAtr 

				/*
					SELECT TOP 50 * FROM #tab03
				*/
			
				-- SELECT * into #tab04 FROM  ( SELECT * FROM #tab03) as tmp
				-- DELETE FROM #tab03
				-- drop table #tab03

				/*
					 Select * from #tab03
					 Where PcCodCtaCre = '107048101001512218' and cCodEstCuo = 'P'
							and cCodPlaPag in
									(select max(cCodPlaPag) 
									 from #tab03 
										WHERE PcCodCtaCre = '107048101001512218')
					 Order By cNumCuoPla

				*/

				CREATE NONCLUSTERED INDEX #tab03_CodigoCliente_IXN ON #tab03(CodigoCliente)
				CREATE NONCLUSTERED INDEX #tab03_CodigoCredito_IXN ON #tab03(CodigoCredito)	
				CREATE NONCLUSTERED INDEX #tab03_PcCodCtaCre_IXN ON #tab03(PcCodCtaCre)
				CREATE NONCLUSTERED INDEX #tab03_NDIAVENCUO_IXN ON #tab03(NDIAVENCUO)	


	-- 03 LLENAR CAMPOS 	
	------------------------CURSOR-----------------------------------
		Declare @ccodcred varchar(18), @CuotaPag decimal(10,5), @CuotaPend decimal(10,5), 
		        @Porcentaje decimal(10,5) , @DiasPromAtr decimal(10,5), @CuotasAprob decimal(10,5) 	
				,@CuotaMax decimal (10,5)	
			--Set @ccodcred = '107008101003765143'
			
			Declare cAmpl CURSOR FOR	
				Select distinct CodigoCredito from #tab02 (NOLOCK) 	

			OPEN cAmpl
				FETCH cAmpl into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @CuotasAprob = (select NumeroCuotas from #tab02 where CodigoCredito = @ccodcred)
				set @CuotaPag = 
						(select count(distinct cNumCuoPla) from #tab03 -- [KPYDPLANPAGCRE] 
							where PcCodCtaCre = @ccodcred and cCodEstCuo = 'P'
								AND cCodPlaPag in 
									(select max(cCodPlaPag) 
									 from #tab03 -- [KPYDPLANPAGCRE] (NOLOCK)
										WHERE cCodEstCuo = 'P'
											and PcCodCtaCre = @ccodcred))
			
						set @DiasPromAtr = 
							(Select 
								 ceiling(avg (NDIAVENCUO))
								from #tab03 
								where PcCodCtaCre = @ccodcred									
									and cCodEstCuo = 'P'
									AND cCodPlaPag in  
										(select max(cCodPlaPag) from #tab03 (NOLOCK)
											where cCodEstCuo = 'P'
												and PcCodCtaCre = @ccodcred))												
								
						set @CuotaPend = (@CuotasAprob - @CuotaPag )						
								
						set @Porcentaje = ((@CuotaPag / @CuotasAprob) * 100) 				
											
						
						If @DiasPromAtr is not null
							begin
								UPDATE #tab03
								SET DiasPromAtr = @DiasPromAtr
								WHERE CodigoCredito = @ccodcred															
							end
						Else
							begin
								UPDATE #tab03
								SET DiasPromAtr = 0
								WHERE CodigoCredito = @ccodcred															
							end		
							
							
						set @CuotaMax = 
						(Select 
								max(NDIAVENCUO)
							from #tab03 
							where PcCodCtaCre = @ccodcred									
								AND cCodPlaPag in  
									(select max(cCodPlaPag) from #tab03 (NOLOCK)
										where PcCodCtaCre = @ccodcred))
																						
						If @CuotaMax is not null
							begin
								UPDATE #tab03
								SET CuotaMax = @CuotaMax
								WHERE CodigoCredito = @ccodcred															
							end
						Else
							begin
								UPDATE #tab03
								SET CuotaMax = 0
								WHERE CodigoCredito = @ccodcred														
							end				

						UPDATE #tab03
						SET CuotaPag = @CuotaPag
						WHERE CodigoCredito = @ccodcred	

						UPDATE #tab03
						SET CuotaPend = @CuotaPend
						WHERE CodigoCredito = @ccodcred

						UPDATE #tab03
						SET Porcentaje = @Porcentaje
						WHERE CodigoCredito = @ccodcred									
				
				FETCH cAmpl INTO @ccodcred
				END
				CLOSE cAmpl
				DEALLOCATE cAmpl

		-----------------------------------------------------------------------

			/*		
				Select * from #tab03 
				where PcCodCtaCre = '107008101003765143'
				Order By cNumCuoPla
				
				Select * from [KPYTConCredit] D

				Select * from [KPYTSUBTIPCRE] STC
				Where STC.cCodTipCre in ('05','06','07','08','09','10','11','12') 

				Select * from KPYTTipPeriod
				Select * from KPYTModCredit	
			*/
				

		-- Drop table #tab04
		Select * into #tab04 FROM 
			(Select top 1  
					CodigoCliente,NombreCliente,CodSBS,Telefono,DireccionDomicilio,DireccionReferencia
					,ZonaDireccion,Distrito,Provincia,Departamento,CodigoCredito,cCodLinCre,TipoCredito
					,SubTipoCredito,ProductoCrediticio,SubProductoCrediticio,MontoDesembolso,SaldoCapital	
					,Moneda,TipoCambio,MontoDesembolsoenSoles,SaldoCapitalenSoles,TEM,NumeroCuotas,DiasAtraso
					,EstadoCredito,cCodModCre,cDesModCre,cCodFueIng,FechaDesembolsoCredito,Anio,Mes,NombreMes
					,Oficina,Zona,CodAsesorActual,NombreAsesorActual,CantEnt,CalifSBS, CuotaPag, CuotaPend
					,Porcentaje, DiasPromAtr,CuotaMax
			 from #tab03 (NOLOCK)) as tmp
		DELETE FROM #tab04
		-- Select * from #tab04

			------------------------CURSOR SOLO UN CREDITO -----------------------------------
				Declare @codclie01 char(12), @codcred01 char(18)			  		
			
					Declare cFiltrando CURSOR FOR	
						Select distinct CodigoCredito from #tab03 (NOLOCK) 					

					OPEN cFiltrando
						FETCH cFiltrando into @codcred01
						WHILE (@@FETCH_STATUS=0)
						BEGIN	

						Insert Into #tab04
						Select top 1							
							CodigoCliente,NombreCliente,CodSBS,Telefono,DireccionDomicilio,DireccionReferencia
							,ZonaDireccion,Distrito,Provincia,Departamento,CodigoCredito,cCodLinCre,TipoCredito
							,SubTipoCredito,ProductoCrediticio,SubProductoCrediticio,MontoDesembolso,SaldoCapital	
							,Moneda,TipoCambio,MontoDesembolsoenSoles,SaldoCapitalenSoles,TEM,NumeroCuotas,DiasAtraso
							,EstadoCredito,cCodModCre,cDesModCre,cCodFueIng,FechaDesembolsoCredito,Anio,Mes,NombreMes
							,Oficina,Zona,CodAsesorActual,NombreAsesorActual,CantEnt,CalifSBS, CuotaPag, CuotaPend
							,Porcentaje, DiasPromAtr, CuotaMax
							
							from #tab03
							where CodigoCredito = @codcred01																		

						FETCH cFiltrando INTO @codcred01
						END
						CLOSE cFiltrando
						DEALLOCATE cFiltrando
				------------------------------------------------------------------------------								
				
			CREATE NONCLUSTERED INDEX #tab04_CodigoCliente_IXN ON #tab04(CodigoCliente)
			CREATE NONCLUSTERED INDEX #tab04_CodigoCredito_IXN ON #tab04(CodigoCredito)		
		
			/*
					Select * from #tab04	-- (186,254 row(s) affected)

					where CodigoCredito = '107004101006441981'

					Select * from #tab04
					Where DiasPromAtr is null
					Order By FechaDesembolsoCredito desc
			*/

			Select * from #tab04

			Select TipoCredito from #tab04
			Group By TipoCredito
			/*
				TipoCredito
				CONSUMO 
				CRÉDITO A MEDIANAS EMPRESAS
				CRÉDITO A PEQUEÑA EMPRESAS -- ok
				CRÉDITOS A MICROEMPRESAS -- ok
				HIPOTECARIOS PARA VIVIENDA -- ok
			*/

			Select * from #tab04
			Where TipoCredito = 'HIPOTECARIOS PARA VIVIENDA'
				and DiasPromAtr <= 6
				and Porcentaje >= 40
				and Zona = 'ZONA LIMA NORTE'


			Select * from #tab04
			Where TipoCredito = 'CRÉDITOS A MICROEMPRESAS'
				and DiasPromAtr <= 6
				and Porcentaje >= 40
				and Zona = 'ZONA LIMA NORTE'

			Select * from #tab04
			Where TipoCredito = 'CRÉDITO A PEQUEÑA EMPRESAS'
				and DiasPromAtr <= 6
				and Porcentaje >= 40
				and Zona = 'ZONA LIMA NORTE'


			Select * from #tab04
			Where TipoCredito = 'CRÉDITO A MEDIANAS EMPRESAS'
				and DiasPromAtr <= 6
				and Porcentaje >= 40
				and Zona = 'ZONA LIMA NORTE'


			Select * from #tab04
			Where TipoCredito = 'CONSUMO'
				and DiasPromAtr <= 6
				and Porcentaje >= 20
				and SubProductoCrediticio not in 
					('CONVENIOS NO ELEGIBLES','CTS','PLAZO FIJO')
				and Zona = 'ZONA LIMA NORTE'

		---------------------------------------------------------