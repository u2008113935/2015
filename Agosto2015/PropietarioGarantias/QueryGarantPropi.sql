

		SELECT distinct cCodCliente
		--,*
		FROM CMACHYOCLI_MANIANA..CLIMGarCliente
		WHERE cDirDomGar like '%Av%Ferrocarril%1790%'

		SELECT A.cCodCliente,C.cNomCliente
			,A.cCodGarCli,A.cCodTipGar,A.cDirDomGar  
		FROM CMACHYOCLI_MANIANA..CLIMGarCliente A
			INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
				ON C.cCodCliente = A.cCodCliente
		Where A.cCodCliente in ('107010348533',
								'107010401472',
								'107010470642',
								'107010845413',
								'107013097551',
								'107013097575',
								'107014110929')
		--,*
		
		-- and cDirDomGar like '%Av%Ferrocarril%1790%'
			/*
			cCodCliente  = '107019678163'
			AND cCodGarCli = '001'
			*/
		
		SELECT *
		FROM CMACHYOCLI_MANIANA..CliMGarFisHipCli
		WHERE cCodCliente  = '107011247503'
			AND cCodGarCli = '001'


		--=======================================
		-- GARANTIAS TITULO VALOR 
		--=======================================
		SELECT *
		FROM CMACHYOCLI_MANIANA..CliMGarTitValCli
		WHERE cCodCliente  = '107010317660'
			AND cCodGarCli = '001'