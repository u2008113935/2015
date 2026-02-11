
	Select * From urirccmae --CMESPRO 20150531
	--WHERE CAPEPAT LIKE '%VALLE' AND CAPEMAT LIKE 'SANTOS%' AND CPRINOM LIKE 'J%'
	--WHERE CAPEPAT LIKE 'pe%a' AND CAPEMAT LIKE 'garcia' AND CPRINOM LIKE 'ivan%' --43987888    
	WHERE CAPEPAT LIKE 'aguirre' AND CAPEMAT LIKE 'colonio' AND CPRINOM LIKE 'eliza%' --    

	
	Select --top 1 * 
		*
	From URIRCCSAL B--
	Where LEFT(B.Cctacon, 4) in ('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')
		and B.CCODEMP != '00107'	

	Select -- top 1 
	* 
	From URIRCCMIFI WHERE lConEstado = 1 and cNomIFI like '%caja%huancayo%'
      
	------------------------------------------------------------------------------------------------
	
	
	Select top 5000000 
		A.*, B.*
	From urirccmae A
		inner join URIRCCSAL B--
			on A.CCODSBS = B.CCODSBS
	Where LEFT(B.Cctacon, 4) in ('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')
		and B.CCODEMP = '00107' and CTIPPER = '2' and CTIPCRE in ('08','09','10')
	Order by A.CCODSBS
	                                                                                                                                                                                       
