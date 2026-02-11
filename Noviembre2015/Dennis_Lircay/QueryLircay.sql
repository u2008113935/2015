
	/*
		Se solicita la siguiente información de la Ag. Lircay de los Sgtes. 
		Asesores SSALDA, JMAURI y AGUERRA con las siguientes condicionantes; 
		Nombre del cliente, Dirección, Destino del crédito, Dir. Fte de Ingreso, 
		Monto, Dias de atraso, fecha de Otorgamiento, estado(vigente - judicial), 
		tipo de crédito, Codigo de expediente, Analista origen, Analista actual. 

	*/


	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-11-01'				
				)

	Select * into #tab01 from (

		Select 		
				ROW_NUMBER() 
				OVER(PARTITION BY CRE.cCodUsuAna
						ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 						
				,CLI.cCodCliente AS 'CodigoCliente'		
				,CLIM.cNomCliente AS 'NombreCliente'
				,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
				,DireccionReferencia = DC.cDirCliRef
				,ZonaDomicilio = cNomZona
				,DIS1.cNomDistri as 'DistritoDomicilio'		 					 			
				,PRO1.cNomProvin AS 'ProvinciaDomicilio' 			
				,DEP1.cNomDepart AS 'DepartamentoDomicilio'	
				,CRE.cCodFueIng
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
				,DiasdeMora = CRE.nDiaAtrCre 														 
				,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
				,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
				,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
				--,CRE.cEstCreCon
				--,EC.cDescriEst AS 'EstadoCredito'	
				,CodDC = CRE.cCodDesCre, DestinoCredito = ISNULL(D2.cDescriDes,'NO REGISTRA')		
				,CodigoExpediente = E.cCodExpCli
				,CRE.cCodUsuAna AS 'CodAsesorActual'
				,SP.cNomPerson AS 'NombreAsesorActual'	
				,B.cCodUsuAna AS 'CodAsesorOrigen'
				,SP1.cNomPerson AS 'NombreAsesorOrigen'		
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
				left JOIN KPYTEstCreCon EC 
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
				left JOIN [KPYTConCredit] D
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
			
				LEFT join KPYTDesCreCon D2
					on D2.cCodDesCre = CRE.cCodDesCre	
			
				inner join [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
					on E.cCodClient = CLI.cCodCliente	
						
				inner join [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMSolicitud B
					on B.cCodSolCre = CRE.cCodSolCre
				inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP1 
					ON SP1.cCodPerson = B.cCodUsuAna					 								

			WHERE CRE.cEstCreCon in ('F','H')					
				and CRE.cCodOficin = '044'
				and CRE.cCodUsuAna in ('SSALDA','JMAURI','AGUERRA')
				and E.cTipExpCli = 'K'

			) as tmp


		
		Select * from #tab01	-- 646
		Where CodigoCredito = '107011101001681079'

		-- Drop table #tab01

		SELECT CodigoCredito, COUNT(CodigoCredito)
		From #tab01
		Group By CodigoCredito
		Having cOUNT(CodigoCredito) > 1
		

		/*
			Select * from GENTOficinas where cDesOficin like '%lircay%'
			Select * from [HYO00402].CMACHYOCLI_TARDE.DBO.CLIDExpediente E
		*/




		--09 FUENTES DE ingreso
		-- drop table #ficod
		Select * into #ficod from (
			Select distinct A.cCodCliente 
			from [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDFUEINGRESO A(NOLOCK)	
				inner join #tab01 B
					on A.cCodCliente = B.CodigoCliente			
			) as tmp

		-- Select * from #ficod

		CREATE NONCLUSTERED INDEX #ficod_cCodCliente_IXN ON #ficod(cCodCliente)	

		-- Select * from #ficod order by cCodCliente

		Select * into #tabfi from (
			Select distinct A.cCodCliente
				,cCodFueIng = isnull(A.cCodFueIng,'0')
				,cCodTipFin = isnull(A.cCodTipFin,'0')
			    ,A.cNomEmp
				,A.cDirEmp                                                                                     				
				,cCodDepart = isnull(A.cCodDepart,'0'),cCodProvin = isnull(A.cCodProvin,'0')
				,cCodDistri = isnull(A.cCodDistri,'0')
				,dFecModReg = isnull(left(cast(A.dFecModReg as date),10),'') 
			
			from [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDFUEINGRESO A(NOLOCK)
				inner join #tab01 B
					on A.cCodCliente = B.CodigoCliente
			--Order By A.cCodCliente
			) as tmp

		CREATE NONCLUSTERED INDEX #tabfi_cCodCliente_IXN ON #tabfi(cCodCliente)	

		-- Select * from #tabfi order by cCodCliente

		/*
		 Drop table #ficod
		 Drop table #tabfi
		 Drop table #fi
		*/

		Select * into #fi from (
			Select top 1 cCodCliente,cCodFueIng,cCodTipFin
					,cNomEmp, cDirEmp
					,cCodDepart
					,cCodProvin, cCodDistri
					,dFecModReg = left(cast(A.dFecModReg as date),10)   
			From [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDFUEINGRESO A	
			) as tmp

		Delete from #fi
		-- Drop table #fi			

		/*
		
		Select * from #fi

		Select * from #ficod
		Select * from #fi Where cCodCliente = '107022049394'

		Select *
		from CMACHYOCLI_201507.DBO.CLIDFUEINGRESO DFI
		Where cCodCliente = '107022049394'

		Select * from #fi
		
		Drop table #fi
		Delete from #fi

		*/	

		-----------------------------------------------------------------------
		Declare @codclient char(12)			  		
			
		Declare cFI CURSOR FOR	

			Select * from #ficod (NOLOCK) 								

			OPEN cFI
			FETCH cFI into @codclient
			WHILE (@@FETCH_STATUS=0)
			BEGIN	

			Insert Into #fi								
				Select top 1
				cCodCliente,cCodFueIng,cCodTipFin
				,cNomEmp, cDirEmp,cCodDepart, cCodProvin, cCodDistri
				,dFecModReg
				from #tabfi
				where cCodCliente = @codclient		
					and cCodFueIng = (Select max(cCodFueIng) 
										From #tabfi
										Where cCodCliente = @codclient)	
					and dFecModReg = (Select max(dFecModReg) 
										From #tabfi
										Where cCodCliente = @codclient)															
				
			FETCH cFI INTO @codclient
			END
			CLOSE cFI
			DEALLOCATE cFI	
	--------------------------------------------------------------------------------------
	
		CREATE NONCLUSTERED INDEX #fi_cCodCliente_IXN ON #fi(cCodCliente)	

		
		Select * into #fi02 from (	
			Select A.* 
				,DIS1.cNomDistri as 'DistritoFuenteIngreso'		 					 			
				,PRO1.cNomProvin AS 'ProvinciaFuenteIngreso' 			
				,DEP1.cNomDepart AS 'DepartamentoFuenteIngreso'	
			From #fi A
				INNER JOIN [GenTDepartame] DEP1
					ON DEP1.cCodDepart = A.cCodDepart
				INNER JOIN [GentProvincia] PRO1
					ON pro1.cCodProvin = A.cCodProvin and pro1.cCodDepart = A.cCodDepart
				INNER JOIN [GentDistrito] DIS1
					ON dis1.cCodDistri = A.cCodDistri	 and dis1.cCodProvin = A.cCodProvin 
						and dis1.cCodDepart = A.cCodDepart	
				) as tmp
				
		
		Select * from #fi02

		Drop table #fi02

		/*
				drop table #fi
				drop table #ficod
				drop table #tabfi
				drop table #tab01
		*/

		select * from #tab01

		
		Select A.*
			-- , B.* 
			, TipoFuenteIngreso =
				Case B.cCodTipFin	
				When 'I' then 'INDEPENDIENTE'
				When 'D' then 'DEPEPENDIENTE'
				else 'NO REGISTRA'
				END
			,DescripcionFuenteIngreso = ISNULL(B.cNomEmp,'NO REGISTRA')
			,DireccionFuenteIngreso = ISNULL(B.cDirEmp,'NO REGISTRA')
			,FechaRegFuenteIng = ISNULL(B.dFecModReg,'NO REGISTRA')
			,DistritoFuenteIngreso = ISNULL(B.DistritoFuenteIngreso,'NO REGISTRA')
			,ProvinciaFuenteIngreso = ISNULL(B.ProvinciaFuenteIngreso,'NO REGISTRA')
			,DepartamentoFuenteIngreso = ISNULL(B.DepartamentoFuenteIngreso,'NO REGISTRA')
		From #tab01 A
			left join #fi02 B
				on A.CodigoCliente = B.cCodCliente