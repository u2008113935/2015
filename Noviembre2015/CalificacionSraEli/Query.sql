
	
	Select * into #tab01 from (	
		Select A.* , B.cCodSBS
		From RCC_CONSULTING A
			INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] B 
				ON B.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS = A.CLIENTE
	) as tmp

	Select * from #tab01
	Select * from RCC_URIESGOS

	drop table #tab01
	
	Select A.* , 
		CalificacionRCC =
		Case CCLAFIN
		when '0' then 'NORMAL'
		when '1' then 'CPP'
		when '2' then 'DEFICIENTE'
		when '3' then 'DUDOSO'
		when '4' then 'PERDIDA'
		ELSE 'NO REGISTRA' END
		,FechaRCC = CMESPRO
	From #tab01 A
		left join RCC_URIESGOS B
			on A.cCodSBS COLLATE SQL_Latin1_General_CP1_CI_AS  = B.CCODSBS
	oRDER bY CLIENTE






	