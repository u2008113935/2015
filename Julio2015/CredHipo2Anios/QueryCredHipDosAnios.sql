	/*
	Relción de los créditos hipotecarios para vivienda por sub producto(mi vivienda/credicasa/mi hogar
	/techo propio/mi construcción...etc) 
	1) montos desembolsados por meses en los dos ultimos años y tasas promedio por sub producto 
	2) Número de créditos por mes en los dos últimos años 
	3) Crecimiento del Saldo mensual por meses en los dos ultimos años. 
	4) monto promedio de desembolso por sub productos por meses en los dos ultimos. 
	*/
	
	--01 relacion de creditos hipotecarios

	SET LANGUAGE spanish;
	Select * into #tab01 from (
	Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY year(CRE.DFECDESCRE)
					ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE),NombreMes =DATENAME(month, CRE.DFECDESCRE)
			--,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 --,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 --,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 			
			--Datos del Cliente					
			--,CLIM.cNomCliente AS 'NombreCliente'	
			--Datos del credito			
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'			
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
			,TEM=CRE.nTasintCom	
			,NumeroCuotas=CRE.nNumCuoApr				
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'
			--,CRE.cEstCreCon
			--,EC.cDescriEst AS 'EstadoCredito'
			,Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END cDesConCre																									
			,O.cCodOficin, O.cDesOficin			
			--,CRE.cCodUsuAna AS 'CodAsesorActual'
			--,SP.cNomPerson AS 'NombreAsesorActual'				
			,ZON.nCodZona, ZON.cDesZona
			,CLI.cCodCliente AS 'CodigoCliente'
			,CRE.cCodCtaCre AS 'CodigoCredito'	
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
			--inner JOIN [sipmpersonal] SP 
				--ON SP.cCodPerson = CRE.cCodUsuAna	
			--condicion credito 
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon
		WHERE CRE.cEstCreCon in ('F','H','I','G')					
			and (CRE.cCodTipCre = '04' and STC.lEstado = '1')			
			AND left(cast(CRE.dFecDesCre as date),10) >='2013-06-01'
			AND left(cast(CRE.dFecDesCre as date),10) <='2015-06-30'					
		-- (1,641 row(s) affected)
		) as tmp

		
		-- Select * from #tab01
		-- Drop table #tab01
		--02 agregando el tipo de cambio por meses a la #tab01
			
			ALTER TABLE #tab01
			ADD nTipCambio MONEY, dFecTipCam char(7)
			--drop column nTipCambio , dFecTipCam 

			SELECT * INTO #tc from (
			SELECT dFecTipCam=rtrim(left(cast(dFecTipCam as date),7))
				,nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),7) >='2013-06'
				and left(cast(dFecTipCam as date),7) <='2015-06' 
			Group by left(cast(dFecTipCam as date),7),nTipCamFij
				) as tmp

			--Select * from #tc

				------------------CURSOR TIPO CAMBIO X FECHA en #tab01-----------------------------------			
				Declare @ccodcred varchar(18), @nTipCambio MONEY, @dFecTipCam char(7), @fecdes char(7)
						
				Declare cTC CURSOR FOR	
					Select DISTINCT CodigoCredito from #tab01 (NOLOCK) 					

				OPEN cTC
					FETCH cTC into @ccodcred
					WHILE (@@FETCH_STATUS=0)
					BEGIN	
							
					Set @fecdes = (Select RTRIM(left(FechaDesembolsoCredito,7)) from #tab01 (NOLOCK) 	
									Where CodigoCredito = @ccodcred)			

					Set @nTipCambio = (Select rtrim(nTipCambio) from #tc 
										where dFecTipCam = @fecdes)

					Set @dFecTipCam = (Select rtrim(dFecTipCam) from #tc 
										where dFecTipCam = @fecdes)				
								
				UPDATE #tab01
				SET nTipCambio = @nTipCambio, dFecTipCam = @dFecTipCam
				WHERE CodigoCredito = @ccodcred																	
				
				FETCH cTC INTO @ccodcred
				END
				CLOSE cTC
				DEALLOCATE cTC				
				------------------------------------------------------------

				--Select * from #tab01

				Select
					Secuencia,Anio,Mes,NombreMes,TipoCredito,SubTipoCredito,ProductoCrediticio,SubProductoCrediticio
					,CodigoCliente,CodigoCredito,TEM,MontoDesembolso,Moneda,FechaDesembolsoCredito
					,nTipCambio,dFecTipCam
					,MontoDesembSoles =
					 case Moneda
					 when 'SOLES' then MontoDesembolso
					 when 'DOLARES' then MontoDesembolso * nTipCambio
					 end
					,NumeroCuotas,Saldo
					,SaldoSoles=
					 case Moneda
					 when 'SOLES' then Saldo
					 when 'DOLARES' then Saldo * nTipCambio
					 end
					,cDesConCre,cCodOficin,cDesOficin,cDesZona
				from #tab01

