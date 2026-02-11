
	/*
	

	*/


	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-10-01'				
				)

	Select * into #tab01 from (

	Select 		
			/*
			ROW_NUMBER() 
			OVER(PARTITION BY CRE.cCodUsuAna
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
			*/
			CLI.cCodCliente AS 'CodigoCliente'		
			,CLIM.cNomCliente AS 'NombreCliente'
			,NumDoc = isnull(CLIM.cNroDocIde, CLIM.cNroDocTri)
			,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
			,DireccionReferencia = isnull(DC.cDirCliRef,'')
			,ZonaDirecc = Z.cNomZona
			,dis1.cCodDistri
			,DIS1.cNomDistri as 'DistritoDirecc'		 					 			
			,PRO1.cNomProvin AS 'ProvinciaDirecc' 			
			,DEP1.cNomDepart AS 'DepartamentoDirecc'	
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
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'											
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
			 INNER JOIN 
			 [KPYTConCredit] D
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

		WHERE CRE.cEstCreCon in ('F','G')					
			and dis1.cCodDepart = '12' and dis1.cCodProvin = '01'
			and dis1.cCodDistri in ('05','06','08','13','20','22','27','28','33','34','36')			
	
		) as tmp


		
		Select * into #tab02 from ( Select top 1 * From #tab01) as tmp
		-- Select * from #tab02
		Delete from #tab02


	--------------------------------------------cursor ---------------------------------------------
	Declare @codcliente1 char(12),  @MonGas decimal (10,5), @Monto decimal(10,5), @Cuota decimal (10,5)
				
		Declare cC02 CURSOR FOR
			Select distinct CodigoCliente from #tab01 (NOLOCK)						
		OPEN cC02
		FETCH cC02 into @codcliente1
		WHILE (@@FETCH_STATUS=0)
		BEGIN				
				Insert Into #tab02
				Select * 
				From #tab01
				Where CodigoCliente = @codcliente1
					and FechaDesembolsoCredito =
							(Select max(FechaDesembolsoCredito) 
								From #tab01
								Where CodigoCliente = @codcliente1
							) 	
					
		FETCH cC02 INTO @codcliente1
		END
		CLOSE cC02
		DEALLOCATE cC02
	-------------------------------------------------------------------	

	Select * from #tab02
	Order By CodigoCliente

		/*
			Select CodigoCliente, count(CodigoCliente) from #tab02
			Group By CodigoCliente
			Having count(CodigoCliente) > 1
			Order By CodigoCliente
	
			drop table #tab01
			drop table #tab02
		*/

		/*
		Select * from [GENTOficinas]
		Where lConEstado = '1' and cDesOficin like '%Chosica%'


		Select * from [GenTDepartame] DEP1 where cNomDepart like '%junin%'

				
		Select * from [GentProvincia] PRO1 where cCodDepart = '12' and cCodProvin = '01'
				
		Select * from [GentDistrito] DIS1 
		Where cCodDepart = '12' and cCodProvin = '01'
			and cCodDistri in ('05','06','08','13','20','22','27','28','33','34','36')

		*/