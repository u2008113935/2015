
	/*
	Se solicita poder remitir la base de datos de potenciales clientes No minoristas para renovación 
	de lineas de créditos, de acuerdo a reglamento al haber cumplido con cancelar el 40% de las cuotas 
	programadas según cronograma de pagos.
	
	*/

	-- 1ro obtener creditos no minoristas

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-09-01'				
				)

	Select * into #tab01 from (

	Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY CRE.cCodUsuAna
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'	
			,CLI.cCodCliente AS 'CodigoCliente'		
			,CLIM.cNomCliente AS 'NombreCliente'
			,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
			,DireccionReferencia = DC.cDirCliRef
			,ZonaDireccion = cNomZona
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
			,EstadoCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END														 
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

		WHERE CRE.cEstCreCon in ('F','H')					
			-- and CRE.cCodOficin = '058'	
			and CRE.cCodTipCre in ('05','06','07','08','09','10','11','12') 
			) as tmp

		/*
		
		Select * from [KPYTSUBTIPCRE] STC
		Where STC.cCodTipCre in ('05','06','07','08','09','10','11','12') 

		*/

		Select * from #tab01

		-- 02 Cuotas Pendientes
				ALTER TABLE #tab01
				Add CuotaPag decimal (10,5) , CuotaPend decimal (10,5)
					,PorcPag decimal (10,5)

		-- Select * from #tab01


		------------------------CURSOR CUOTAS PEND-----------------------------------
		Declare @codcred10 varchar(18), @CuotaPag10 decimal (10,5)
			,@CuotaPend10 decimal (10,5), @CuotasAprob10 int
			,@PorcPag10 decimal (10,5)
			
			Declare cCuotaPend01 CURSOR FOR
				
				Select distinct CodigoCredito from #tab01 (NOLOCK) 									

			OPEN cCuotaPend01
				FETCH cCuotaPend01 into @codcred10
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				Set @CuotasAprob10 = ( Select NumeroCuotas from #tab01
										Where CodigoCredito = @codcred10)
				
				Set @CuotaPag10 = 
						(Select count(distinct cNumCuoPla) 
						 From KPYDPLANPAGCRE (NOLOCK) -- [KPYDPLANPAGCRE] 
						 Where cCodCtaCre = @codcred10 and cCodEstCuo = 'P'
								and cCodPlaPag in 
								(Select max(cCodPlaPag) 
										from [KPYDPLANPAGCRE] (NOLOCK)
								 WHERE cCodCtaCre = @codcred10 and cCodEstCuo = 'P'))

				Set @CuotaPend10 = ( @CuotasAprob10 - @CuotaPag10 )	
				Set @PorcPag10 = (( @CuotaPag10 / @CuotasAprob10 ) * 100)							
				
				UPDATE #tab01
				SET CuotaPag = @CuotaPag10
				WHERE CodigoCredito = @codcred10	
				
				UPDATE #tab01
				SET CuotaPend = @CuotaPend10
				WHERE CodigoCredito = @codcred10																				

				UPDATE #tab01
				SET PorcPag = @PorcPag10
				WHERE CodigoCredito = @codcred10	
				
				FETCH cCuotaPend01 INTO @codcred10
				END
				CLOSE cCuotaPend01
				DEALLOCATE cCuotaPend01
		-------------------------------------------------------------------

		
		Select * from #tab01
		Where PorcPag >= 40 

		-- Drop table #tab01

