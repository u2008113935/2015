---------------------------------RCC-----------------------------------------------------
	select top 5 * from CRICMACHYO_DIARIO.DBO.urirccmae --CCLAFIN
	select top 5 * from CRICMACHYO_DIARIO.DBO.urirccsal --CCALEMP
	select top 5 * from CRICMACHYO_DIARIO.DBO.urirccmifi

-----------------------------------------------------------------------------------------

	Select * from CRICMACHYO_DIARIO.DBO.urirccsal
	Where left(CCTACON,4) 
				in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
			and cCodSBS = '0009556940'								
			

	Select Count(CCODEMP)
	from CRICMACHYO_DIARIO.DBO.urirccsal
	Where left(CCTACON,4) 
			in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
		and cCodSBS = '0009556940'			


	SELECT * FROM CRICMACHYO_DIARIO.DBO.URIRCCMIFI
	WHERE cCodIFI IN ('00072','00006','00072','00004')

	