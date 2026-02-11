	Select --top 10 
	* 
	from [HYO00402].CMACHYOCLI_MANIANA.dbo.ClimDirecc
	where cCodCliente='107012504683' and bDirPredet = 1


	Select top 1 
	*
	from CMACHYOCLI_MANIANA..CLIMPERNAT

	SELECT TOP 5 *
	FROM  [HYO00402].CMACHYOCLI_TARDE.DBO.CLIDFUEINGRESO
	WHERE cCodTipFin = 'I'
			

	SELECT *
	FROM [HYO00402].CMACHYOCLI_TARDE.DBO.CLIDFUEINGRESO
	WHERE cCodCliente = '107010000130' --'107010000050' 

	
	SELECT *
	FROM [HYO00402].CMACHYOCLI_TARDE.DBO.CLIDFUEINGRESO
	WHERE cCodCliente = '107010000191'


	SELECT cCodTipFin
	FROM [HYO00402].CMACHYOCLI_TARDE.DBO.CLIDFUEINGRESO
	Group By cCodTipFin


	Select * from ResumenClientesFin

	-------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------
	Select 
		--A.*
		,C.cCodCliente, C.cCodSbs
		,DirecDomic=B.cDirCliente
		,DE.cNomDepart, PR.cNomProvin,DI.cNomDistri
		,B.cCodDepart, B.cCodProvin, B.cCodDistri
		,DirecNegocio =D.cDirEmp 
		,DE1.cNomDepart,PR1.cNomProvin,DI1.cNomDistri
		,D.cCodDepart, D.cCodProvin, D.cCodDistri
	FROM [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C  
	--from ResumenClientesFin A
		--INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C  
			--ON C.cCodSbs COLLATE SQL_Latin1_General_CP1_CI_AS  = A.cCodSbs
		inner join [HYO00402].CMACHYOCLI_MANIANA.dbo.ClimDirecc B
			on B.cCodCliente = C.cCodCliente
		INNER JOIN [HYO00402].CMACHYOCLI_TARDE.dbo.CLIDFUEINGRESO D
			ON D.cCodCliente = C.cCodCliente
		
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTDepartame DE
			ON DE.cCodDepart = B.cCodDepart
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTDepartame DE1
			ON DE1.cCodDepart = D.cCodDepart
		
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTProvincia PR
			ON PR.cCodProvin = B.cCodProvin and PR.cCodDepart = B.cCodDepart
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTProvincia PR1
			ON PR1.cCodProvin = D.cCodProvin and PR1.cCodDepart = D.cCodDepart

		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTDistrito DI
			ON DI.cCodDistri = B.cCodDistri AND DI.cCodDepart=B.cCodDepart	
				AND DI.cCodProvin=B.cCodProvin 
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTDistrito DI1
			ON DI1.cCodDistri = D.cCodDistri AND DI1.cCodDepart=D.cCodDepart	
				AND DI1.cCodProvin=D.cCodProvin 
			
	WHERE B.bDirPredet = 1 AND D.cCodTipFin = 'I'
	Order by A.N  
	-------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------

	SELECT * FROM [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTDepartame
	SELECT * FROM [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTProvincia
	SELECT * FROM [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.GENTDistrito
	