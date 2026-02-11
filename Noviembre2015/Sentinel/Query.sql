
	Select * 
	From CRICMACHYO_DIARIO.dbo.URIRCCMAE    -- set 2015	
	Where   CAPEPAT like '%mercado%'	
		and CAPEMAT	like '%curi%'	
		--and CAPECAS like '%%'	
		and CPRINOM like '%margari%'	
		and CSEGNOM like '%%'	

	
	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCSAL 