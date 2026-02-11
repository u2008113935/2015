
	/*
		zona,agencia,asesor  y /o auxiliar de creditos,saldo de colocaciones
		,saldo de colocaciones pyme, saldo de colocaciones consumo, ratio de mora
		,numero de clientes, tasa acticva ponderada, alcance poi como agencia 
		
	*/
	
		SET LANGUAGE spanish;
			--Tipo cambio a junio 2015
		DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
			SET @nTipCambio = (
				SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
					nTipCambio = nTipCamFij
				FROM GENTTipCambio
				WHERE left(cast(dFecTipCam AS DATE),10) ='2015-12-01'				
					)

		-- DROP TABLE #tab01
		Select * into #tab01 from (

			Select 	
					CRE.cCodUsuAna AS 'CodAsesor'
					,SP.cNomPerson AS 'NombreAsesor'
					,N.cDesClaSub	
					,UltimoCargo = 	CA.cDesCarPer 
					,C.cCodConven,C.cDesConven		
				
					,Oficina = O.cDesOficin										
					,Zona = ZON.cDesZona			
				
					--,Anio= year(CRE.DFECDESCRE)
					,Mes = MONTH (CRE.DFECDESCRE)
					,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
					,CLI.cCodCliente AS 'CodigoCliente'		
					,CLIM.cNomCliente AS 'NombreCliente'					
					--Datos del credito		 								
					,CRE.cCodCtaCre AS 'CodigoCredito'				
					,CRE.cCodTipCre
					,STC.cDesTipCre AS 'TipoCredito'
					,STC.cDesSubTip AS 'SubTipoCredito'			 
					,CRE.cCodProduc 
					,STC.cDesProCre AS 'ProductoCrediticio' 			 
					,CRE.cCodSubPro 
					,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
					,case cre.cCodTipMon
						when '1' then 'SOLES'
						when '2' then 'DOLARES'
						end AS 'Moneda'
					--,CRE.nMonCapDes as 'MontoDesembolso' 
					--,TipoCambio = @nTipCambio
					,MontoDesembolsoenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN CRE.nMonCapDes
						WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
						END						
					,nSaldoCapi = (CASE WHEN CRE.cEstCreCon IN ('F', 'H')
										THEN (CRE.nMonCapDes - CRE.nMonCapPag) 
											* CASE WHEN CRE.cCodTipMon = '2' 
										THEN @nTipCambio ELSE 1 END
										ELSE 0 END)
					,nSaldoVig = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.cCodRefina = 'N'
										THEN CRE.nMonSalNor * CASE WHEN CRE.cCodTipMon = '2' 
										THEN @nTipCambio ELSE 1 END
										ELSE 0 END)
					,nSaldoVen = (CASE WHEN CRE.cEstCreCon = 'F' and CRE.nMonSalVen > 0
										THEN CRE.nMonSalVen * CASE WHEN CRE.cCodTipMon = '2' 
										THEN @nTipCambio ElSE 1 END
											ELSE 0 END)
					,nSaldoJud = (CASE WHEN CRE.cEstCreCon = 'H' THEN CRE.nMonSalVen 
											* CASE WHEN CRE.cCodTipMon = '2'
										THEN @nTipCambio ELSE 1 END
										ELSE 0 END)
					,nSaldoRef = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.nMonSalNor > 0 
											AND CRE.cCodRefina = 'S'
										THEN CRE.nMonSalNor	* CASE WHEN CRE.cCodTipMon = '2' 
										THEN @nTipCambio ELSE 1 END
										ELSE 0 END)					
					,TEM		 = CRE.nTasintCom	
					,TEA	  	 = (POWER((CRE.nTasintCom/100 + 1 ), 12)-1) * 100									
					,EstadoCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END					
					,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolso'				
					
			FROM [KPYMCRECONVEN] CRE (NOLOCK)		
					INNER JOIN [GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre
					INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
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
					INNER JOIN [sipmpersonal] SP 
						ON SP.cCodPerson = CRE.cCodUsuAna	
					--condicion credito 
					LEFT JOIN [KPYTConCredit] D
						ON D.cCondicCon = CLI.cCondicCon			 																			
					
					INNER join KPYMConvenios C
						ON C.cCodConven = CRE.cCodConven and C.cCodEstCon = 'A'			

							
					INNER JOIN SIPTCARGOPER CA
						ON CA.cCodGruPer = SP.cCodGruPer 
				
					INNER JOIN [SIPDIncAsiPon] P 
						ON P.cCodPerson = SP.cCodPerson	AND P.cCodPeriodo = '2015/10'
							AND P.cCodSituac = 'A'								
			
					INNER join [SIPTClaSubNiv] N
						ON	N.cCodNivel = P.cCodNivel AND N.cCodSubNiv = P.cCodSubNiv 
							AND N.cCodClaSub = P.cCodClaSub AND N.lConEstado = 1 
							AND N.nCodPAPApr	=	8									
				
				WHERE CRE.cEstCreCon in ('F','H')								
					AND LEFT(cast(CRE.dFecDesCre as date),10) >= '2015-09-01' 
					--AND C.cCodConven in ('CFA15','CFRP15','CFAE15')
					--and CRE.cCodUsuAna = 'AALEGR'
				--Order By CRE.cCodUsuAna
				) as tmp
				
				--	(67,041 row(s) affected)


		/*
			
			SELECT * FROM #tab01

			SELECT * FROM [SIPDIncAsiPon] P 
			ORDER BY P.cCodPeriodo DESC
						
			Select C.cDesConven	,* 
			From KPYMConvenios C
			Where C.cDesConven like '%campaña%'
				-- C.cCodConven = 'CFRO14'
			Order By dFecRegCon desc


		*/

		-- 
		
		SELECT * INTO #tab02 FROM (
				SELECT TOP 1
						Zona,Oficina,Mes,NombreMes,cCodConven,cDesConven,CodAsesor,NombreAsesor,
						cDesClaSub,UltimoCargo,TipoCredito,CodigoCredito,EstadoCredito,
						FechaDesembolso, MontoDesembolsoenSoles, nSaldoCapi, nSaldoVig, nSaldoVen,
						nSaldoJud, nSaldoRef, TEM, TEA 
				FROM #tab01
				) AS tmp
		
		DELETE FROM #tab02
				
		ALTER TABLE #tab02
		ADD NroClientes NUMERIC(14,4), NroCreditos NUMERIC(14,4), RatioMora NUMERIC(14,4),
			TAP NUMERIC(14,4)

		-- DROP TABLE #tab02
		-- SELECT * FROM #tab02
		-- DECLARE @lnTea NUMERIC(14,4)
		
		--Select * into #tab02 from (
		
	
	--03 INSERTANDO
	------------------------CURSOR  -----------------------------------
		Declare @CodAsesor char(10)			  		
			
			Declare cCur01 CURSOR FOR	
			
			Select distinct CodAsesor from #tab01 (NOLOCK) 					

			OPEN cCur01
			FETCH cCur01 into @CodAsesor
			WHILE (@@FETCH_STATUS=0)
			BEGIN	
					
					INSERT INTO #tab02 
						Select 
							Zona,Oficina,Mes,NombreMes
							,cCodConven,cDesConven
							,CodAsesor,NombreAsesor,cDesClaSub,UltimoCargo,TipoCredito
							,CodigoCredito
							,EstadoCredito, FechaDesembolso
							,MontoDesembolsoenSoles = sum(MontoDesembolsoenSoles)
							,SaldoCapi = sum(nSaldoCapi)
			
							,SaldoVig =  sum(nSaldoVig)
							,SaldoVen =  sum(nSaldoVen)
							,SaldoJud =  sum(nSaldoJud)
							,SaldoRef =  sum(nSaldoRef)
							,TEM
							,TEA								
							,NroClientes = count (distinct (CodigoCliente))
							,NroCreditos = count (distinct (CodigoCredito))
							,RatioMora = (sum(nSaldoVen) + sum(nSaldoJud)) / sum(nSaldoCapi) --* 100)
							--,Total = (Select sum(MontoDesembolsoenSoles) from #tab01)
							,TAP	 =  (MontoDesembolsoenSoles) /
										(Select sum(MontoDesembolsoenSoles) from #tab01
										 WHERE CodAsesor	= @CodAsesor)	--'FBASUA')
										  * TEA
						From #tab01
						WHERE CodAsesor		=	@CodAsesor --'FBASUA'
						Group By Zona,Oficina,Mes,NombreMes,cCodConven,cDesConven,
							CodAsesor,NombreAsesor,cDesClaSub,UltimoCargo,TipoCredito,
							EstadoCredito, FechaDesembolso,
							CodigoCredito,MontoDesembolsoenSoles, TEM, TEA

			FETCH cCur01 INTO @CodAsesor
			END
			CLOSE cCur01
			DEALLOCATE cCur01

			--	) as tmp

			--	(67,041 row(s) affected)
		/*
			Select * from #tab01 
			
			SELECT * FROM #tab02
			--WHERE CodAsesor =	'JHUAMO'
			ORDER BY CodAsesor


		*/

	
			-- (6,066 row(s) affected) al cierre nov 2015

	/*
		
		Drop table #tab01
		Drop table #tab02
		Drop table #tab03

	*/


	/*
	Select A.* , O.cDesOficin , ZON.cDesZona, N.cDesClaSub, P.cCodClaSub
					,FechaCese = ISNULL(LEFT(CAST(P.dFecCesIns AS DATE),10),'')
					,EstadoLaboral =
						Case when P.dFecCesIns is null then 'VIGENTE'
						ELSE 'CESADO' END	
					,UltimoCargo = 	C.cDesCarPer 
					,UltimaArea = AA.cDesAreaCmac 
	From SIPDIncPunAlc A			
					INNER JOIN [GENTOficinas] O 
						ON O.cCodOficin = A.cCodOficin and O.lConEstado = '1'			
					INNER JOIN [Gentofizonas] GOZ
						ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
					INNER JOIN [GentZonas] ZON
						ON ZON.nCodZona = GOZ.nCodZona
					left join SIPMPersonal P
						on P.cCodPerson = A.cCodPerson						
					left join SIPTCLASUBNIV N
						on N.cCodNivel = left(A.cCodNivAna,2) and N.cCodSubNiv = substring(A.cCodNivAna,3,1) 
							and N.cCodClaSub = P.cCodClaSub  and N.nCodPAPApr = '8'	
					left join SIPTCARGOPER C
						on C.cCodGruPer = P.cCodGruPer 				
					left join [HYO00409\HISTORICO].SOFCMACHYO_201510.dbo.SIPTAreaCmac AA					
						on AA.cCodAreaCmac = P.cCodAreaCmac
	Where ZON.nCodZona = '4'  
	*/