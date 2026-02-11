		/*
		
		Créditos aprobados por el usuario : HROMERO
		Heber Fernando Romero Leo( ADM)
		Agencia : Cañete
		Tiempo: A la fecha
		Campos:
			ccodcliente,ccodctacre, nMonCapDes, MonCapDesSoles, dfecDesCre, Moneda
			,ccodTipGar,nDiaAtrCre,cDesTipCre,cDesSubTip,cDesProCre,cDesSubCre,Sal_cap
			,SAL_SOLES,Sal_ Cartea vencida,Sal _ Cartera judicial,Sal _ Cartera Atrasada 
			,cDescriEst,cDirCliente,cDirDomGar,Ref,cDesCorta,Ana_Origen,cnomperson
			,Ana_Responsable,cnomperson

		*/

		/*
		KPY_ActEvaIntCom_sp
 
		SELECT TOP 20 *
		FROM kpydComaprCre

		SELECT *
		FROM kpydComaprCre
		Where cCodPerson = 'HROMER'
		Order By dFecRegApr

		Select cCodOficin,* from KPYMSolicitud
		Where cCodOficin = '043'
				and cCodSolCre = '0430013176'

		Select cCodOficin,* from KPYMSolicitud
		Where cCodOficin = '043'

		Select * from [GENTOficinas] O 
		where cDesOficin like '%Cañe%'

		Select *
		from [sipmpersonal] SP 
		Where cNomPerson like '%Romero%Leo%Heber%Fernando%'
		-- cCodPerson: HROMER

		Select * From KPYMCRECONVEN
		Where cCodCtaCre = '107043101000902570'

		Select * from [GENMCRECLI] 
		where cCodLinCre = '0430009440'

		*/

		SET LANGUAGE spanish;

		DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01')	


		SELECT 
			Anio= year(A.dFecRegApr), Mes = MONTH (A.dFecRegApr)
			,NombreMes =DATENAME(month, A.dFecRegApr)
			,CodigoCliente = CC.cCodCliente, NombreCliente = CC.cNomCliente
			,CodigoCredito = C.cCodCtaCre
			,MontoDesembolsado = C.nMonCapDes
			,FechaDesembolso = left(cast(C.dFecDesCre as date),10)
			,Moneda = 
				case C.cCodTipMon
				when '1' then 'SOLES'
				when '2' then 'DOLARES'
				end 
			,A.cCodSolCre
			,STC.cDesTipCre AS 'TipoCredito'
			,STC.cDesSubTip AS 'SubTipoCredito'			
			,STC.cDesProCre AS 'ProductoCrediticio' 			
			,STC.cDesSubcRE AS 'SubProductoCrediticio'
			--,(C.nMonCapDes - C.nMonCapPag) AS 'SaldoCapital'

			,nSaldoCapi = (CASE WHEN C.cEstCreCon IN ('F', 'H')
								THEN (C.nMonCapDes - C.nMonCapPag) * 
											CASE WHEN C.cCodTipMon = '2' THEN @nTipCambio 
											ELSE 1 END
								ELSE 0 END)
			,nSaldoVig = (CASE WHEN C.cEstCreCon = 'F' AND C.cCodRefina = 'N'
								THEN C.nMonSalNor * 
											CASE WHEN C.cCodTipMon = '2' THEN @nTipCambio 
											ELSE 1 END
								ELSE 0 END)
			,nSaldoVen = (CASE WHEN C.cEstCreCon = 'F' and C.nMonSalVen > 0
								THEN C.nMonSalVen * 
											CASE WHEN C.cCodTipMon = '2' THEN @nTipCambio 
								            ELSE 1 END
								ELSE 0 END)
			,nSaldoJud = (CASE WHEN C.cEstCreCon = 'H' THEN C.nMonSalVen * 
											CASE WHEN C.cCodTipMon = '2' THEN @nTipCambio 
											ELSE 1 END
								ELSE 0 END)
			,nSaldoRef = (CASE WHEN C.cEstCreCon = 'F' AND C.nMonSalNor > 0 AND C.cCodRefina = 'S'
								THEN C.nMonSalNor	* 
											CASE WHEN C.cCodTipMon = '2' THEN @nTipCambio 
											ELSE 1 END
									ELSE 0 END)

			,TEM=C.nTasintCom	
			,NumeroCuotas=C.nNumCuoApr	
			,DiasAtraso = C.nDiaAtrCre
			,EstadoCredito =
				Case C.cEstCreCon
				when 'G' then 'CANCELADO' 
				ELSE D.cDesConCre
				END
			,A.cCodPerson, A.lEstOpiFav, A.lEstOpiDes, A.cCodTipAct
			,A.cCodUsuReg, A.dFecRegApr, A.cCodCarPer, O.cDesOficin	
			,C.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'	
			,B.cCodUsuAna AS 'CodAsesorOrigen'
			,SP1.cNomPerson AS 'NombreAsesorOrigen'--NOMBRE ANALISTA 	
			,DG.cCodTipGar, DG.cCodGarCli			
			,TitularGarantia = C1.cNomCliente
			,Direccion = CD.cDirCliente	
			,Referencia = CD.cDirCliRef	
			,DE.cNomDepart				
			,PR.cNomProvin				
			,DI.cNomDistri			
		FROM kpydComaprCre A
			inner join KPYMSolicitud B
				on A.cCodSolCre = B.cCodSolCre
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = B.cCodOficin
			inner join KPYMCRECONVEN C
				on C.cCodSolCre = A.cCodSolCre
			inner join [GENMCRECLI] G
				on G.cCodCtaCre = C.cCodCtaCre and G.cCodLinCre = B.cCodLinCre
			INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CC 
				ON CC.cCodCliente = G.cCodCliente
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON C.cCodTipCre = STC.cCodTipCre AND C.cCodProduc = STC.cCodProduc 
					AND C.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = G.cCondicCon
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = C.cCodUsuAna	
				
			Inner join KPYDGarLinCre DG	
				on DG.cCodLinCre = G.cCodLinCre		
			left join CMACHYOCLI_MANIANA..CLIMGarCliente CG
				on CG.cCodCliente = DG.cCodCliente 
					and CG.cCodTipGar = DG.cCodTipGar
					and CG.cCodGarCli = DG.cCodGarCli
			left join CMACHYOCLI_MANIANA..CLIDDirGarant CD
				on CD.cCodCliente = DG.cCodCliente and CD.cCodGarCli = DG.cCodGarCli 
			
			INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C1 
					ON C1.cCodCliente = DG.cCodCliente

			inner join GENTDepartame DE
				on DE.cCodDepart = CD.cCodDepart
			inner join GENTProvincia PR
				on PR.cCodProvin = CD.cCodProvin and PR.cCodDepart = CD.cCodDepart
			inner join GENTDistrito DI 
				on DI.cCodDistri = CD.cCodDistri and DI.cCodDepart = CD.cCodDepart
					and DI.cCodProvin = CD.cCodProvin
			Inner JOIN [sipmpersonal] SP1 
				ON SP1.cCodPerson = B.cCodUsuAna
		Where A.cCodPerson = 'HROMER' and B.cCodOficin = '043'
			and C.cEstCreCon in ('F','G','I','H')
			and DG.cCodEstGar = 'A'
		Order By A.dFecRegApr


		
		