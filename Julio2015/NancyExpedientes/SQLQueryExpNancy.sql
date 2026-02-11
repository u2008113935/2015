		--01
		select * from ExpeNanV01

		--02 llenado el codigo de cliente y cod credito
		select * into #t01 from (
			Select cCodCtaCre,cCodCliente
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] 
			where cCodCtaCre COLLATE SQL_Latin1_General_CP1_CI_AS	
					in  (select Credito from ExpeNanV01 )
			--order by cCodCtaCre
			) as tmp

			select * from #t01
			select len(cCodCliente) from #t01

		--03 Llenar Codigo de Cliente en ExpeNanV01-
		/*
		SELECT TOP 5 * 
		FROM [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
		WHERE E.CTIPEXPCLI='K' AND E.lconEstado = 1
		*/										

		----------Llenar Codigo de Cliente en ExpeNanV01------------------------------
		Declare @codcred char(18), @codcli char(12)
		
			Declare cExp CURSOR FOR	
				select credito from ExpeNanV01 (NOLOCK) 	

			OPEN cExp
				FETCH cExp into @codcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				set @codcli = ( SELECT cCodCliente
								FROM #t01 (NOLOCK)
								WHERE cCodCtaCre = @codcred )
			
				UPDATE ExpeNanV01
				SET CodigoCliente = @codcli
				WHERE Credito = @codcred	

				FETCH cExp INTO @codcred
				END
				CLOSE cExp
				DEALLOCATE cExp
		---------------------------------------------------------------

			Select * from ExpeNanV01 (NOLOCK) 

		--04 llenando el codigo expediente en ExpeNanV01

		SELECT TOP 5 len(cCodExpCli),* 
		FROM [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
		WHERE E.CTIPEXPCLI='K' AND E.lconEstado = 1

		 
		----------Codigo Expediente en ExpeNanV01-----------------------------
		Declare @codclie char(12), @codexp char(9)
		
			Declare cExp01 CURSOR FOR	
				select CodigoCliente from ExpeNanV01 (NOLOCK) 	

			OPEN cExp01
				FETCH cExp01 into @codclie
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				set @codexp = 
					(SELECT cCodExpCli
					FROM [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
					WHERE E.CTIPEXPCLI='K' AND E.lconEstado = 1 
						and cCodClient = @codclie)
			
				UPDATE ExpeNanV01
				SET  CodigoExpediente = @codexp
				WHERE CodigoCliente = @codclie	

				FETCH cExp01 INTO @codclie
				END
				CLOSE cExp01
				DEALLOCATE cExp01
		----------------------------------------------------------------- 

			Select * from ExpeNanV01
		