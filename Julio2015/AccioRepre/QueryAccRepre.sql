	Select top 5 * from CMACHYOCLI_MANIANA.DBO.CLIMClienteS CLITIT (NOLOCK) 	

	select top 5 * from CMACHYOCLI_MANIANA.DBO.cliamclientes

	select top 5 * from CMACHYOCLI_MANIANA.DBO.cliamperjur

	select top 5 * from CMACHYOCLI_MANIANA.DBO.clidactrepjur

		select  * from CMACHYOCLI_MANIANA.DBO.clidactrepjur
		where cCodCliente='107013772476'--'107019733516'

		select cCodCliente, count(cDocIdeRep)
		from CMACHYOCLI_MANIANA.DBO.clidactrepjur
		group by cCodCliente
		order by cCodCliente

	select top 5 * from CMACHYOCLI_MANIANA.DBO.clidactaccjur
		select * from CMACHYOCLI_MANIANA.DBO.clidactaccjur
		where cCodCliente = '107013772476'

		select cCodCliente, count(cDocIdeAcc)
		from CMACHYOCLI_MANIANA.DBO.clidactaccjur
		group by cCodCliente
		order by cCodCliente

	select top 5 * from CMACHYOCLI_MANIANA.DBO.clidactdirjur
		select * from CMACHYOCLI_MANIANA.DBO.clidactdirjur
		where cCodCliente = '107013772476'

		select cCodCliente, count(cDocIdeDir)
		from CMACHYOCLI_MANIANA.DBO.clidactdirjur
		group by cCodCliente
		order by cCodCliente

	select top 5 * from CMACHYOCLI_MANIANA.DBO.CLIDRepresCli
		select * from CMACHYOCLI_MANIANA.DBO.CLIDRepresCli
		where cCodCliente = '107019733516'--'107013772476'

		select cCodCliente, count(cCodCliRep)
		from CMACHYOCLI_MANIANA.DBO.CLIDRepresCli
		group by cCodCliente
		order by cCodCliente

	Select top 5 * from CMACHYOCLI_MANIANA.DBO.ClimClientes


	
	