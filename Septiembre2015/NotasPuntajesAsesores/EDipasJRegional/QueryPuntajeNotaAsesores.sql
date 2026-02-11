	/*
	Buen día, sirva la presente para solicitar las notas obtenidas de los responsables 
	o lideres de comités
	según relación adjunta al presente.
	Las notas son desde el mes de enero al cierre de Junio. 06 meses en total. 
	A la espera de su pronta atención. dado que es necesario contar ello a
	fin de responder un memo de la GM.
	*/

	-------------------------------------------------------
	/*
		--	pago de incentivos
	Select * From [SIPDIncCreCal] -- Detalle de Incentivo de crédito calculado de analistas
	Where cCodPeriodo >= '2015/01' 
		and cCodPerson in ('OCARDE','JTICSE','GQUISP','FTAIPE','LPOMAH','JDIAZF','EHUARC','OHUAMA','RLOPEP','APEREZ'
	,'LALBOR','SPORTA','MSICHA','AAVILA','NMEZAP','TTORRE','NCASTR','ISACHA','KANGUL','LMALLQ','SARAUJ','PHERRE'
	,'CBALBI','APOMAR','RTORRE','LRONCA','SSAUÑE','LHUAMA','PVEGAP','JCORDE','OTORRE','RPUCLL','WCISNE','AYUPAN'
	,'BGRANA')
	order by cCodPerson


	Select *
	From SIPDIncAsiPon -- Detalle de asignación de ponderaciones para incentivo de créditos
	where cCodPeriodo >= '2015/01' 
		and cCodPerson in ('OCARDE','JTICSE','GQUISP','FTAIPE','LPOMAH','JDIAZF','EHUARC','OHUAMA','RLOPEP','APEREZ'
	,'LALBOR','SPORTA','MSICHA','AAVILA','NMEZAP','TTORRE','NCASTR','ISACHA','KANGUL','LMALLQ','SARAUJ','PHERRE'
	,'CBALBI','APOMAR','RTORRE','LRONCA','SSAUÑE','LHUAMA','PVEGAP','JCORDE','OTORRE','RPUCLL','WCISNE','AYUPAN'
	,'BGRANA')

		select *
		from  kpyhsalcarana		-- Tabla historica de saldos de creditos por analista comité y oficina
		where dfecproces between '2015.04.30' and '2015.05.31'
			and lestadosal=1
			and ccodusuana='aapoli'


		select *
		from  kpymmetanacre		-- Maestro de metas mensuales por analista
		where ccodperiodo='2015/05'
		and ccodusuana='aapoli'

		select *
		from KPYHSalCarIni		-- Tabla Historica de Saldos Iniciales de Creditos para el Calculo de Incentivos
		where ccodperiod='2015/05'
		and ccodusuana='aapoli'

		--ponderacion
		select *
		from  SIPDIncAsiPon		--Detalle de asignación de ponderaciones para incentivo de créditos
		where cCodPeriodo='2015/04'
		and cCodPerson='aapoli'

		---analisis ini fin res
		select *
		from SIPDIncAlcMen		-- Detalle de alcance mensual de metas para incentivos de créditos
		where cCodPeriodo='2015/04'
		and cCodPerson='aapoli'

		--nota final
		Select *
		From SIPDIncPunAlc		-- Puntaje alcanzado
		Where cCodPeriodo >='2015/01'
				and cCodPerson in ('OCARDE','JTICSE','GQUISP','FTAIPE','LPOMAH','JDIAZF','EHUARC','OHUAMA','RLOPEP','APEREZ'
		,'LALBOR','SPORTA','MSICHA','AAVILA','NMEZAP','TTORRE','NCASTR','ISACHA','KANGUL','LMALLQ','SARAUJ','PHERRE'
		,'CBALBI','APOMAR','RTORRE','LRONCA','SSAUÑE','LHUAMA','PVEGAP','JCORDE','OTORRE','RPUCLL','WCISNE','AYUPAN'
		,'BGRANA')
		order by cNomPerson -- cCodPerson,cCodPeriodo	
	
		--- Nivel de Colaboradores
		Select *
		From SIPTClaSubNiv
		Where nCodPAPApr=8
			and  cCodNivel='03'			
		--cCodNivAna = 03E
			
	*/
	-------------------------------------------------------
	--pago de incentivos
	Select 
		 B.cCodPeriodo,B.cNomPerson, B.cCodPerson --,SP.cNomPerson AS 'NombreAsesor'--, N.cDesClaSub
		,Ponderacion = P.cCodTipPon, N.cDesClaSub
		--, A.nIncentVar, A.nIncentFij
		
		--,A.nPunCreNue
			,B.nPunCreNue
		--,A.nPunSalCar
			,B.nPunSalCar
		--,A.nPunVenJud
			,B.nPunVenJud
		--,A.nPunVen830
			,B.nPunVen830
		--,A.nPunNumCli
			,B.nPunNumCli
		--,A.nPunSalCarPlus, A.nPunVen830Plus, A.nPunVenJudPlus,A.nPunCreNuePlus, A.nPunNumCliPlus
		--,A.nNotaFinalPlus --, A.nPorPenCas, A.nPorPenDef
		--,A.nPunTotMor
			,B.nPunTotMor --A.nPunConoci
		--,A.nNotaFinal
			,B.nNotaFinal --, A.nMonIncVar
		--,A.nFacMinInc, A.nMonIncFij
		--,A.nMonIncTot, 
		--,A.nNotFinAcu, A.nFacPartic
		--,A.cCodEstado		
		--,A.cCodOficin
		,O.cDesOficin
		--,ZON.nCodZona
		,ZON.cDesZona
		--,A.dFecRegist--, A.cCodUsuReg, A.dFecUltMod, A.cCodUsuMod, A.nMonDistri		
		--,A.nPorPenCli, A.nPorPenDes	, A.nRenCarter, A.nMonSalTot, A.nMonIngGen, A.nMonProvCre
	From SIPDIncPunAlc B
		--INNER join [SIPDIncCreCal] A					
			--on A.cCodPerson = B.cCodPerson
		INNER JOIN [GENTOficinas] O 
			ON O.cCodOficin = B.cCodOficin and O.lConEstado = '1'			
		INNER JOIN [Gentofizonas] GOZ		
			ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
		INNER JOIN [GentZonas] ZON
			ON ZON.nCodZona = GOZ.nCodZona	
		left JOIN [sipmpersonal] SP 
			ON SP.cCodPerson = B.cCodPerson 			
		
		LEFT JOIN [SIPDIncAsiPon] P 
			ON P.cCodPerson = B.cCodPerson	AND P.cCodPeriodo = '2015/01'
				AND P.cCodSituac = 'A'								
		
		--/*
		LEFT join [SIPTClaSubNiv] N
			ON	N.cCodNivel = P.cCodNivel AND N.cCodSubNiv = P.cCodSubNiv 
				AND N.cCodClaSub = P.cCodClaSub AND N.lConEstado = 1 
				AND N.nCodPAPApr=8
			--*/
	Where B.cCodPerson in ('OCARDE','JTICSE','GQUISP','FTAIPE','LPOMAH','JDIAZF'
	,'EHUARC','OHUAMA','RLOPEP','APEREZ'
	,'LALBOR','SPORTA','MSICHA','AAVILA','NMEZAP','TTORRE','NCASTR'
	,'ISACHA','KANGUL','LMALLQ','SARAUJ','PHERRE'
	,'CBALBI','APOMAR','RTORRE','LRONCA','SSAUÑE','LHUAMA','PVEGAP'
	,'JCORDE','OTORRE','RPUCLL','WCISNE','AYUPAN'
	,'BGRANA')
		and B.cCodPeriodo >='2015/01'  
		--and A.cCodPeriodo >='2015/01'
	Order by B.cNomPerson, B.cCodPeriodo
                                                                                    
			--A.cCodOficin
		--and cCodPerson='aapoli'
		--and cCodOficin='009'
		
		
		/*
		Select * from [sipmpersonal] SP where cNomPerson like '%GRANADOS%PORRAS%'

		TICSE/RODRIGUEZ,JHONATHAN WILLIAMS - JTICSE                                                                   
		CARDENAS/GUTIERREZ DE LEYTTH,JOHANA - OCARDE                                                                                      
		QUISPE/MENDOZA,ANGEL - GQUISP                                                                                                     
		TAIPE/BOZA,FREDY - FTAIPE                                                                                                         
		POMA/HUAYLINOS,LUIS ANTENOR - LPOMAH                                                                                              
		DIAZ/FERNANDEZ,JESUS PONCE - JDIAZF                                                                                               
		HUARCAYA/CCENTE,EDWIN EDGAR - EHUARC                                                                                              
		HUAMAN/ACUÑA,CARLOS COSTER - OHUAMA                                                                                               
		LOPEZ/PAULINO,RUBEN DARIO - RLOPEP                                                                                                
		PEREZ/ROMAN,ALICIA - APEREZ                                                                                                       
		ALBORNOZ/FLORES,LUIS MIGUEL - LALBOR                                                                                             
		PORTA/ZAMUDIO,SERGIO ROBERT - SPORTA                                                                                             
		SICHA/QUISPE,MARISA - MSICHA                                                                                                     
		AVILA/AVELLANEDA,ALKENDY JONATHAN - AAVILA                                                                                       
		MEZA/PEREZ,NOEL ANTONIO - NMEZAP                                                                                                  
		TORRES/HUAYCUCH,HENRI NILTON - TTORRE                                                                                            
		CASTRO/ZEVALLOS,NELLY - NCASTR                                                                                                   
		ISAIAS SACHA CHAHUAYO - ISACHA
		KETTY ANGULO CRUZATT - KANGUL
		EFRAIN LUIS MALLQUI ALFONZO - LMALLQ
		SAMUEL HERNAN  ARAUJO CARDENAS - SARAUJ
		PAOLA HERRERA REAÑO - PHERRE
		CARLOTA BALBIN SALAS - CBALBI
		ANA POMA ROMANI - APOMAR
		JORGE LUIS TORRES DONAIRES - RTORRE
		LAURA JESSICA RONCAL GUZMAN - LRONCA
		SAUL SAUÑE LAZARO - SSAUÑE
		ALFREDO HUAMAN CUNYA -LHUAMA 
		PAVEL VEGA PACHECO - PVEGAP
		JHOBER CORDERO ZAMORA - JCORDE
		JOSE TORRES CAMARENA - OTORRE
		RAUL PUCLLAS BOLIVIA - RPUCLL
		CISNEROS/LLOCCLLA,WILBER - WCISNE                                                                                                
		JACOB YUPANQUI QUISPE - AYUPAN
		BEEL GRANADOS PORRAS - BGRANA
		*/
