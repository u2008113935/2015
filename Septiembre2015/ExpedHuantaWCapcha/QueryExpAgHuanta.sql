		--01

		Select * from ExpHuanta
		where Cliente = 'TAMBRACC SALINAS, ALFREDO'
		
		--02 llenado el codigo de cliente y cod credito
		/*
		
		Select top 5 *
		FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] 

		Select top 5 *
		FROM [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 

		*/
		-- Drop table #t00
		select * into #t00 from (
			Select cCodCliente,cNomCliente
			FROM [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES]  
			where cNomCliente COLLATE SQL_Latin1_General_CP1_CI_AS	
					in  (select rtrim(Cliente) from ExpHuanta )
			--order by cCodCliente
			) as tmp
		
			/*
			Select * from ExpHuanta
			Select * from #t00

			Select A.Cliente, B.cCodCliente, B.cNomCliente from ExpHuanta A
				inner join #t00 B
					on B.cNomCliente COLLATE SQL_Latin1_General_CP1_CI_AS	 
					= A.Cliente

			Cliente						cCodCliente		cNomCliente
			TAMBRACC SALINAS, ALFREDO	107010395237	TAMBRACC SALINAS, ALFREDO
			TAMBRACC SALINAS, ALFREDO	107020856729	TAMBRACC SALINAS, ALFREDO

			Select *
			FROM [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C
			Where cCodCliente in ('107010395237','107020856729')  

			Select * from HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC
			Where cCodCliente in ('107010395237','107020856729')

			Select * from HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.[GenTDepartame]
			Where cCodDepart in ('05','12')

			Select * from #t00 where cCodCliente = '107010395237'
			
			Delete #t00
			where cCodCliente = '107010395237'
			*/
			-- drop table #tab00
			Select * into #tab00 from (
				Select A.*, B.cCodCliente--, B.cNomCliente 
				From ExpHuanta A
					inner join #t00 B
						on B.cNomCliente COLLATE SQL_Latin1_General_CP1_CI_AS	 
						= A.Cliente
				) as tmp

		/*
		Select * from #tab00

		Select top 5 *
		FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] 

		Select top 5 *
		FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMcreconven] A

		Select * from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas]
		where cDesOficin like '%huanta%'

		SELECT cCodExpCli, E.*
		FROM [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
		WHERE E.CTIPEXPCLI='K' AND E.lconEstado = 1 
			and cCodClient = @codclie
		*/

		-- Drop table #t01
		select * into #t01 from (
			Select A.cCodCtaCre,B.cCodCliente
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMcreconven] A
				inner join [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] B
					on A.cCodCtaCre = B.cCodCtaCre
			where cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS	
							in  (select cCodCliente from #tab00 )
					and A.cCodOficin = '061'
					and A.cEstCreCon in ('F','H')					
			--order by cCodCtaCre
			) as tmp
		
			-- Select * from #t01
			-- drop table #tab011
		Select * into #tab011 from (
			Select A.*, B.cCodCtaCre --, B.cNomCliente 
			From #tab00 A
				inner join #t01 B
					on B.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS	 
					= A.cCodCliente
			) as tmp


			Select A.*,E.cCodExpCli 
			from #tab011 A
				inner join [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
					on E.cCodClient = A.cCodCliente
			Where E.CTIPEXPCLI='K' AND E.lconEstado = 1 
			Order By A.Nro

