		/*	
		SELECT 
			A.CCODSBS,A.CCODEMP,A.NSALDOS,A.CCALEMP,B.ccodempsisfin , B.cNomEmpSisFin 
		FROM [URIRCCSAL808] A
				INNER JOIN [GENCODSBSEMPSISFIN] B
					ON B.ccodempsisfin = A.CCODEMP
		WHERE left(A.CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
				AND A.CCODSBS IN (''
			)


		Select top 1 * FROM [URIRCCMAE808] A where CCODSBS = '0094301858'
		*/

	Select 
		B.*
		,E.cCodCreSbs, E.cDesTipCre
		--,STUFF(LEFT(CCTACON,6),3,1,'0')			
	FROM [URIRCCSAL808] B 
		INNER JOIN [URITTIPCREDIT] E
			ON E.cCodCreSbs = B.CTIPCRE
	WHERE left(B.CCTACON,4) 
			in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
		  AND B.CCODSBS IN (
			
			  )		

ORDER BY B.CCODSBS			  	  
		
		/*
		Select top 1 * FROM [URIRCCSAL808] B 
		Select top 1 * from [GENCODSBSEMPSISFIN] C

		Select * from [URITTIPCREDIT] E
		*/


