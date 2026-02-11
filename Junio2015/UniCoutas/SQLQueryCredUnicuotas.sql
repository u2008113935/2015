	Select * from CredUnicuotas
	Where NombreCliente = 'TICLLACURI RAMOS, SANTOS'


	Select C.*,
			A.cCodCliente, A.cNomCliente,B.cCodCtaCre
	From [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES]  A	
			inner join 	[HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.[GENMCreCli] B
				on B.cCodCliente = A.cCodCliente
			INNER JOIN CredUnicuotas C
				ON C.Codcredito COLLATE SQL_Latin1_General_CP1_CI_AS = B.cCodCtaCre
	Where A.cNomCliente COLLATE SQL_Latin1_General_CP1_CI_AS	
			in (select NombreCliente from CredUnicuotas)
	ORDER BY A.cCodCliente


	--	select top 2 * from [HYO00402].SOFCMACHYO_DIARIO_MEDIODIA.dbo.[GENMCreCli]
