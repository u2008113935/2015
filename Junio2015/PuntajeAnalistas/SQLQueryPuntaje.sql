		/*
		select *
		from  kpyhsalcarana
		where dfecproces between '2015.04.30' and '2015.05.31'
		and lestadosal=1
		and ccodusuana='aapoli'

		select *
		from  kpyhsalcarana
		where dfecproces in('2015.04.30','2015.05.15','2015.05.31')
		and lestadosal=1
		and ccodusuana='aapoli'


		select *
		from  kpymmetanacre
		where ccodperiodo='2015/05'
		and ccodusuana='aapoli'

		select *
		from KPYHSalCarIni
		where ccodperiod='2015/05'
		and ccodusuana='aapoli'

		--ponderacion
		select *
		from  SIPDIncAsiPon
		where cCodPeriodo='2015/04'
		and cCodPerson='aapoli'

		---analisis ini fin res
		select *
		from SIPDIncAlcMen
		where cCodPeriodo='2015/04'
		and cCodPerson='aapoli'

		--nota final
		select *
		from SIPDIncPunAlc
		where cCodPeriodo='2015/04'
		and cCodPerson='aapoli'

		--pago de incentivos
		select *
		from SIPDIncCreCal
		where cCodPeriodo='2015/04'
		--and cCodPerson='aapoli'
		and cCodOficin='009'
		/*
		nMonIncVar
		1398.36
		+
		nMonIncFij
		525.00
		=
		nMonIncTot
		1888.40*/

		---nivel de colaboradores
		select *
		from SIPTClaSubNiv
		where nCodPAPApr=8
		and  cCodNivel='03'			
		--cCodNivAna = 03E
		*/


		
	--pago de incentivos
	Select 
		 A.cCodPerson, SP.cNomPerson AS 'NombreAsesor'--, N.cDesClaSub
		,Ponderacion = P.cCodTipPon, N.cDesClaSub
		,A.cCodPeriodo --, A.nIncentVar, A.nIncentFij
		,A.nPunCreNue, A.nPunSalCar, A.nPunVenJud
		,A.nPunVen830, A.nPunNumCli
		--,A.nPunSalCarPlus, A.nPunVen830Plus, A.nPunVenJudPlus,A.nPunCreNuePlus, A.nPunNumCliPlus
		--,A.nNotaFinalPlus --, A.nPorPenCas, A.nPorPenDef
		,A.nPunTotMor --A.nPunConoci
		,A.nNotaFinal --, A.nMonIncVar
		--,A.nFacMinInc, A.nMonIncFij
		,A.nMonIncTot
		--,A.nNotFinAcu, A.nFacPartic
		,A.cCodEstado		
		,A.cCodOficin, O.cDesOficin
		,ZON.nCodZona, ZON.cDesZona
		--,A.dFecRegist--, A.cCodUsuReg, A.dFecUltMod, A.cCodUsuMod, A.nMonDistri		
		--,A.nPorPenCli, A.nPorPenDes	, A.nRenCarter, A.nMonSalTot, A.nMonIngGen, A.nMonProvCre
	From [SIPDIncCreCal] A					
		INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = A.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = A.cCodPerson 
			
			LEFT JOIN [SIPDIncAsiPon] P 
				ON P.cCodPerson = A.cCodPerson	AND P.cCodPeriodo = '2015/05'
					AND P.cCodSituac = 'A'								
			--/*
			LEFT join [SIPTClaSubNiv] N
				ON	N.cCodNivel = P.cCodNivel AND N.cCodSubNiv = P.cCodSubNiv 
					AND N.cCodClaSub = P.cCodClaSub AND N.lConEstado = 1 
					AND N.nCodPAPApr=8
			--*/
	Where A.cCodPeriodo='2015/05'
		and ZON.nCodZona = '4'		
	Order by -- A.cCodPerson , --
			A.cCodOficin
		--and cCodPerson='aapoli'
		--and cCodOficin='009'
