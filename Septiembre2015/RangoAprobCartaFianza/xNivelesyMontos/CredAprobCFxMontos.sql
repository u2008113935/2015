		/*
		
		Cartas fianza rango de aprobacion 

		*/

		/*

		Select top 5 * 		
		FROM KPYMCRECARFIA C (NOLOCK)				 		
				inner join kpydComaprCre A
					on A.cCodSolCre = C.cCodSolCre

		select top 1 * from GENMCRECLI
		select top 1 * from KPYMCRECARFIA

		Select top 5 *
		FROM kpydComaprCre
			inner join KPYMSolicitud B
				on A.cCodSolCre = B.cCodSolCre
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = B.cCodOficin
			inner join KPYMCRECONVEN C
				on C.cCodSolCre = A.cCodSolCre
			inner join [GENMCRECLI] G
				on G.cCodCtaCre = C.cCodCtaCre and G.cCodLinCre = B.cCodLinCre


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

		/*
		SET LANGUAGE spanish;

		DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01')	
		*/
			
		----------------------------------------------------------------------------
		-- Drop table #tab1
		SET LANGUAGE spanish;
	
		DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
			set @nTipCambio = (
				SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
					nTipCambio = nTipCamFij
				FROM GENTTipCambio
				WHERE left(cast(dFecTipCam as date),10) ='2015-09-01')
		
		Select * into #tab1 from (

		Select 						
			CodigoClienteSolicitante = GEN.CCODCLIENTE
			,FIA.cCodSolCre
			,NombreClienteSolicitante = CLITIT.CNOMCLIENTE 									 			
			,CodigoLineaCredito = GEN.CCODLINCRE								
			,CodigoCartaFianza = FIA.CCODCTACRE, NumeroCartaFianza = FIA.CNROCARFIA
			,FIA.CESTCARFIA
			,EstadoCartaFianza = EC.cDesEstCar								
			,ValorCartaFianza = FIA.NVALCARFIA			
			,FIA.cCodTipMon
			,TipoCambio = @nTipCambio
			,ValorEnSoles = 
			case FIA.cCodTipMon
			WHEN '1' THEN FIA.NVALCARFIA
			WHEN '2' THEN @nTipCambio * FIA.NVALCARFIA
			END
			,FechaAprob = left(cast(dFecRegApr as date),7)
			,A.lEstOpiFav 
			,A.cCodTipAct, Nivel = isnull(N.cDesTipAct,'')
			,A.cCodCarPer, CC.cDesCarPer, S.cTipActSis
			--,N.cCodOficin 			
		FROM KPYMCRECARFIA FIA (NOLOCK)				 		
			inner join kpydComaprCre A
				on A.cCodSolCre = FIA.cCodSolCre
			inner JOIN GENMCRECLI GEN (NOLOCK) 
				ON (FIA.CCODCTACRE = GEN.CCODCTACRE)
			inner JOIN [hyo00402].CMACHYOCLI_MANIANA.DBO.CLIMClienteS CLITIT (NOLOCK) 										
				ON (CLITIT.CCODCLIENTE = GEN.CCODCLIENTE)			
			
			inner join kpymsolicitud S
				on S.cCodSolCre = FIA.cCodSolCre
			left join KPYTTipActa N
				on N.cCodTipAct = S.cTipActSis--A.cCodTipAct 
					--and N.lConEstado = '1'
					and N.cCodOficin = S.cCodOficin	

			INNER JOIN KPYTEstCarFia EC
				ON EC.cEstCarFia = FIA.CESTCARFIA 

			inner join SIPTCARGOPER CC
				on CC.cCodGruPer = A.cCodCarPer

		where FIA.CESTCARFIA in ('K','G') 			
			and A.lEstOpiFav = '1'	
			and left(cast(dFecRegApr as date),7) >= '2015-06'
			and left(cast(dFecRegApr as date),7) <= '2015-08'			
		--Order By GEN.CCODCLIENTE		
			) as tmp

		/*

		Select * from #tab1
		Order by CodigoClienteSolicitante
		-- (394 row(s) affected)

		Select 
			cTipActSis,Nivel,cCodCarPer,cDesCarPer
			,CantiCF=count(CodigoCartaFianza)	
		From #tab1
		Group By cTipActSis,Nivel,cCodCarPer,cDesCarPer			
		*/
		-- drop table #tab2
	Select * into #tab2 from (
		Select 			
			/*
			ROW_NUMBER() 
			OVER(PARTITION BY cTipActSis
					ORDER BY MONTH (FechaAprob) ) AS Secuencia 
			*/		
			-- NombreMes =DATENAME(month, cast(FechaAprob as char(30))) 
			CodigoCartaFianza , NumeroCartaFianza
			,Nivel,cCodCarPer,cDesCarPer
			,CantiCF = count(CodigoCartaFianza)
			,FechaAprob 
			--,ValorEnSoles = sum (ValorEnSoles)
			,ValorEnSoles 
			,Nivel_I =
				Case when ValorEnSoles <= 14000 then  count (CodigoCartaFianza)
				else 0 end 
			,Nivel_II =
				Case when ValorEnSoles >= 14001 and ValorEnSoles <= 40000
				then  count (CodigoCartaFianza)
				else 0 end 
			,Nivel_III =
				Case when ValorEnSoles >= 40001 and ValorEnSoles <= 87500
				then  count (CodigoCartaFianza)
				else 0 end 
			,Nivel_IV =
				Case when ValorEnSoles >= 87501 and ValorEnSoles <= 140000
				then  count (CodigoCartaFianza)
				else 0 end 
			,Nivel_V =
				Case when ValorEnSoles >= 140001 and ValorEnSoles <= 210000
				then  count (CodigoCartaFianza)
				else 0 end 
			,Nivel_VI =
				Case when ValorEnSoles >= 210001 
				then  count (CodigoCartaFianza)
				else 0 end 
		from #tab1 	
		Group By 
			CodigoCartaFianza , NumeroCartaFianza,
			Nivel,cCodCarPer,cDesCarPer,FechaAprob, ValorEnSoles
		--Order BY FechaAprob, ValorEnSoles
		) as tmp


		-- Select * from #tab2


		Select 
			FechaAprob,Nivel,cCodCarPer,cDesCarPer
			,CantiCF = count(CodigoCartaFianza)
			,Nivel_I = SUM(Nivel_I)
			,Nivel_II = SUM(Nivel_II)
			,Nivel_III = SUM(Nivel_III)
			,Nivel_IV = SUM(Nivel_IV)
			,Nivel_V = SUM(Nivel_V)
			,Nivel_VI = SUM(Nivel_VI)			
		from #tab2
		Group By Nivel,cCodCarPer,cDesCarPer,FechaAprob
		Order By FechaAprob

		/*
		Select cCodTipAct,Nivel,cCodCarPer from #tab1
		Group by cCodTipAct,Nivel,cCodCarPer

		Select cCodTipAct from #tab1
		Group by cCodTipAct Order by cCodTipAct

		
		Select 
			NivelI = (Select NivelI = count(distinct CodigoCartaFianza)			
						From #tab1
						Where ValorEnSoles <= 14000)						

			,NivelII = (Select NivelII = count(distinct CodigoCartaFianza)			
						From #tab1
						Where ValorEnSoles <= 40000 and ValorEnSoles > 14000)				

			,NivelIII = (Select NivelIII = count(CodigoCartaFianza)			
						From #tab1
						Where ValorEnSoles <= 87500 and ValorEnSoles > 40000)

			,NivelIV = (Select NivelIII = count(CodigoCartaFianza)			
						From #tab1
						Where ValorEnSoles <= 140000 and ValorEnSoles > 87500)

			,NivelV = (Select NivelIII = count(CodigoCartaFianza)			
						From #tab1
						Where ValorEnSoles <= 210000)

			,NivelVI = (Select NivelIII = count(CodigoCartaFianza)			
						From #tab1
						Where ValorEnSoles > 210000)			
			*/			
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------			
						
		/*
		
		Select top 5 * from KPYMSOLICITUD

		Select * from KPYTTipSolCre where lConEstado = '1'
		

		Select * from kpydComaprCre where cCodSolCre = '0020108165'
		select * from kpymsolicitud where cNroDocIde = '43111949'

		Select * from [sipmpersonal] where cCodGruPer = 'ADM'
 
		Select * from SIPTCARGOPER where cCodGruPer in
		(
		'013',
		'057',
		'OOO',
		'OPE',
		'ADM',		
		'018',
		'GDN',
		'GE2'
		)
			--on C.cCodGruPer = P.cCodGruPer 
		
		Select * from KPYTEstCarFia
		Select * from KPYMCRECARFIA
		select * from kpydComaprCre A				
		Select cCodOficin,* GENMCRECLI GEN (NOLOCK) 
		Select cCodOficin,* from kpymsolicitud
		where cCodSolCre = '0020036437'


		select * from KPYTTipActa where lConEstado = '1'

		Select cCodTipAct,cDesTipAct
		from KPYTTipActa
		Group by cCodTipAct,cDesTipAct
		Order By cCodTipAct

		Select * from KPYDActa

		Select * from KPRDDetActa		
		where cCarUsuAct = ''

		013
		057
		OOO
		OPE
		ADM
		ADM
		018
		GDN
		GE2

		Select top 5 * from kpydComaprCre A
		
		Select * from kpydComaprCre A
		where cCodSolCre = '0020036437'

		Select lEstOpiFav from kpydComaprCre A
		Group By lEstOpiFav


		Select cCodTipAct from kpydComaprCre A
		Group By cCodTipAct
		
		107010010364	0020036437	ALIAGA MARTIN, ALEJANDRO CARLOS	0020035301	107002101004047787

		Select top 1 * from KPYMCRECARFIA 
		Select * from GENTMONEDA
		Select * from SIPTCARGOPER C

		Select P.cCodPerson, P.cNomPerson, P.cCodGruPer
			,C.cCodGruPer, C.cDesCarPer  
		from Sipmpersonal P 
			inner join SIPTCARGOPER C
				on C.cCodGruPer = P.cCodGruPer 
		where P.cCodPerson = 'YROJAS'
			--P.cNomPerson like '%peña%garcia%guiller%'	
		----------------------------------------------------------------
		
		Select *
		from kpydComaprCre A
		Where cCodPerson != cCodUsuReg


		Select top 5 * 
		FROM KPYMCRECARFIA FIA (NOLOCK)
			inner JOIN GENMCRECLI GEN (NOLOCK) 
				ON (FIA.CCODCTACRE = GEN.CCODCTACRE)	
			inner join KPYDGARLINCRE GARLIN (NOLOCK) 
				on GARLIN.cCodLinCre = GEN.cCodLinCre
			inner JOIN GENDGARANTIA TIPGAR (NOLOCK)
				ON TIPGAR.CCODgarant = GARLIN.CCODTIPGAR and TIPGAR.lconestado = 1

		Select * from KPYDGARLINCRE
		Where ccodCliente = '107011772232'
	

		Select * from GENDGARANTIA
		where cdestipgar like '%plazo%'
			and lconestado = '1'

		-- RPDPF 	GM SOBRE DEPOSITO A PLAZO FIJO
		*/