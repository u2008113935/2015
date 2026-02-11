
	Select * from RepNancy

	Select Credito, count(Credito) from RepNancy
	Group by Credito
	Having count(Credito) > 1

		
		/*
			Select * from #t00
			Select * from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas] O
			Where cDesOficin like '%barranca%'
		*/

		-- Drop table #t01
		select * into #t01 from (
			Select A.cCodCtaCre,B.cCodCliente, E.cCodExpCli 
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMcreconven] A
				inner join [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] B
					on A.cCodCtaCre = B.cCodCtaCre			
				left join [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
					on E.cCodClient = B.cCodCliente
			where A.cCodCtaCre COLLATE SQL_Latin1_General_CP1_CI_AS	
							in  (select Credito from RepNancy )
				and E.CTIPEXPCLI='K' AND E.lconEstado = 1 				
			--order by cCodCtaCre
			) as tmp
		
			-- Select * from #t01
			-- drop table #tab011
			Select A.*, B.cCodCliente, B.cCodExpCli
			From RepNancy A
				left join #t01 B
					on B.cCodCtaCre COLLATE SQL_Latin1_General_CP1_CI_AS	 
					= A.Credito
			Order By Nro
