		/*
		Extracción de una Cartera empresarial con la siguiente data: 
			1. Tipo de crédito pequeña y micro empresa. 
			2. Moneda: soles 
			3. Solo desembolsos a partir del 24.07.2015 hasta el 30.08.2015 
			4. Plazo: no mayor a 24 meses. 
			5. Modalidad: cualquiera 
			6. Calificación: 100% normal 
			7. Personas Naturales o Jurídica 
			8. Nombre y apellido del cliente 
			9. Monto desembolsado 
			10. Saldo de Capital 
			11. Plazo del crédito 
			12. Plazo por pagar 
			13. TEA 
			14. TEM 
			15. Fecha de desembolso 
			16. Sub producto 
			17. Dirección del cliente
			18. Ubicación: distrito, provincia, Departamento
		*/

	--Select top 10 * From KPYTModCredit M
	--Select * from HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMLinFinCre LIN   

	SET LANGUAGE spanish;
	--Tipo cambio 

	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
	Set @nTipCambio = (
	SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
			nTipCambio = nTipCamFij
	FROM GENTTipCambio
	WHERE left(cast(dFecTipCam as date),10) ='2015-09-01'				
				)
	-- Select @nTipCambio
	
	-- drop table #tab01
	Select * into #tab01 from (
			Select 		
					ROW_NUMBER() 
					OVER(PARTITION BY year(CRE.DFECDESCRE)
							ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
					,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
					,NombreMes =DATENAME(month, CRE.DFECDESCRE)					
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
			
					,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
					,TEM=CRE.nTasintCom	
					,NumeroCuotas=CRE.nNumCuoApr
					,DiasAprobados=CRE.nNumDiaApr
					,DiasGracia = CRE.nNumDiaGra
					,FormaPagoDias = ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)												 
					,CRE.cCodModCre, M.cDesModCre, CRE.cLibAmoCre
					,CodLC = CRE.nNroLinFin, LineaCredito =LIN.cDesLinFin
					,CIUU = isnull(CLIM.cCodCiiu,'9999')
					,DescripcionCIUU = CI.cdesactivi
					--,CRE.cEstCreCon
					--,EC.cDescriEst AS 'EstadoCredito'
					,EstadoCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END
					,CodDC = CRE.cCodDesCre, DestinoCredito = D2.cDescriDes								
					,Oficina = O.cDesOficin							
					--,ZON.nCodZona
					,Zona = ZON.cDesZona			
					--Datos del Cliente			
					,CLI.cCodCliente AS 'CodigoCliente'		
					,CLIM.cNomCliente AS 'NombreCliente'
					,TipoPersona =
						 Case CLIM.cCodClaPer					
						 When '1' then 'P. NATURAL'
						 When '2' then 'PJ. SIN LUCRO'
						 When '3' then 'PJ.CON LUCRO'
						 End
					--,DepartDomi = DC.cCodDepart, ProvinDomi = DC.cCodProvin
					--,DistriDomi = DC.cCodDistri				
					,DEP1.cNomDepart AS 'Departamento'			 
					,PRO1.cNomProvin AS 'Provincia' 
					,DIS1.cNomDistri as 'Distrito'
					,CaliRCC = 
						Case when RCC.CCLAFIN = '0' then 'NORMAL' ELSE 'NO REGISTRA' END
					, MesRCC = left(cast(RCC.CMESPRO as date),7)
					
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
					inner join KPYTModCredit M
						on CRE.cCodModCre = M.cCodModCre
					inner join [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC				
						on DC.cCodCliente = CLIM.CCODCLIENTE and DC.bDirPredet = '1'			
					
					INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMLinFinCre LIN     
						ON CRE.nNroLinFin = LIN.nNroLinFin and LIN.lConEstado = '1'
					
					INNER JOIN [GenTDepartame] DEP1
						ON DEP1.cCodDepart = DC.cCodDepart
					INNER JOIN [GentProvincia] PRO1
						ON pro1.cCodProvin = DC.cCodProvin and pro1.cCodDepart = DC.cCodDepart
					INNER JOIN [GentDistrito] DIS1
						ON dis1.cCodDistri = DC.cCodDistri	 and dis1.cCodProvin = DC.cCodProvin 
							and dis1.cCodDepart = DC.cCodDepart
					/*
					inner join KPYMLinFinCre L
						on L.cCodTipRec	= CRE.cCodTipRec and L.cCodRecurs = CRE.cCodRecurs
					*/	
					-- Select top 5 * from CRICMACHYO_DIARIO.DBO.urirccmae RCC
					inner join HYO00402.CRICMACHYO_DIARIO.DBO.urirccmae RCC
						on RCC.cCodSBS = CLIM.cCodSbs	
					
					LEFT join KPYDDesCreCon D1
						on D1.cCodCtaCre = CRE.cCodCtaCre 
							and D1.cCodDesCre = CRE.cCodDesCre
					
					LEFT join KPYTDesCreCon D2
						on D2.cCodDesCre = CRE.cCodDesCre

					left join GENTCodCiiu CI
						on CI.ccodciiu = CLIM.cCodCiiu					
										
				WHERE CRE.cEstCreCon = 'F' -- in ('F','H','I','G')					
					and 
						/*
					 ((CRE.cCodTipCre = '02' 
						  --and STC.cDesSubCre in ('EMPRESARIAL','AGROPECUARIO','CREDIVIP EMPRESA') 
						  and STC.lEstado = '1') 
							or
						 (CRE.cCodTipCre = '13' 
						 --and STC.cDesSubCre in ('EMPRESARIAL','AGROPECUARIO','CREDIVIP EMPRESA') 
						 and STC.lEstado = '1'))	
						*/ 
						 ((CRE.cCodTipCre = '12' and STC.lEstado = '1'))	
						 	
					and left(cast(CRE.dFecDesCre as date),10) >= '2015-04-23'
					and left(cast(CRE.dFecDesCre as date),10) <= '2015-07-22'	
					and CRE.nNumCuoApr <= '36'	
					and RCC.CCLAFIN = '0'	
					and LIN.cCodRecurs = '01'
					and LIN.cCodTipMon = '1'
					--and LIN.cCodTipCre in ('02','13')
					and LIN.cCodTipCre = '12'
					and ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra) <= 1080 	
			
		) as tmp
		
		-- (22,271 row(s) affected)
		
		/*
		Select CodigoCredito, count(CodigoCredito)
		from #tab01
		GRoup by CodigoCredito
		Having count(CodigoCredito) > 1 
		
		Select *
		from #tab01
		Where CodigoCredito = '107048101002473867'
		*/
		CREATE NONCLUSTERED INDEX #tab01_CodigoCredito_IXN ON #tab01(CodigoCredito)	

		Select * into #tab02 from (Select top 1 * from #tab01) as tmp
		-- Select * from #tab02
		Delete from #tab02
		
		------------------------------------------------------------------
		Declare @codcred char(18) --, @monpaggas money, @fechapag date							
				
				Declare cCredEmp CURSOR FOR
					select distinct CodigoCredito 
					from #tab01 (NOLOCK)

				OPEN cCredEmp
				FETCH cCredEmp into @codcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN			
					  
				Insert Into #tab02 					
					Select top 1 *
					FROM #tab01
					where CodigoCredito = @codcred						
			
				FETCH cCredEmp INTO @codcred
				END
				CLOSE cCredEmp
				DEALLOCATE cCredEmp
		-------------------------------------------------------------------

		CREATE NONCLUSTERED INDEX #tab02_CodigoCredito_IXN ON #tab02(CodigoCredito)	

		Select * from #tab02
		Order By Secuencia,Anio,mes

		Select CodigoCredito, count(CodigoCredito)
		from #tab02
		GRoup by CodigoCredito
		Having count(CodigoCredito) > 1 

			
		/*		
			Drop table #tab01
			Drop table #tab02

			SELECT *
			FROM KPYDDesCreCon
			WHERE cCodSolCre = '0010183575'
 
			SELECT * FROM KPYTDesCreCon WHERE cCodDesCre = 6
 
			SELECT *
			FROM KPYDTipDesCre
			WHERE cCodSolCre = '0010183575'
 
			SELECT *
			FROM KPYTTipDesCre 
			WHERE cCodDesCre = 6



		Select cCodDesCre,* from KPYDDesCreCon						
		Select cCodDesCre,* from KPYTDesCreCon where lConEstado = '1'
		Select cCodDesCre,* from KPYTTipDesCre

		Select *
		from HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMLinFinCre LIN 
		where lConEstado = '1' AND cCodRecurs = '01' AND cCodTipMon = 1
			and cCodTipCre in ('02','13')

		Select nNroLinFin,cDesLinFin,cCodRecurs
		from HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMLinFinCre LIN 
		where lConEstado = '1'
		Group By nNroLinFin,cDesLinFin,cCodRecurs

		Select * from KPYDRecurso
		*/

		-- Select * from CRICMACHYO.DBO.urirccmae

		--Solo desembolsos a partir del 24.07.2015 hasta el 30.08.2015 
		-- Select * from KPYMLinFinCre L
		
		/*
		Select * From [KPYTSUBTIPCRE] STC
		Where STC.lEstado = '1' and cCodTipCre in ('02','13')

		Select DC.cCodConDom
		from [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC

		Select *
		from [HYO00406\HISTORICO].SOFCMACHYO_201507.dbo.GENTConDomici 
		where cCodConDom = '4'
		*/