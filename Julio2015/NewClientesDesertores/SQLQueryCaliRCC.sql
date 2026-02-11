		/*
		-----------------------------CURSOR---------------------------------------
				Declare @ccodsbs varchar(12), @cant int
				Declare cClienteIfi CURSOR FOR					
					SELECT COD_SBS1 
					FROM #CREMICROCANC01 (NOLOCK) 
					WHERE COD_SBS1 NOT IN ('0000000001','0000000002')	
						--and cCodOficin = '001'
												
				OPEN cClienteIfi
				FETCH cClienteIfi into @ccodsbs
				WHILE (@@FETCH_STATUS=0)
				BEGIN					
					set @cant =	(	
							SELECT COUNT (DISTINCT B.CCODEMP)							
							FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B  (NOLOCK)			
							WHERE B.CCODSBS = @ccodsbs and B.CCALEMP = '0'
									and LEFT(B.Cctacon, 4) in 
								('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')	
							    )
								
						IF  @cant < = 3 
								
							BEGIN 
							INSERT INTO #CREMICROIFIS		 					
									SELECT 	* FROM #CREMICROCANC01  (NOLOCK) 		
									WHERE COD_SBS1 = @ccodsbs 
									--AND  COD_SBS1 IS not NULL								
							
							Update #CREMICROIFIS
							Set cEntFin = @cant
							WHERE COD_SBS1 = @ccodsbs 	--AND  COD_SBS1 IS not NULL	
							 				
							END	 					

				FETCH cClienteIfi INTO @ccodsbs
				END
				CLOSE cClienteIfi
				DEALLOCATE cClienteIfi				
			*/
	----------------------------------------------------------------------------
		
		---------------CANTIDAD DE ENTIDADES------------------------------------
		/*
		SELECT B.CCODSBS,B.CCODEMP,B.Cctacon,B.CCALEMP 
		FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B  (NOLOCK)			
		WHERE B.CCALEMP = '0' and LEFT(B.Cctacon, 4) in 
					('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')	
			  and B.CCODSBS in 
		(		
		
		)
		*/
		--------------------------------------------------------------------------
		/*
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808]		--CMESPRO 20150531
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808_ABR15]  --CMESPRO 20150430
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808_MAR15]	--CMESPRO 20150331
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808_FEB15]	--CMESPRO 20150228
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808_ENE15]	--CMESPRO 20150131
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808_DIC14]	--CMESPRO 20141231
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808_NOV14]	--CMESPRO 20141130
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808_OCT14]	--CMESPRO 20141031
		select top 1 * from HYO00410.URIESGOS.dbo.[urirccmae808_SET14]	--CMESPRO 20140930

		select top 5 * from HYO00410.URIESGOS.dbo.[URIRCCSAL808]
		*/
		------------------CALIFICACION SBS-----------------------------------------
		Select 
			A.CCODSBS,A.CMESPRO,A.CCLAFIN
			,B.CCODSBS,B.CMESPRO,B.CCLAFIN 
			,C.CCODSBS,C.CMESPRO,C.CCLAFIN 
			,D.CCODSBS,D.CMESPRO,D.CCLAFIN 
			,E.CCODSBS,E.CMESPRO,E.CCLAFIN 
			,F.CCODSBS,F.CMESPRO,F.CCLAFIN 
			,G.CCODSBS,G.CMESPRO,G.CCLAFIN 
			,H.CCODSBS,H.CMESPRO,H.CCLAFIN 
			,I.CCODSBS,I.CMESPRO,I.CCLAFIN 
		From HYO00410.URIESGOS.dbo.[urirccmae808] A
			INNER JOIN HYO00410.URIESGOS.dbo.[urirccmae808_ABR15] B
				ON A.CCODSBS = B.CCODSBS		
			INNER JOIN HYO00410.URIESGOS.dbo.[urirccmae808_MAR15] C
				ON A.CCODSBS = C.CCODSBS
			INNER JOIN HYO00410.URIESGOS.dbo.[urirccmae808_FEB15] D
				ON A.CCODSBS = D.CCODSBS
			INNER JOIN HYO00410.URIESGOS.dbo.[urirccmae808_ENE15] E
				ON A.CCODSBS = E.CCODSBS
			INNER JOIN HYO00410.URIESGOS.dbo.[urirccmae808_DIC14] F
				ON A.CCODSBS = F.CCODSBS
			INNER JOIN HYO00410.URIESGOS.dbo.[urirccmae808_NOV14] G
				ON A.CCODSBS = G.CCODSBS
			INNER JOIN HYO00410.URIESGOS.dbo.[urirccmae808_OCT14] H
				ON A.CCODSBS = H.CCODSBS
			INNER JOIN HYO00410.URIESGOS.dbo.[urirccmae808_SET14] I
				ON A.CCODSBS = I.CCODSBS
		WHERE A.CCODSBS IN
		(
		
		)


